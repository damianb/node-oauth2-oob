async = require 'async'
utils = require './utils'
Application = require './application'

tokenBytes = 64
authCodeBytes = 20

class Server
	constructor: (@storage, options) ->
		{ @tokenDuration, @authCodeDuration } = options
		@tokenDuration = (1000 * 60 * 60 * 24) if !@tokenDuration # 24 hours
		@authCodeDuration = (1000 * 60 * 5) if !@authCodeDuration # 5 minutes

	newApp: (options, fn) ->
		if arguments.length is 2
			fn null, new Application @, options
		else
			return new Application @, options

	dropApp: (app, fn) ->
		if !(app instanceof Application)
			throw new Error 'OAuth2-OOB.Server.dropApp expects an OAuth2-OOB.Application instance as a parameter, none provided'

		async.parallel [
			(cb) ->
				app.drop cb
			(cb) ->
				@storage.drop 'token', { appId: app.appId }, cb
		], fn

	getApp: (appId, fn) ->
		@storage.get 'application', { appId: appId }, (err, data) =>
			if err then return fn err
			fn null, @newApp data

	getAppByRefresh: (token, fn) ->
		@_getAppBy { refreshToken: token }, fn

	getAppByAccess: (token, fn) ->
		@_getAppBy { accessToken: token }, fn

	_getAppBy: (params, fn) ->
		@storage.get 'token', params, (err, tokenEntry) =>
			if err then return fn err
			@getApp tokenEntry.appId, fn

	getAuthCode: (app, userId, fn) ->
		utils.randString authCodeBytes, (err, code) =>
			@storage.add 'authCode', { appId: app.appId, userId: userId, code: code, expiry: Date.now() + @authCodeDuration }, fn

	getTokens: (app, authCode, fn) ->
		@storage.get 'authCode', { appId: app.appId, code: code }, (err, authCode) ->
			if err then return fn err
			if !authCode? then return fn 'no such auth code'
			if Date.now() > authCode.expiry
				@storage.drop 'authCode', { appId: app.appId, code: code }, (err) ->
					if err then return fn err
					fn 'auth code expired' # auth try expired, sorry.

			@storage.drop 'authCode', { appId: app.appId, code: code }, (err) =>
				if err then return fn err
				@_genTokens (tokens) =>
					@storage.add 'token', { appId: app.appId, scope: app.scope, refreshToken: tokens.refreshToken, accessToken: tokens.accessToken, expiry: Date.now() + @tokenDuration }, fn

	refreshTokens: (app, appSecret, refresh, fn) ->
		if appSecret isnt app.appSecret then return fn 'refresh authentication failure'
		@storage.get 'token', { appId: app.appId, refreshToken: refresh }, (err, refreshToken) =>
			if err then return fn err
			if !refreshToken then return fn 'no such token'

			@storage.drop 'token', { appId: app.appId, refreshToken: refresh }, (err) ->
				if err then return fn err
				@_genTokens (tokens) =>
					@storage.add 'token', { appId: app.appId, scope: app.scope, refreshToken: tokens.refreshToken, accessToken: tokens.accessToken, expiry: Date.now() + @tokenDuration }, fn

	checkAccess: (token, fn) ->
		@storage.get 'token', { accessToken: token }, (err, accessToken) ->
			if err then return fn err
			if !accessToken? then return fn 'no such token'
			if Date.now > accessToken.expiry
				@storage.drop 'token', { accessToken: token }, (err) ->
					if err then return fn err
					fn 'token expired'

			fn null, true, accessToken

	_genTokens: (fn) ->
		async.parallel {
			refreshToken: (cb) ->
				utils.randString tokenBytes, cb
			accessToken: (cb) ->
				utils.randString tokenBytes, cb
		}, fn

module.exports = Server

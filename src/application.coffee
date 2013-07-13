bc = require 'base-converter'
crypto = require 'crypto'
utils = require './utils'

clientIdBytes = 48
clientSecretBytes = 60

class Application
	constructor: (@server, options) ->
		# note: we'll be sticking with the RFC; space delimited scope params, not comma delimited. OBEY THE FUCKING RFC WHEN YOU CAN.
		{ @appId, @appSecret, @name, @description, @owner, @scope } = options
		@redirectURI = 'urn:ietf:wg:oauth:2.0:oob' # we'll take after google here - since OOB auth is *not* RFC for some stupid damn reason.
	create: (fn) ->
		@storage.add 'application', { appId: @appId, appSecret: @appSecret, desc: @description, ownerId: @owner, scope: @scope }, fn
	drop: (fn) ->
		@storage.drop 'application', { appId: @appId }, fn
	@makeClientId: (fn) ->
		utils.randString clientIdBytes, fn
	@makeClientSecret: (fn) ->
		utils.randString clientSecretBytes, fn

module.exports = Application

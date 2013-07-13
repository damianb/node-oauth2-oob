# Storage mechanism for NeDB: https://github.com/louischatriot/nedb

class NeDBStore
	constructor: (@db) ->
		# @db should be an NeDB datastore!
		if typeof @db isnt 'Object' then throw new Error 'Must be provided an NeDB datastore'
	add: (type, data, cb) ->
		data.type = type
		@db.insert(data, cb)
	drop: (type, data, cb) ->
		@db.remove(data, {}, cb)
	get: (type, data, cb) ->
		data.type = type
		@db.findOne(data, cb)

modules.exports = NeDBStore

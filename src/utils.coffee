utils =
	randString: (size, fn) ->
		crypto.randomBytes size, (err, bytes) ->
			if err then return fn err
			fn null, bc.decTo36 bc.hexToDec bytes.toString 'hex'

module.exports = utils

#
# the following is a simple OAuth2 server, designed for ONLY oob authentication.
# redirect authentication is entirely unimplemented (intentionally)
# this code is designed *only* for handling authentication for installed applications.
#


#
# the following are just some example datastructures, what to expect for everything
#

###
ex =
	authCode: {
		appId: ''
		userId: ''
		code: ''
		expiry: ''
	}
	token: {
		appId: ''
		userId: ''
		refreshToken: ''
		accessToken: ''
		expiry: ''
		scope: ''
	}
	application: {
		appId: ''
		appSecret: ''
		ownerId: ''
		name: ''
		desc: ''
		scope: ''
	}
###

module.exports = oauth2 =
	server: require './server'
	application: require './application'
	utils: require './utils'

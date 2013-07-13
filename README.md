# oauth2-oob

A lightweight OAuth2 server framework that provides a flexible API without locking users down to specific frameworks.

This package was designed with device authorization in mind (and not external website authorization).  No capacity for redirects exists; all redirectURIs are "urn:ietf:wg:oauth:2.0:oob" for compatibility with libraries designed to handle Google OAuth2.

## supported

Database support includes NeDB.

MongoDB support is planned at some point.

You can build your own driver relatively easy, too - look at how the nedb storage driver is designed, it's fairly simple.

## license

MIT license - copyright (c) 2013 Damian Bushong

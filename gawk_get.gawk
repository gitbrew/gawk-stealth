#!/usr/bin/gawk -f
#
# gawk_get
# iadnah 2011
#
# gawk_get makes an HTTP request (no https) and dumps the raw output
#
# Config variables:
#   VHOST	: where to connect to; site to request
#   USERAGENT	: specify a custom user agent
#   PORT	: port to connect to; default is 80
#   HEADERS	: any extra HTTP headers to send
#   FILE	: url path to request; default is /
#

BEGIN {
	if (VHOST == "")
		if ( length(ENVIRON["VHOST"]) > 0 ) {
			VHOST=ENVIRON["VHOST"]
		} else {
			VHOST="www.something.com"
		}

	if (PORT == "")
		if ( length(ENVIRON["PORT"]) > 0 ) {
			PORT=ENVIRON["PORT"]
		} else {
			PORT=80
		}

	if (FILE == "")
		if ( length(ENVIRON["FILE"]) > 0 ) {
			FILE=ENVIRON["FILE"]
		} else {
			FILE="/"
		}

	if (HEADERS == "")
		if ( length(ENVIRON["HEADERS"]) > 0 ) {
			HEADERS=ENVIRON["HEADERS"]
		}

	if (USERAGENT == "")
		if ( length(ENVIRON["USERAGENT"]) > 0 ) {
			USERAGENT=ENVIRON["USERAGENT"]
		} else {
			USERAGENT="Gawkget (0.0.1/iadnah)"
		}

	NetService="/inet/tcp/0/" VHOST "/" PORT

	REQUEST="GET " FILE " HTTP/1.0\r\nHost: " VHOST "\r\nUser-Agent: " USERAGENT "\r\n" HEADERS "\r\n\r\n"

	print REQUEST |& NetService

	while ((NetService |& getline) > 0)
		print $0
	close(NetService)
}

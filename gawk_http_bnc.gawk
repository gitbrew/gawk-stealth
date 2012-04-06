#!/usr/bin/gawk -f
#
# gawk_http_bnc
# iadnah 2011
#
# gawk_http_bnc listens on a given port and whenever a client connects
# it performs an HTTP request as configured and sends the raw output
# to the client
#
# Config variables:
#   VHOST	: where to connect to; site to request
#   USERAGENT	: specify a custom user agent
#   PORT	: port to connect to; default is 80
#   HEADERS	: any extra HTTP headers to send
#   FILE	: url path to request; default is /
#
#   LPORT	: port to listen on; default is 8888
#

BEGIN {
	if (LPORT == "")
		if ( length(ENVIRON["LPORT"]) > 0 ) {
			LPORT=ENVIRON["LPORT"]
		} else {
			LPORT=8888
		}

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

	while (1 == 1) {
		ListenService="/inet/tcp/" LPORT "/0/0"
		ListenService |& getline

		NetService="/inet/tcp/0/" VHOST "/" PORT

		REQUEST="GET " FILE " HTTP/1.0\r\nHost: " VHOST "\r\nUser-Agent: " USERAGENT "\r\n" HEADERS "\r\n\r\n"

		print REQUEST |& NetService

		while ((NetService |& getline) > 0)
			print $0 |& ListenService
		close(NetService)
		close(ListenService)
	}
}

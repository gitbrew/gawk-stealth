#!/usr/bin/gawk -f
# awk banner grabber
# iadnah - 2011
#
# gawk -v LPORT=localport -v SERVICE=host/port -f <this-file>
#	ex: gawl -v LPORT=80 -v SERVICE=localhost/22
#	above connects to port 22 on localhost with source port 80
#
# You can also pass the options as environment variables


BEGIN {
	if ( LPORT == "" )
		if ( length(ENVIRON["LPORT"]) > 0 ) {
			LPORT = ENVIRON["LPORT"]
		} else {
			LPORT = 0
		}

	if ( SERVICE == "" )
		if ( length(ENVIRON["SERVICE"]) > 0 ) {
			SERVICE = ENVIRON["SERVICE"]
		}

	service="/inet/tcp/" LPORT "/" SERVICE
	print service
	service |& getline
	print $0
	close(service)
}

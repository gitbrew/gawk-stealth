#!/usr/bin/gawk -f
# gawkserv - simple gawk server
# iadnah 2011
#
# Listens on the given port and accepts 3 commands:
#
#  LIST <arg>	: runs ls -lh on the target
#  GET <arg>	: returns contents of the file
#  EXEC <args>	: runs the args as a shell command and shows output
#
#  The server disconnects the client after each command
#
#
# Config vars:
#
#  maxconnects	: server dies after this many operations
#
#  LPORT	: local port
#
#  SILENT	: if set to "1" don't output stuff to the console

BEGIN {
        i = 0		


	if ( maxconnects == "" ) {
		if ( length(ENVIRON["maxconnects"]) > 0 ) {
			maxconnects = ENVIRON["maxconnects"];
		} else {
			maxconnects=10
		}
	}

	if ( LPORT == "" ) {
		if ( length(ENVIRON["LPORT"]) > 0 ) {
			LPORT = ENVIRON["LPORT"];
		} else {
			LPORT=8888
		}
	}

	if ( SILENT == "" ) {
		if ( length(ENVIRON["SILENT"]) > 0) {
			SILENT = ENVIRON["SILENT"];
		}
	}


	while ( i < maxconnects ) {
	        NetService = "/inet/tcp/" LPORT "/0/0"

	        NetService |& getline

		if ( SILENT != "1" ) {
			printf("Incoming connect!\n\tcmd string: %s\n", $0)
		}

		if ($1 == "LIST") {
			DataPipe = ("ls -lh " $2)
		}
		else if ($1 == "GET") {
			DataPipe = ("cat " $2)
		}
		else if ($1 == "EXEC") {
			cmd = $0
			sub(/^EXEC /, "", $cmd)
			DataPipe = ($cmd)
		} else {
			DataPipe = ("uname -a")
		}
		
	        while ((DataPipe | getline) > 0) {
	                print $0 |& NetService
	        }
	        close(NetService)
		i++
		if ( SILENT != "1" ) {
			print "Handled " i " connections."
		}
	}
}

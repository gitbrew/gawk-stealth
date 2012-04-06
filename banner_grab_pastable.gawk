# awk banner grabber
# iadnah - 2011
#
# Run like this:
# 1) /usr/bin/gawk -f /dev/stdin
# 2) edit and paste the below, hit enter
# 3) hit ctrl+d to execute
# 

BEGIN {	service="/inet/tcp/0/localhost/22"; print service; service |& getline; print $0; close(service); }

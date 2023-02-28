#!/bin/python3
mapfile="/etc/security/oauth-mapfile.cron"

import sys
import syslog
import urllib.parse as urlparse


inputuser=urlparse.unquote(sys.argv[1])

usermapping=dict(authuser="",mapped="")
try:
    for line in open(mapfile,'r',encoding="utf-8"):
        (authuser,mapped) = line.split()
        usermapping[authuser.strip("\"")]=mapped
except:
    syslog.syslog("failed to read mapping")

if inputuser in usermapping:
    print(usermapping[inputuser])
else:
    print("")

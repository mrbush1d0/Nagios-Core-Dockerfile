#!/bin/bash
service apache2 start
service nagios start
tail -f /usr/local/nagios/var/nagios.log

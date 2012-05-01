#!/bin/sh

##########################################################
##	CONFIG ME HERE					##
##########################################################

# Your username at the service provider.
# (leave the single quotes there!)
UTILIZADOR='username'

# That magical thing only you know of.
# (leave the single quotes there!)
PALAVRACHAVE='password'

# Watch out for the permissions on this file!!!
# chmod 700 me!

# The names to update separated with spaces.
# (leave the single quotes there!)
RECORDS='domain.tld host.domain.tld'

# The nameserver to use.
# You must have been told what nameservers you where going use...
# (leave the single quotes there!)
NS='ns12.zoneedit.com'

# The log file.
# (leave the single quotes there!)
REGISTO='/var/log/ddns-updater.log'

# Date format.
DATA="$(date +"%F @ %T")"

##########################################################
## 	STOP messing around with the rest of the code.	##
##	Your job is done. :-)				##
##########################################################

# Your courrent ip:
NEWIP=$(wget -q -O - http://myip.dnsomatic.com/)

# for each record...
for R in $RECORDS
do
	{
## dig command is often not available, so let's choose only one of the next two options accordingly
	if [ $(which dig) ]
	then
		{
# using dig (cleaner):
		OLDIP=$(dig +short -t A -4 $R. @$NS)
		}
	else
		{
# using host (more common):
		OLDIP=$(host $R $NS -t A -4 |grep "$R has address" |egrep -o "[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}")
		}
	fi
# ...see if it has changed...
	if [ "$NEWIP" = "$OLDIP" ]
	then
		{
#  ...and if it didn't, do nothing,
		continue
		}
	else
		{
# if it did change, update it using SSL.
		RESULT=$(wget --no-check-certificate -q -O - --http-user=$UTILIZADOR --http-passwd=$PALAVRACHAVE https://dynamic.zoneedit.com/auth/dynamic.html?host=$R)
# And log the result.
		echo "$DATA ($R -> $NEWIP) $RESULT" >> $REGISTO
		}
	fi
	}
done
exit 0

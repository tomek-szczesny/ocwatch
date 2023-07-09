#!/bin/bash

ID=0
OLDMSG=""
while true
do
	NEWLEAGUE=$(curl -s league.openclonk.org:80/league.php)
	if [ "$LEAGUE" != "$NEWLEAGUE" ]
	then
		echo triggered
		GAMES=$(echo "$NEWLEAGUE" | grep -c [[]Reference[]])
		MSG=""
		if [ $GAMES -gt 0 ]
		then
			for (( i=1; i<=$GAMES; i++ ))
			do
				TITLE=$(echo "$NEWLEAGUE" | grep Title= | sed 's/Title=//g' | sed "${i}q;d")
				STATE=$(echo "$NEWLEAGUE" | grep State= | sed 's/State=//g' | sed "${i}q;d")
				MSG="$MSG\n$TITLE - $STATE"
			done
			
			if [ "$MSG" != "$OLDMSG" ]
			then
				echo sending notification
				ID=$(gdbus call --session \
					--dest=org.freedesktop.Notifications \
					--object-path=/org/freedesktop/Notifications \
					--method=org.freedesktop.Notifications.Notify \
					"" $ID "" 'OpenClonk games detected!' "$MSG" \
					'[]' '{"desktop-entry": <"openclonk">,"transient": <true>, "urgency": <1>}'\
					120000)

				# Store the ID of the last sent notification, so it may be replaced	
				ID=$(echo $ID | sed 's/(uint32 //g' | sed 's/,)//g')
			fi
		fi
		OLDMSG="$MSG"
	fi
	LEAGUE=$NEWLEAGUE
	sleep 10
done

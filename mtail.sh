#!/bin/bash

# mtail. multiple tail. 
# version 1.0.5
# pike@kw.nl

if [ $# -gt 0 ]; then
	LOGS=$@
else 
	LOGS=""
	LOGS=`locate *.log`

	# the above would tail all files on your system.
	# you probably want something more like :

	#LOGS="$LOGS `ls /var/log/apache2/*access*log`"
	#LOGS="$LOGS /var/log/mysql.log"
fi

MTAIL="/tmp/mtail.log"
TMPDIR="/tmp/mtail/"
INTERVAL_TAIL=30
INTERVAL_ROTATE=1
DASH="---------------- "
 
case "$1" in
	--help)
		echo "Usage: mtail [filenames]"
		exit 0;
		;;
esac
	
if (test $# -eq 0);
then
	$0 $LOGS;
	#exit 0;
else

	# make or cleanup tmpdir
	if (test ! -d $TMPDIR)
	then
		mkdir $TMPDIR
		chmod a+w $TMPDIR
	fi
	rm $TMPDIR/*
	
	# unique prefix
	UNIQUE=$$
	
	# create logs
	touch $MTAIL
	chmod a+w $MTAIL


	# start tailing the output file
	# will output to stdout
	tail -f $MTAIL &
 
	echo >> $MTAIL
	echo $DASH >> $MTAIL; 
	echo `date` Starting ... >> $MTAIL;
	echo "press CNTRL-C to stop"
	echo $DASH >> $MTAIL

	# filter filenames
	FILENAMES=""
	for FILENAME in $*;
	do
		if (test -f $FILENAME)
		then
			BASENAME=`basename $FILENAME`;
			LOGNAME="$UNIQUE-$BASENAME";
			echo $DASH > $TMPDIR/$LOGNAME
			chmod a+w $TMPDIR/$LOGNAME
			FILENAMES="$FILENAMES $FILENAME"
		else
			$FILENAME >> $MTAIL #produces nice error
		fi
	done

	# on control-c, kill my children
	trap 'echo; echo exiting ..; pkill -u $USER -P $$  ; echo logged in $MTAIL; exit 0'  SIGINT

	# tail and pipe files
	for FILENAME in $FILENAMES;
	do	
		echo "tail -f $FILENAME" >> $MTAIL
		BASENAME=`basename $FILENAME`;
		LOGNAME="$UNIQUE-$BASENAME";
		tail --follow=name --retry -s $INTERVAL_TAIL $FILENAME >>  $TMPDIR/$LOGNAME &
		sleep $INTERVAL_ROTATE
	done
 	
	# loop forever
	while (test 2 -gt 1)
	do
		for FILENAME in $FILENAMES;
		do	
			BASENAME=`basename $FILENAME`;
			LOGNAME="$UNIQUE-$BASENAME";
			NUMLINES=`cat -A $TMPDIR/$LOGNAME | wc -l`
			if (test $NUMLINES -gt 1) 
			then
				echo "" >> $MTAIL 
				echo $DASH >> $MTAIL
				echo `date "+%H:%M:%S"` $BASENAME >> $MTAIL
				cat $TMPDIR/$LOGNAME >> $MTAIL
				echo $DASH > $TMPDIR/$LOGNAME # empty file
			fi
			sleep $INTERVAL_ROTATE
		done
	done
fi
exit 0;


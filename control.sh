#!/bin/bash
path=`dirname "$0":`
mqtt=`cat $path/settings | grep mqttserver | cut -f2`
mqttuser=`cat $path/settings | grep mqttuser | cut -f2`
mqttpass=`cat $path/settings | grep mqttpass | cut -f2`
mqttport=`cat $path/settings | grep mqttport | cut -f2`
name=`cat $path/settings | grep openhabname | cut -f2`

check()
{
$path/heatpump info
}

mosquitto_sub -v -R -h $mqtt -p $mqttport -u $mqttuser -P $mqttpass -t evoheat/# | while read line
do
	settemp=`echo $line | grep "$name"/targettemp/command | rev | cut -d ' ' -f1 | rev`
	mode=`echo $line | grep "$name"/mode/command | rev | cut -d ' ' -f1 | rev`
	power=`echo $line | grep "$name"/power/command | rev | cut -d ' ' -f1 | rev`
	if [[ ! -z $settemp ]]; then
		$path/heatpump temp $settemp
		check
	fi

	if [[ ! -z $mode ]]; then
		echo $line
		if [[ $mode = "1" ]]; then
			$path/heatpump mode intelligent
			check
		elif [[ $mode = "2" ]]; then
			$path/heatpump mode eco
			check
		elif [[ $mode = "3" ]]; then
			$path/heatpump mode hybrid
			check
		elif [[ $mode = "4" ]]; then
			$path/heatpump mode fast
			check
		fi
	fi

	if [[ ! -z $power ]]; then
		echo $line
		if [[ $power = "1" ]]; then
			$path/heatpump on
			check
		elif [[ $power = "0" ]]; then
			$path/heatpump off
			check
		fi
	fi
done

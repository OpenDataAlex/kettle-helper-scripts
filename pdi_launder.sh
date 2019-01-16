#!/bin/sh
#
#  PDI Launcher
#  
#  Purpose:  This generic script makes it easier to execute PDI jobs/transformations
#            without having to know what to use for PDI.  Also handles log files.
#            Usage:  sh pdi_launcher.sh job project/process.kjb "/level:Detailed -Dparam:value"
#
#  Created:  04/01/2015
#

#User Provided values
PROCESS_TYPE=$1
PROCESS=$2
PARAMETERS=$3

#PARAMETERS - change these as necessary
PDI_CODE_HOME="/path/to/source/code/"
PDI_HOME="/path/to/data-integration/"
PDI_LOG_HOME="/path/to/store/log/"

#PARAMETERS - don't change these...
CURRENT_TIME=`date +"%Y_%m_%d_%H_%M_%S"`
LOG_FILE_PATH_BASE=$(echo $PROCESS | cut -f1 -d .)
LOG_FILE_NAME_BASE=$(echo ${LOG_FILE_PATH_BASE##*/})
PROCESS_TYPE_LIST="trans, transformation, job"
TOUCH_FILE=${PDI_LOG_HOME}/touchfiles/${LOG_FILE_NAME_BASE}.touch


#Debugging lines.
#echo "Log file path base is: ${LOG_FILE_PATH_BASE}"
#echo "Touch file is: ${TOUCH_FILE}"

#Are we trying to run a job or transformation?
if [[ $PROCESS_TYPE == "trans" ]] || [[ $PROCESS_TYPE == "transformation" ]]; then
   EXECUTE_PROCESS=pan.sh
elif [[ $PROCESS_TYPE == "job" ]]; then
   EXECUTE_PROCESS=kitchen.sh
else
   echo 'ERROR - Process type must be one of the following: ' $PROCESS_TYPE_LIST
   exit
fi

cd $PDI_HOME

#Create logging directories
mkdir -p $PDI_LOG_HOME/$LOG_FILE_PATH_BASE

#Create a touchfile which makes sure the process doesn't try to run more than one of itself.

#First, we must ensure the touchfile directory exists...
mkdir -p $PDI_LOG_HOME/touchfiles

if [ ! -f $TOUCH_FILE ]; then
    touch $TOUCH_FILE

	sh $EXECUTE_PROCESS /file:$PDI_CODE_HOME/$PROCESS $PARAMETERS > $PDI_LOG_HOME/$LOG_FILE_PATH_BASE/${LOG_FILE_NAME_BASE}_${CURRENT_TIME}.log
	rm $TOUCH_FILE
else
	#echo 'Found the touchfile...'
	#echo $TOUCH_FILE

	NUM_PROCS=$( ps -ef | grep "${PROCESS}" | wc -l)

	echo 'ERROR - There is a touch file preventing this process from kicking off.'

	if [ "$NUM_PROCS" -ge 1 ]; then

		echo 'ERROR - It appears the process is still running.'

	else

		echo 'ERROR - It appears the touchfile did not get deleted and the process is not running.'

	fi
fi


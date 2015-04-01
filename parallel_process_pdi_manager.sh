#!/bin/sh
#
# Parallel process PDI Manager
#
# Purpose:  To parallel execute PDI processes based on interdependencies and loads.
#           For when you need to control inter-job dependencies without an
#           enterprise scheduler.
#	    Usage:  sh parallel_process_pdi_manager.sh extract
#
# Created: 04/01/2015
#

#User Provided Values
PROCESS_TYPE=$1


#PARAMETERS - don't change these...
CURRENT_TIME=`date +"%Y_%m_%d_%H_%M_%S"`

#PARAMETERS - change these as necessary
EXECUTION_LAUNCH_LOG_BASE="/path/to/logs/parallel_process_launch_log/${PROC_TYPE}"
EXECUTION_LAUNCH_LOG="${EXECUTION_LAUNCH_LOG_BASE}/${PROCESS_TYPE}_launch_log_${CURRENT_TIME}.log"
LAUNCH_SCRIPT="/path/to/pdi_launcher.sh"
PROCESS_OPTIONS="extract, mart, other_project"


#Ensuring the log directory is in place for the process manager.
mkdir -p $EXECUTION_LAUNCH_LOG_BASE

touch $EXECUTION_LAUNCH_LOG

#Writing functions for process execution command and log line command.
function process_execution_setup {
    PROCESS=$1

    echo "${LAUNCH_SCRIPT} job ${PROCESS} && echo 'job ${PROCESS} complete' >> ${EXECUTION_LAUNCH_LOG}"
}



function log_line {

    BATCH_NUMBER=$1
	
	echo "processing ${BATCH_NUMBER} batch" >> ${EXECUTION_LAUNCH_LOG}
}

# The processes being controlled by this launcher.

#Extract processes
sample_extract_job=$(process_execution_setup extract/sample_extract_jb.kjb )

#Mart Load processes
sample_mart_job=$(process_execution_setup mart/sample_mart_jb.kjb )

#This statement controls which process loop gets triggered, based on the process type passed by the script call.

if [[ $PROCESS_TYPE == "extract" ]]; then

    #Run the following processes in parallel.
        eval $sample_extract_job & eval $another_extract_job &
	eval log_line 'first'
	while true
	do
	  lines=`wc -l ${EXECUTION_LAUNCH_LOG} | cut -f 1 -d ' '`;
	  #echo "${EXECUTION_LAUNCH_LOG} : $lines"
	  
	  case $lines in
	    3)
		  eval $yet_another_extract_job &
		  eval log_line 'second'
		  ;;
		5)
		  echo 'Extract processes have completed.' >> ${EXECUTION_LAUNCH_LOG}
		  ;;
		*)
		  sleep 60
		  ;;
		esac
	done
elif [[ $PROCESS_TYPE == "mart" ]]; then
    
	#Run the following processes in parallel.
	eval $sample_mart_job & eval $another_mart_job &
	eval log_line 'first'
	
	while true
	do
	  lines=`wc -l ${EXECUTION_LAUNCH_LOG} | cut -f 1 -d ' '`;
	  echo "${EXECUTION_LAUNCH_LOG} : $lines"
	  
	  case $lines in
	    3)
	      eval $yet_another_extract_job &
		  eval log_line 'second'
		  ;;
	    5)
	      echo 'Mart processes have completed.' >> ${EXECUTION_LAUNCH_LOG}
	      ;;
	    *)
	      sleep 60
	      ;;
	    esac
	done	
		  
else
  echo "Please run this script with one of the following options: ${PROCESS_OPTIONS}"
fi

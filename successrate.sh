#!/usr/bin/env bash
#A StorJ node monitor script for telegraf: Contains code contributed by: BrightSilence, turbostorjdsk / KernelPanick, Alexey

LOG_SOURCE="${1}"
#TIMEFRAME="24h"

if [ -e "${LOG_SOURCE}" ]
then
	# the first argument is passed and it's an existing log file
	LOG="cat ${LOG_SOURCE}"
else
	# assumes your docker container is named 'storagenode'. If not, pass it as the first argument, e.g.:
	# bash successrate.sh mynodename
	DOCKER_NODE_NAME="${1:-storagenode}"
	LOG="docker logs $DOCKER_NODE_NAME"
fi

#Get Node ID (NOTE: Head-n15 may prove to be unreliable for users that may archive early parts of the file,
#since it's the fastest way, we'll leave it for now)
node_id=$(eval "docker logs storagenode" 2>&1| head -n15 | awk -F' ' '/Node/ && /started/{print substr($4,0,7)}')
#NO_SUCH_CONTAINER_ERROR="Error: No such container: $CONTAINER_NAME"
#Cath if node ID collector fails (name Default)
if [ -z "$node_id" ]
  then node_id="Default"
fi

#Node Success Rates


#count of successful audits
audit_success=$($LOG 2>&1 | grep GET_AUDIT | grep downloaded -c)
#count of recoverable failed audits
audit_failed_warn=$($LOG 2>&1 | grep GET_AUDIT | grep failed | grep -v exist -c)
#count of unrecoverable failed audits
audit_failed_crit=$($LOG 2>&1 | grep GET_AUDIT | grep failed | grep exist -c)
#Ratio of Successful to Failed Audits
if [ $(($audit_success+$audit_failed_crit+$audit_failed_warn)) -ge 1 ]
then
	audit_successrate=$( $audit_success / ( $audit_success + $audit_failed_crit + $audit_failed_warn )) * 100
else
	audit_successrate=0.000
fi
#if [ $(($audit_success+$audit_failed_crit+$audit_failed_warn)) -ge 1 ]
#then
#	audit_recfailrate=$(printf '%.3f\n' $(echo -e "$audit_failed_warn $audit_success $audit_failed_crit" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))
#else
#	audit_recfailrate=0.000
#fi
#if [ $(($audit_success+$audit_failed_crit+$audit_failed_warn)) -ge 1 ]
#then
#	audit_failrate=$(printf '%.3f\n' $(echo -e "$audit_failed_crit $audit_failed_warn $audit_success" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))
#else
#	audit_failrate=0.000
#fi



#count of successful downloads
dl_success=$($LOG 2>&1 | grep '"GET"' | grep downloaded -c)
#canceled Downloads from your node
dl_canceled=$($LOG 2>&1 | grep '"GET"' | grep 'download canceled' -c)
#Failed Downloads from your node
dl_failed=$($LOG 2>&1 | grep '"GET"' | grep 'download failed' -c)
#Ratio of canceled Downloads
#if [ $(($dl_success+$dl_failed+$dl_canceled)) -ge 1 ]
#then
#	dl_canratio=$(printf '%.3f\n' $(echo -e "$dl_canceled $dl_success $dl_failed" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))
#else
#	dl_canratio=0.000
#fi
#Ratio of Failed Downloads
#if [ $(($dl_success+$dl_failed+$dl_canceled)) -ge 1 ]
#then
#	dl_failratio=$(printf '%.3f\n' $(echo -e "$dl_failed $dl_success $dl_canceled" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))
#else
#	dl_failratio=0.000
#fi
#Ratio of Successful Downloads
if [ $(($dl_success+$dl_failed+$dl_canceled)) -ge 1 ]
then
	dl_ratio=$( $dl_success / ( $dl_success + $dl_failed + $dl_canceled )) * 100
else
	dl_ratio=0.000
fi



#count of successful uploads to your node
put_success=$($LOG 2>&1 | grep '"PUT"' | grep uploaded -c)
#count of rejected uploads to your node
put_rejected=$($LOG 2>&1 | grep 'upload rejected' -c)
#count of canceled uploads to your node
put_canceled=$($LOG 2>&1 | grep '"PUT"' | grep 'upload canceled' -c)
#count of failed uploads to your node
put_failed=$($LOG 2>&1 | grep '"PUT"' | grep 'upload failed' -c)
#Ratio of Rejections
if [ $(($put_success+$put_rejected+$put_canceled+$put_failed)) -ge 1 ]
then
	put_accept_ratio=$( ($put_success + $put_canceled + $put_failed) / ( $put_rejected + $put_success + $put_canceled + $put_failed )) * 100
else
	put_accept_ratio=0.000
fi
#Ratio of Failed
#if [ $(($put_success+$put_rejected+$put_canceled+$put_failed)) -ge 1 ]
#then
#	put_fail_ratio=$(printf '%.3f\n' $(echo -e "$put_failed $put_success $put_canceled" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))
#else
#	put_fail_ratio=0.000
#fi
#Ratio of canceled
#if [ $(($put_success+$put_rejected+$put_canceled+$put_failed)) -ge 1 ]
#then
#	put_cancel_ratio=$(printf '%.3f\n' $(echo -e "$put_canceled $put_failed $put_success" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))
#else
#	put_cancel_ratio=0.000
#fi
#Ratio of Success
if [ $(($put_success+$put_failed+$put_canceled+$put_failed)) -ge 1 ]
then
	put_ratio=$( $put_success / ( $put_success + $put_failed + $put_canceled )) * 100
else
	put_ratio=0.000
fi


#count of successful downloads of pieces for repair process
get_repair_success=$($LOG 2>&1 | grep GET_REPAIR | grep downloaded -c)
#count of failed downloads of pieces for repair process
get_repair_failed=$($LOG 2>&1 | grep GET_REPAIR | grep 'download failed' -c)
#count of canceled downloads of pieces for repair process
get_repair_canceled=$($LOG 2>&1 | grep GET_REPAIR | grep 'download canceled' -c)
#Ratio of Fail GET_REPAIR
#if [ $(($get_repair_success+$get_repair_failed+$get_repair_canceled)) -ge 1 ]
#then
#	get_repair_failratio=$(printf '%.3f\n' $(echo -e "$get_repair_failed $get_repair_success $get_repair_canceled" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))
#else
#	get_repair_failratio=0.000
#fi
#Ratio of Cancel GET_REPAIR
#if [ $(($get_repair_success+$get_repair_failed+$get_repair_canceled)) -ge 1 ]
#then
#	get_repair_canratio=$(printf '%.3f\n' $(echo -e "$get_repair_canceled $get_repair_success $get_repair_failed" | awk '{print ( $1 / ( $1 + $2 + $3 )) * 100 }'))
#else
#	get_repair_canratio=0.000
#fi
#Ratio of Success GET_REPAIR
if [ $(($get_repair_success+$get_repair_failed+$get_repair_canceled)) -ge 1 ]
then
	get_repair_ratio=$( $get_repair_success / ( $get_repair_success + $get_repair_failed + $get_repair_canceled )) * 100
else
	get_repair_ratio=0.000
fi

#count of successful uploads of repaired pieces
put_repair_success=$($LOG 2>&1 | grep PUT_REPAIR | grep uploaded -c)
#count of canceled uploads repaired pieces
put_repair_canceled=$($LOG 2>&1 | grep PUT_REPAIR | grep 'upload canceled' -c)
#count of failed uploads repaired pieces
put_repair_failed=$($LOG 2>&1 | grep PUT_REPAIR | grep 'upload failed' -c)
#Ratio of Fail PUT_REPAIR
if [ $(($put_repair_success+$put_repair_failed+$put_repair_canceled)) -ge 1 ]
then
	put_repair_failratio=$( $put_repair_failed / ( $put_repair_failed + $put_repair_success + $put_repair_canceled )) * 100
else
	put_repair_failratio=0.000
fi
#Ratio of Cancel PUT_REPAIR
if [ $(($put_repair_success+$put_repair_failed+$put_repair_canceled)) -ge 1 ]
then
	put_repair_canratio=$( $put_repair_canceled / ( $put_repair_canceled + $put_repair_success + $put_repair_failed )) * 100
else
	put_repair_canratio=0.000
fi
#Ratio of Success PUT_REPAIR
if [ $(($put_repair_success+$put_repair_failed+$put_repair_canceled)) -ge 1 ]
then
	put_repair_ratio=$( $put_repair_success / ( $put_repair_success + $put_repair_failed + $put_repair_canceled )) * 100
else
	put_repair_ratio=0.000
fi

#count of successful deletes
delete_success=$($LOG 2>&1 | grep deleted -c)
#count of failed deletes
delete_failed=$($LOG 2>&1 | grep PUT_REPAIR | grep 'delete failed' -c)
#Ratio of Fail delete
if [ $(($delete_success+$delete_failed)) -ge 1 ]
then
	delete_failratio=$($delete_failed / ( $delete_success + $delete_failed )) * 100
else
	delete_failratio=0.000
fi
#Ratio of Success delete
if [ $(($delete_success+$delete_failed)) -ge 1 ]
then
	delete_ratio=$($delete_success / ( $delete_success + $delete_failed )) * 100
else
	delete_ratio=0.000
fi


#InfluxDB format export
echo "StorJHealth,NodeId=$node_id FailedCrit=$audit_failed_crit,FailedWarn=$audit_failed_warn,Success=$audit_success,Ratio=$audit_successrate,Deleted=$delete_success $(date +'%s%N')"
#Newvedalken254
echo "StorJHealth,NodeId=$node_id DLFailed=$dl_failed,DLSuccess=$dl_success,DLRatio=$dl_ratio,PUTFailed=$put_failed,PUTSuccess=$put_success,PUTRatio=$put_ratio,PUTLimit=$put_rejected,PUTAcceptRatio=$put_accept_ratio $(date +'%s%N')"
#Repair
echo "StorJHealth,NodeId=$node_id GETRepairFail=$get_repair_failed,GETRepairSuccess=$get_repair_success,GETRepairRatio=$get_repair_ratio,PUTRepairFailed=$put_repair_failed,PUTRepairSuccess=$put_repair_success,PUTRepairRatio=$put_repair_ratio $(date +'%s%N')"

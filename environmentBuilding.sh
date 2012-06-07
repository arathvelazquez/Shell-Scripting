#!/bin/bash 
die () { 
		echo >&2 "$@" 
		exit 1
	} 

upper() { 
		up=$(echo $1 | tr '[a-z]' '[A-Z]') 
		echo $up
	} 

lower() {	
		low=$(echo $1 | tr '[A-Z]' '[a-z]') 
		echo $low
	} 

create_logs_folder() { 
		if [ ! -d "./logs" ] ; then 
		mkdir ./logs; 
		fi 
	} 

validate_users() { 
	case $1 in 
		d01) 	user="hd01";; 
		d02) 	user="hd02";; 
		d03) 	user="hd03";; 
		d04) 	user="hd04";; 
		t01) 	user="ht01";; 
		t02) 	user="ht02";; 
		t03) 	user="ht03";; 
		t04) 	user="ht04";; 
		pd) 	user="hp01";; 
		*)	user="NO";; 
	esac 
	echo $user 
	} 

#Validate number of parameters. 
[ "$#" -eq 3 ] || die "Requires 3 parameters: APP SET ENVIRONMENT 
APP : <H or T> 
SET : <H_MAIN,T_MAIN,etc.> 
ENVIRONMENT : <D01,D02,D03...,T01,T02,...,etc>" 

#'Uppercasing and lowercasing' parameters 
application=$(upper $1); 
workset=$(upper $2); 
environment=$(lower $3) 

#Specific commands for H and T 
	case $application in 
		"H") 
			app=$(echo $application | tr '[A-Z]' '[a-z]') 
			build_command="/bin/build.sh h" 
			build_grep="Created dir: /h/" 
			build_subdir="" 
			;; 
		"T") 
			app=$(echo $application | tr '[A-Z]' '[a-z]') 
			build_command="/bin/build.sh t" 
			build_grep="Created dir: /t/" 
			build_subdir="" 
			;; 
		*) 	ERR_MSG="Please enter a valid option! <H,T>" 
			echo $ERR_MSG 
			exit 1	
	esac 

#Time stamp 
fecha=$(date '+%m%d%y'); 
hora=$(date); 
time_stamp=`date '+20%y%m%d_%H%M%S' ` 

#Deploy Flag 
DEPLOY=false; 

#Creating 2 logs. One for script execution and other one for building output. 
create_logs_folder #Create logs folder. 
LOGBUILD=./logs/${application}_build_${workset}_${time_stamp}.log	#Build LOG 
LOG=./logs/${app}_execution_${workset}_${time_stamp}.log	 		#Execution LOG 

#Building 
echo "" 																							|tee $LOG 
echo "Log generated automatically" 																	|tee -a $LOG 
echo "Executing build for "$application 															|tee -a $LOG 
echo '' 																							|tee -a $LOG 
echo 'Building new baseline to '$workset	 														|tee -a $LOG 
hora=$(date); 
echo 'Time: ' $hora	 																				|tee -a $LOG 
echo 'Saving log...' 																				|tee -a $LOG 
$build_command $workset 																			|tee $LOGBUILD 
echo '' 																							|tee -a $LOG 
hora=$(date); 
echo 'Saved at ' $hora 																				|tee -a $LOG 
echo 'Build execution has finished' 																|tee -a $LOG 

#Validations after build 
cat $LOGBUILD | grep 'BUILD FAILED' 
if [ $? -eq 0 ] ; then 
	echo 'The build failed!' 																		|tee -a $LOG 
	exit 1 
else 
	cat $LOGBUILD | grep "$build_grep" 
	if [ $? -eq 0 ] ; then 
		baseline_path=$(cat $LOGBUILD | grep "$build_grep" | cut -d ':' -f 2) 
		echo "New baseline: $baseline_path" 
		DEPLOY=true; 
	else 
		echo '' 																					|tee -a $LOG 
		echo '' 																					|tee -a $LOG 
		echo 'There is not enough data to proceed.' 												|tee -a $LOG 
		echo 'Exiting...' 																			|tee -a $LOG 
		#DEPLOY=true; #Used for testing 
		exit 1 
	fi 
fi 

if [ "$DEPLOY" = true ]; then 
	echo 'It seems build was created correctly.'; 
	echo 'Do you want continue with deployment?(y/n)'; 
	read deploy; 
	if [ "$deploy" = "y" ]; then 
		echo "Baseline to be deployed: $baseline_path"												|tee -a $LOG 
		echo '' 
		user=$(validate_users $environment) 
		if [ "$user" = "NO" ]; then 
			echo "The environment is not valid."	 												|tee -a $LOG 
			echo " "	 																			|tee -a $LOG 
			echo "Exiting..."	 																	|tee -a $LOG 
			exit 1
		fi 
		log_path=$(pwd) 
		echo "Deployment will be executed from $baseline_path :"									|tee -a $LOG 
		echo "sudo -u $user /u001/cm/bin/mdeploy.ksh $environment" 									|tee -a $LOG 
		echo " "	 																				|tee -a $LOG 
		echo "Deployment starting..."	 															|tee -a $LOG 
		echo " "	 																				|tee -a $LOG 
		cd $baseline_path 
		sudo -u $user /u001/cm/bin/mdeploy.ksh $environment 
		cd $log_path 
		pwd 
		echo "Finishing..."	 																		|tee -a $LOG 
		echo " "	 																				|tee -a $LOG 
		echo "Do not forget to check log file for error"											|tee -a $LOG 
	else 
		echo "The user selected 'NO Deployment'"	 												|tee -a $LOG 
	fi 
fi

#!/bin/bash
die ()  {								#Finish script and send error message.								
		echo >&2 "$@"
		exit 1 
} 

upper() {								#to uppercase	
		up=$(echo $1 | tr '[a-z]' '[A-Z]')
		echo $up
}		
	
lower() {								#to lowercase
		low=$(echo $1 | tr '[A-Z]' '[a-z]')
		echo $low
}

baselineHasT(){								#Add _T to BASELINE parameter.		
	has_T=$(echo $1 | grep '_[T]$')
		if [ $? -eq 0 ] ; then
			base=$1
			echo $base
		else 
			base=$1"_T"
			echo $base
	fi
}

baselineWithoutT(){							#Remove _T to BASELINE parameter.		
	without_T=$(echo $1|sed 's/_T$//g')
	echo $without_T
}	

createLogsFolder() {
	if [ ! -d "logs" ] ; then
		mkdir logs;
	fi
}

validateCOM_Users() {
	case $1 in
	        dev01)  terminal="y9dev1"
			user="usrdev01";;
	        dev02)  terminal="y9dev2"
	                user="usrdev02";;
	        dev03)  terminal="y9dev3"
	                user="usrdev03";;
		dev04)  terminal="y9dev4"
	                user="usrdev04";;
	        dev05)  terminal="y9dev5"
	                user="usrdev05";;
	        test01) terminal="y9test1"
	                user="usrtest01";;
	        test02) terminal="y9test2"
			user="usrtest02";;
	        test03) terminal="y9test3"
	                user="usrtest03";;
	        test04) terminal="y9test4"
	                user="usrtest04";;
	        test05) terminal="y9test5"
	                user="usrtest05";;
		test06) terminal="y9test6"
	                user="usrtest06";;
		test07) terminal="y9test7"
	                user="usrtest07";;
		test08) terminal="y9test8"
	                user="usrtest08";;
		test09) terminal="y9test9"
	                user="usrtest09";;
	        *)	ERR="NO"
			echo $ERR
			exit 1
			;;
	esac
	//echo $user@$terminal
}	

#Validate number of parameters.
##### Change FOLDER/BASELINE to generalize with other APPS
[ "$#" -eq 3 ] || die "Requires 3 parameters:  APP ENVIRONMENT BASELINE 

APP 		: <OM,ODS,POS,G>
ENVIRONMENT 	: <TEST02,TEST02,...,DEV01,...,E1,E2,etc...>
BASELINE 	: <OM_CUSTOM_01...0006,F_POS_08...0012,etc>

Usage (example): 
./deploys.sh POS TEST01 F_CPOS_10.00_0037

IMPORTANT NOTE: For OM and G you should type baseline folder too. 
Examples:
./deploys.sh OM TEST01 R2_5/OM_CUSTOM_02.00_0039_T
./deploys.sh G E2 R6.0/CG_APP_06.00_0043_T 

(For G, check if folder is needed.)

Notes:
	1.- BASELINE does not require '_T'
"

#'Uppercase and lowercase' parameters
APPL=$(upper $1);
ENVI=$(lower $2);
BASE=$(upper $3);
BASE_T=$(baselineHasT $BASE);
echo $APPL $ENVI $BASE_T
#exit 1

#Date and time
fecha=$(date '+%m%d%y');
hora=$(date);

#Creating 2 logs. One for script execution and other one for building output.
createLogsFolder 						#Create logs folder.
app=$(echo $APPL | tr '[A-Z]' '[a-z]')
LOGDEPLOY=./logs/${APPL}_${ENVI}_${fecha}_deploy.log		#Log for build build.sh.oms WORKSET
LOG=./logs/${app}_${fecha}_deploy.log				#Log for execution

case $APPL in
	"OM") 				
			####### Read and validate logs are not implemented yet.
			#These following lines are used for read and validate logs for "error","warn" and "fail"
			#deploy_log="/u001/apps/${ENVI}/log/${BASE}" #For grep error, fail and warnings.
			#deploy_log_command="ls /u001/apps/${ENVI}/log/ | grep ${deploy_log}_deploy" #For grep error, fail and warnings.
			#######
			deploy_command="/u001/apps/releases/om/${BASE_T}/source/scripts/omdeploy.ksh ${ENVI}"					
			user_terminal=$(validateCOM_Users $ENVI)
			if [ $user_terminal = "NO" ] ; then
				echo "ERROR: ${ENVI} is not valid as an environment."
			else
				echo "ssh -q $user_terminal $deploy_command"
			fi
			;; 
	"ODS") 
			deploy_command="/u001/apps/releases/ods/${BASE_T}/cmbuild/scripts/sqdeploy.ksh ${ENVI}"
			####	SSH FOR X0319VP61
			####	Validate users!! Pause coding for this application for a while.
			;;
	"POS") 
			deploy_command="/u001/apps/releases/pos/${BASE_T}/Tools/Source/scripts/ksh/sfdeploy.ksh ${ENVI}"
			deploy_grep="Created dir: /u001/apps/releases/pos/"
			deploy_subdir=""
			;;
	"G") 
			deploy_command="/u001/apps/releases/g/${BASE_T}/Tools/Source/scripts/ksh/cgbuild.ksh cg.${ENVI}.config"
			deploy_grep="Created dir: /u001/apps/releases/g/"
			deploy_subdir=""
			;;
	*) ERR_MSG="Please enter a valid option! <OM, ODS, POS or G>"
	   echo $ERR_MSG
	   exit 1	
esac

echo "Do not forget to check log file for errors"
echo "Exiting"
exit 1

#######################################
#######################################
# PARA EL DEPLOYMENT, NO ES NECESARIO DE AQUI PARA ABAJO.
# EVENTUALMENTE SERA BORRADO
#######################################

fecha=$(date '+%m%d%y');
hora=$(date);
app=$(echo $APPL | tr '[A-Z]' '[a-z]') 
DEPLOY=false;
LOGDEPLOY=./logs/${APPL}_${ENVI}_${fecha}_deploy.log	#Log for build build.sh.oms WORKSET
LOG=./logs/${app}_${fecha}.log				#Log for execution

#Building
echo ''                                                 |tee $LOG
echo 'Executing build for '$application                 |tee -a $LOG
echo ''                                                 |tee -a $LOG
echo 'Building new baseline to '$workset		|tee -a $LOG
echo 'Saving log...' 			                |tee -a $LOG
hora=$(date);
echo 'Time: ' $hora					|tee -a $LOG
echo ''                                                 |tee -a $LOG
$build_command $workset 			        |tee $LOGDEPLOY #./build.sh log
hora=$(date);
echo 'Saved at ' $hora                     		|tee -a $LOG
echo 'Build execution has finished'                     |tee -a $LOG

#Validations to change permissions
cat $LOGDEPLOY | grep 'BUILD FAILED'
    if [ $? -eq 0 ] ; then
			echo 'The build failed!'	|tee -a $LOG 
			exit 1
    else 
			cat $LOGDEPLOY | grep $build_grep
			if [ $? -eq 0 ] ; then 						 
				echo 'Changing permissions....'         		|tee -a $LOG
				baseline_path=$(cat $LOGDEPLOY | grep $build_grep | cut -d ':' -f 2)
				chmod -R 775 $baseline_path$build_subdir;
				ls -l $baseline_path$build_subdir;		       
				echo 'Permissions have been changed!'   		|tee -a $LOG
				DEPLOY=true;
			else
				echo ''                                 		|tee -a $LOG
				echo ''                                 		|tee -a $LOG
				echo 'There is not enough data to proceed.' 		|tee -a $LOG
				echo 'Exiting...'                       		|tee -a $LOG
				DEPLOY=true;
				#exit 1
			fi
    fi
	
if [ "$DEPLOY" = true ]; then
    echo 'It seems build worked correctly.';
	echo 'Do you want continue with deployment?(y/n)';
	read deploy;
		if [ "$deploy" = "y" ]; then
			echo 'Could you please provide more details';
		else
			echo "NO Deployment";
		fi
fi
#!/bin/bash
#Validate, create, deployment, review of logs and sending mail
die ()  {
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

validateUsers() {
	case $1 in
	        dev01)  	user="d01";;
	        dev02)  	user="d02";;
	        dev03)  	user="d03";;
			dev04)  	user="d04";;
	        test01) 	user="t01";;
	        test02)  	user="t02";;
	        test03)  	user="t03";;
	        test04)  	user="t04";;
	        prod)  		user="p01";;
	        *)			user="NO";;
				#exit 1 //#El 'exit 1' se hará en cuando se use en la sección del Deployment
	esac
	echo $user
}

sendMail(){
	mail $(whoami) < $LOG
}

######
######  Validar el tercer parametro para ejecutar o no el deployment. Ejemplo: Si solo queremos cambiar los permisos, no ejecutar el deploy NI preguntar si se desea el deploy
######
if [ "$#" -lt 3 ] || [ "$#" -gt 4 ] ; then
	
		echo "
Parameters:  APPLICATION WORKSET ENVIRONMENT DEPLOYMENT

APPLICATION				: <H, E, T or S>
WORKSET					: <H_MAIN,E_MAIN,T_MAIN,etc.>
ENVIRONMENT 			: <DEV01,DEV02,DEV03...,TEST01,TEST02,...,etc>
DEPLOYMENT(Optional) 	: <Y,N> Default: Y

Usage (examples): 
./buildCCM.sh CE CE_MAIN dev01
./buildCCM.sh CH CH_MAIN dev03 Y
./buildCCM.sh CT CT_MAIN tst03 N

For further information or files, please contact Fabricio, Arath. 
an ID: xwr5"
		exit 1
	else 
		deployment=$(upper $4);
		if [ "$#" -eq 4 ] ; then 						 	
			if [ "$deployment" == "Y" ] || [ "$deployment" == "N" ] ; then 						 
				if [ "$deployment" == "Y" ] ; then 						 
					#echo "Si por parametro"
					DEPLOY=true
				else
					#echo "No por parametro"
					DEPLOY=false
				fi
			else 
				echo "Fourth parameter is not valid. Please, use Y or N or BLANK"	
				exit 1
			fi
		else
				#echo "True by default"
				DEPLOY=true
		fi
fi

echo "If deployment is required, please enter your password:           
(NOTE: Your password is NOT stored. Review code if needed.)" 
read -s -p "Password: " password;
#read password;
#echo $password;

#'Uppercasing and lowercasing' parameters
application=$(upper $1);
workset=$(upper $2);
environment=$(lower $3)

#Specific commands for CH and CT
case $application in
	"H") 	
			build_command="/u001/bin/build.sh h"
			build_grep="Created dir: /u001/releases/h/cphist/"
			build_subdir=""
			;; 
	"T") 
			build_command="/u001/bin/build.sh t"
			build_grep="Created dir: /u001/releases/t/"
			build_subdir=""
			;;
	"E") 
			build_command="/u001/bin/build.sh e"
			build_grep="Created dir: /u001/releases/e/"
			build_subdir="/CECustomerService"
			;;
	"S") 
			build_command="/u001/bin/build.sh s"
			build_grep="Created dir: /u001/releases/s/"
			build_subdir=""
			;;
	*) ERR_MSG="Please enter a valid option! <H,T,S or E>"
	   echo $ERR_MSG
	   exit 1	
esac

#Time stamp
fecha=$(date '+%m%d%y');
hora=$(date);
time_stamp=`date '+20%y%m%d_%H%M%S' `
#Deploy Flag
#DEPLOY=false;
#Creating 2 logs. One for script execution and other one for building output.
create_logs_folder 											#Create logs folder.
app=$(echo $application | tr '[A-Z]' '[a-z]')
LOGBUILD=./logs/${application}_build_${workset}_${time_stamp}.log	#Build LOG
LOGDEPLOY=/logs/${application}_deploy_${workset}_${time_stamp}.log #Deploy LOG
LOG=./logs/${app}_execution_${workset}_${time_stamp}.log			#Execution LOG

#Building
echo ""                                                 |tee $LOG
echo "Log generated automatically"                      |tee -a $LOG
echo "Executing build for "$application                 |tee -a $LOG
echo ''                                                 |tee -a $LOG
echo 'Building new baseline to '$workset				|tee -a $LOG
hora=$(date);
echo 'Time: ' $hora				        				|tee -a $LOG
echo ''                                                 |tee -a $LOG
echo 'Saving log...' 			                		|tee -a $LOG
$build_command $workset 								|tee $LOGBUILD
echo ''                                                 |tee -a $LOG
hora=$(date);
echo 'Saved at ' $hora                     				|tee -a $LOG
echo "Build execution has finished"                     |tee -a $LOG
echo " "                                                |tee -a $LOG
#Validations after build
cat $LOGBUILD | grep 'BUILD FAILED'
    if [ $? -eq 0 ] ; then
			echo ''
			echo ''
			echo 'The build failed!'        			|tee -a $LOG 
			sendMail
			exit 1
    else 
			cat $LOGBUILD | grep "$build_grep"
			if [ $? -eq 0 ] ; then 						 
			      baseline_path=$(cat $LOGBUILD | grep "$build_grep" | cut -d ':' -f 2)
			      echo "New baseline: $baseline_path"	 |tee -a $LOG
			      #DEPLOY=true;
			else
			      echo ''                                 |tee -a $LOG
			      echo ''                                 |tee -a $LOG
			      echo 'There is not enough data to proceed.' |tee -a $LOG
			      echo 'Exiting...'                       |tee -a $LOG
				  sendMail
			      exit 1
			fi
    fi

if [ "$DEPLOY" = true ]; then
    	echo ''											|tee -a $LOG
		echo "Baseline to be deployed: $baseline_path"	|tee -a $LOG
		echo ''											|tee -a $LOG				
		user=$(validateUsers $environment)
		if [ "$user" = "NO" ]; then
			echo "The environment is not valid."		|tee -a $LOG
			echo " "									|tee -a $LOG
			echo "Exiting..."							|tee -a $LOG
			sendMail
			exit 1
		fi
		user=$app$user
		log_path=$(pwd)
		echo "Deployment will be executed from $baseline_path$build_subdir :"|tee -a $LOG
		echo "sudo -u $user /u001/bin/sdcmdeploy.ksh $environment" |tee -a $LOG
		echo " "										|tee -a $LOG
		hora=$(date);
		echo "Deployment started at $hora"				|tee -a $LOG
		echo " "										|tee -a $LOG
		cd $baseline_path$build_subdir
		echo "$password" | sudo -S -u $user /u001/bin/sdcmdeploy.ksh $environment | tee -a $log_path$LOGDEPLOY
		cd $log_path
		pwd
		deploy_output=$(cat $log_path$LOGDEPLOY | grep "Log file is avai" | grep "deploy" | cut -d ":" -f 2)
		hora=$(date);
		echo "Deployment finished at $hora"				|tee -a $LOG
		echo " "										|tee -a $LOG
		echo " "										|tee -a $LOG
		echo "Review of log file:"						|tee -a $LOG
		echo "Error messges:"							|tee -a $LOG
		grep -i "error" $deploy_output					|tee -a $LOG
 		echo " "										|tee -a $LOG
		echo "Failure messages:"						|tee -a $LOG
		grep -i "fail" $deploy_output					|tee -a $LOG
		echo " "										|tee -a $LOG
 		echo "Warning messages:"						|tee -a $LOG
		grep -i "warn" $deploy_output				|tee -a $LOG
		echo " "										|tee -a $LOG
		#cat CH_deploy_CH_MAIN_20110617_103512.log | grep "Log file is avai" | grep "deploy" | cut -d ":" -f 2     #########LEER EL LOG DEL DEPLOY
		echo "Sending log...."
		sendMail
fi

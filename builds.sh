#!/bin/bash
#This script requires this file: deployments.sh
#For further information or files, please contact Fabricio, Arath. 
upper() {
		up=$(echo $1 | tr '[a-z]' '[A-Z]')
		echo $up
	}
	
createLogsFolder() {
	if [ ! -d "logs" ] ; then
		mkdir logs;
	fi
}

######
######  Validar el tercer parametro para ejecutar o no el deployment. Ejemplo: Si solo queremos cambiar los permisos, no ejecutar el deploy NI preguntar si se desea el deploy
######
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ] ; then
	
		echo "
Parameters:  APPLICATION WORKSET DEPLOYMENT

APPLICATION		: <OM,ODS,POS,G>
WORKSET			: <OM_MAIN,OM_R2_5_DEV,ODS_MAIN,...,etc>
DEPLOYMENT(Optional) 	: <Y,N> Default: Y

Usage (examples): 
./builds.sh OM OM_MAIN Y
./builds.sh ODS ODS_MAIN N

Notes: 
	1.- For deployment, requires file called: 'deployments.sh'
	2.- Validate build and deploy server before launching.

For further information or files, please contact Fabricio, Arath. 
an ID: xwr5"
		exit 1
	else 
		deployment=$(upper $3);
		if [ "$#" -eq 3 ] ; then 						 	
			if [ "$deployment" == "Y" ] || [ "$deployment" == "N" ] ; then 						 
				if [ "$deployment" == "Y" ] ; then 						 
					#echo "Si por parametro"
					DEPLOY=true
				else
					#echo "No por parametro"
					DEPLOY=false
				fi
			else 
				echo "Third parameter is not valid. Please, use Y or N or BLANK"	
				exit 1
			fi
		else
				#echo "Si por default"
				DEPLOY=true
		fi
fi

#'Uppercase and lowercase' parameters
application=$(upper $1);
workset=$(upper $2);

#Specific commands for different apps
case $application in
	"OM") 	
			build_command="/u001/apps/bin/build.sh oms"
			build_grep="Created dir: /u001/apps/releases/om/"
			build_subdir="/source/scripts/"
			msg_environment=" <test01|test02|..|dev01|dev02|..>"
			;; 
	"ODS") 
			build_command="/u001/apps/bin/build.sh sq"
			build_grep="Created dir: /u001/apps/releases/ods/"
			build_subdir="/cmbuild/scripts/"
			msg_environment=" <test01|test02|..|dev01|dev02|..>"
			;;
	"POS") 
			build_command="/u001/apps/bin/build.sh pos"
			build_grep="Created dir: /u001/apps/releases/pos/"
			build_subdir=""
			msg_environment=" <E1|E2|..|E3|E9|..>"
			;;
	"G") 
			build_command="/u001/apps/bin/build.sh g"
			build_grep="Created dir: /u001/apps/releases/g/"
			build_subdir=""
			msg_environment=" <E1|E2|..|E9|..|E18|..>"
			;;
	*) ERR_MSG="Please enter a valid option! <OM, ODS, POS or G>"
	   echo $ERR_MSG
	   exit 1	
esac

#Time stamp
fecha=$(date '+%m%d%y');
hora=$(date);
time_stamp=`date '+20%y%m%d_%H%M%S' `

#Creating 2 logs. One for script execution and other one for building output.
createLogsFolder 											#Create logs folder.
app=$(echo $application | tr '[A-Z]' '[a-z]') 				#lowercase for log
LOGBUILD=./logs/${application}_build_${workset}_${time_stamp}.log	#Build LOG
LOG=./logs/${app}_execution_${workset}_${time_stamp}.log			#Execution LOG

#Building
echo ''                                                 |tee $LOG
echo 'Executing build for '$application                 |tee -a $LOG
echo ''                                                 |tee -a $LOG
echo 'Building new baseline to '$workset				|tee -a $LOG

hora=$(date);
echo 'Time: ' $hora					                    |tee -a $LOG
echo 'Saving log...' 			                        |tee -a $LOG
$build_command $workset 			          			|tee $LOGBUILD #./build.sh log
hora=$(date);
echo 'Saved at ' $hora                     				|tee -a $LOG
echo 'Build execution has finished'                     |tee -a $LOG

#Validations
cat $LOGBUILD | grep 'BUILD FAILED'
    if [ $? -eq 0 ] ; then
			echo 'The build failed!'	      		    |tee -a $LOG 
			mail $(whoami) < $LOG
			exit 1
    else 
			cat $LOGBUILD | grep "$build_grep"
			if [ $? -eq 0 ] ; then 						 
				echo 'Changing permissions....'         |tee -a $LOG
				baseline_path=$(cat $LOGBUILD | grep "$build_grep" | cut -d ':' -f 2)
				chmod -R 775 $baseline_path$build_subdir;
				ls -l $baseline_path$build_subdir;		       
				echo 'Permissions have been changed!'   |tee -a $LOG				
				#DEPLOY=true; #SOLO PARA PRUEBAS - YA es determinado por el parametro inicial
			else
				echo ''                                 |tee -a $LOG
				echo ''                                 |tee -a $LOG
				echo 'There is not enough data to proceed.' |tee -a $LOG
				echo 'Exiting...'                       |tee -a $LOG
				#exit 1 			#Descomentar para PRODUCTION
				#mail $(whoami) < $LOG
			fi
    fi

if [ "$DEPLOY" = true ]; then
    echo 'It seems build was created correctly.'			|tee -a $LOG
	echo '';
	echo 'Do you want to continue with deployment?(y/n)'	|tee -a $LOG
	read deploy;
		if [ "$deploy" = "y" ]; then
			echo 'Could you please provide the Environment? Example: '$msg_environment; 
			read environment;
			echo ''
			#Se cuenta el array apartir del dos, porque el 1 es antes del primer slash "/"
			#baseline_path="/u001/apps/releases/om/R2_5/OM_CUSTOM_02.00_0039_T"
			#baseline_path="/u001/apps/releases/sq/sods/SQ_SODS_03.00_0018_T" 
			#baseline_path="/u001/apps/releases/pos/SF_CPOS_10.00_0037_T"
			#baseline_path="/u001/apps/releases/g/CG_APP_07.00_0003_T"
			#echo $baseline_path 	#Comment for PROD
			
			case $application in
				"OM") 	
					baseline2deploy=$(echo $baseline_path | awk '{split($0,array,"/")} END{print array[8]"/"array[9]}');; 
				"ODS") 
					baseline2deploy=$(echo $baseline_path | awk '{split($0,array,"/")} END{print array[9]}');;
				"OS") 	
					baseline2deploy=$(echo $baseline_path | awk '{split($0,array,"/")} END{print array[8]}');;
				"G") 	
					baseline2deploy=$(echo $baseline_path | awk '{split($0,array,"/")} END{print array[8]}');;
			esac
			
			echo "Baseline to be deployed: $baseline2deploy"
			echo ''
			#echo "Proceed with current baseline? If not, you will need to enter baseline to be deployed.(y/n)";
			#Add WHILE LOOP to validate input.
			
			until [ "$new_baseline" = "y" ] || [ "$new_baseline" = "n" ]; do 
				echo "Proceed with current baseline? If not, you will need to enter baseline to be deployed.(y/n)";
				read new_baseline;
				echo $new_baseline
        	done
			
			#echo "Exiting for DEBUG"
			#exit 1
			
			#read new_baseline;
				if [ "$new_baseline" = "y" ]; then
					echo $baseline2deploy;
				else
					echo 'Provide baseline folder and baseline to be deployed:'
					echo ''
					echo 'Note: Only for COM, please type the baseline folder and baseline as follows (example): 
						R2_5/OM_CUSTOM_02.05.00_0039_T'
					read baseline2deploy;
					echo $baseline2deploy;
				fi
			
			sh deployments.sh $application $environment $baseline2deploy
		else
			echo "'NO Deployment' selected by user"							|tee -a $LOG
		fi
fi
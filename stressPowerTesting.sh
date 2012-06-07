#!/bin/bash
i=0
#$1  Numbers of iterations.
REPORT=./stressPowerTesting.log
VALUES_VDD=(1 2 3 4 5)

echo 'Stress Power Testing' 																	|tee $REPORT	
echo 																							|tee -a $REPORT	

while [ $i -lt 6 ]
do
	echo '==========================' 															|tee -a $REPORT	
	echo 'Iteration number: ' $i  																|tee -a $REPORT
	echo 																						|tee -a $REPORT	
	echo 'Iteration number: ' $i	


	case $i in
		0) echo 																				|tee -a $REPORT
			echo 'Turn on SmartReflex' 															|tee -a $REPORT
			echo 'Commands:' 																	|tee -a $REPORT
			echo 'echo 1 > /power/sr_vdd1_autocomp' 											|tee -a $REPORT
			echo 'echo 1 > /power/sr_vdd2_autocomp' 											|tee -a $REPORT
			echo 																				|tee -a $REPORT			
			echo 1 > /power/sr_vdd1_autocomp
			echo 1 > /power/sr_vdd2_autocomp ;;
			
		1)  echo 																				|tee -a $REPORT
			echo 'Turn off SmartReflex' 														|tee -a $REPORT
			echo 'Commands:' 																	|tee -a $REPORT
			echo 'echo 0 > /power/sr_vdd1_autocomp' 											|tee -a $REPORT
			echo 'echo 0 > /power/sr_vdd2_autocomp' 											|tee -a $REPORT
			echo 																				|tee -a $REPORT			
			echo 0 > /power/sr_vdd1_autocomp
			echo 0 > /power/sr_vdd2_autocomp ;;
			
		2)  echo 																				|tee -a $REPORT
			echo 'Core Retention' 																|tee -a $REPORT
			echo 'Commands:' 																	|tee -a $REPORT
			echo 'echo -n 0 > /power/enable_mpucoreoff' 										|tee -a $REPORT
			echo 																				|tee -a $REPORT
			echo -n 0 > /power/enable_mpucoreoff ;;
			
		3)  echo 																				|tee -a $REPORT
			echo 'Core Off' 																	|tee -a $REPORT
			echo 'Commands:' 																	|tee -a $REPORT
			echo 'echo -n 1 > /power/enable_mpucoreoff' 										|tee -a $REPORT
			echo 																				|tee -a $REPORT
			echo -n 1 > /power/enable_mpucoreoff ;;
			
		4)  echo 																				|tee -a $REPORT
			echo 'DVFS On' 																		|tee -a $REPORT
			echo 'Commands:' 																	|tee -a $REPORT
			echo 'echo "ondemand" > /sys/system/cpu0/cpufreq/governor' 							|tee -a $REPORT
			echo 																				|tee -a $REPORT
			echo "ondemand" > /sys/system/cpu0/cpufreq/governor ;;		
		
		5)  echo 																				|tee -a $REPORT
			echo 'DVFS Off' 																	|tee -a $REPORT
			echo 'Commands:' 																	|tee -a $REPORT
			echo 'echo "performance" > /sys/system/cpu0/cpufreq/governor' 						|tee -a $REPORT
			echo 																				|tee -a $REPORT
			echo "performance" > /sys/system/cpu0/cpufreq/governor ;;
			
		*) ERR_MSG="Please, enter a valid case!"
	esac

	echo 'Start changing OPP' 																	|tee -a $REPORT
	echo 																						|tee -a $REPORT
	
	for (( j=1;j<=2;j++)) do

		RNDM_VALUE=$((RANDOM%5))
		echo 'Random value for VDD: ' ${VALUES_VDD[ $RNDM_VALUE]} 								|tee -a $REPORT
		echo 'Random value for VDD: ' ${VALUES_VDD[ $RNDM_VALUE]} 
		echo 'echo -n' ${VALUES_VDD[ $RNDM_VALUE]}  '> /power/vdd1_opp_value' 					|tee -a $REPORT
		echo -n ${VALUES_VDD[ $RNDM_VALUE]}  > /power/vdd1_opp_value
		
		VDD1=`/power/vdd1_opp_value`			
		echo 'VDD1 = ' $VDD1   																	|tee -a $REPORT
		echo "$VDD1" 
		
		VDD2=`/power/vdd2_opp_value`			
		echo 'VDD2 = ' $VDD2   																	|tee -a $REPORT
		echo "$VDD2" 
		echo 																					|tee -a $REPORT	
		sleep 0.5
	done
	i=`expr $i + 1`
done

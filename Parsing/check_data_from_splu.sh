#!/bin/bash

today=$(date '+%Y-%m-%d');
time_stamp=`date '+20%y%m%d_%H%M%S' `
ERROR_LOG=./errors_dexcloud.log
REPORT_LOG=./report_dexcloud_${time_stamp}.log
echo $REPORT_LOG;

echo " "                |tee $REPORT_LOG
echo "Started at: "     |tee -a $REPORT_LOG
date                    |tee -a $REPORT_LOG
echo " "                |tee -a $REPORT_LOG
echo " "                |tee -a $REPORT_LOG
echo "List of errors"   |tee -a $REPORT_LOG
#cat $log | egrep -i $today | cut -d' ' -f 5 | sort -u >> errors.log;
##cat Feb_19_2013_17-58-33_DexCloudLog.log | egrep -i $today | egrep ":[0-9]{2,3}"
#cat Dexcloud_Feb-26-2013_03-50_raw.txt | egrep -i $today | awk '{if ($5 ~ /com|dexknows|org/) print $5; else if($4 ~ /com|dexknows|org/) print $4}' | sort -u > errors.log;
#cat $1 | egrep -i $today | awk '{if ($5 ~ /com|dexknows|org/) print $5; else if($4 ~ /com|dexknows|org/) print $4}' | sort -u > errors_TEST.log;

#Obtengo todos los errores que contiene el archivo.
cat $1 | egrep -i "201[23]-[0-1][0-9]-[1-3][0-9]" | awk '{if ($5 ~ /com|dexknows|org/) print $5; else if($4 ~ /com|dexknows|org/) print $4}' | sort -u > $ERROR_LOG;

unset array_errors;
for i in $(cat $ERROR_LOG); do array_errors=("${array_errors[@]}" "$i"); done

num_errores=${#array_errors[@]};
num_errores=`expr $num_errores - 1`;
#echo $num_errores;

#Inicializo con 0 todos los valore del Array que tiene el contador de cada error
unset count_errors;
for i in $(seq 0 $num_errores); do count_errors=("${count_errors[@]}" 0); done
#echo ${#count_errors[@]};

contador=0;
for j in $(cat $1);
        do 
            for i in $(seq 0 $num_errores); 
                do  
                    if [ ${array_errors[$i]} == $j ];then
                        if [ $contador -lt 1 ]; then
                            echo $j;
                        fi;
                        contador=`expr ${count_errors[$i]} + 1`;
                        eval count_errors[$i]=$contador;
                        break;
                    fi;
                done;
                #echo $counter;
        done;

echo " "              |tee -a $REPORT_LOG
echo " "              |tee -a $REPORT_LOG

for z in $(seq 0 $num_errores); 
    do 
        echo "Error: " ${array_errors[$z]} " has " ${count_errors[$z]} | tee -a $REPORT_LOG; 
    done;

echo " "              |tee -a $REPORT_LOG
echo " "              |tee -a $REPORT_LOG
echo "Finished at: "  |tee -a $REPORT_LOG
date                  |tee -a $REPORT_LOG
#----------------------------------------------------
            #if [ "$i" == "$st" ];then
            #    if [ "$count" -lt 1 ]; then
            #        echo $st;
            #    fi;
            #    (( count += 1 ));
            #fi;
#----------------------------------------------------




#for i in $(cat errors.log);
#        do count=0;
#                for j in $(cat Dexcloud_Feb-26-2013_03-50_raw.txt);
#                        do st=$(echo $j);
#                                if [ "$i" == "$st" ];then
#                                        if [ "$count" -lt 1 ]; then
#                                                echo $st;
#                                        fi;
#                                        (( count += 1 ));
#                                fi;
#                        done;
#                        echo $count;
#        done#

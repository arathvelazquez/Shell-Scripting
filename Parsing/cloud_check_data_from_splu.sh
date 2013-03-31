#!/bin/bash

today=$(date '+%Y-%m-%d');
time_stamp=`date '+20%y%m%d_%H%M%S' `
ERROR_LOG=./errors.log
REPORT_LOG=./report_cloud_${time_stamp}.log
echo "Log file: " $REPORT_LOG;

echo " "                |tee $REPORT_LOG
echo "Started at: "     |tee -a $REPORT_LOG
date                    |tee -a $REPORT_LOG
echo " "                |tee -a $REPORT_LOG
echo "List of errors"   |tee -a $REPORT_LOG


#Obtener todos los errores únicos que contiene el archivo.
cat $1 | egrep -i "201[23]-[0-1][0-9]-[1-3][0-9]" | awk '{if ($5 ~ /com|knows|org/) print $5; else if($4 ~ /com|knows|org/) print $4}' | sort -u > $ERROR_LOG;

unset array_errors;
for i in $(cat $ERROR_LOG); do array_errors=("${array_errors[@]}" "$i"); done

num_errores=${#array_errors[@]};
num_errores=`expr $num_errores - 1`;
#echo $num_errores;

#Inicializo con 0 todos los valores del Array que tiene el contador de cada error
unset count_errors;
for i in $(seq 0 $num_errores); do count_errors=("${count_errors[@]}" 0); done
#echo ${#count_errors[@]};

contador=0;

            for i in $(seq 0 $num_errores); 
                do  total_errors=0;
                    total_errors=$(cat $1 | egrep -i ${array_errors[$i]} | wc -l);
                    #contador=`expr ${count_errors[$i]} + 1`;
                    eval count_errors[$i]=$total_errors;
                done;

echo " "              |tee -a $REPORT_LOG
echo " "              |tee -a $REPORT_LOG

for z in $(seq 0 $num_errores); 
    do 
        echo "Error: " ${array_errors[$z]} " - " ${count_errors[$z]} " events." | tee -a $REPORT_LOG; 
    done;

echo " "              |tee -a $REPORT_LOG
echo " "              |tee -a $REPORT_LOG
echo "Finished at: "  |tee -a $REPORT_LOG
date                  |tee -a $REPORT_LOG

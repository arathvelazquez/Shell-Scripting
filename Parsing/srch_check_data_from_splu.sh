#!/bin/bash

today=$(date '+%Y-%m-%d');
time_stamp=`date '+20%y%m%d_%H%M%S' `
ERROR_LOG=./errors_search.log
REPORT_LOG=./report_dexcloud_${time_stamp}.log
echo "Log file: " $REPORT_LOG;

echo " "                |tee $REPORT_LOG
echo "Started at: "     |tee -a $REPORT_LOG
date                    |tee -a $REPORT_LOG
echo " "                |tee -a $REPORT_LOG
echo "List of errors"   |tee -a $REPORT_LOG


#Obtener todos los errores únicos que contiene el archivo.
cat $1 | egrep "[0-9]{2}:[0-9]{2}*.[0-9]{3}" | awk '{if ($7 ~ /com|knows|org/) print $7; else if($8 ~ /com|knows|org/) print $8; else if($3 ~ /com|dexknows|org/) print $3}' | sort -u | sed 's/\[//' | sed 's/\]//' > $ERROR_LOG;

unset array_errors;
for i in $(cat $ERROR_LOG); do array_errors=("${array_errors[@]}" "$i"); done

num_errores=${#array_errors[@]};
num_errores=`expr $num_errores - 1`;
#echo "Numero de errores: "$num_errores;

#Inicializo con 0 todos los valore del Array que tiene el contador de cada error
unset count_errors;
for i in $(seq 0 $num_errores); do count_errors=("${count_errors[@]}" 0); done
echo " "              |tee -a $REPORT_LOG

            for i in $(seq 0 $num_errores); 
                do  total_errors=0;
		    		total_errors=$(cat $1 | egrep "[0-9]{2}:[0-9]{2}*.[0-9]{3}" | egrep -i ${array_errors[$i]} | wc -l);
                    eval count_errors[$i]=$total_errors;
                    echo "Error: " ${array_errors[$i]} " - " $total_errors " events." | tee -a $REPORT_LOG;
                done;


#for z in $(seq 0 $num_errores); 
#    do 
#        echo "Error: " ${array_errors[$z]} " - " ${count_errors[$z]} " events." | tee -a $REPORT_LOG; 
#    done;

echo " "              |tee -a $REPORT_LOG
echo " "              |tee -a $REPORT_LOG
echo "Finished at: "  |tee -a $REPORT_LOG
date                  |tee -a $REPORT_LOG

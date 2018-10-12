#!/bin/bash
# script di lancio del processo di graficazione fulmini
# prende come argomento il numero di secondi di sleeping
nomescript=${0##*/}
if [ $1 < 300 ]
then
   dormi=300
else
   dormi=$1
fi
while [ 1 ]
do
        python scarica_fulmini.py
        sleep $dormi
done

#!/bin/bash
. /home/meteo/fulmini/conf/variabili_ambiente
. /home/meteo/.bashrc

ieri=$(date --d yesterday +%Y%m%d)
ieri_ini=${ieri}0000
ieri_end=${ieri}2359
ora_daily="10"
ctrlfile_daily=$log_dir/${ieri}_"daily.ctrl"


if [ $(date +%H) -eq $ora_daily ] && [ ! -f "$ctrlfile_daily" ]; then
	Rscript fulmini_periodo.R $ieri_ini $ieri_end $day_dir/${ieri}.dat
	echo "OK, file ${ieri}.dat prodotto" > $ctrlfile_daily
else
	echo "non sono le $ora_daily oppure ho già prodotto il file $ctrlfile_daily --> proseguo"
fi

exit

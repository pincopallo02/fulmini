#!/bin/bash
#===================================================================================
#
#	FILE:  fulmini.sh
#
#	USAGE:  fulmini.sh <data (aaaammgg)> <run (00-12)>
#
#  	DESCRIZIONE: sincronizza la cartella "lampi" del server ftp meteoranew (DPC) con la cartella locale
#				 /archivio/raw. Poi a partire da questa fa varie elaborazioni. Nella cartella lampi sono
#				 presenti i file contenenti i fulmini registrati dalla rete LAMPINET ogni 5 minuti nelle
# 				 ultime 48 ore.
#				 
#				 
#	OPTIONS:  
# 	REQUIREMENTS: lftp, R
#				   
#	NOTE:  Documentation: Biron D. (2009) LAMPINET – Lightning Detection in Italy. In: Betz H.D., Schumann U., Laroche P. (eds)
#						  Lightning: Principles, Instruments and Applications. Springer, Dordrecht 
#						  (https://link.springer.com/content/pdf/10.1007%2F978-1-4020-9079-0_6.pdf)
#
#	AUTHOR:  gpm
#	CREATO:  ago 2018
#   REVISIONI:  ---
#===================================================================================
#
. /home/meteo/fulmini/conf/variabili_ambiente
. /home/meteo/.bashrc

# info per log
orainizio=$(date +%s) && 
echo -e "\n#-----------------------------------------------------------------------------------------"
echo -e "Inizio script giorno-ora: `date`\n"

#-----------------------------------------------------------------------------------------
#Definizione variabili
#-----------------------------------------------------------------------------------------
nomescript=`basename $0 .sh`
aaaammgg=$(date +%Y%m%d)
fulmini_recenti=$rec_dir/fulmini_recenti.dat
ieri=$(date --d yesterday +%Y%m%d)
ieri_ini=${ieri}0000
ieri_end=${ieri}2359

#definisce a che ora (UTC) viene prodotto il file di fulmini giornalieri del giorno prima 
ora_daily="05"
# definisce il nome del file di controllo che serve a registrare l'avvenuta produzione del file giornaliero
ctrlfile_daily=$log_dir/${ieri}_"daily.ctrl"

#-----------------------------------------------------------------------------------------
#Controllo se la procedura è già in esecuzione: se sì esco
#-----------------------------------------------------------------------------------------
export LOCKDIR=$tmp_dir/$nomescript-$aaaammgg.lock && echo "lockdir -----> $LOCKDIR"
T_MAX=5400

if mkdir "$LOCKDIR" 2>/dev/null
then
        echo "acquisito lockdir: $LOCKDIR"
        echo $$ > $LOCKDIR/PID
else
        echo "Script \"$nomescript.sh\" già in esecuzione alle ore `date +%H%M` con PID: $(<$LOCKDIR/PID)"
        echo "controllo durata esecuzione script"
        ps --no-heading -o etime,pid,lstart -p $(<$LOCKDIR/PID)|while read PROC_TIME PROC_PID PROC_LSTART
        do
                SECONDS=$[$(date +%s) - $(date -d"$PROC_LSTART" +%s)]
                echo "------Script \"$nomescript.sh\" con PID $(<$LOCKDIR/PID) in esecuzione da $SECONDS secondi"
                if [ $SECONDS -gt $T_MAX ]
                then
                        echo "$PROC_PID in esecuzione da più di $T_MAX secondi, lo killo"
                        pkill -15 -g $PROC_PID
						result=$?
                        if [ $result -eq 0 ]; then
                            echo `date +"%Y-%m-%d %H:%M:%S"`" > pkill: Processo $PROC_ID killato correttamente"
                        #    exit 1
						else if [ $result -eq 1 ]; then
                            echo `date +"%Y-%m-%d %H:%M:%S"`" > pkill: Nessun processo corrispondente ai parametri indicati. $PROC_ID NON killato correttamente"
                            exit 1
                        else if [ $result -eq 2 ]; then
                            echo `date +"%Y-%m-%d %H:%M:%S"`" > pkill: Errore di sintassi nel comando pkill"
                            exit 1
                        else if [ $result -eq 3 ]; then
                            echo `date +"%Y-%m-%d %H:%M:%S"`" > pkill: ERRORE FATALE esco dallo script"
                            exit 1
                        fi
                      fi
                    fi
                  fi
                fi
        done
        echo "*********************************************************"
        exit
fi
# 
trap "rm -fvr "$LOCKDIR";
rm -fv $tmp_dir/$$"_"*;
echo;
echo \"Fine script `basename $0` alle ore: `date` \";
echo \"#-----------------------------------------------------------------------------------------\";
exit" EXIT HUP INT QUIT TERM

#-----------------------------------------------------------------------------------------
# Sincronizzazione (mirror) cartella locale con ftp remoto e creazione di un file unico
# con tutti i fulmini recenti
#-----------------------------------------------------------------------------------------

# A cosa serve la riga sotto? Dalla man page di lftp: "Close idle connections. By default only with the current server, use -a to close all idle connections"
/usr/bin/lftp -c close -a

# Utilizza lftp per connettersi all'ftp e sincronizzare la cartella locale con quella remota
# (mirror: mirror specified source directory to the target directory) 
# (-v: verbose operation)
# (-e: delete files not present at the source)
# (--only-newer: download only newer files)
/usr/bin/lftp -u $USER,$PASS -e "mirror -v -e --only-newer $REMOTE_DIR $raw_dir; exit" $HOST


#-----------------------------------------------------------------------------------------
# Elaborazioni
#-----------------------------------------------------------------------------------------

# Concateno tutti i file "pentaminutali" in un unico file
cat ${raw_dir}/*.TXT > $fulmini_recenti

# produco il file dei fulmini totali di ieri passando il controllo allo script R
if [ $(date +%H) -eq $ora_daily ] && [ ! -f "$ctrlfile_daily" ]; then
	Rscript /home/meteo/fulmini/bin/functions/fulmini_periodo.R $ieri_ini $ieri_end $day_dir/${ieri}.dat
	echo "OK, file ${ieri}.dat prodotto" > $ctrlfile_daily
else
	echo "non sono le $ora_daily oppure ho già prodotto il file $ctrlfile_daily --> proseguo"
fi

#-----------------------------------------------------------------------------------------
# Mantengo "pulite" la directory /log cancellando i file più vecchi di 15 giorni
#-----------------------------------------------------------------------------------------
find $log_dir/ -type f -name "*.log" -mtime +15 -exec rm -v {} \;
find $log_dir/ -type f -name "*.ctrl" -mtime +15 -exec rm -v {} \;

#-----------------------------------------------------------------------------------------
# Conclusione
#-----------------------------------------------------------------------------------------
orafine=$(date +%s)
differenza=$(($orafine - $orainizio))
echo -e "\nTempo di esecuzione script: $differenza secondi\n"
#logger -is -p user.info "$nomescript terminato con successo!" -t "RSND"
#echo -e "\n******Fine script: `basename $0` alle ore: `date` ************************\n\n"
exit






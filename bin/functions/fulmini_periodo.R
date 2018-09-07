# 
#===================================================================================
#
#	FILE:  fulmini_periodo.R 
#
#	USAGE:  fulmini_periodo.R <dataorainizio (aaaammgghhmm)> <dataorafine (aaaammgghhmm)> <path/nomefileoutput>
#
#  	DESCRIZIONE: legge il file fulmini_recenti.dat da ../archivio/rec
#				 e produce un file solo con i fulmini del periodo specificato.
#				 Ovviamente il periodo richiesto deve essere all'interno del periodo
#				 a cui si riferiscono i fulmini nel file.
#				 
#	OPTIONS:  
# 	REQUIREMENTS: R
#				   
#	NOTE:  
#          
#          Notes:
#          •	
#          •	
#          •	
#          •	
#
#	AUTHOR:  gpm
#	CREATO:  ago 2018
#   REVISIONI:  ---
#===================================================================================
#

# carica le librerie necessarie
#library(...)

# legge i percorsi dalle variabili d'ambiente
dirin  <-Sys.getenv("rec_dir")
dirout <-Sys.getenv("out_dir")

# legge il parametro passato (step)
args <- commandArgs(TRUE)
     ## Se non si passano gli argomenti viene visualizzato l'help
     if(length(args) < 1) {
       args <- c("--help")
     }
     ## Help section
     if("--help" %in% args) {
       cat("
           Script fulmini_periodo.R
      
           Argomenti da passare:
           aaaammgghhmm		- dataora di inizio periodo
           aaaammgghhmm		- dataora di fine periodo
           path/nomefileoutput  - facoltativo: nome del file di output con path completo
           --help              	- stampa questo help
      
           Esempio:
           Rscript  fulmini_periodo.R 201808020000 201808022359 /home/meteo/fulmini/archivio/day/20180802.dat\n")
       q(save="no")
     }

# legge e riformatta dataora
dataorainizio = args[1]
dataorafine = args[2]

yyyyi<-substr(dataorainizio,1,4)
mmi  <-substr(dataorainizio,5,6)
ddi  <-substr(dataorainizio,7,8)
hhi  <-substr(dataorainizio,9,10)
nni  <-substr(dataorainizio,11,12)

yyyyf<-substr(dataorafine,1,4)
mmf  <-substr(dataorafine,5,6)
ddf  <-substr(dataorafine,7,8)
hhf  <-substr(dataorafine,9,10)
nnf  <-substr(dataorafine,11,12)

ini <- paste(yyyyi,'-',mmi,'-',ddi,' ',hhi,':',nni,':00',sep='')
fin <- paste(yyyyf,'-',mmf,'-',ddf,' ',hhf,':',nnf,':59',sep='')

# imposta alcune variabili
nomein='fulmini_recenti.dat'
filein <- paste(dirin,'/',nomein,sep='')

# se non ho passato il nome del file di output lo creo
if (length(args) == 3) {
	fileout = args[3]
} else {
	nomeout=paste(yyyyi,mmi,ddi,hhi,nni,'-',yyyyf,mmf,ddf,hhf,nnf,sep='')
	fileout <- paste(dirout,'/',nomeout,'.dat',sep='')
}

cat("dataorainizio", dataorainizio, "\n ")
cat("dataorafine", dataorafine, "\n ")
cat("ini", ini, "\n ")
cat("fin", fin, "\n ")
cat("nomein", nomein, "\n ")
cat("filein", filein, "\n ")
#cat("nomeout", nomeout, "\n ")
cat("fileout", fileout, "\n ")

#
# ****** Inizio elaborazione *****************************************************************
#

# legge il file da trattare
lampi <- read.table(filein,header = FALSE, colClasses = c("character","character","numeric","numeric","numeric","character","character"), col.names=c("Date", "Time", "Lat", "Lon", "Val", "KA", "CG"))
# aggiunge una colonna con data-ora nel formato giusto per poter fare una selezione basata su data-ora
lampi$DateTime <- as.POSIXct(paste(lampi$Date,lampi$Time))
# estrae il sottoinsieme compreso tra dataorainizio e dataorafine e...
lampi_ieri <- subset(lampi, DateTime>=ini & DateTime<=fin, select = c("Date", "Time", "Lat", "Lon", "Val", "KA", "CG"))
str(lampi_ieri) 
# ...lo scrive su file
write.table(lampi_ieri,file=fileout, quote=F, row.names=F, col.names=F)



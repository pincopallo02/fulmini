# -*- coding: utf-8 -*-
"""
Created on Tue Oct  2 10:12:46 2018

@author: mmussin
"""

# prendo i fulmini da lampinet
# meccanismo di alimentazione:
# 1. mi collego a meteoranew tramite proxy
# 2. verifico l'esistenza del file del giorno in corso AAAAMMGG.dat
# 3. se il file esiste, leggo i dati e vedo quando è l'ultimo
# 4. determino l'elenco dei file da leggere
# 5. ciclo sui file:
#    -> li trasferisco in locale
#    -> leggo il df
#    -> appendo il df
#    -> scrivo il nuovo df
# 6. copio su minio di ARPA
# NOTA: too many I/O may slower the process
# 0. Inizializzazioni
import matplotlib
matplotlib.use('Agg')
import os
import datetime as dt
import pandas as pd
from ftplib import FTP
from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
import warnings
import matplotlib.cbook
from minio import Minio
warnings.filterwarnings("ignore",category=matplotlib.cbook.mplDeprecation)
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
HOST='meteoranew.protezionecivile.it'
USER='lombardia'
PASS=os.getenv('FTP_PASS')
REMOTE_DIR='/lampi'
ftp=FTP()
# funzione di graficazione fulmini: legge da file e plotta il contenuto del file
def gf(nomefile):
    print('elaboro il giorno ' + nomefile)
    fig = plt.figure(num=None, figsize=(22, 16) )
   # read file input con dati
    df=pd.read_csv(filepath_or_buffer=nomefile,sep='\s+',names=['date','time','lat','lon','int','unit','ground'],parse_dates={'datetime':['date','time']})
    h=0
    colori=['#8B008B','#C71585','#FF4500','#FFA500','#FFD700','#FFFF00']
    ax=fig.add_subplot(111)
    m = Basemap(projection='merc',llcrnrlat=36,urcrnrlat=48.2,llcrnrlon=6,urcrnrlon=18.6,resolution='i', epsg=4326,ax=ax)
    m.drawcoastlines()
    m.drawrivers()
    m.shadedrelief(scale=0.9)
    plt.title("Fulmini del giorno " + nomefile.split('.')[0]+' alle '+dt.datetime.utcnow().strftime('%H:%M UTC')+' (ultimo dato:'+df.datetime.iloc[-1].strftime('%H:%M')+')')
    print('inizio plottaggio '+ nomefile)
    df[(df.lat>35) & (df.lat<47) & (df.lon>6.5) & (df.lon<18.5)]
    numero_fulmini=[]
    for c in colori:
       lats=df.lat[(df.datetime.dt.hour>=h) & (df.datetime.dt.hour<=h+4-1) & (df.ground=='G')]
       lons=df.lon[(df.datetime.dt.hour>=h) & (df.datetime.dt.hour<=h+4-1) & (df.ground=='G')]
       x,y=m(lons,lats)
       m.scatter(x,y,color=c,marker="+")
       numero_fulmini.append(df.lat[(df.datetime.dt.hour>=h) & (df.datetime.dt.hour<=h+4-1) & (df.ground=='G')].count())
       h+=4
    axin=inset_axes(m.ax,width="12%",height="12%",loc=3)
    axin.bar([4,8,12,16,20,24],numero_fulmini, width=2,color=colori,tick_label=[4,8,12,16,20,24])
    axin.tick_params(axis='y',direction='in')          
    axin.grid(b=True, axis='y')
    plt.savefig(nomefile.split('.')[0]+'.png',bbox_inches='tight')         
    plt.show()
# 1.
ftp.connect(host='proxy2.arpa.local',port=2121)
ftp.set_debuglevel(0)
ftp.login(USER+'@'+HOST,PASS)
elenco_file=ftp.nlst(REMOTE_DIR)
#print(elenco_file)
# se il file esiste ne leggo il contenuto
curdate=dt.datetime.utcnow()
nomefile=curdate.strftime('%Y%m%d')+'.dat'
nomeimg=nomefile.split('.')[0]+'.png'
file_controllo='file_controllo.txt'
try:
    cntl=pd.read_csv(filepath_or_buffer=file_controllo,names=['nomefile'])
except:
    cntl=pd.DataFrame()
# 2.

    #lastdata=df.date.iloc[-1]
# 3.4.5. elenco file contiene l'elenco dei file su meteora: devo scaricare solo quelli che non ho già scaricato  
for nf in elenco_file:
    comando='RETR '+ nf
    fi=nf[16:24] #fi contiene solo AAAAMMGG
    if ((fi == curdate.strftime('%Y%m%d')) & (not(cntl.nomefile.str.contains(nf).any()))):
        fhandle=open(curdate.strftime('%Y%m%d')+'.dat','a')
        ftp.retrbinary(comando,fhandle.write)
        fhandle.close()
        cntl=cntl.append({'nomefile': nf},ignore_index=True)
cntl.to_csv(path_or_buf=file_controllo, header=False,index=False)
try: 
    gf(nomefile)
except:
    print( 'ERRORE: file '+ nomefile + ' non trovato')    
# trasferimento a minio    
minioClient=Minio('10.10.99.135:9000',access_key='ACCESS_KEY',secret_key='SECRET_KEY',secure=False)
try:
    with open(nomeimg,'rb') as file_data:
        file_stat=os.stat(nomeimg)
        print(minioClient.put_object('lampinet',nomeimg,file_data,file_stat.st_size))
except:
    print ('something went wrong')


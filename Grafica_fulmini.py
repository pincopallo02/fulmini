# -*- coding: utf-8 -*-

from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import warnings
import matplotlib.cbook
import datetime as dt
import os
nomefileout='C:\\Users\\mmussin\\Pictures\\'
warnings.filterwarnings("ignore",category=matplotlib.cbook.mplDeprecation)
from mpl_toolkits.axes_grid1.inset_locator import inset_axes

print('inizio lettura dati')
def gf(nomefile):
    print('elaboro il giorno ' + nomefile)
    fig = plt.figure(num=None, figsize=(22, 16) )
   # read file input con dati
    df=pd.read_csv(filepath_or_buffer='.\\data\\'+nomefile+'.dat',sep='\s+',names=['date','time','lat','lon','int','unit','ground'],parse_dates=['date','time'])
    h=0
    colori=['#8B008B','#C71585','#FF4500','#FFA500','#FFD700','#FFFF00']
    ax=fig.add_subplot(111)
    m = Basemap(projection='merc',llcrnrlat=35,urcrnrlat=47,llcrnrlon=6.5,urcrnrlon=18.5,resolution='i', epsg=4326,ax=ax)
    m.drawcoastlines()
    m.drawrivers()
    m.shadedrelief(scale=0.9)
    plt.title("Fulmini del giorno " + nomefile)
    print('inizio plottaggio '+ nomefile)
    df[(df.lat>35) & (df.lat<47) & (df.lon>6.5) & (df.lon<18.5)]
    numero_fulmini=[]
    for c in colori:
       lats=df.lat[(df.time.dt.hour>=h) & (df.time.dt.hour<=h+4-1) & (df.ground=='G')]
       lons=df.lon[(df.time.dt.hour>=h) & (df.time.dt.hour<=h+4-1) & (df.ground=='G')]
       x,y=m(lons,lats)
       m.scatter(x,y,color=c,marker="+")
       numero_fulmini.append(df.lat[(df.time.dt.hour>=h) & (df.time.dt.hour<=h+4-1) & (df.ground=='G')].count())
       h+=4
    axin=inset_axes(m.ax,width="20%",height="20%",loc=3)
    axin.bar([4,8,12,16,20,24],numero_fulmini, width=2,color=colori,tick_label=[4,8,12,16,20,24])
    axin.tick_params(axis='y',direction='in')          
    axin.grid(b=True, axis='y')
    plt.savefig(nomefileout+nomefile+'.png',bbox_inches='tight')         
    plt.show()
l=os.listdir('.\\data')
li=[x.split('.')[0] for x in l]
for nf in li:
    gf(nf)
   

    
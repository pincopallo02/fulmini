FROM conda/miniconda2
RUN apt-get update
RUN apt-get -y install libgl1-mesa-glx
RUN conda install Basemap
RUN conda install pandas
RUN conda install Minio
WORKDIR /usr/src/myapp
COPY *.py ./
RUN mkdir templates
COPY templates/* templates/
CMD ["python", "scarica_fulmini.py"]

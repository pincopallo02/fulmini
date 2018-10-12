FROM conda/miniconda2
RUN apt-get update
RUN apt-get -y install libgl1-mesa-glx
RUN conda install Basemap
RUN conda install pandas
RUN pip install minio
RUN pip install Pillow
WORKDIR /usr/src/myapp
COPY *.py ./
RUN mkdir templates
COPY templates/* templates/
#CMD ["python", "scarica_fulmini.py"]

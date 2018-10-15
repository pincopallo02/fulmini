FROM conda/miniconda2
RUN apt-get update
RUN apt-get -y install libgl1-mesa-glx
RUN apt-get -y install vim
RUN conda install Basemap
RUN conda install pandas
RUN pip install minio
RUN pip install Pillow
WORKDIR /usr/src/myapp
COPY *.py ./
COPY *.sh ./
RUN mkdir templates
RUN touch file_controllo.txt
COPY templates/* templates/
CMD ["./launch.sh", "600"]

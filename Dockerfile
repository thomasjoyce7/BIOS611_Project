FROM rocker/verse
RUN apt update && apt install -y man-db && rm -rf /var/lib/apt/lists/*
RUN yes | unminimize
RUN apt update && apt install git
RUN R -e "install.packages(\"tinytex\")"
RUN R -e "tinytex::install_tinytex()"
RUN apt update -y && apt install -y python3-pip
RUN pip3 install jupyter jupyterlab
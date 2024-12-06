# Use rocker/verse as base image (R + RStudio Server)
FROM rocker/verse

# Install necessary utilities and clear apt cache
RUN apt update && apt install -y \
    man-db \
    git \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install Python libraries via pip3
RUN pip3 install --no-cache-dir \
    pandas \
    seaborn \
    matplotlib 

# Install R packages
RUN R -e "install.packages('tinytex')"

# Install booktabs using existing LaTeX distribution
RUN R -e "tinytex::tlmgr_install('booktabs')"

# Install additional R packages for time series analysis
RUN R -e "install.packages('forecast', repos='http://cran.r-project.org')"

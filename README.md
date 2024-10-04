BIOS 611 Project
=====================================================

Hi, this is my 611 Data Science Project. 
I will analyze the Berlin Marathon dataset. 

Getting Started
=====================================================

Build the docker image by typing:
```
docker build . -t 611-project
```

Then start an RStudio by typing:
```
docker run -d -e PASSWORD=<your-password> --rm -p 8787:8787 -v "$(pwd):/home/rstudio/project"
```

Once the Rstudio is running connect to it by visiting
https://localhost:8787 in your browser. 

To build the final report, visit the terminal in RStudio and type

```
make report.pdf
```
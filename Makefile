.PHONY: clean
.PHONY: init

init:
	mkdir -p derived_data
	mkdir -p figures

clean:
	rm -rf derived_data
	rm -rf figures
	mkdir -p derived_data
	mkdir -p figures
	
# Create a tidied runners dataset by removing runners without times and 
# specifying the exact ranges for each age group
derived_data/runners_tidied.csv: source_data/Berlin_Marathon_data_1974_2019.csv tidy_marathon_data.R
	Rscript tidy_marathon_data.R

report.pdf:
	R -e "rmarkdown::render(\"report.Rmd\", output_format=\"pdf_document\")"
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

report.pdf:
	R -e "rmarkdown::render(\"report.Rmd\", output_format=\"pdf_document\")"
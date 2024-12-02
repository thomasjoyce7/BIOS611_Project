.PHONY: clean
.PHONY: init

init:
	mkdir -p derived_data
	mkdir -p joined_data
	mkdir -p figures
	mkdir -p tables

clean:
	rm -rf derived_data
	rm -rf joined_data
	rm -rf figures
	rm -rf tables
	mkdir -p derived_data
	mkdir -p joined_data
	mkdir -p figures
	mkdir -p tables
	
# Create a tidied runners dataset by removing runners without times and 
# specifying the exact ranges for each age group
derived_data/runners_tidied.csv: source_data/Berlin_Marathon_data_1974_2019.csv tidy_marathon_data.R
	Rscript tidy_marathon_data.R

# Create a tidied weather dataset by changing the temperatures from celcius to farenheit
# and renaming the columns 
derived_data/weather_tidied.csv: source_data/Berlin_Marathon_weather_data_since_1974.csv tidy_weather_data.R
	Rscript tidy_weather_data.R
	
# Create a dataset with runners and weather by left joining runners_tidied and weather_tidied
joined_data/runner_weather_data.csv: derived_data/runners_tidied.csv derived_data/weather_tidied.csv join_runner_weather_data.R
	Rscript join_runner_weather_data.R
	
# Create plots for total runners each year, total runners by gender each year, and total
# runners by age each year
figures/runners_per_year.png figures/annual_runners_by_gender.png figures/annual_runners_by_age.png: derived_data/runners_tidied.csv runner_count_figures.R
	Rscript runner_count_figures.R
	
# Create plots for finishing times
figures/avg_annual_times.png figures/avg_times_by_gender.png figures/avg_times_by_age.png figures/winning_times_by_gender.png figures/marathon_time_distributions.png: derived_data/runners_tidied.csv runner_times_figures.R
	Rscript runner_times_figures.R
	
# Create weather figures for annual temperature trends, annual precipitation trends, and 
# hours of sunshine vs. clouds
figures/annual_temp_trends.png figures/annual_precipitation_trends.png figures/annual_sky_conditions.png: derived_data/weather_tidied.csv weather_figures.R
	Rscript weather_figures.R
	
# Create heatmap of feature correlations
figures/correlation_heatmap.png: joined_data/runner_weather_data.csv feature_correlation_heatmap.py
	python3 feature_correlation_heatmap.py

# Create figures for winning male time series models
figures/male_ts.png figures/male_ts_covariates.png: derived_data/runners_tidied.csv derived_data/weather_tidied.csv male_time_series.R
	Rscript male_time_series.R
	
# Create tables for winning male time series models
tables/male_ts_table.rds tables/male_ts_covariates_table.rds: derived_data/runners_tidied.csv derived_data/weather_tidied.csv male_time_series.R
	Rscript male_time_series.R	
	
# Create figures for winning female time series models
figures/female_ts.png figures/female_ts_covariates.png: derived_data/runners_tidied.csv derived_data/weather_tidied.csv female_time_series.R
	Rscript female_time_series.R

# Create tables for winning female time series models
tables/female_ts_table.rds tables/female_ts_covariates_table.rds: derived_data/runners_tidied.csv derived_data/weather_tidied.csv female_time_series.R
	Rscript female_time_series.R	

# Write report to pdf
report.pdf: figures/runners_per_year.png figures/avg_annual_times.png figures/annual_runners_by_age.png figures/avg_times_by_age.png figures/marathon_time_distributions.png figures/winning_times_by_gender.png figures/annual_precipitation_trends.png figures/annual_temp_trends.png figures/correlation_heatmap.png figures/male_ts.png tables/male_ts_table.rds figures/male_ts_covariates.png tables/male_ts_covariates_table.rds figures/female_ts.png tables/female_ts_table.rds figures/female_ts_covariates.png tables/female_ts_covariates_table.rds
	R -e "rmarkdown::render(\"report.Rmd\", output_format=\"pdf_document\")"
library(tidyverse)
library(readr)

runner_data <- read_csv("derived_data/runners_tidied.csv")

weather_data <- read_csv("derived_data/weather_tidied.csv")

runner_weather_data <- left_join(x=runner_data, y=weather_data, by="Year")

write.csv(runner_weather_data, file="joined_data/runner_weather_data.csv", row.names=FALSE)



library(tidyverse)

library(readr)
weather_data <- read_csv("source_data/Berlin_Marathon_weather_data_since_1974.csv")

weather_data <- weather_data %>% rename(Year = YEAR)

print(problems(weather_data))

print("Change the temperature columns from degrees celcius to degrees farenheit.")

celcius_to_farenheit <- function(celcius){
  farenheit <- (9/5)*celcius + 32
  farenheit
}

weather_data$AVG_TEMP_F <- celcius_to_farenheit(weather_data$AVG_TEMP_C)

weather_data$MIN_TEMP_F <- celcius_to_farenheit(weather_data$MIN_TEMP_C)

weather_data$MAX_TEMP_F <- celcius_to_farenheit(weather_data$MAX_TEMP_C)

tidied_weather_data <- weather_data %>% select(-AVG_TEMP_C, -MIN_TEMP_C, -MAX_TEMP_C)

write.csv(tidied_weather_data, file="derived_data/weather_tidied.csv", row.names=FALSE)



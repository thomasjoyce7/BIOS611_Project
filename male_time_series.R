library(forecast)
library(readr)
library(tidyverse)
library(hms)

runner_data <- read_csv("derived_data/runners_tidied.csv")

weather_data <- read_csv("derived_data/weather_tidied.csv")

male_winning_times <- runner_data %>% filter(Gender == "Male") %>% group_by(Year) %>% summarize(Time = min(Time))

male_ts_data <- merge(weather_data,male_winning_times,by="Year")
male_ts_data$Time <- as_hms(male_ts_data$Time)  


# Add winning times manually for when the year is missing 
years <- data.frame(Year = seq(1974,2019,by=1))

male_missing_years <- setdiff(years$Year, male_ts_data$Year)
male_missing_years
male_missing_df <- data.frame(Year = male_missing_years, matrix(NA, nrow = length(male_missing_years), ncol = ncol(male_ts_data) - 2), 
                         Time = c(as_hms("02:20:02"),as_hms("02:16:48")))
colnames(male_missing_df) <- colnames(male_ts_data)
male_ts_data <- rbind(male_ts_data, male_missing_df)
male_ts_data <- male_ts_data %>% arrange(Year)



# Model without covariates ----------------------------------------------

# Time Series Analysis for Male Winning Times
male_winners_ts <- ts(male_ts_data$Time, start = c(1974), frequency = 1)

set.seed(123)
model_1 <- auto.arima(male_winners_ts, trace=TRUE)
summary(model_1)
male_forecasted_times <- forecast(model_1, h = 5)

seconds_to_period(round(male_forecasted_times$mean))

# Save plot as png
png("figures/male_ts.png", width=882, height=457, res=144)

# Plot the forecast
par(mar = c(5, 6, 4, 2) + 0.1, mgp = c(4, 1, 0))

plot(male_forecasted_times, 
     main = "Forecast of Berlin Marathon Male Winning Times", 
     ylab = "Winning Time",
     yaxt = "n")

# Get the y-axis values
y_values <- seq(6000, 10500, by = 900)  # Retrieve default y-axis tick positions

# Convert y-axis values from seconds to hh:mm:ss
hours <- y_values %/% 3600
minutes <- (y_values %% 3600) %/% 60
seconds <- y_values %% 60
y_labels <- sprintf("%01d:%02d:%02d", hours, minutes, seconds)

# Add custom y-axis
axis(2, at = y_values, labels = y_labels, las = 1)

mtext("Year", side = 1, line = 2)
mtext("Using ARIMIA model without covariates",side=3, line=0.4)

dev.off()

# Model with covariates -------------------------------------------------------------------------
covariates <- as.matrix(male_ts_data[,c("PRECIP_mm","SUNSHINE_hrs","CLOUD_hrs","MAX_TEMP_F")])
model_2 <- auto.arima(male_winners_ts, xreg=covariates)  
summary(model_2)

future_covariates <- data.frame(PRECIP_mm = c(0.0,2.1,0.0,1.3,0.0), 
                                SUNSHINE_hrs = c(6.0,4.5,6.5,5.0,6.0),
                                CLOUD_hrs = c(4.0,5.5,3.5,5.0,4.0),
                                MAX_TEMP_F = c(68,65,68,66,66))
future_covariates <- as.matrix(future_covariates)

forecast_with_covariates <- forecast(model_2, xreg=future_covariates, h=5)

seconds_to_period(round(forecast_with_covariates$mean))


# Save plot as png
png("figures/male_ts_covariates.png", width=882, height=457, res=144)

# Plot the forecast
par(mar = c(5, 6, 4, 2) + 0.1, mgp = c(4, 1, 0))

plot(forecast_with_covariates, 
     main = "Forecast of Berlin Marathon Male Winning Times",
     ylab = "Winning Time",
     yaxt = "n")

# Get the y-axis values
y_values <- seq(6000, 10500, by = 900)  # Retrieve default y-axis tick positions

# Convert y-axis values from seconds to hh:mm:ss
hours <- y_values %/% 3600
minutes <- (y_values %% 3600) %/% 60
seconds <- y_values %% 60
y_labels <- sprintf("%01d:%02d:%02d", hours, minutes, seconds)

# Add custom y-axis
axis(2, at = y_values, labels = y_labels, las = 1)

mtext("Year", side = 1, line = 2)
mtext("Using ARIMIA model with covariates",side=3, line=0.4)

dev.off()



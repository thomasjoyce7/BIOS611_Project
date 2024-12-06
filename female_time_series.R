library(forecast)
library(readr)
library(tidyverse)
library(hms)
library(knitr)

runner_data <- read_csv("derived_data/runners_tidied.csv")

weather_data <- read_csv("derived_data/weather_tidied.csv")

runner_counts <- runner_data %>% count(Year)
runner_counts <- runner_counts %>% rename(Count = n)


female_winning_times <- runner_data %>% filter(Gender == "Female") %>% group_by(Year) %>% summarize(Time = min(Time))

female_ts_data <- merge(weather_data,merge(runner_counts, female_winning_times,by="Year"),by="Year")
female_ts_data$Time <- as_hms(female_ts_data$Time)


# Add winning times manually for when the year is missing 
years <- data.frame(Year = seq(1974,2019,by=1))

female_missing_years <- setdiff(years$Year, female_ts_data$Year)
female_missing_years
female_missing_df <- data.frame(Year = female_missing_years, matrix(NA, nrow = length(female_missing_years), ncol = ncol(female_ts_data) - 2), 
                                Time = c(as_hms("03:04:12"),as_hms("02:57:09"),as_hms("02:47:18"),as_hms("02:25:15"),as_hms("02:20:14")))
colnames(female_missing_df) <- colnames(female_ts_data)
female_ts_data <- rbind(female_ts_data, female_missing_df)
female_ts_data <- female_ts_data %>% arrange(Year)


# Model without covariates -----------------------------------------------------

# Time Series Analysis for Female Winning Times
female_winners_ts <- ts(female_ts_data$Time, start = c(1974), frequency = 1)

set.seed(123)
model_1 <- auto.arima(female_winners_ts)
summary(model_1)
female_forecasted_times <- forecast(model_1, h = 5)

seconds_to_period(round(female_forecasted_times$mean))

# Save plot as png
png("figures/female_ts.png", width=882, height=457, res=144)

# Plot the forecast
par(mar = c(5, 6, 4, 2) + 0.1, mgp = c(4, 1, 0))

plot(female_forecasted_times, 
     main = "Forecast of Berlin Marathon Female Winning Times", 
     ylab = "Winning Time",
     yaxt = "n")

# Get the y-axis values
y_values <- seq(6000, 16000, by = 1800)  # Retrieve default y-axis tick positions

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

# Create and save table comparing forecasted winning times to actual winning times
actual_winning_times <- c(NA, "02:20:09","02:15:37","02:11:53", "02:16:42")
actual_winning_times <- as_hms(actual_winning_times)

table1_data <- data.frame(Year = c(2020, 2021, 2022, 2023, 2024), Actual = actual_winning_times, Forecast = hms(round(female_forecasted_times$mean,0)))

table1_data$Error = as.numeric(table1_data$Actual) - as.numeric(table1_data$Forecast)
table1_data$Error = hms(table1_data$Error)

# Calculate MAE
MAE <- mean(abs(as.numeric(table1_data$Error)), na.rm = TRUE)
MAE <- hms(MAE)

# Format the MAE for display in the caption
MAE_text <- paste("(MAE =", format(MAE,"%H:%M:%S"),")")

# Create the table with the caption including MAE
table1 <- kable(table1_data, caption = paste("Comparison of actual vs. forecasted female winning times for the ARIMA model without covariates. ", MAE_text))

saveRDS(table1, file = "tables/female_ts_table.rds")


# Model with covariates ------------------------------------------------
covariates <- as.matrix(female_ts_data[,c("PRECIP_mm","SUNSHINE_hrs","CLOUD_hrs","MAX_TEMP_F")])

set.seed(123)
model_2 <- auto.arima(female_winners_ts, xreg=covariates)  
summary(model_2)

future_covariates <- data.frame(PRECIP_mm = c(0.0,2.1,0.0,1.3,0.0), 
                                SUNSHINE_hrs = c(6.0,4.5,6.5,5.0,6.0),
                                CLOUD_hrs = c(4.0,5.5,3.5,5.0,4.0),
                                MAX_TEMP_F = c(68,65,68,66,66))
future_covariates <- as.matrix(future_covariates)

forecast_with_covariates <- forecast(model_2, xreg=future_covariates, h=5)

seconds_to_period(round(forecast_with_covariates$mean))


# Save plot as png
png("figures/female_ts_covariates.png", width=882, height=457, res=144)

# Plot the forecast
par(mar = c(5, 6, 4, 2) + 0.1, mgp = c(4, 1, 0))

plot(forecast_with_covariates, 
     main = "Forecast of Berlin Marathon Female Winning Times",
     ylab = "Winning Time",
     yaxt = "n")

# Get the y-axis values
y_values <- seq(6000, 16000, by = 1800)  # Retrieve default y-axis tick positions

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


# Create and save table comparing forecasted winning times to actual winning times
actual_winning_times <- c(NA, "02:20:09","02:15:37","02:11:53", "02:16:42")
actual_winning_times <- as_hms(actual_winning_times)

table2_data <- data.frame(Year = c(2020, 2021, 2022, 2023, 2024), Actual = actual_winning_times, Forecast = hms(round(forecast_with_covariates$mean,0)))

table2_data$Error = as.numeric(table2_data$Actual) - as.numeric(table2_data$Forecast)
table2_data$Error = hms(table2_data$Error)

# Calculate MAE
MAE2 <- round(mean(abs(as.numeric(table2_data$Error)), na.rm = TRUE),2)
MAE2 <- hms(MAE2)

# Format the MAE for display in the caption
MAE2_text <- paste("(MAE =", format(MAE2,"%H:%M:%S"),")")

# Create the table with the caption including MAE
table2 <- kable(table2_data, caption = paste("Comparison of actual vs. forecasted female winning times for the ARIMA model with covariates. ", MAE2_text))

saveRDS(table2, file = "tables/female_ts_covariates_table.rds")




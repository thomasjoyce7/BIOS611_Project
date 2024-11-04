library(tidyverse)

library(readr)
weather_data <- read_csv("derived_data/weather_tidied.csv")


long_data1 <- weather_data %>% select(Year, MIN_TEMP_F, AVG_TEMP_F, MAX_TEMP_F) %>% pivot_longer(cols = c(MIN_TEMP_F, AVG_TEMP_F, MAX_TEMP_F), 
                          names_to = "Temp Type", values_to = "Temperature")

fig1 <- ggplot(long_data1, aes(x = Year, y = Temperature, color = `Temp Type`, group = `Temp Type`)) +
  geom_line(size = 0.3) +
  labs(title = "Berlin Marathon Annual Temperautre Trends", x = "Year", y = "Temperature (°F)") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size=6))+
  scale_color_manual(values = c("MIN_TEMP_F" = "blue", "AVG_TEMP_F" = "green", "MAX_TEMP_F" = "red"),
                     labels = c("MIN_TEMP_F" = "Mininum", "AVG_TEMP_F" = "Average", "MAX_TEMP_F" = "Maximum"))+
  scale_x_continuous(breaks = seq(1974, 2019, by = 1))
ggsave("figures/annual_temp_trends.png", plot=fig1, width=9, height=5)


fig2 <- ggplot(weather_data, aes(x = Year, y = PRECIP_mm)) + 
  geom_line() +
  labs(title = "Berlin Marathon Annual Precipitation", x = "Year", y = "Precipitation (mm)") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size=6)) +
  scale_x_continuous(breaks = seq(1974, 2019, by = 1))
ggsave("figures/annual_precipitation_trends.png", plot=fig2, width=9, height=5)


long_data2 <- weather_data %>% select(Year, SUNSHINE_hrs, CLOUD_hrs) %>% pivot_longer(cols = c(SUNSHINE_hrs, CLOUD_hrs), 
                                                                                                 names_to = "Weather", values_to = "Hours")
fig3 <- ggplot(long_data2, aes(x = Year, y = Hours, color = Weather, group = Weather)) +
  geom_line(size = 0.3) +
  labs(title = "Berlin Marathon Annual Sunshine vs. Clouds Hours", x = "Year", y = "Daily Hours") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size=6))+
  scale_color_manual(values = c("SUNSHINE_hrs" = "darkorange", "CLOUD_hrs" = "blue"),
                     labels = c("SUNSHINE_hrs" = "Sunshine", "CLOUD_hrs" = "Clouds"))+
  scale_x_continuous(breaks = seq(1974, 2019, by = 1))
ggsave("figures/annual_sky_conditions.png", plot=fig3, width=9, height=5)





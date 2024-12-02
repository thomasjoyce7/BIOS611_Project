library(tidyverse)
library(hms)

library(readr)
runner_data <- read_csv("derived_data/runners_tidied.csv")


avg_annual_times <- runner_data %>% group_by(Year) %>% summarize(mean(Time))
avg_annual_times <- avg_annual_times %>% rename(`Avg Time`=`mean(Time)`)  

fig1 <- ggplot(avg_annual_times, aes(x = Year, y = `Avg Time`)) +
  geom_point() +
  scale_y_continuous(
    labels = function(y) format(as_hms(y)),  
    breaks = seq(as.numeric(as_hms("03:20:00")), as.numeric(as_hms("04:20:00")), by = 10*60),
    limits = c(as.numeric(as_hms("03:20:00")), as.numeric(as_hms("04:20:00")))) +
  labs(title = "Berlin Marathon Average Finishing Times 1974 to 2019", x = "Year", y = "Average Finishing Time") +
  scale_x_continuous(breaks = seq(1974, 2019, by = 1)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 6))
ggsave("figures/avg_annual_times.png", plot=fig1, width = 8, height = 5)


avg_times_by_gender <- runner_data %>% group_by(Year,Gender) %>% summarize(mean(Time))
avg_times_by_gender <- avg_times_by_gender %>% rename(`Avg Time`=`mean(Time)`)

fig2 <- ggplot(avg_times_by_gender, aes(x = Year, y = `Avg Time`, color = Gender, group = Gender)) +
  geom_line() +
  scale_y_continuous(
    labels = function(y) format(as_hms(y)),
    breaks = seq(as.numeric(as_hms("03:00:00")), as.numeric(as_hms("04:50:00")), by = 10*60),
    limits = c(as.numeric(as_hms("03:00:00")), as.numeric(as_hms("04:50:00")))) +
  labs(title = "Berlin Marathon Average Annual Finishing Times by Gender", x = "Year", y = "Average Finishing Time") +
  scale_x_continuous(breaks = seq(1974, 2019, by = 1)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 6))
ggsave("figures/avg_times_by_gender.png", plot=fig2, width = 8, height = 5)



avg_times_by_age <- runner_data %>% group_by(Year,Age) %>% summarize(mean(Time))
avg_times_by_age <- avg_times_by_age %>% rename(`Avg Time`=`mean(Time)`)

fig3 <- ggplot(avg_times_by_age, aes(x = Year, y = `Avg Time`, color = Age, group = Age)) +
  geom_line() +
  scale_y_continuous(
    labels = function(y) format(as_hms(y)),
    breaks = seq(as.numeric(as_hms("03:00:00")), as.numeric(as_hms("06:00:00")), by = 20*60),
    limits = c(as.numeric(as_hms("03:00:00")), as.numeric(as_hms("06:00:00")))) +
  labs(title = "Berlin Marathon Average Annual Finishing Times by Age", x = "Year", y = "Average Finishing Time") +
  scale_x_continuous(breaks = seq(1974, 2019, by = 1)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 6))
ggsave("figures/avg_times_by_age.png", plot=fig3, width = 8, height = 6)



winning_times <- runner_data %>% group_by(Year,Gender) %>% summarize(min(Time))
winning_times <- winning_times %>% rename(`Winning Time`=`min(Time)`)

fig4 <- ggplot(winning_times, aes(x = Year, y = `Winning Time`, color = Gender, group = Gender)) +
  geom_line() +
  scale_y_continuous(
    labels = function(y) format(as_hms(y)),
    breaks = seq(as.numeric(as_hms("02:00:00")), as.numeric(as_hms("04:00:00")), by = 10*60),
    limits = c(as.numeric(as_hms("02:00:00")), as.numeric(as_hms("04:00:00")))) +
  labs(title = "Berlin Marathon Winning Times by Gender", x = "Year", y = "Winning Time") +
  scale_x_continuous(breaks = seq(1974, 2019, by = 1)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 6))
ggsave("figures/winning_times_by_gender.png", plot=fig4, width = 8, height = 5)



summary_stats <- runner_data %>%
  group_by(Gender) %>%
  summarize(mean_time = mean(Time), sd_time = sd(Time), count = length(Gender))

fig5 <- ggplot(runner_data, aes(x = Time, y = after_stat(density))) +
  geom_histogram(aes(color = Gender), binwidth = 10, alpha = 0.5, position = "identity") +
  geom_density(adjust = 4) + 
  facet_wrap(~ Gender) +  
  labs(title = "Distributions of Marathon Times by Gender", x = "Time", y = "Probability Density") +
  scale_x_continuous(
    labels = function(x) format(as_hms(x)),
    breaks = seq(as.numeric(as_hms("02:00:00")), as.numeric(as_hms("08:00:00")), by = 180*60)) +
  scale_y_continuous(breaks=c(0,0.0001,0.0002,0.0003),labels=c("0","0.0001","0.0002","0.0003"))+
  theme(legend.position = "none") +  
  geom_text(data = summary_stats, aes(x = Inf, y = Inf, 
                              label = paste("Mean:", as_hms(round(mean_time, 0)), 
                                            "\nSD:", as_hms(round(sd_time, 0)),
                                            "\nn =", count)),
            hjust = 1.2, vjust = 1.2, size = 3.5) 
ggsave("figures/marathon_time_distributions.png", plot=fig5, width = 8, height = 5)

 

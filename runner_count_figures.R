library(tidyverse)

library(readr)
runner_data <- read_csv("derived_data/runners_tidied.csv")

fig1 <- ggplot(runner_data, aes(x=factor(Year))) +
  geom_bar(stat="count",fill="blue") +
  labs(title="Berlin Marathon Runners per Year 1974 to 2019", x="Year", y="Number of Runners")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggsave("figures/runners_per_year.png", plot=fig1, width=8, height=6)

runners_by_gender <- runner_data %>% group_by(Year, Gender) %>% summarise(Count = n())

fig2 <- ggplot(runners_by_gender, aes(x = Year, y = Count, color = Gender, Group = Gender)) + 
  geom_line() +
  labs(title = "Berlin Marathon Runners Each Year by Gender", x = "Year", y = "Number of Runners") +
  scale_color_manual(values = c("darkblue", "darkgreen")) + 
  theme_minimal() +
  theme(plot.background = element_rect(fill = "white", color = NA),  
    panel.background = element_rect(fill = "white", color = NA))+
  scale_x_continuous(breaks = seq(1974, 2019, by = 5))
ggsave("figures/annual_runners_by_gender.png", plot=fig2, width=8, height=6)

runners_by_age <- runner_data %>% filter(Age!="Unknown") %>% group_by(Year, Age) %>% summarise(Count = n())

fig3 <- ggplot(runners_by_age, aes(x = Year, y = Count, color = Age, Group = Age)) + 
  geom_line() +
  labs(title = "Berlin Marathon Runners Each Year by Age", x = "Year", y = "Number of Runners") +
  scale_x_continuous(breaks = seq(1974, 2019, by = 5))
ggsave("figures/annual_runners_by_age.png", plot=fig3, width = 8, height = 6)




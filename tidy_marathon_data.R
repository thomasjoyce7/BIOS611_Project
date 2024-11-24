library(tidyverse)

library(readr)
runner_data <- read_csv("source_data/Berlin_Marathon_data_1974_2019.csv")

runner_data <- runner_data %>% 
  rename(Year = YEAR, Country = COUNTRY, Gender = GENDER, Age = AGE, Time = TIME)

print(problems(runner_data))

runner_data %>% count(Year)
print("No observations were recorded for 1978 or 1980.")

runner_data %>% filter(Gender=="female") %>% count(Year)
print("No female observations were recorded in 1976, 1978, 1980, 1994, or 2019.")

runner_data %>% filter(is.na(Year))
runner_data %>% filter(is.na(Country))
runner_data %>% filter(is.na(Gender))
runner_data %>% filter(is.na(Age))
runner_data %>% filter(is.na(Time))

print("The only columns with missing data are Country and Age. The only year with Country data is 2019. Instead of removing all the runners without a country, I will change missing values for Country to Unknown.")

distinct_rows <- runner_data %>% distinct()

cat(sprintf("There are %d distinct rows and %d total rows in the original dataset.\n (%d duplicates)",
            nrow(runner_data %>% distinct()), nrow(runner_data), nrow(runner_data)-nrow(runner_data %>% distinct())))

print("The non-distinct rows likely still represent distinct runners. There are many people in the same age/gender categories who ran the same times. This is evident when checking the official results on the Berlin Marathon website. Hence, we should not remove the non-distict rows.")

runner_data %>% distinct(Gender)

runner_data %>% distinct(Age)
print("Some of the Age values are represented by arbitrary letters. These should be changed to Unknown.")

runner_data %>% distinct(Time)
runner_data %>% count(Time=="no time")
print("2405 runners have no time. These runners need to be removed from the dataset.")

print("Create a tidied dataset based on these observations.")

tidied_runner_data <- runner_data %>% filter(Time!="no time") 

tidied_runner_data$Country[is.na(tidied_runner_data$Country)] <- "Unknown"

tidied_runner_data$Age[tidied_runner_data$Age %in% c("A","B","BM","Ber","C","D1","D2","D3",
                                                     "DA","DB","DH","DJ","L","L1","L2","L3",
                                                     "L4","M","M0","M<",NA)] <- "Unknown"

tidied_runner_data <- tidied_runner_data %>%
  mutate(Gender = case_when(Gender == "male" ~ "Male", Gender == "female" ~ "Female"))

tidied_runner_data <- tidied_runner_data %>%
  mutate(Age = case_when(
    Age == "Unknown" ~ "Unknown",
    Age < 20 ~ "<20",
    Age >= 20 & Age < 30 ~ "20-29", Age >= 30 & Age < 35 ~ "30-34",
    Age >= 35 & Age < 40 ~ "35-39", Age >= 40 & Age < 45 ~ "40-44",
    Age >= 45 & Age < 50 ~ "45-49", Age >= 50 & Age < 55 ~ "50-54",
    Age >= 55 & Age < 60 ~ "55-59", Age >= 60 & Age < 65 ~ "60-64",
    Age >= 65 & Age < 70 ~ "65-69", Age >= 70 & Age < 75 ~ "70-74",
    Age >= 75 & Age < 80 ~ "75-79", Age >= 80 ~ "80+",
    TRUE ~ as.character(Age)  
  ))

library(hms)

tidied_runner_data <- tidied_runner_data %>% mutate(
  Year = as.numeric(Year),
  Country = as.character(Country),
  Age = as.character(Age),
  Gender = as.character(Gender),
  Time = as_hms(Time)
)

write.csv(tidied_runner_data, file="derived_data/runners_tidied.csv", row.names=FALSE)



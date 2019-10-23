library(mongolite)
library(tidyverse)
library(lubridate)
library(ggpubr)

m <- mongo("listings", "mpcrawl")

# Load all data (not that much data)
data <- m$find() %>% as_tibble() %>%
  mutate_all(sapply, toString)

# Filter some users
data <- data %>%
  filter(seller != "Biedveilingen") %>% 
  distinct(url, scrap_date, price, .keep_all=TRUE)

# Create variable to indicate advertisement
data <- data %>%
  mutate(is_ad = if_else(str_sub(url, 1, 1) == "a", TRUE, FALSE))

# Clean date and price column
data.clean <- data %>%
  mutate(price = if_else(str_detect(price, "€"), str_sub(price, 3),
                         NA_character_)) %>%
  filter(!is.na(price)) %>%
  mutate(price = str_replace_all(price, "\\.", ""),
         price = as.numeric(str_replace(price, ",", "."))) %>%
  mutate(post_date = dmy_hm(date, locale="nl_NL")) %>%
  filter(price >= 5, price <= 3000)

# For now, only use actual listings
data.listings <- data.clean %>%
  filter(!is_ad)

# First try: match title to type of iPhone using Levenhstein distance
data.listings <- data.listings %>%
  mutate(title = str_to_lower(title),
         description = str_to_lower(description)) %>%
  mutate(iphone_type = case_when(
    str_detect(title, "i[ -]*phone[ -]*4s") ~ "iphone 4s",
    str_detect(title, "i[ -]*phone[ -]*4") ~ "iphone 4",
    str_detect(title, "i[ -]*phone[ -]*5s") ~ "iphone 5s",
    str_detect(title, "i[ -]*phone[ -]*5") ~ "iphone 5",
    str_detect(title, "i[ -]*phone[ -]*6s") ~ "iphone 6s",
    str_detect(title, "i[ -]*phone[ -]*6[ ]?plus") ~ "iphone 6 Plus",
    str_detect(title, "i[ -]*phone[ -]*6") ~ "iphone 6",
    str_detect(title, "i[ -]*phone[ -]*se") ~ "iphone SE",
    str_detect(title, "i[ -]*phone[ -]*7[ ]?plus") ~ "iphone 7 Plus",
    str_detect(title, "i[ -]*phone[ -]*7") ~ "iphone 7",
    str_detect(title, "i[ -]*phone[ -]*8[ ]?plus") ~ "iphone 8 Plus",
    str_detect(title, "i[ -]*phone[ -]*8") ~ "iphone 8",
    str_detect(title, "i[ -]*phone[ -]*xr") ~ "iphone XR",
    str_detect(title, "i[ -]*phone[ -]*xs[ ]?max") ~ "iphone XS Max",
    str_detect(title, "i[ -]*phone[ -]*xs") ~ "iphone XS",
    str_detect(title, "i[ -]*phone[ -]*x") ~ "iphone X",
    str_detect(title, "i[ -]*phone[ -]*10") ~ "iphone X",
    str_detect(title, "i[ -]*phone[ -]*11[ ]?pro[ ]?max") ~ "iphone 11 Pro Max",
    str_detect(title, "i[ -]*phone[ -]*11[ ]?pro") ~ "iphone 11 Pro",
    str_detect(title, "i[ -]*phone[ -]*11") ~ "iphone 11",
    str_detect(description, "i[ -]*phone[ -]*4s") ~ "iphone 4s",
    str_detect(description, "i[ -]*phone[ -]*4") ~ "iphone 4",
    str_detect(description, "i[ -]*phone[ -]*5s") ~ "iphone 5s",
    str_detect(description, "i[ -]*phone[ -]*5") ~ "iphone 5",
    str_detect(description, "i[ -]*phone[ -]*6s") ~ "iphone 6s",
    str_detect(description, "i[ -]*phone[ -]*6[ ]?plus") ~ "iphone 6 Plus",
    str_detect(description, "i[ -]*phone[ -]*6") ~ "iphone 6",
    str_detect(description, "i[ -]*phone[ -]*se") ~ "iphone SE",
    str_detect(description, "i[ -]*phone[ -]*7[ ]?plus") ~ "iphone 7 Plus",
    str_detect(description, "i[ -]*phone[ -]*7") ~ "iphone 7",
    str_detect(description, "i[ -]*phone[ -]*8[ ]?plus") ~ "iphone 8 Plus",
    str_detect(description, "i[ -]*phone[ -]*8") ~ "iphone 8",
    str_detect(description, "i[ -]*phone[ -]*xr") ~ "iphone XR",
    str_detect(description, "i[ -]*phone[ -]*xs[ ]?max") ~ "iphone XS Max",
    str_detect(description, "i[ -]*phone[ -]*xs") ~ "iphone XS",
    str_detect(description, "i[ -]*phone[ -]*x") ~ "iphone X",
    str_detect(description, "i[ -]*phone[ -]*10") ~ "iphone X",
    str_detect(description, "i[ -]*phone[ -]*11[ ]?pro[ ]?max") ~ "iphone 11 Pro Max",
    str_detect(description, "i[ -]*phone[ -]*11[ ]?pro") ~ "iphone 11 Pro",
    str_detect(description, "i[ -]*phone[ -]*11") ~ "iphone 11",
    TRUE ~ NA_character_
  )) %>%
  mutate(iphone_type = factor(iphone_type, levels=c(NA_character_,
                                                    "iphone 4", "iphone 4s",
                                                    "iphone 5", "iphone 5s",
                                                    "iphone 6", "iphone SE",
                                                    "iphone 6s", "iphone 6 Plus", 
                                                    "iphone 7", "iphone 7 Plus", 
                                                    "iphone 8", "iphone 8 Plus", 
                                                    "iphone X", "iphone XR", 
                                                    "iphone XS", "iphone XS Max", 
                                                    "iphone 11", "iphone 11 Pro", 
                                                    "iphone 11 Pro Max"),
                              ordered=TRUE))

# Check what we missed
data.listings.missing <- data.listings %>%
  filter(is.na(iphone_type))

data.listings <- data.listings %>%
  filter(!is.na(iphone_type))

#### Extract features of phone ####

# Note that the number of gb is a multiple of 16, i.e. 16, 32, 64, etc so we 
# check for this number to appear in the title or description
data.listings <- data.listings %>%
  mutate(storage_cap = case_when(
    str_detect(title, "16") ~ 16,
    str_detect(title, "32") ~ 32,
    str_detect(title, "64") ~ 64,
    str_detect(title, "128") ~ 128,
    str_detect(title, "256") ~ 256,
    str_detect(title, "512") ~ 512,
    TRUE ~ NA_real_
  )) %>%
  mutate(storage_cap = if_else(is.na(storage_cap), case_when(
    str_detect(description, "16") ~ 16,
    str_detect(description, "32") ~ 32,
    str_detect(description, "64") ~ 64,
    str_detect(description, "128") ~ 128,
    str_detect(description, "256") ~ 256,
    str_detect(description, "512") ~ 512,
    TRUE ~ NA_real_
  ),
  storage_cap))

# Check whether sold device has icloud lock
data.listings <- data.listings %>%
  mutate(locked = if_else(str_detect(title, "icloud[ ]*lock"), TRUE, FALSE))


#### Filter relevent ads ####

# Only keep listings younger than 7 days
data.listings.new <- data.listings %>%
  mutate(scrap_date = dmy(scrap_date)) %>%
  filter(ymd(scrap_date) - as_date(post_date) <= days(7))


#### Create figures ####

data.phone <- data.listings.new %>%
  group_by(iphone_type) %>%
  summarise(N = n(),
            avg_price = mean(price),
            sd_price = sd(price))

ggplot(data.phone, aes(x=iphone_type, y=avg_price)) +
  geom_bar(stat="identity") +
  labs(x="", y="Average price") +
  scale_y_continuous(labels = scales::dollar_format(suffix = "", prefix = "€"),
                     breaks = c(0, 250, 500, 750, 1000, 1250, 1500)) +
  theme_pubr() +
  theme(panel.grid.major.y = element_line(color="#858585"),
        axis.text.x = element_text(angle=-90, vjust = 0.1, hjust=0))

data.first.analysis <- data.listings.new %>%
  filter(!is.na(iphone_type), post_date >= ymd('2019-01-01')) %>%
  mutate(week = week(post_date)) %>%
  group_by(week, iphone_type) %>%
  summarise(n = n(),
            avg_price = mean(price))

# Plot
ggplot(data.first.analysis, aes(x=week, y=avg_price, colour=iphone_type)) +
  geom_line() +
  geom_point() + 
  labs(x="Week", y="Average price", colour="",
       title="Average iPhone Prices Listed on September 23, 2019",
       caption = "Source: marktplaats.nl") +
  scale_y_continuous(labels = scales::dollar_format(suffix = "", prefix = "€"),
                     breaks = c(0, 250, 500, 750, 1000, 1250, 1500)) +
  scale_x_continuous(breaks = seq(min(data.first.analysis$week), max(data.first.analysis$week))) +
  theme_pubr() +
  theme(panel.grid.major.y = element_line(color="#d6d6d6"),
        legend.position = "bottom")

# Listings per week
data.week <- data.first.analysis %>%
  group_by(week) %>%
  summarise(n = sum(n))

ggplot(data.week, aes(x=week, y=n)) +
  annotate(geom="rect", xmin=37, xmax=38, ymin=-Inf, ymax=Inf, fill="grey", alpha=0.3) + 
  geom_line() +
  geom_point() + 
  labs(x="Week number", y="Numer of listings", colour="",
       title="Number of iPhone Listings on September 23, 2019",
       caption = "Source: marktplaats.nl") +
  scale_y_continuous() +
  scale_x_continuous(breaks = seq(min(data.week$week), max(data.week$week))) +
  theme_pubr() +
  theme(panel.grid.major.y = element_line(color="#d6d6d6"),
        legend.position = "bottom")


# Distribution of prices of iPhone SE

iphone.SE.data <- data.listings.new %>%
  filter(iphone_type == "iphone SE")

SE.hist <- ggplot(iphone.SE.data, aes(x=price)) +
  geom_histogram() +
  theme_pubr() +
  scale_x_continuous(labels = scales::dollar_format(suffix = "", prefix = "€"),
                     limits = c(0, 200),
                     breaks = c(0, 50, 100, 150, 200)) +
  scale_y_continuous() +
  labs(x = "Price", y="", title="Density of all listed iPhone SE's")

print(SE.hist)


library(mongolite)
library(tidyverse)

m <- mongo("listings", "mpcrawl")

# Load all data (not that much data)
data <- m$find() %>% as_tibble() %>%
  mutate_all(sapply, toString)

# Filter some users
data <- data %>%
  filter(seller != "Biedveilingen") %>% 
  distinct()

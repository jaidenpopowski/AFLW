# AFLW Historical Statistics

# Package names
packages <- c("tidyverse", "fitzRoy")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

# Read in data from 2017-2022A seasons
afl_w_history <- read_csv("AFLW History.csv")

# Calculate team totals across stat lines
game_totals <- afl_w_history %>% 
  select(-lastUpdated) %>% 
  group_by(providerId,team.name) %>% 
  summarise(across(c(goals:`clearances.totalClearances`), sum),.groups = 'drop') %>% 
  select(-ratingPoints,-ranking,-superGoals,-goalEfficiency,-shotEfficiency,-interchangeCounts)

colnames(game_totals) <- paste("team",colnames(game_totals),sep=".")
colnames(game_totals)[1] <- 'providerId'
colnames(game_totals)[2] <- 'team.name'

# Collate final data
data <- afl_w_history %>% 
  left_join(game_totals, by = c("providerId","team.name"))

write.csv(data, file = "AFLW Statistics.csv")

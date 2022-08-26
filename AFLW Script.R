# AFLW Historical Statistics

# Install tidyverse for data manipulation
if (!require("tidyverse")) install.packages("tidyverse")

# Install the developer version of fitzRoy
devtools::install_github("jimmyday12/fitzRoy")

# Load libraries
library(tidyverse)
library(fitzRoy)

# Read in data from 2017-2022A seasons
afl_w_history <- read_csv("AFLW/AFLW History.csv") %>% 
  rbind(
    test <- fetch_player_stats_afl(season="2022",comp="AFLW") %>% 
      filter(compSeason.shortName == "AFLW Season 7") %>% 
      select(-extendedStats,-home.team.name,-away.team.name)
  )

# calculate team totals across stat lines
game_totals <- afl_w_history %>% 
  select(-lastUpdated) %>% 
  group_by(providerId,team.name) %>% 
  summarise(across(c(goals:`clearances.totalClearances`), sum),.groups = 'drop') %>% 
  select(-ratingPoints,-ranking,-superGoals,-goalEfficiency,-shotEfficiency,-interchangeCounts)

colnames(game_totals) <- paste("team",colnames(game_totals),sep=".")
colnames(game_totals)[1] <- 'providerId'
colnames(game_totals)[2] <- 'team.name'

# collate final data
data <- afl_w_history %>% 
  left_join(game_totals, by = c("providerId","team.name"))

write.csv(data, file = "AFLW Statistics.csv")

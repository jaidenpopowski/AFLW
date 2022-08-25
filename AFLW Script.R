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

# Read in data from 2017-2022A seasons and combine with any new stats from 2022B season
afl_w_history <- read_csv("AFLW/AFLW History.csv") %>% 
  rbind(
    fetch_player_stats_afl(season="2022",comp="AFLW") %>% 
      filter(compSeason.shortName == "AFLW Season 7") %>% 
      select(-extendedStats)
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

library(stringr)
library(reshape2)
library(dplyr)
library(ggplot2)
rm(list = ls())


# set working directory
setwd('../Speech/Results/Raw')

# subject_id
id <-"JC1144"

# Load in Ba-Da categorization
df1 <- read.csv(paste0(id, "_1.txt"), skip = 1)
df1$stimulus <- gsub(".wav","", df1$stimulus)
audio_cols <- colsplit(df1$stimulus, "_", names=c("junk","step","duration","step"))
df1$step <- audio_cols$step
df1$duration <- audio_cols$duration
df1 <-mutate(df1, selection_code = ifelse(selection == "Sa", 1, 0))



# Load in my second trial
df2 <- read.csv(paste0(id, "_2.txt"), skip = 1)
df2$stimulus <- gsub(".wav","", df2$stimulus)
audio_cols <- colsplit(df2$stimulus, "_", names=c("junk","step","duration","step"))
df2$step <- audio_cols$step
df2$duration <- audio_cols$duration
df2 <-mutate(df2, selection_code = ifelse(selection == "Sa", 1, 0))

# Bind them together
sum_sa_sha <- rbind(df1,df2)

sum_sa_sha$duration <- as.factor(sum_sa_sha$duration)

# Process percents scored
df_sum <- sum_sa_sha %>%
  group_by(step,duration) %>%
  summarise(response = mean(selection_code, na.rm = TRUE),
            RT = mean(RT))
# Make duration a factor


px1 <- ggplot(df_sum, aes(step, response, colour = duration))+
  geom_point(size = 3)+
  geom_line()+
  scale_x_continuous(breaks = seq(1,7))+
  scale_y_continuous(labels = scales::percent, limits = c(0, 1))+
  labs(title = paste0("Categorization, ", id), subtitle = "/ʃa/-/sa/")+
  labs(x = "Step", y = "Proportion Answered 'Sa'")+
  #theme(axis.text = element_text(size = 12),
  #     axis.title = element_text(size = 14))
  theme(text = element_text(size = 18))

px1


ggsave(paste0("./Plots/Cat_Summary_", id, ".png"), px1, width = 8, height = 8)
write.csv(subset(df_sum, duration == 100), file = paste0("../Psychometrics/Raw/", "Psychometrics_100_", id, ".csv"))
write.csv(subset(df_sum, duration == 300), file = paste0("../Psychometrics/Raw/", "Psychometrics_300_", id, ".csv"))


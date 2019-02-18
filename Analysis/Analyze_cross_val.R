rm(list = ls())
library(ggplot2)

library(dplyr)

filepath = "../Results/CV_10"

filelist = list.files(path = filepath,pattern = ".*.csv")
full_file_list <- paste0(filepath, '/',filelist)
cvpm <- data.frame()
#assuming tab separated values with a header    
for (i in 1:length(full_file_list)){
  data<- read.csv(paste0(full_file_list[i]))
  cvpm <- rbind(cvpm, data)}

# Which subjects do we actually want to use?
df_subj <- read.csv("../cleaned_data.csv")
subj_list <- unique(df_subj$subject_id)

                    
# Summarize the cross validation results, which are still separated by fold
cv_sum <- cvpm %>%
  group_by(SubjectID, block, width) %>%
  summarise(mse = median(p),
            sum = n())%>%
  filter(SubjectID %in% subj_list)%>%
  filter(SubjectID != "IC955")


#ggplot(cv_sum, aes(width, mse))+
#  geom_point()+
#  geom_line(aes(group = block))+
#  facet_wrap(~SubjectID, nrow=3) 


# Baseline the traces with reference to MSE @ 0 width
baselined <- function(df){
  ref <- df %>%
    group_by(SubjectID, block)%>%
    filter(width == 0) %>%
    dplyr::select(mse)
  colnames(ref)[3] <- "baseline"
  
  df <- merge(df, ref)
  df$normed <- df$mse - df$baseline
  return(df)
}

cv_sum_norm <- baselined(cv_sum)
big_mu_norm <- cv_sum_norm %>%
  group_by(width) %>%
  summarise(mse2 = median(normed),
            se = 1.253*sd(normed)/sqrt(n()))

ggplot(big_mu_norm, aes(width, mse2))+
  geom_point()+
  geom_line()+
  geom_ribbon(aes(ymin=mse2-se, ymax = mse2+se), alpha = 0.3)


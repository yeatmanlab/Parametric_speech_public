library(dplyr)
library(ggplot2)
library(reshape2)

rm(list = ls())
bio <- read.csv("../cleaned_data.csv")

bio_df <- bio %>%
  group_by(subject_id)%>%
  summarise(wasi_fs2 = unique(wasi_fs2),
            wasi_mr_ts = unique(wasi_mr_ts),
            wj_brs = unique(wj_brs),
            wj_wa_ss = unique(wj_wa_ss),
            wj_lwid_ss = unique(wj_lwid_ss),
            twre_index = unique(twre_index),
            twre_pde_ss = unique(twre_pde_ss),
            twre_swe_ss = unique(twre_swe_ss),
            ctopp_pa = unique(ctopp_pa),
            ctopp_pm = unique(ctopp_pm),
            ctopp_rapid = unique(ctopp_rapid),
            age_at_testing = mean(age_at_testing),
            adhd_dx = unique(adhd_dx),
            read = unique(read),
            group = unique(group))

aggregate(ctopp_rapid ~ group, bio_df, mean)
# Standard deviations in each group
aggregate(ctopp_rapid ~ group, bio_df, sd)


bio_ba <- subset(bio_df, group != "Above Average")
bio_aa <- subset(bio_df, group != "Below Average")

##### Some correlations ####
summary(lm(wj_brs ~ twre_index, bio_df))
summary(lm(age_at_testing ~ read, bio_df))
kruskal.test(age_at_testing ~ group, bio_df)
kruskal.test(adhd_dx ~ group, bio_df)

# ADHD distributions?
table(bio_df$group, bio_df$adhd_dx)



# Age at testing
wilcox.test(age_at_testing ~ group, bio_ba)
wilcox.test(age_at_testing ~ group, bio_aa)

# WASI 
wilcox.test(wasi_fs2 ~ group, bio_ba)
wilcox.test(wasi_fs2 ~ group, bio_aa)

wilcox.test(wasi_mr_ts ~ group, bio_ba)
wilcox.test(wasi_mr_ts ~ group, bio_aa)

# WJ-BRS
wilcox.test(wj_brs ~ group, bio_ba)
wilcox.test(wj_brs ~ group, bio_aa)

wilcox.test(wj_lwid_ss ~ group, bio_ba)
wilcox.test(wj_lwid_ss ~ group, bio_aa)

wilcox.test(wj_wa_ss ~ group, bio_ba)
wilcox.test(wj_wa_ss ~ group, bio_aa)

# TOWRE
wilcox.test(twre_index ~ group, bio_ba)
wilcox.test(twre_index ~ group, bio_aa)

wilcox.test(twre_swe_ss ~ group, bio_ba)
wilcox.test(twre_swe_ss ~ group, bio_aa)

wilcox.test(twre_pde_ss ~ group, bio_ba)
wilcox.test(twre_pde_ss ~ group, bio_aa)

# CTOPP
wilcox.test(ctopp_pa~ group, bio_ba)
wilcox.test(ctopp_pa ~ group, bio_aa)

wilcox.test(ctopp_pm~ group, bio_ba)
wilcox.test(ctopp_pm ~ group, bio_aa)

wilcox.test(ctopp_rapid~ group, bio_ba)
wilcox.test(ctopp_rapid ~ group, bio_aa)



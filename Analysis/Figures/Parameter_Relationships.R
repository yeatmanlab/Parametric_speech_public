# Make a plot of the slope, lapse, and PC components for all the data we have so far
library(ggplot2)
library(tidyr)
library(ggExtra)
library(ggpubr)
library(RColorBrewer)

rm(list = ls())

# Load in the data
setwd("/home/eobrien/bde/Projects/Parametric_Speech_public/Speech/Analysis")
#setwd("P://bde/Projects/Parametric/Speech/Analysis")
psychometrics <- read.csv("../cleaned_psychometrics.csv")

# Do PCA
params <- psychometrics[,4:7]
PCA<- prcomp(params, scale=TRUE)
psychometrics <- cbind(psychometrics, PCA$x)

# Estimate the lapse rate
psychometrics$lapse_rate <- with(psychometrics, (lo_asymp + hi_asymp) / 2)

# Get the composite reading score
psychometrics$read <- (psychometrics$wj_brs + psychometrics$twre_index)/2 
# Melt the dataframe
psych_sub <- psychometrics %>%
  dplyr::select(c("duration","subject_id", "read","slope","lapse_rate","PC1"))
psych_sub <- gather(psych_sub, condition, measurement, slope:PC1, factor_key = TRUE)

# Formatting for plotting
psych_sub$duration <- as.factor(psych_sub$duration)
levels(psych_sub$duration) = c("100 ms", "300 ms") 
levels(psych_sub$condition) = c("Slope", "Asymptote", "Principal\nComponent")
#psych_sub$condition <- ordered(psych_sub$condition, levels = c("Principal\nComponent", "Slope", "Asymptote"))


# Dummy data
dummy = data.frame(reading_score=80, condition=rep(c("Principal\nComponent", "Slope","Asymptote"), each=1), 
                    value=c(1.2*max(psych_sub$measurement[psych_sub$condition=="Principal\nComponent"]),
                            1.2*max(psych_sub$measurement[psych_sub$condition=="Slope"]),
                            1.2*max(psych_sub$measurement[psych_sub$condition=="Asymptote"])))


px <- ggplot(psych_sub, aes(read, measurement))+
  geom_point()+
  geom_blank(data=dummy, aes(reading_score, value))+
  facet_grid(condition ~ duration, scales = "free_y" )+
  geom_smooth(method = "lm", aes(colour = duration),size = 1.5, alpha = 0.6)+
  #scale_color_manual(values = c("tomato3","turquoise3"))+
  scale_color_brewer(palette = "Set1")+
  theme_bw()+
  xlab("Reading Score")+
  ylab("Parameter Estimate")+
  stat_cor(label.y.npc = "top",label.x.npc = "left")+
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 14),
        strip.text = element_text(size = 18),
        legend.position="none")

px

ggsave("parameter_relationships.pdf", px,
       device=cairo_pdf, width=6, height=8)
ggsave("parameter_relationships.png", px,
       width=6, height=8)
  

#############################################################################
# effects <- reshape(psychometrics, idvar = "subject_id", timevar = "duration", direction = "wide")
# 
# effect <- effects %>%
#   dplyr::group_by(subject_id)%>%
#   dplyr::summarise(fx = PC1.300 - PC1.100,
#             read = unique(read.300))
# effect$group <- with(effect, ifelse(read <= 85, "Dyslexic",
#                                                   ifelse(read > 100, "Above Average",
#                                                          "Below Average")))
# effect <- na.omit(effect)
# my_palette = c(brewer.pal(3, "Set1"))
# 
# px <- ggplot(effect, aes(read, fx))+
#   geom_point(size = 3, alpha = 0.8)+
#   theme_bw()+
#   geom_smooth(method = "lm", color = my_palette[3], size = 2)+
#   theme(legend.position = "left",
#         axis.title = element_text(size = 20),
#         axis.text = element_text(size = 16))+
#   xlab("Reading Score")+
#   ylab("Within-subject difference in PC1\n(300 ms - 100 ms)")+
#   guides(color =guide_legend(title="Group"))+
#   stat_cor(label.y.npc = "top",label.x.npc = "right", size = 5)
# 
# px
# 
# 
# ggsave("effect_duration.pdf", px,
#        device=cairo_pdf, width=11.5, height=8)
# ggsave("effect_duration.png", px,
#        width=11.5, height=8)

############################################################################

# Melt the dataframe
psych_sub2 <- psych_sub %>%
  spread(duration, measurement)

psych_sub2$`Duration Effect\n(300 ms - 100 ms)` <- psych_sub2$`300 ms` - psych_sub2$`100 ms`

psych_sub3 <- gather(psych_sub2, duration, measurement, `100 ms`:`Duration Effect\n(300 ms - 100 ms)`, factor_key = TRUE)

dummy = data.frame(reading_score=80, condition=rep(c("Principal\nComponent", "Slope","Asymptote"), each=1), 
                   value=c(1.35*max(psych_sub3$measurement[psych_sub3$condition=="Principal\nComponent"], na.rm=TRUE),
                           1.35*max(psych_sub3$measurement[psych_sub3$condition=="Slope"], na.rm=TRUE),
                           1.35*max(psych_sub3$measurement[psych_sub3$condition=="Asymptote"], na.rm=TRUE)))


px <- ggplot(psych_sub3, aes(read, measurement))+
  geom_point()+
  geom_blank(data=dummy, aes(reading_score, value))+
  facet_grid(condition ~ duration, scales = "free_y" )+
  geom_smooth(method = "lm", aes(colour = duration),size = 1.5, alpha = 0.6)+
  scale_color_brewer(palette = "Set1")+
  theme_bw()+
  xlab("Reading Score")+
  ylab("Parameter Estimate")+
  stat_cor(label.y.npc = "top",label.x.npc = "left", size = 6)+
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 14),
        strip.text = element_text(size = 18),
        legend.position="none")

px

ggsave("effect_duration2.png", px,
       width=11.5, height=8)
ggsave("effect_duration2.pdf", px,
       width=11.5, height=8)




# ############################################################################
# PC100 <- ggplot(subset(psych_sub, duration == "100 ms" & condition == "Principal\nComponent"),
#                 aes(read, measurement))+ 
#   geom_point() + 
#   theme(axis.title.x = element_blank(), axis.ticks.x = element_blank(), axis.text.x = element_blank(), plot.margin=margin(l=0,unit="cm"))+
#   ylab("PC1")+
#   geom_smooth(method = "lm", colour = "red")
# 
# PC300 <- ggplot(subset(psych_sub, duration == "300 ms" & condition == "Principal\nComponent"),
#                 aes(read, measurement))+ 
#   geom_point() + 
#   geom_smooth(method = "lm")+
#   theme(axis.title = element_blank(), axis.ticks = element_blank(), axis.text = element_blank(),plot.margin=margin(l=-0.8,unit="cm") )
# 
# sl100 <- ggplot(subset(psych_sub, duration == "100 ms" & condition == "Slope"),
#                 aes(read, measurement))+ 
#   geom_point() + 
#   geom_smooth(method = "lm",colour = "red")+
#   theme(axis.title.x = element_blank(), axis.ticks.x = element_blank(), axis.text.x = element_blank(), plot.margin=margin(l=0,unit="cm"))+
#   ylab("Slope")
# 
# sl300 <- ggplot(subset(psych_sub, duration == "300 ms" & condition == "Slope"),
#                 aes(read, measurement))+ 
#   geom_point() + 
#   geom_smooth(method = "lm")+
#   theme(axis.title = element_blank(), axis.ticks = element_blank(), axis.text = element_blank(),plot.margin=margin(l=-0.8,unit="cm"))+
#   ylab("")
# 
# as100 <- ggplot(subset(psych_sub, duration == "100 ms" & condition == "Asymptote"),
#                 aes(read, measurement))+ 
#   geom_point() + 
#   geom_smooth(method = "lm",colour = "red")+
#   theme(plot.margin=margin(l=0,unit="cm"),axis.title.x = element_blank())+
#   ylab("Asymptote")
# 
# as300 <- ggplot(subset(psych_sub, duration == "300 ms" & condition == "Asymptote"),
#                 aes(read, measurement))+ 
#   geom_point() + 
#   geom_smooth(method = "lm")+
#   theme(axis.title = element_blank(), axis.ticks.y = element_blank(), axis.text.y = element_blank(),plot.margin=margin(l=0,unit="cm"))
# 
# 
# 
# 
# plot_grid(PC100, PC300, sl100, sl300, as100, as300, ncol = 2, align = "hv")
# 
# pc_density <- geom_density(subset(psych_sub, condition == "Principal\nComponent"), aes(x = )) +
#   coord_flip()
# 
# pc_dens <- ggdensity(subset(psych_sub, condition == "Principal\nComponent"), x = "measurement", 
#                      fill = "duration", palette = "jco") + coord_flip() + clean_theme() + guides(fill = FALSE)
# sl_dens <- ggdensity(subset(psych_sub, condition == "Slope"), x = "measurement", 
#                      fill = "duration", palette = "jco") + coord_flip() + clean_theme() + guides(fill = FALSE)
# as_dens <- ggdensity(subset(psych_sub, condition == "Asymptote"), x = "measurement", 
#                      fill = "duration", palette = "jco") + coord_flip() + clean_theme()+ guides(fill = FALSE)
# 
# all <- plot_grid(PC100, PC300,pc_dens, sl100, sl300, sl_dens, as100, as300, as_dens, ncol = 3, align = "hv", rel_widths = c(3,3,1.5))
# 
# ggsave("out.png", all)




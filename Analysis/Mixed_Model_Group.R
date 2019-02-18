# This script does linear models on the fit psychometric functions
library(dplyr)
library(lme4)
library(pbkrtest)
library(ggplot2)

rm(list = ls())
psychometrics <- read.csv("../cleaned_psychometrics.csv")

## set deviation contrasts
psychometrics$duration<- factor(psychometrics$duration, levels=c("100", "300"))
duration_dimnames <- list(levels(psychometrics$duration),
                          levels(psychometrics$duration)[2])
contrasts(psychometrics$duration) <- matrix(c(-0.5, 0.5), nrow=2, dimnames=duration_dimnames)

# Only compare two groups
psychometrics <- subset(psychometrics, group != "Below Average")


### center reading score, etc
psychometrics$adhd_dx <- as.logical(psychometrics$adhd_dx)
psychometrics$wj_brs <- scale(psychometrics$wj_brs, scale = FALSE)
psychometrics$twre_index <- scale(psychometrics$twre_index, scale = FALSE)
psychometrics$wasi_mr_ts <- scale(psychometrics$wasi_mr_ts, scale=FALSE)

psychometrics <- na.omit(psychometrics)


## ## ## ## ## ## ##
##  SLOPE MODELS  ##
## ## ## ## ## ## ##
full_model <- lmer(slope ~ group*duration + adhd_dx + wasi_mr_ts  +  (1|subject_id),
                   data=psychometrics)
# p-values for full model
coefs <- data.frame(coef(summary(full_model)))
df.KR <- get_ddf_Lb(full_model, fixef(full_model))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)

## model selection: nuisance variables
no_wasi_model <- update(full_model, ~ . - wasi_mr_ts)
anova(full_model, no_wasi_model) # Can remove wasi

pb.b <- PBmodcomp(full_model, no_wasi_model, nsim = 500)
pb.b

no_adhd_model <- update(full_model, ~ . - adhd_dx)
anova(full_model, no_adhd_model) # OK to remove adhd

no_nuisance_model <- update(full_model, ~ .  - adhd_dx -wasi_mr_ts)
anova(full_model, no_nuisance_model) # OK to remove both nuisance parameters

# Does duration matter?
no_duration_model <- lmer(slope ~ group + (1|subject_id), data=psychometrics)
anova(no_nuisance_model, no_duration_model) # Don't want to remove duration

# Does group matter?
no_wj_model <- lmer(slope ~ duration +(1|subject_id), data=psychometrics)
anova(no_nuisance_model, no_wj_model) # Group doesn't matter

pb.b <- PBmodcomp(no_nuisance_model, no_wj_model, nsim = 500)
pb.b

fit <- lmer(slope ~ duration+ group + (1|subject_id), psychometrics)
win_model <- fit
summary(win_model)
coefs <- data.frame(coef(summary(win_model)))
df.KR <- get_ddf_Lb(win_model, fixef(win_model))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)


# Is there any significant effect of group overall? Omnibus statistical value
group_only <- lmer(slope ~ group  + (1|subject_id), psychometrics)
df.KR <- get_ddf_Lb(group_only, fixef(group_only))

Fval <- anova(group_only)$F
df1 <- anova(group_only)$Df
omnibus_sig = 1-pf(Fval, df1, df.KR)
omnibus_sig

# Now for duration
dur_only <- lmer(slope ~ duration + (1|subject_id), psychometrics)
df.KR <- get_ddf_Lb(dur_only, fixef(group_only))

Fval <- anova(dur_only)$F
df1 <- anova(dur_only)$Df
omnibus_sig = 1-pf(Fval, df1, df.KR)
omnibus_sig


### ## ## ## ## ## ## ##
##  LAPSE RATE MODEL ##
## ## ## ## ## ## ## ##
psychometrics$lapse_rate <- with(psychometrics, (lo_asymp + hi_asymp) / 2)

full_model <- lmer(lapse_rate ~ group*duration + wasi_mr_ts + adhd_dx +  (1|subject_id),
                   data=psychometrics)
# p-values for full model
coefs <- data.frame(coef(summary(full_model)))
df.KR <- get_ddf_Lb(full_model, fixef(full_model))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)

## model selection: nuisance variables
no_wasi_model <- update(full_model, ~ . - wasi_mr_ts)
anova(full_model, no_wasi_model) # OK to remove wasi

no_adhd_model <- update(full_model, ~ . - adhd_dx)
anova(full_model, no_adhd_model) # OK to remove adhd

no_nuisance_model <- update(full_model, ~ . - wasi_mr_ts - adhd_dx)
anova(full_model, no_nuisance_model) # OK to remove both nuisance parameters

# Does duration matter?
no_duration_model <- lmer(lapse_rate ~ group + (1|subject_id), data=psychometrics)
anova(no_nuisance_model, no_duration_model) # No evidence duration matters for lapse

# Does wj matter?
no_wj_model <- lmer(lapse_rate ~ duration+ (1|subject_id), data=psychometrics)
anova(no_nuisance_model, no_wj_model) #No, we must keep reading!

#### Selected model ####
win_model <- lmer(lapse_rate ~group + (1|subject_id), data = psychometrics)

coefs <- data.frame(coef(summary(win_model)))
df.KR <- get_ddf_Lb(win_model, fixef(win_model))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)

# Is there any significant effect of group overall? Omnibus statistical value
group_only <- lmer(lapse_rate ~ group + (1|subject_id), psychometrics)
df.KR <- get_ddf_Lb(group_only, fixef(group_only))

Fval <- anova(group_only)$F
df1 <- anova(group_only)$Df
omnibus_sig = 1-pf(Fval, df1, df.KR)
omnibus_sig



## ## ## ## ## ## ## ##
##      PCA MODEL    ##
## ## ## ## ## ## ## ##


# DO PCA
params <- psychometrics[,4:7]
PCA<- prcomp(params, scale=TRUE)
psychometrics <- cbind(psychometrics, PCA$x)

summary(PCA)
# Now let's see what predicts the first PCA component
lmfit <- lmer(PC1 ~ group*duration + adhd_dx + wasi_mr_ts + (1|subject_id), psychometrics)
# Summary for full model
coefs <- data.frame(coef(summary(lmfit)))
df.KR <- get_ddf_Lb(lmfit, fixef(lmfit))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)

# Remove nuisance variables
lmfit_no_wasi <- update(lmfit, ~ . - wasi_mr_ts)
anova(lmfit, lmfit_no_wasi)

lmfit_no_adhd <- update(lmfit, ~ . - adhd_dx)
anova(lmfit, lmfit_no_adhd)

lmfit_no_nuisance <- update(lmfit, ~ . - wasi_mr_ts - adhd_dx)
anova(lmfit, lmfit_no_nuisance) # OK to remove both nuisances!

coefs <- data.frame(coef(summary(lmfit_no_nuisance)))
df.KR <- get_ddf_Lb(lmfit_no_nuisance, fixef(lmfit_no_nuisance))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)

# To the main model
lmfit_no_duration <- lmer(PC1 ~ group  + (1|subject_id), data=psychometrics)
anova(lmfit_no_nuisance, lmfit_no_duration) #can't remove main effect of duration

lmfit_no_int <- lmer(PC1 ~ group + duration + (1|subject_id), data=psychometrics)
anova(lmfit_no_nuisance, lmfit_no_int) #can remove interaction

win <- lmer(PC1 ~ group + duration + (1|subject_id), data = psychometrics)


# This is the winner
coefs <- data.frame(coef(summary(win)))
df.KR <- get_ddf_Lb(win, fixef(win))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)

#### Is there an significant effect of including group?
group_only <- lmer(PC1 ~ group + (1|subject_id), psychometrics)
df.KR <- get_ddf_Lb(group_only, fixef(group_only))

Fval <- anova(group_only)$F
df1 <- anova(group_only)$Df
omnibus_sig = 1-pf(Fval, df1, df.KR)
omnibus_sig

######## Effect size of duration ################
dur_only <- lmer(PC1 ~ duration*group + (1|subject_id), psychometrics)
df.KR <- get_ddf_Lb(dur_only, fixef(dur_only))

Fval <- anova(dur_only)$F
df1 <- anova(dur_only)$Df
omnibus_sig = 1-pf(Fval, df1, df.KR)
omnibus_sig

################### GET COHENS D ####################################
psy_sum <- psychometrics %>%
  group_by(subject_id)%>%
  summarise(PC1 = mean(PC1),
            slope = mean(slope),
            lapse = mean(lapse_rate),
            group = unique(group))
psy_sum$group <- factor(psy_sum$group)

cohen.d(psy_sum$PC1, psy_sum$group)

cohen.d(psy_sum$slope, psy_sum$group)

cohen.d(psy_sum$lapse, psy_sum$group)

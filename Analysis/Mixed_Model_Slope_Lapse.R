# This script does linear models on the fit psychometric functions
library(dplyr)
library(lme4)
library(pbkrtest)
library(ggplot2)

rm(list = ls())
psychometrics <- read.csv("../cleaned_psychometrics.csv")

psychometrics$read <- (psychometrics$wj_brs + psychometrics$twre_index)/2
## set deviation contrasts
psychometrics$duration<- factor(psychometrics$duration, levels=c("100", "300"))
duration_dimnames <- list(levels(psychometrics$duration),
                          levels(psychometrics$duration)[2])
contrasts(psychometrics$duration) <- matrix(c(-0.5, 0.5), nrow=2, dimnames=duration_dimnames)

### center reading score, etc
psychometrics$adhd_dx <- as.logical(psychometrics$adhd_dx)
psychometrics$wj_brs <- scale(psychometrics$wj_brs, scale = FALSE) #log(max(psychometrics$wj_brs)+1 - psychometrics$wj_brs)
psychometrics$twre_index <- scale(psychometrics$twre_index, scale = FALSE)
psychometrics$read <- scale(psychometrics$read, scale = FALSE) #log(max(psychometrics$wj_brs)+1 - psychometrics$wj_brs)
psychometrics$wasi_mr_ts <- scale(psychometrics$wasi_mr_ts, scale=FALSE)


## ## ## ## ## ## ##
##  SLOPE MODELS  ##
## ## ## ## ## ## ##
psychometrics <- na.omit(psychometrics)
psychometrics <- psychometrics %>%
  subset(threshold >= 1 & threshold <= 7 & subject_id != "IC955")

full_model <- lmer(slope ~ read*duration + adhd_dx + wasi_mr_ts  +  (1|subject_id),
                   data=psychometrics)
# p-values for full model
coefs <- data.frame(coef(summary(full_model)))
df.KR <- get_ddf_Lb(full_model, fixef(full_model))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)


## model selection: nuisance variables
no_wasi_model <- update(full_model, ~ . - wasi_mr_ts)
#anova(full_model, no_wasi_model) # OK to remove wasi
PBmodcomp(full_model, no_wasi_model, nsim = 500)


no_adhd_model <- update(full_model, ~ . - adhd_dx)
#anova(full_model, no_adhd_model) # OK to remove adhd
PBmodcomp(full_model, no_adhd_model, nsim = 500)

no_nuisance_model <- update(full_model, ~ .  - adhd_dx - wasi_mr_ts)
#anova(full_model, no_nuisance_model) # OK to remove both nuisance parameters
PBmodcomp(full_model, no_nuisance_model, nsim = 500)


# Does duration matter?
no_duration_model <- lmer(slope ~ read + (1|subject_id), data=psychometrics)
#anova(no_nuisance_model, no_duration_model) # Don't want to remove duration
PBmodcomp(no_nuisance_model, no_duration_model, nsim = 500)


# Does wj matter?
no_wj_model <- lmer(slope ~ duration+ (1|subject_id), data=psychometrics)
#anova(no_nuisance_model, no_wj_model) # Don't want to remove reading
PBmodcomp(no_nuisance_model, no_wj_model, nsim = 500)

# Does interaction matter? OK to remove interaction
no_int_model <- lmer(slope ~ duration + read + (1|subject_id), data = psychometrics)
#anova(no_nuisance_model, no_int_model) # OK to remove interaction
PBmodcomp(no_nuisance_model, no_int_model, nsim = 500)
          
fit <- lmer(slope ~ read + duration + (1|subject_id), psychometrics)
win_model <- fit
summary(win_model)
coefs <- data.frame(coef(summary(win_model)))
df.KR <- get_ddf_Lb(win_model, fixef(win_model))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)


summary(lm(read ~ wasi_mr_ts, psychometrics))

# Estimate p-values
read_only <- lmer(slope ~ read + (1|subject_id), psychometrics)
PBmodcomp(win_model, read_only, nsim = 500)


### ## ## ## ## ## ## ##
##  LAPSE RATE MODEL ##
## ## ## ## ## ## ## ##
psychometrics$lapse_rate <- with(psychometrics, (lo_asymp + hi_asymp) / 2)

full_model <- lmer(lapse_rate ~ read*duration + wasi_mr_ts + adhd_dx +  (1|subject_id),
                   data=psychometrics)
# p-values for full model
coefs <- data.frame(coef(summary(full_model)))
df.KR <- get_ddf_Lb(full_model, fixef(full_model))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)

## model selection: nuisance variables
no_wasi_model <- update(full_model, ~ . - wasi_mr_ts)
#anova(full_model, no_wasi_model) # OK to remove wasi
PBmodcomp(full_model, no_wasi_model, nsim = 500)

no_adhd_model <- update(full_model, ~ . - adhd_dx)
#anova(full_model, no_adhd_model) # OK to remove adhd
PBmodcomp(full_model, no_adhd_model, nsim = 500)

no_nuisance_model <- update(full_model, ~ . - wasi_mr_ts - adhd_dx)
#anova(full_model, no_nuisance_model) # OK to remove both nuisance parameters
PBmodcomp(full_model, no_nuisance_model, nsim = 500)


# Does duration matter?
no_duration_model <- lmer(lapse_rate ~ read + (1|subject_id), data=psychometrics)
#anova(no_nuisance_model, no_duration_model) # No evidence duration matters for lapse
PBmodcomp(no_nuisance_model, no_duration_model, nsim = 500)

# Does wj matter?
no_wj_model <- lmer(lapse_rate ~ duration+ (1|subject_id), data=psychometrics)
#anova(no_nuisance_model, no_wj_model) #No, we must keep reading!
PBmodcomp(no_nuisance_model, no_wj_model, nsim = 500)

#### Selected model ####
win_model <- lmer(lapse_rate ~read + (1|subject_id), data = psychometrics)

coefs <- data.frame(coef(summary(win_model)))
df.KR <- get_ddf_Lb(win_model, fixef(win_model))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)

## ## ## ## ## ## ## ##
##      PCA MODEL    ##
## ## ## ## ## ## ## ##


# DO PCA
params <- psychometrics[,4:7]
PCA<- prcomp(params, scale=TRUE)
psychometrics <- cbind(psychometrics, PCA$x)

summary(PCA)

# Now let's see what predicts the first PCA component
lmfit <- lmer(PC1 ~ read*duration + adhd_dx + wasi_mr_ts + (1|subject_id), psychometrics)
# Summary for full model
coefs <- data.frame(coef(summary(lmfit)))
df.KR <- get_ddf_Lb(lmfit, fixef(lmfit))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)

# Remove nuisance variables
lmfit_no_wasi <- update(lmfit, ~ . - wasi_mr_ts)
#anova(lmfit, lmfit_no_wasi)
PBmodcomp(lmfit, lmfit_no_wasi, nsim = 500)

lmfit_no_adhd <- update(lmfit, ~ . - adhd_dx)
#anova(lmfit, lmfit_no_adhd)
PBmodcomp(lmfit, lmfit_no_adhd, nsim = 500)

lmfit_no_nuisance <- update(lmfit, ~ . - wasi_mr_ts - adhd_dx)
#anova(lmfit, lmfit_no_nuisance) # OK to remove both nuisances!
PBmodcomp(lmfit, lmfit_no_nuisance, nsim = 500)


# To the main model

lmfit_no_duration <- lmer(PC1 ~ read + read:duration + (1|subject_id), data=psychometrics)
#anova(lmfit_no_nuisance, lmfit_no_duration) #can't remove main effect of duration
PBmodcomp(lmfit_no_nuisance, lmfit_no_duration, nsim = 500)

lmfit_no_int <- lmer(PC1 ~ read + duration + (1|subject_id), data=psychometrics)
#anova(lmfit_no_nuisance, lmfit_no_int) #can remove interaction
PBmodcomp(lmfit_no_nuisance, lmfit_no_int, nsim = 500)

win <- lmer(PC1 ~ read + duration + (1|subject_id), data = psychometrics)

# This is the winner
coefs <- data.frame(coef(summary(win)))
df.KR <- get_ddf_Lb(win, fixef(win))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)


win <- lmer(PC1 ~ wasi_mr_ts + read + (1|subject_id), data = psychometrics)

# This is the winner
coefs <- data.frame(coef(summary(win)))
df.KR <- get_ddf_Lb(win, fixef(win))
coefs$p.KR <- 2*(1-pt(abs(coefs$t.value), df.KR))
print(coefs)


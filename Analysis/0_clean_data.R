# Process data
#!/usr/bin/env Rscript

## prep_data.R
## loads, cleans, aggregates, and saves raw response data and psychometric fits.

library(dplyr)
#setwd('/home/eobrien/bde/Projects/Parametric_Speech_public/Speech')
## When loading/saving, this script assumes the working directory is set to the
## root directory of the repo. Relative to this script's location that is:
#setwd("..")

## load the raw response data
response_df <- data.frame()
data_dir <- file.path("Results", "Raw")
raw_files <- list.files(path=data_dir)
## keep only categorization data (not discrimination); remove practice blocks
## and pilot data (subject "nnn")
raw_files <- raw_files[!grepl("practice", raw_files)]
raw_files <- raw_files[!grepl("nnn", raw_files)]
raw_files <- raw_files[!grepl("Pilot", raw_files)]
raw_files <- raw_files[!grepl("Plots", raw_files)]
## read in remaining raw data files
opts <- options(warn=2)  # convert warnings to errors, while reading in files
for (fname in raw_files) {
  ## skip=1 because first row of each file is a timestamp
  df_tmp <- tryCatch(read.csv(file.path(data_dir, fname), row.names=1, skip=1),
                     error=function(e) {print(paste("skipping", fname, 
                                                    conditionMessage(e))); e})
  if(inherits(df_tmp, "error")) next
  ## only keep complete blocks
  if(dim(df_tmp)[1] == 105) {
    df_tmp$subject_id <- strsplit(fname, "_")[[1]][1]
    df_tmp$continuum <-  "/ʃa/-/sa/"
    df_tmp$duration <- ifelse(grepl("100", df_tmp$stimulus), "100","300")
    df_tmp$run_id <- paste0(df_tmp$subject_id, '_', df_tmp$sound2)
    df_tmp$stimulus <- as.character(df_tmp$stimulus)
    df_tmp$step <- sapply(df_tmp$stimulus,
                          function(i) strsplit(strsplit(i, "_")[[1]][2],
                                               ".", fixed=TRUE)[[1]][1])
    df_tmp$response <- ifelse(df_tmp$selection %in% c("Sa"), 1, 0)
    
    ## get the timestamp
    conn <- file(file.path(data_dir, fname), "r")
    df_tmp$psych_date <- strsplit(readLines(conn, 1), ",")[[1]][1]
    close(conn)
    ## concatenate with other files
    response_df <- rbind(response_df, df_tmp)
  } else {
    print(paste("skipping", fname, "(incomplete block)"))
  }
}
options(opts)  # restore default options

# Change GB240 and GB208 to whatever they should be
response_df$subject_id <- gsub("GB240", "HB240",response_df$subject_id )
response_df$subject_id <- gsub("GB241", "KB241",response_df$subject_id )
response_df$subject_id <- gsub("KB578", "JB578",response_df$subject_id )

## load the repository / registry data
repository_df <- read.csv("../RDRPRepository_DATA_2018-10-05_1343.csv")
registry_df <- read.csv("../RDRPRegistry_DATA_2018-10-05_1402.csv")
demog_df <- merge(repository_df, registry_df, by = "record_id")

## filter out subjects not in our sample
subject_ids <- unique(response_df$subject_id)
record_ids <- demog_df %>% filter(sid.x %in% subject_ids) %>% dplyr::select(record_id)
subject_df <- demog_df %>% filter(record_id %in% record_ids$record_id)

## get reading scores
names <- colnames(demog_df)
wj_cols <- c("wj_brs","wj_wa_ss","wj_lwid_ss")
ctopp_cols <- c("ctopp_pa","ctopp_rapid","ctopp_pm")
twre_cols <- c("twre_index","twre_pde_ss","twre_swe_ss")
wasi_cols <- c("wasi_fs2", "wasi_mr_ts")
reading_columns <- c("record_id", "dys_dx", "adhd_dx", "brain_injury", "aud_dis",
                     "psych_dx", wj_cols, ctopp_cols, twre_cols, wasi_cols)
reading_df <- subject_df %>% dplyr::select(reading_columns)
reading_df <- reading_df[!duplicated(reading_df),]
## combine scores from distinct sessions
reading_df <- reading_df %>% group_by(record_id) %>% 
  summarise_all(funs(mean(as.numeric(.), na.rm=TRUE)))

## biographic details
bio_df <- subject_df[c("sid.x", "dob", "record_id","gender")]
bio_df[bio_df==""] <- NA
bio_df <- na.omit(bio_df)
bio_df$dob <- as.POSIXct(bio_df$dob, format="%Y-%m-%d")
colnames(bio_df)[colnames(bio_df) == "sid.x"] <- "subject_id"

## merge biographic info, reading scores, and psychometric data
use_df <- merge(bio_df, response_df)
use_df <- merge(use_df, reading_df)

## compute age at testing
use_df$age_at_testing <- with(use_df, difftime(psych_date, dob, units="weeks"))
use_df$age_at_testing <- as.numeric(use_df$age_at_testing) / 52.25

# Subjects who did not pass the hearing screening
hearing <- c("JB724")

# Num subjects
length(unique(use_df$subject_id))

# How many subjects were in the age group and had no auditory disorder- ie, were eligible for the study
use_df <- use_df %>% 
  filter(age_at_testing >= 8) %>%       
  filter(age_at_testing < 13)  %>%
  filter(aud_dis == 0 | is.nan(aud_dis))

length(unique(use_df$subject_id))

## How many passed thehearing and wasi screens?
use_df <- use_df %>%
  filter(!(subject_id %in% hearing)) %>% 
              # no auditory disorder
  filter(wasi_fs2 >= 80 | is.nan(wasi_fs2)) %>%           # WASI criterion
  filter(wasi_mr_ts > 30)           # WASI nonverbal not less than 2 sd below mean
 

length(unique(use_df$subject_id))
## assign to groups
use_df$read <- (use_df$wj_brs + use_df$twre_index)/2
use_df$group <- with(use_df, ifelse(read<= 85, "Dyslexic",
                                    ifelse(read >= 100, "Above Average",
                                           "Below Average")))

## drop identifying information
use_df <- use_df[ , !(names(use_df) == "dob")]

## ## ## ## ## ## ## ## ## ## ##
## LOAD PSYCHOMETRIC FIT DATA ##
## ## ## ## ## ## ## ## ## ## ##
#setwd("..")
fpath <- file.path("Results", "Psychometrics", "Fit15")
flist <- list.files(fpath)
psychometric_df <- do.call(rbind, lapply(file.path(fpath, flist), read.csv))
## make subject_id & asymptote column names consistent
psychometric_df <- rename(psychometric_df, subject_id=SubjectID,
                          lo_asymp=guess, hi_asymp=lapse)
psychometric_df$continuum <- '/ʃa/-/sa/' 

psychometric_df$subject_id <- gsub("GB240", "HB240",psychometric_df$subject_id )
psychometric_df$subject_id <- gsub("GB241", "KB241",psychometric_df$subject_id )
psychometric_df$subject_id <- gsub("KB578", "JB578",psychometric_df$subject_id )
## na.locf is "last observation carry forward". This works because we know the
## rows of the psychometrics dataframe are loaded in groups of 3, where all 3
## rows of the CSV file are the same contrast, and "single" is the last row.
psychometric_df$continuum <- zoo::na.locf(psychometric_df$continuum)
## add group and reading ability to psychometrics dataframe
columns <- c("subject_id", "group", "wj_brs","twre_index","adhd_dx", "wasi_mr_ts","age_at_testing",
             "ctopp_pa", "ctopp_pm", "ctopp_rapid","gender")
group_table <- unique(use_df[columns])

# Which subjects are in use_df, but not psychometric df?
use_list <- unique(psychometric_df$subject_id)
qual_list <- unique(use_df$subject_id)
comp <- setdiff(qual_list, use_list)


psychometric_df <- subset(psychometric_df,
                          subject_id %in% use_df$subject_id)


psychometric_df <- merge(psychometric_df, group_table, all.x=TRUE, all.y=FALSE)




length(unique(psychometric_df$subject_id))

psychometric_df <- psychometric_df %>%
  filter(threshold >= 1) %>%
  filter(threshold <= 7) %>%
  filter(deviance < 30)

length(unique(psychometric_df$subject_id))

# Make sure there are no duplicate columns
psychometric_df <- psychometric_df[!duplicated(psychometric_df), ]

write.table(psychometric_df, file="cleaned_psychometrics.csv", sep=",",
            quote=FALSE, row.names=FALSE)


# For the purposes of publicationt able, get gender and age distributions
subj_sum <- psychometric_df %>%
  group_by(subject_id) %>%
  summarise(group = unique(group),
            num_girls = unique(gender) - 1)
table(subj_sum$group)
table(subj_sum$group, subj_sum$num_girls)

# Now, save only the data for subjects we have full data for
use_df <- subset(use_df, subject_id %in% psychometric_df$subject_id)
write.table(use_df, file="cleaned_data.csv", sep=",", quote=FALSE, row.names=FALSE)

setwd("./Analysis")


####### See any disorders
disorders <- repository_df %>%
  dplyr::select(c("record_id","learning_dis_notes","other_dis")) %>%
  subset(record_id %in% use_df$record_id)%>%
  subset(learning_dis_notes != "" | other_dis != "")



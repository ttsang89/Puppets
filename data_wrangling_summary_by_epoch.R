### This script is to group the variables by epochs
### We'll get a dataframe  ordered by participant and a separate row for each unique combination of speaker and head turns. I'll then order it by frequency and duration. 
### Things to consider: Do we want sum? maybe also average of each epoch. 
### For sure we want total durations per and then calculate percentage

packages = c("tidyverse", "data.table", "readxl", "dplyr")
lapply(packages, require, character.only = TRUE)

data = read_excel('___2019_04-08_puppet_head_speaker_analyses.xlsx', sheet="Sheet1")

data = as.data.frame(data)

condensed_dataframe_ball <- data %>%
  group_by(filebase_name, Speaker, Speaker_head,Ball_present) %>%
  summarize(count = n(),
            sum_t1_t0 = sum(`T1-T0`),
            average_t1_t0= mean(`T1-T0`),
            total_valid_fix_dur_MS = sum(valid_fixation_dur_MS),
            total_puppet_head_dur_MS = sum(puppet_head_dur_MS),
            total_actress_head_dur_MS = sum(person_head_dur_MS),
            total_puppet_body_dur_MS=sum(puppet_body_dur_MS),
            total_actress_body_dur_MS=sum(person_body_dur_MS),
            total_ball_dur_MS = sum(ball_dur_MS),
            total_background_dur_MS = sum(background_dur_MS),
            percent_valid=total_valid_fix_dur_MS/sum_t1_t0*100,
            percent_puppet_head = total_puppet_head_dur_MS/total_valid_fix_dur_MS*100,
            percent_actress_head=total_actress_head_dur_MS/total_valid_fix_dur_MS*100,
            percent_puppet_body = total_puppet_body_dur_MS/total_valid_fix_dur_MS*100,
            percent_actress_body=total_actress_body_dur_MS/total_valid_fix_dur_MS*100,
            percent_ball=total_ball_dur_MS/total_valid_fix_dur_MS*100,
            percent_background=total_background_dur_MS/total_valid_fix_dur_MS*100)


write.csv(condensed_dataframe_ball,'Box Sync/Tawny_work/Puppet_Project/spreadsheets/04-16-19_full_dataset_condensed_ball.csv')


###let's condense the dataframe to make bargraphs of ET measures 
### first only get ASD and TD
data = as.data.frame(data)
data$DX_as_num <-NA
data$DX_as_num[data$DX=="ASD"] <- 1
data$DX_as_num[data$DX=="DD"] <- 2
data$DX_as_num[data$DX=="TD"] <- 0
ASD_TD_data = subset(data,DX_as_num<=1)

et_QC_dataframe <- ASD_TD_data %>%
  group_by(PartID, DX) %>%
  summarize(calibration_accuracy = mean(static_nn_mean_conv),
            percent_valid_looking= mean(percent_valid))
library(ggrepel)
median(et_QC_dataframe$calibration_accuracy)+2*sd(et_QC_dataframe$calibration_accuracy)
median(et_QC_dataframe$percent_valid_looking)-2*sd(et_QC_dataframe$percent_valid_looking)


names=et_QC_dataframe$DX
#qplot(DX, calibration_accuracy, data=et_QC_dataframe, geom=c("boxplot","jitter"), fill=DX) + 
ggplot(et_QC_dataframe, aes(DX,calibration_accuracy,label = PartID)) +  geom_point(color = ifelse(et_QC_dataframe$calibration_accuracy <2, "black", "red"), size = 2) + geom_jitter()
+
  geom_text_repel(data          = subset(et_QC_dataframe, calibration_accuracy >2),
                  nudge_y       = 150+ subset(et_QC_dataframe, calibration_accuracy > 23.03)$calibration_accuracy,
                  segment.size  = 0.2,
                  segment.color = "grey50",
                  direction     = "x") +
  theme_classic(base_size = 12)

ggplot(et_QC_dataframe, aes(DX,percent_valid_looking,label = PartID)) + 
  geom_point(color = ifelse(et_QC_dataframe$percent_valid_looking <20, "red", "black"), size = 2)
+
  geom_text_repel(data= subset(et_QC_dataframe, percent_valid_looking <20),
                  nudge_y       = 3-subset(et_QC_dataframe, percent_valid_looking <20)$percent_valid_looking,
                  segment.size  = 0.2,
                  segment.color = "grey50",
                  direction     = "x") +
  theme_classic(base_size = 12)




library(tidyverse)
library(readxl)
library(stringi)
library(reshape2)

# Check plate reader data for tn7 growth rates and ompW growth in NaCl.

df<-read_excel("PATH_TO_REPO/20hr_growth_curve_01072021.xlsx", skip = 9)

names(df)

# Make data 'long' format, convert to minutes, extract well ID etc

df<-df %>%
  select(-"Reading", -"...99") %>%
  reshape2::melt(., id.vars = "avg. time [s]") %>%
  mutate(well_id = stri_extract_first_regex(variable, "[A-Z][0-9]+")) %>%
  rename(seconds = "avg. time [s]", od = value) %>%
  mutate(minutes = round(seconds / 60)) %>%
  select(-variable)

# Link up with index file (well ID and treatment)

# Example format:
#meta<-data.frame(well_id = c('A01', 'A02'), treatment = c('treatment', 'control'))
meta<-read.csv("PATH_TO_REPO/plate_reader_metadata.csv")

df2<-df %>%
  right_join(meta, by = "well_id", all) %>%
  mutate(perc_nacl = gsub("%.+", "", treatment)) %>%
  mutate( experiment = ifelse(grepl("%", treatment), "nacl", "tn7")) %>%
  mutate( hours = minutes / 60) %>%
  filter( hours > 0)

# Plot NaCl experiment results first:

# All data
df2 %>%
  filter(experiment == "nacl") %>%
  ggplot(., aes(hours, od))+
  geom_point()+
  geom_smooth()+
  facet_wrap(~ well_id, ncol = 12)

# Agggregated data:
a<-df2 %>%
  filter(experiment == "nacl") %>%
  group_by(perc_nacl, geno, hours) %>%
  summarise(mean = mean(od), sd = sd(od)) %>%
  ggplot(., aes(hours, mean))+
  geom_point( size = 1, aes(color = geno))+
  facet_wrap( ~perc_nacl)+
  geom_ribbon( aes(group = geno, ymin = mean - sd, ymax = mean+ sd), alpha = 0.1)+
  geom_smooth( aes(color = geno))+
  theme_classic()+
  scale_color_brewer(type = "qual", palette = 3)+
  scale_y_log10()+
  theme( text = element_text(size = 15))+
  xlab("Hours")+
  ylab("OD600")+
  labs(color = "Genotype")

# Stats. Extract final densities at 20hrs.

t20<-df2 %>%
  filter(experiment == "nacl") %>%
  filter(hours == 20) %>%
  filter(perc_nacl == 4)

dim(t20)

hist(t20$od)
head(t20)
m1<-glm(od ~ geno, data = t20)  
qqnorm(resid(m1))
qqline(resid(m1))
m2<-update(m1,~.-geno)
anova(m1, m2, test = "F")

### Add biolog data and make into panel plot:
df2<-read.csv("PATH_TO_REPO/ompW_lacA_results_26hrs.csv")
# Is actually 28hours but mislabelled file.

lacA2<-df2 %>%
  reshape2::melt(., id.vars = c('Value', 'geno')) %>%
  mutate(., well = as.factor(paste(Value, gsub("X", "", variable), sep = ""))) %>%
  select(geno, value, well) %>%
  filter( geno == "lacA") %>%
  rename( lacA_od = value)

ompW2<-df2 %>%
  reshape2::melt(., id.vars = c('Value', 'geno')) %>%
  mutate(., well = as.factor(paste(Value, gsub("X", "", variable), sep = ""))) %>%
  select(geno, value, well) %>%
  filter( geno == "ompW") %>%
  rename( ompw_od = value)

tmp<-lacA2 %>%
  left_join(., ompW2, by = "well")

tmp %>%
  filter( well == "A1") %>%
  head()

g1 <- filter(tmp, well == " B12")

b<-ggplot(tmp, aes(lacA_od, ompw_od))+
  geom_point()+
  geom_smooth( method = "lm", color = "black", linetype = "dashed")+
  geom_point(data=g1, colour="darkred") +  # this adds a red point
  geom_text(data=g1, label="NaCl", vjust=1.25)+
  theme_classic()+
  xlab("WT LacA OD750")+
  ylab("ompW OD750")+
  theme(text = element_text(size = 15))

cowplot::plot_grid(a, b, ncol = 1, labels = c('A', 'B'))





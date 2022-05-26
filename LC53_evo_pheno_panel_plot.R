

# Plots for Ella MS (abiotic resistance evolution)

library(tidyverse)
library(readxl)

# Plot 1. Panel plot of bacteria and phage densities through time.
# Note 0% LB recorded = no salt added i.e. actually 0.5% NaCl as per recipe hence substitution.

# OD first

od<-read_excel("~/Dropbox/MC_fellowship/MCF/SS/structure_altr_proj/student_project/ella_studentship/data/Ella_Data_Summership.xlsx",
               sheet = 1)

od<-od %>%
  reshape2::melt(., id.vars = c('Replicate', 'Salt')) %>%
  mutate(day = as.numeric(as.character(variable))) %>%
  mutate( phage = ifelse(grepl("NP", Replicate), "no_phage", "phage")) %>%
  mutate( idx = paste(Replicate, Salt, sep = "_")) %>%
  mutate( Salt = gsub(0, 0.5, Salt))

a<-od %>%
  mutate( phage = ifelse(grepl("no_phage", phage), "No Phage", "Phage")) %>%
  ggplot(., aes(day, value))+
  geom_line( aes(group = idx, color = Salt), alpha = 0.3)+
  geom_smooth( aes(color = Salt, fill = Salt), linetype = "dashed", alpha = 0.3)+
  facet_wrap( ~phage, ncol = 1)+
  theme_classic()+
  theme(text = element_text(size = 15))+
  xlab("Day")+
  ylab("OD 600")+
  labs(color = "NaCl\n%")+
  scale_color_brewer(type = "qual", palette = 6)+
  scale_fill_brewer(type = "qual", palette = 6)+
  guides(fill = 'none')

# Phage titres
pfu<-read_excel("~/Dropbox/MC_fellowship/MCF/SS/structure_altr_proj/student_project/ella_studentship/data/Ella_Data_Summership.xlsx",
               sheet = 4)

pfu<-pfu %>%
  reshape2::melt(., id.vars = c('Replicate', 'Salt')) %>%
  mutate(day = as.numeric(as.character(variable))) %>%
  mutate( phage = ifelse(grepl("NP", Replicate), "no_phage", "phage")) %>%
  mutate( idx = paste(Replicate, Salt, sep = "_")) %>%
  mutate( Salt = gsub(0, 0.5, Salt))

b<-pfu %>%
  mutate( phage = ifelse(grepl("no_phage", phage), "No Phage", "Phage")) %>%
  filter( phage == "Phage") %>%
  ggplot(., aes(day, value))+
  geom_line( aes(group = idx, color = Salt), alpha = 0.3)+
  geom_smooth( aes(color = Salt, fill = Salt), linetype = "dashed", alpha = 0.3)+
  theme_classic()+
  theme(text = element_text(size = 15))+
  xlab("Day")+
  ylab("PFU / mL")+
  labs(color = "NaCl\n%")+
  scale_color_brewer(type = "qual", palette = 6)+
  scale_fill_brewer(type = "qual", palette = 6)+
  guides(fill = 'none')+
  scale_y_log10()

# Resistance

res<-read_excel("~/Dropbox/MC_fellowship/MCF/SS/structure_altr_proj/student_project/ella_studentship/data/Ella_Data_Summership.xlsx",
                sheet = 6)

c<-res %>%
  rename(prop = `Proportion Resistant`) %>%
  mutate( Salt = gsub(0, 0.5, Salt)) %>%
  mutate( phage = ifelse(grepl("NP", Replicate), "no_phage", "phage")) %>%
  filter(!Replicate == "ANC") %>%
  mutate( phage = ifelse(grepl("no_phage", phage), "No Phage", "Phage")) %>%
  ggplot(., aes(phage, prop))+
  geom_boxplot( aes(color = Salt))+
  geom_point( aes(color = Salt), position = position_dodge( width = 0.75))+
  theme_classic()+
  theme(text = element_text(size = 15))+
  xlab("Treatment")+
  ylab("Proportion\nResistant")+
  labs(color = "NaCl\n%")+
  scale_color_brewer(type = "qual", palette = 6)+
  scale_fill_brewer(type = "qual", palette = 6)+
  guides(fill = 'none')


### Combine into panel plot:
left<-cowplot::plot_grid(a, b, ncol = 1)
right<-cowplot::plot_grid( c, b, ncol = 1, labels = c('B', 'C'))
cowplot::plot_grid(a, right, ncol = 2, labels = c('A', ''))




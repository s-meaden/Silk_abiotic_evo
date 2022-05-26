
library(tidyverse)

# Plot of SNPs > 30% freq.
# Already filtered out SNPs present in ancestral line.

df<-read.table("PATH_TO_REPO/30pc_freq_SNP_list.txt",
            sep = "\t", header = T)  

df %>%
  mutate(salt = gsub("0", "0.5", salt)) %>%
  mutate(salt = gsub("%", "", salt)) %>%
  filter( phage == "phage") %>%
  ggplot(., aes(position, freq))+
  geom_point( aes(shape = as.character(replicate), color = salt), size = 4)+
  #facet_wrap( ~ salt, ncol = 1)+
  scale_x_continuous( limits = c(0,5000000), labels = scales::comma)+
  theme_classic()+
  xlab("Genomic Position")+
  ylab("Frequency in\npopulation (%)")+
  labs( shape = "Replicate", color = "NaCl\n%")+
  theme(text = element_text(size = 15))+
  scale_color_brewer(type = "qual", palette = 6)
  

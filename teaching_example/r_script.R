# replicate DiD charts/results for Quasi-Market Competition in Public Service Provision: User Sorting and Cream Skimming
# Hans Henrik Sievertsen (h.h.sievertsen@bristol.ac.uk), March 2021

# clear workspace
rm(list=ls())
# set working directory
setwd("C:/github/quasi_market_student_segregation/teaching_example")
# libraries
library("ggplot2")
library("dplyr")
library("readr")
# load data
df<-read_csv("did_data.csv")
# create DiD plot
ggplot(df,aes(x=year,y=segregation,color=type))+
     geom_line()+
     geom_point()+
     theme_minimal()+
     labs(x=" ", y="Segregation", colour=" ")+
     theme(legend.position = "top")+
     geom_vline(xintercept=2006.5, linetype="dashed")+
     ylim(0,0.07)+
     scale_x_continuous(breaks=seq(2003,2011,2),labels=seq(2003,2011,2))

# Compare means
mean_pre_control=colMeans(df%>%filter(year<2007,type=="Control")%>%select(segregation))
mean_pre_treated=colMeans(df%>%filter(year<2007,type=="Treated")%>%select(segregation))
mean_post_control=colMeans(df%>%filter(year>=2007,type=="Control")%>%select(segregation))
mean_post_treated=colMeans(df%>%filter(year>=2007,type=="Treated")%>%select(segregation))
print(paste("Difference post: ",(mean_post_treated-mean_post_control)))
print(paste("Difference pre: ",(mean_pre_treated-mean_pre_control)))
print(paste("Difference-in-differences: ",(mean_post_treated-mean_post_control)-(mean_pre_treated-mean_pre_control) ))

# Prepare data for regression
df<-df%>%mutate(Post=ifelse(year>2006,1,0),Treated=ifelse(type=="Treated",1,0),PostXTreated=Post*Treated)
# Estimate model with OLS
regresults<-lm(segregation~Treated+Post+PostXTreated,data=df)
# Print results
summary(regresults)

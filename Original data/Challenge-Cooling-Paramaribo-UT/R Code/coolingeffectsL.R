############ Start #################
# This script is to compute and visualize the cooling effects
# by comparing the temperatures of different locations.  


# remove everything that might still be in workspace and load packages
rm(list=ls())
library(tidyverse)
library(chron)
library(ggplot2)
library(scales)
library(dplyr)
library(ggrepel)
library(ggpubr)

homepath<-"D:/PhD/UrbanClimate paper/Analysis/R_wd"
setwd(homepath)

# read the cleaned data
alldata.times<-read.csv("alldataFinal.csv")

alldata.times$chrondate<-dates(alldata.times$chrondate)
alldata.times$chrontimes<-times(alldata.times$chrontimes)

alldata.times$season<-as.factor(alldata.times$season)
summary(alldata.times$season)
alldata.times$diurnal<-as.factor(alldata.times$diurnal)
summary(alldata.times$diurnal)

###### Calculate hourly average temps across days and locations ######

#turning chrontimes object to numeric to resolve plot x-axis issue
#the same name is used to avoid having to replace the name everywhere 
#in the calculations

chrontime<-as.numeric(c(0,1,2,3,4,5,6,7,8,9,10,11,12,13
                        ,14,15,16,17,18,19,20,21,22,23))

#create dataframe with locations and times
temp.hours<-expand.grid(unique(chrontime),
                        unique(alldata.times$location))
names(temp.hours)<-c("chrontimes","location")

for(i in unique(temp.hours$chrontimes)){
  for(j in unique(temp.hours$location)){
    
  temp.hours$diurnal[temp.hours$chrontimes==i & 
                       temp.hours$location==j]<- 
    case_when(is.na(temp.hours$chrontimes[i])~ "night",
              temp.hours$chrontimes[i]=="6" ~ "day",
              temp.hours$chrontimes[i]=="7"~ "day",
              temp.hours$chrontimes[i]=="8"~ "day",
              temp.hours$chrontimes[i]=="9"~ "day",
              temp.hours$chrontimes[i]=="10"~ "day",
              temp.hours$chrontimes[i]=="11"~ "day",
              temp.hours$chrontimes[i]=="12"~ "day",
              temp.hours$chrontimes[i]=="13"~ "day",
              temp.hours$chrontimes[i]=="14"~ "day",
              temp.hours$chrontimes[i]=="15"~ "day",
              temp.hours$chrontimes[i]=="16"~ "day",
               TRUE ~ "night")
}}
temp.hours$diurnal<-as.factor(ifelse(is.na(temp.hours$diurnal),"night",
                           paste(temp.hours$diurnal)))

# add day and night
#for (i in unique(temp.hours$chrontimes)){
#  temp.hours$diurnal[temp.hours$chrontimes==i]<-
#    as.character(alldata.times$diurnal
#                 [alldata.times$chrontimes==i])}

print(temp.hours)

# calculate annual mean temp and humidity per hour
for (i in unique(temp.hours$chrontimes)){  
  for (j in unique(temp.hours$location)){   

  temp.hours$meanT.year[temp.hours$chrontimes==i & temp.hours$location==j]<-
    mean(alldata.times$temp[alldata.times$hour==i & 
                            alldata.times$location==j],na.rm=T)

  temp.hours$meanH.year[temp.hours$chrontimes==i & temp.hours$location==j]<-
      mean(alldata.times$humidity[alldata.times$hour==i & 
                                    alldata.times$location==j], na.rm=T)
  }}

# calculate seasonal mean temp and humidity per hour
for (i in unique(temp.hours$chrontimes)){
  for (j in unique(temp.hours$location)){
    
    temp.hours$meanT.dry[temp.hours$chrontimes==i & temp.hours$location==j]<-
      mean(alldata.times$temp[alldata.times$hour==i & 
                                alldata.times$location==j & 
                                alldata.times$season=="dry"], na.rm=T)
    
    temp.hours$meanT.wet[temp.hours$chrontimes==i & temp.hours$location==j]<-
      mean(alldata.times$temp[alldata.times$hour==i &
                                alldata.times$location==j &
                                alldata.times$season=="wet"], na.rm=T)
    
    temp.hours$meanH.dry[temp.hours$chrontimes==i & temp.hours$location==j]<-
      mean(alldata.times$humidity[alldata.times$hour==i & 
                                    alldata.times$location==j &
                                    alldata.times$season=="dry"], na.rm=T)
    
    temp.hours$meanH.wet[temp.hours$chrontimes==i & temp.hours$location==j]<-
      mean(alldata.times$humidity[alldata.times$hour==i &
                                    alldata.times$location==j &
                                    alldata.times$season=="wet"], na.rm=T)
  }
}

temp.hours<-temp.hours[order(temp.hours$chrontimes),]
print(temp.hours)
#write.csv(temp.hours,file="alt_hourlytemp.csv")

###### A - calculate delta T (Average T across as reference) ########

# create dataframe with delta T annual
cooling.A<- data.frame(unique(temp.hours$chrontimes))
names(cooling.A)<- c("chrontimes")

# calculate average across drops per hour
for (i in unique(cooling.A$chrontimes)){
  
  cooling.A$meanTacross[cooling.A$chrontimes==i] <- 
    mean(temp.hours$meanT.year[temp.hours$chrontimes==i])
}

# calculate deltaT as meanTacross-dropT annual

for (i in unique(cooling.A$chrontimes)){
  cooling.A$deltaT1[cooling.A$chrontimes==i]<- 
    cooling.A$meanTacross[cooling.A$chrontimes==i] -
    temp.hours$meanT.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop1"]
  
  cooling.A$deltaT2[cooling.A$chrontimes==i]<- 
    cooling.A$meanTacross[cooling.A$chrontimes==i] -
    temp.hours$meanT.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop2"]
  
  cooling.A$deltaT4[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop4"]
    
    cooling.A$deltaT6[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop6"]
    
    cooling.A$deltaT8[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop8"]
    
    cooling.A$deltaT9[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop9"]
    
    
    cooling.A$deltaT11[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop11"]
    
    cooling.A$deltaT12[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop12"]
    
    cooling.A$deltaT14[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop14"]
    
    cooling.A$deltaT15[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop15"]
    
    cooling.A$deltaT16[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop16"]
    
    cooling.A$deltaT17[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop17"]
    
    cooling.A$deltaT18[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop18"]
    
    cooling.A$deltaT19[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop19"]
    
    cooling.A$deltaT21[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop21"]
    
    cooling.A$deltaT22[cooling.A$chrontimes==i]<- 
      cooling.A$meanTacross[cooling.A$chrontimes==i] -
      temp.hours$meanT.year[temp.hours$chrontimes==i & 
                              temp.hours$location=="Drop22"]
  }
  

cooling.A<-cooling.A[order(cooling.A$chrontimes),]
print(cooling.A)

## calculate deltaT as meanTacross(per season)-dropT(per season)

# create dataframe with delta T seasonal
cooling.dry<- data.frame(unique(temp.hours$chrontimes))
names(cooling.dry)<- c("chrontimes")

# Add average across drops per hour
for (i in unique(cooling.dry$chrontimes)){
  
  cooling.dry$meanTdry[cooling.dry$chrontimes==i]<-
    mean(temp.hours$meanT.dry[temp.hours$chrontimes==i])
}

# calculate deltaT for dry season

for (i in unique(cooling.dry$chrontimes)){
  cooling.dry$deltaT1[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop1"]
  
  cooling.dry$deltaT2[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop2"]
  
  cooling.dry$deltaT4[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop4"]
  
  cooling.dry$deltaT6[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop6"]
  
  cooling.dry$deltaT8[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop8"]
  
  cooling.dry$deltaT9[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop9"]
  
  cooling.dry$deltaT11[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop11"]
  
  cooling.dry$deltaT12[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop12"]
  
  cooling.dry$deltaT14[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop14"]
  
  cooling.dry$deltaT15[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop15"]
  
  cooling.dry$deltaT16[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop16"]
  
  cooling.dry$deltaT17[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop17"]
  
  cooling.dry$deltaT18[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop18"]
  
  cooling.dry$deltaT19[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop19"]
  
  cooling.dry$deltaT21[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop21"]
  
  cooling.dry$deltaT22[cooling.dry$chrontimes==i]<- 
    cooling.dry$meanTdry[cooling.dry$chrontimes==i] -
    temp.hours$meanT.dry[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop22"]
}

print(cooling.dry)

# Repeat delta T for wet season

# create dataframe with delta T wet season
cooling.wet<- data.frame(unique(temp.hours$chrontimes))
names(cooling.wet)<- c("chrontimes")

# Add average across drops per hour
for (i in unique(cooling.wet$chrontimes)){
  
  cooling.wet$meanTwet[cooling.wet$chrontimes==i]<-
    mean(temp.hours$meanT.wet[temp.hours$chrontimes==i])
}

# calculate deltaT for wet season

for (i in unique(cooling.wet$chrontimes)){
  cooling.wet$deltaT1[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop1"]
  
  cooling.wet$deltaT2[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop2"]
  
  cooling.wet$deltaT4[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop4"]
  
  cooling.wet$deltaT6[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop6"]
  
  cooling.wet$deltaT8[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop8"]
  
  cooling.wet$deltaT9[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop9"]
  
  cooling.wet$deltaT11[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop11"]
  
  cooling.wet$deltaT12[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop12"]
  
  cooling.wet$deltaT14[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop14"]
  
  cooling.wet$deltaT15[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop15"]
  
  cooling.wet$deltaT16[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop16"]
  
  cooling.wet$deltaT17[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop17"]
  
  cooling.wet$deltaT18[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop18"]
  
  cooling.wet$deltaT19[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop19"]
  
  cooling.wet$deltaT21[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop21"]
  
  cooling.wet$deltaT22[cooling.wet$chrontimes==i]<- 
    cooling.wet$meanTwet[cooling.wet$chrontimes==i] -
    temp.hours$meanT.wet[temp.hours$chrontimes==i & 
                           temp.hours$location=="Drop22"]
}

print(cooling.wet)


### plot delta T  ###

plotA<-ggplot(data=cooling.A,aes(x=chrontimes))+
  geom_line(aes(y=deltaT1,color='D1')) +
  geom_line(aes(y=deltaT2,color='D2')) +
  geom_line(aes(y=deltaT4,color='D4')) +
  geom_line(aes(y=deltaT6,color='D6')) +
  geom_line(aes(y=deltaT8,color='D8')) +
  geom_line(aes(y=deltaT9,color='D9')) +
  geom_line(aes(y=deltaT11,color='D11')) +
  geom_line(aes(y=deltaT12,color='D12')) +
  geom_line(aes(y=deltaT14,color='D14')) +
  geom_line(aes(y=deltaT15,color='D15')) +
  geom_line(aes(y=deltaT16,color='D16')) +
  geom_line(aes(y=deltaT17,color='D17')) +
  geom_line(aes(y=deltaT18,color='D18')) +
  geom_line(aes(y=deltaT19,color='D19')) +
  geom_line(aes(y=deltaT21,color='D21')) +
  geom_line(aes(y=deltaT22,color='D22')) +
  coord_cartesian(ylim=c(-4,3)) +
  scale_x_continuous(breaks=seq(0,23, by=1))+
  scale_y_continuous(breaks=seq(-4,3, by=1))+
  expand_limits(x=0, y=0)+
  annotate(geom="label",x=12,y=2.75,label="D4",
                    size=2, color="dark green",)  +
  annotate(geom="label",x=10,y=1.9,label="D8",
           size=2, color="chartreuse 4")  +
  annotate(geom="label",x=9.2,y=1.2,label="D2",
           size=2, color="dark olive green")  +
  annotate(geom="label",x=15,y=1.2,label="D22",
           size=2, color="darkolivegreen3")  +
  annotate(geom="label",x=10.5,y=0.7,label="D6",
           size=2, color="chartreuse2")  +
  annotate(geom="label",x=7.5,y=0.45,label="D12",
           size=2, color="dark cyan")  +
  annotate(geom="label",x=12,y=0.7,label="D14",
           size=2, color="dark khaki")  +
  annotate(geom="label",x=15,y=0.65,label="D18",
           size=2, color="darkgoldenrod3")  +
  annotate(geom="label",x=19.5,y=0,label="D21",
           size=2, color="dark salmon")  +
  annotate(geom="label",x=2,y=0.9,label="D17",
           size=2, color="brown 1")  +
  annotate(geom="label",x=5,y=1.1,label="D16",
           size=2, color="darkseagreen")  +
  annotate(geom="label",x=8,y=(-1.7),label="D15",
           size=2, color="coral4")  +
  annotate(geom="label",x=11,y=(-1.7),label="D9",
           size=2, color="cadetblue")  +
  annotate(geom="label",x=5,y=(-1.05),label="D19",
           size=2, color="burlywood3")  +
  annotate(geom="label",x=10,y=(-2.5),label="D1",
           size=2, color="dark grey")  +
  annotate(geom="label",x=14,y=(-3),label="D11",
           size=2, color="azure4")  +
  scale_color_manual(values=c(D4="dark green",D8="chartreuse 4",
                              D2="dark olive green",D22="dark olive green 3", 
                              D6="chartreuse 2",D12="dark cyan",D14="dark khaki",
                              D18="dark golden rod 3",D21="dark salmon",
                              D17="brown 1",D16="dark sea green",
                              D15="coral4",D9="cadetblue",D19="burlywood 3",
                              D1="dark grey",D11="azure4"),guide="none") + 
  labs(y="Delta T (C)", x="Time of day") +
  ggtitle("Cooling effect compared to location average T")+
  theme(legend.position="none")
print(plotA)

dev.off()

### Plot delta T seasonal ###

#Dry season

plotD<-ggplot(data=cooling.dry,aes(x=chrontimes))+
  geom_line(aes(y=deltaT1,color='D1')) +
  geom_line(aes(y=deltaT2,color='D2')) +
  geom_line(aes(y=deltaT4,color='D4')) +
  geom_line(aes(y=deltaT6,color='D6')) +
  geom_line(aes(y=deltaT8,color='D8')) +
  geom_line(aes(y=deltaT9,color='D9')) +
  geom_line(aes(y=deltaT11,color='D11')) +
  geom_line(aes(y=deltaT12,color='D12')) +
  geom_line(aes(y=deltaT14,color='D14')) +
  geom_line(aes(y=deltaT15,color='D15')) +
  geom_line(aes(y=deltaT16,color='D16')) +
  geom_line(aes(y=deltaT17,color='D17')) +
  geom_line(aes(y=deltaT18,color='D18')) +
  geom_line(aes(y=deltaT19,color='D19')) +
  geom_line(aes(y=deltaT21,color='D21')) +
  geom_line(aes(y=deltaT22,color='D22')) +
  coord_cartesian(ylim=c(-4,3)) +
  scale_x_continuous(breaks=seq(0,23, by=1))+
  scale_y_continuous(breaks=seq(-4,3, by=1))+
  expand_limits(x=0, y=0)+
  annotate(geom="label",x=12,y=2.9,label="D4",
           size=2, color="dark green",)  +
  annotate(geom="label",x=9.3,y=1.85,label="D8",
           size=2, color="chartreuse 4")  +
  annotate(geom="label",x=14,y=2.2,label="D2",
           size=2, color="dark olive green")  +
  annotate(geom="label",x=14,y=1.5,label="D22",
           size=2, color="darkolivegreen3")  +
  annotate(geom="label",x=10.75,y=0.7,label="D6",
           size=2, color="chartreuse2")  +
  annotate(geom="label",x=8,y=0.75,label="D12",
           size=2, color="dark cyan")  +
  annotate(geom="label",x=12.2,y=0.7,label="D14",
           size=2, color="dark khaki")  +
  annotate(geom="label",x=15,y=0.7,label="D18",
           size=2, color="darkgoldenrod3")  +
  annotate(geom="label",x=19.5,y=0.2,label="D21",
           size=2, color="dark salmon")  +
  annotate(geom="label",x=2,y=1,label="D17",
           size=2, color="brown 1")  +
  annotate(geom="label",x=5,y=1.1,label="D16",
           size=2, color="darkseagreen")  +
  annotate(geom="label",x=7.5,y=(-1.9),label="D15",
           size=2, color="coral4")  +
  annotate(geom="label",x=13.2,y=(-1.5),label="D9",
           size=2, color="cadetblue")  +
  annotate(geom="label",x=5,y=(-1.1),label="D19",
           size=2, color="burlywood3")  +
  annotate(geom="label",x=11.3,y=(-2.5),label="D1",
           size=2, color="dark grey")  +
  annotate(geom="label",x=14.5,y=(-3.5),label="D11",
           size=2, color="azure4")  +
  scale_color_manual(values=c(D4="dark green",D8="chartreuse 4",
                              D2="dark olive green",D22="dark olive green 3", 
                              D6="chartreuse 2",D12="dark cyan",D14="dark khaki",
                              D18="dark golden rod 3",D21="dark salmon",
                              D17="brown 1",D16="dark sea green",
                              D15="coral4",D9="cadetblue",D19="burlywood 3",
                              D1="dark grey",D11="azure4"),guide="none") + 
  labs(y="Delta T (C)", x="Time of day") +
  ggtitle("Dry season cooling")+
  theme(legend.position="none")
print(plotD)

dev.off()

# wet season

plotW<-ggplot(data=cooling.wet,aes(x=chrontimes))+
  geom_line(aes(y=deltaT1,color='D1')) +
  geom_line(aes(y=deltaT2,color='D2')) +
  geom_line(aes(y=deltaT4,color='D4')) +
  geom_line(aes(y=deltaT6,color='D6')) +
  geom_line(aes(y=deltaT8,color='D8')) +
  geom_line(aes(y=deltaT9,color='D9')) +
  geom_line(aes(y=deltaT11,color='D11')) +
  geom_line(aes(y=deltaT12,color='D12')) +
  geom_line(aes(y=deltaT14,color='D14')) +
  geom_line(aes(y=deltaT15,color='D15')) +
  geom_line(aes(y=deltaT16,color='D16')) +
  geom_line(aes(y=deltaT17,color='D17')) +
  geom_line(aes(y=deltaT18,color='D18')) +
  geom_line(aes(y=deltaT19,color='D19')) +
  geom_line(aes(y=deltaT21,color='D21')) +
  geom_line(aes(y=deltaT22,color='D22')) +
  coord_cartesian(ylim=c(-4,3)) +
  scale_x_continuous(breaks=seq(0,23, by=1))+
  scale_y_continuous(breaks=seq(-4,3, by=1))+
  expand_limits(x=0, y=0)+
  annotate(geom="label",x=12,y=2.9,label="D4",
           size=2, color="dark green",)  +
  annotate(geom="label",x=10.5,y=2,label="D8",
           size=2, color="chartreuse 4")  +
  annotate(geom="label",x=13.5,y=0.85,label="D2",
           size=2, color="dark olive green")  +
  annotate(geom="label",x=13,y=1.6,label="D22",
           size=2, color="darkolivegreen3")  +
  annotate(geom="label",x=11,y=0.7,label="D6",
           size=2, color="chartreuse2")  +
  annotate(geom="label",x=8,y=0.4,label="D12",
           size=2, color="dark cyan")  +
  annotate(geom="label",x=12.2,y=0.3,label="D14",
           size=2, color="dark khaki")  +
  annotate(geom="label",x=15.5,y=0.65,label="D18",
           size=2, color="darkgoldenrod3")  +
  annotate(geom="label",x=19.5,y=0,label="D21",
           size=2, color="dark salmon")  +
  annotate(geom="label",x=2,y=0.7,label="D17",
           size=2, color="brown 1")  +
  annotate(geom="label",x=5,y=1.1,label="D16",
           size=2, color="darkseagreen")  +
  annotate(geom="label",x=15,y=(-1),label="D15",
           size=2, color="coral4")  +
  annotate(geom="label",x=10.5,y=(-1.35),label="D9",
           size=2, color="cadetblue")  +
  annotate(geom="label",x=5,y=(-1.1),label="D19",
           size=2, color="burlywood3")  +
  annotate(geom="label",x=9,y=(-2.5),label="D1",
           size=2, color="dark grey")  +
  annotate(geom="label",x=14.4,y=(-3),label="D11",
           size=2, color="azure4")  +
  scale_color_manual(values=c(D4="dark green",D8="chartreuse 4",
                              D2="dark olive green",D22="dark olive green 3", 
                              D6="chartreuse 2",D12="dark cyan",D14="dark khaki",
                              D18="dark golden rod 3",D21="dark salmon",
                              D17="brown 1",D16="dark sea green",
                              D15="coral4",D9="cadetblue",D19="burlywood 3",
                              D1="dark grey",D11="azure4"),guide="none") + 
  labs(y="Delta T (C)", x="Time of day") +
  ggtitle("Wet season cooling")+
  theme(legend.position="none")
print(plotW)

ggarrange(plotD,plotW,labels=c("a","b"),ncol=1,nrow=2)

###### B - Compare absolute meanT at 6AM and 1PM for all drops ######
### Comparing day and night  

### create dataframe
bufferdata<-read.csv("D:/PhD/UrbanClimate paper/Analysis/R_wd/Nina/Paramaribodropsall.csv")
bufferdata$buff300.lc.t<-as.numeric(bufferdata$buff300.lc.t)

cooling.B<-expand.grid(unique(alldata.times$location),
                unique(alldata.times$chrontimes
                       [alldata.times$chrontimes=="06:00:00"]),
                unique(alldata.times$chrontimes
                       [alldata.times$chrontimes=="13:00:00"]))
names(cooling.B)<-c("location","Dtemp6AM","Dtemp1PM")

# add tree cover in the order of locations as in alldata.times
treecover_order<-c(0.74,0.18,0.24,0.08,0.32,0.10,0.14,0.10,
                   0.08,0.14,0.14,0.28,0.28,0.08,0.04,0.12)
cooling.B$treecover<-treecover_order
cooling.B<-cooling.B[,c(1,4,2,3)]

# calculate mean temps at 6.00 and 13.00 for wet and dry season
for (i in cooling.B$location){
  
  cooling.B$Dtemp6AM[cooling.B$location==i]<-
      mean(alldata.times$temp[alldata.times$chrontimes=="06:00:00" & 
                                alldata.times$location==i &
                                alldata.times$season=="dry"],na.rm=T)
  cooling.B$Dtemp1PM[cooling.B$location==i]<-
    mean(alldata.times$temp[alldata.times$chrontimes=="13:00:00" & 
                              alldata.times$location==i &
                              alldata.times$season=="dry"],na.rm=T)  
  
  cooling.B$Wtemp6AM[cooling.B$location==i]<-
    mean(alldata.times$temp[alldata.times$chrontimes=="06:00:00" & 
                              alldata.times$location==i &
                              alldata.times$season=="wet"],na.rm=T)
  cooling.B$Wtemp1PM[cooling.B$location==i]<-
    mean(alldata.times$temp[alldata.times$chrontimes=="13:00:00" & 
                              alldata.times$location==i &
                              alldata.times$season=="wet"],na.rm=T)  
  }

print(cooling.B)   #Doublecheck

write.csv(cooling.B,file="6am1pmtemp.csv")

### create scatterplot 6.00 x 13.00 temp in wet and dry season

plotB_daysD<-ggplot(data=cooling.B, aes(x=Dtemp1PM, y=Dtemp6AM,
                                        label=location))+
  geom_point(aes(size=treecover)) +
  geom_text(nudge_x=0.2, nudge_y=0.15, size=2.5)+
  coord_cartesian(xlim=c(28,33),ylim=c(23.5,26)) +
  scale_x_continuous(breaks=seq(28,33, by=1))+
  scale_y_continuous(breaks=seq(23.5,26, by=0.5))+
  labs(y="Temp 06.00 AM (C)", x="Temp 1.00 PM (C)") +
  ggtitle("Dry season diurnal cooling effect Paramaribo")
print(plotB_daysD)

dev.off()

plotB_daysW<-ggplot(data=cooling.B, 
                    aes(x=Wtemp1PM, y=Wtemp6AM,label=location))+
  geom_point(aes(size=treecover)) +
  geom_text(hjust=-0.2, vjust=0,check_overlap =T,size=2.5)+
  coord_cartesian(xlim=c(27,33),ylim=c(23,26)) +
  scale_x_continuous(breaks=seq(27,33, by=1))+
  scale_y_continuous(breaks=seq(23,26, by=0.5))+
  labs(y="Temp 06.00 AM (C)", x="Temp 1.00 PM (C)") +
  ggtitle("Wet season diurnal cooling effect Paramaribo")
print(plotB_daysW)

dev.off()
###### C - humidity (A+B) #######

#create dataframe with humidity per hour

hum.A<- data.frame(unique(temp.hours$chrontimes))
names(hum.A)<- c("chrontimes")

#arrange humidity per location in separate columns
for (i in unique(hum.A$chrontimes)){
  hum.A$RH1[hum.A$chrontimes==i]<- 
      temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop1"]
  hum.A$RH2[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop2"]
  
  hum.A$RH4[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop4"]
  
  hum.A$RH6[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop6"]
  
  hum.A$RH8[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop8"]
  
  hum.A$RH9[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop9"]
  
  hum.A$RH11[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop11"]
  
  hum.A$RH12[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop12"]
  
  hum.A$RH14[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop14"]
  
  hum.A$RH15[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop15"]
  
  hum.A$RH16[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop16"]
  
  hum.A$RH17[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop17"]
  
  hum.A$RH18[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop18"]
  
  hum.A$RH19[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop19"]
  
  hum.A$RH21[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop21"]
  
  hum.A$RH22[hum.A$chrontimes==i]<- 
    temp.hours$meanH.year[temp.hours$chrontimes==i & 
                            temp.hours$location=="Drop22"]
}

hum.A<-hum.A[order(hum.A$chrontimes),]
print(hum.A)

#draw plot 
plotC<-ggplot(data=hum.A,aes(x=chrontimes))+
  geom_line(aes(y=RH1,color='D1')) +
  geom_line(aes(y=RH2,color='D2')) +
  geom_line(aes(y=RH4,color='D4')) +
  geom_line(aes(y=RH6,color='D6')) +
  geom_line(aes(y=RH8,color='D8')) +
  geom_line(aes(y=RH9,color='D9')) +
  geom_line(aes(y=RH11,color='D11')) +
  geom_line(aes(y=RH12,color='D12')) +
  geom_line(aes(y=RH14,color='D14')) +
  geom_line(aes(y=RH15,color='D15')) +
  geom_line(aes(y=RH16,color='D16')) +
  geom_line(aes(y=RH17,color='D17')) +
  geom_line(aes(y=RH18,color='D18')) +
  geom_line(aes(y=RH19,color='D19')) +
  geom_line(aes(y=RH21,color='D21')) +
  geom_line(aes(y=RH22,color='D22')) +
  coord_cartesian(ylim=c(60,100)) +
  scale_x_continuous(breaks=seq(0,23, by=1)) +
  scale_y_continuous(breaks=seq(60,100, by=10)) +
  annotate(geom="label",x=9.5,y=98,label="D4",
           size=2.0, color="dark green",)  +
  annotate(geom="label",x=9.5,y=92,label="D8",
           size=2.0, color="chartreuse 4")  +
  annotate(geom="label",x=16,y=80,label="D2",
           size=2.0, color="dark olive green")  +
  annotate(geom="label",x=12,y=80,label="D22",
           size=2.0, color="darkolivegreen3")  +
  annotate(geom="label",x=7,y=86,label="D6",
           size=2.0, color="chartreuse2")  +
  annotate(geom="label",x=5,y=90,label="D12",
           size=2.0, color="dark cyan")  +
  annotate(geom="label",x=6.5,y=95,label="D14",
           size=2.0, color="dark khaki")  +
  annotate(geom="label",x=12,y=75,label="D18",
           size=2.0, color="darkgoldenrod3")  +
  annotate(geom="label",x=3,y=91,label="D21",
           size=2.0, color="dark salmon")  +
  annotate(geom="label",x=20.5,y=90,label="D17",
           size=2.0, color="brown 1")  +
  annotate(geom="label",x=19,y=98,label="D16",
           size=2.0, color="darkseagreen")  +
  annotate(geom="label",x=17,y=76, label="D15",
           size=2.0, color="coral4")  +
  annotate(geom="label",x=14,y=72.5,label="D9",
           size=2.0, color="cadetblue")  +
  annotate(geom="label",x=14.5,y=67,label="D19",
           size=2.0, color="burlywood3")  +
  annotate(geom="label",x=12.5,y=64.5,label="D1",
           size=2.0, color="dark grey")  +
  annotate(geom="label",x=17.5,y=66,label="D11",
           size=2.0, color="azure4")  +
  scale_color_manual(values=c(D4="dark green",D8="chartreuse 4",
                              D2="dark olive green",D22="dark olive green 3", 
                              D6="chartreuse 2",D12="dark cyan",D14="dark khaki",
                              D18="dark golden rod 3",D21="dark salmon",
                              D17="brown 1",D16="dark sea green",
                              D15="coral4",D9="cadetblue",D19="burlywood 3",
                              D1="dark grey",D11="azure4"),guide="none") + 
  labs(y="Relative humidity (%)", x="Time of day") +
  ggtitle("Mean relative humidity per location")+
  theme(legend.position="none")
print(plotC)

figure<-ggarrange(plotA,plotC,labels=c("a","b"), ncol=1, nrow=2)

print(figure)
dev.off()
# This file looks at diurnal dynamics and differences between seasons.


### always good to check
library(installr)
updateR()

# remove everything that might still be in workspace and load packages
rm(list=ls())
library(chron)
library(tidyverse)
library(ggplot2)
library(ggpubr)

homepath<-"C:/Users/best004/OneDrive - Wageningen University & Research/PhD/RQ - ITC/Analysis/R_wd/Nina"
setwd(homepath)
# getwd()


############## read csv file ##############
alldata<-read.csv("alldataFINAL.csv")

# check whether all is correct format -> turn into chron object & factor again
str(alldata)

alldata$chrondate<-dates(alldata$chrondate)
alldata$chrontimes<-times(alldata$chrontimes)
alldata$season<-as.factor(alldata$season)
alldata$diurnal<-as.factor(alldata$diurnal)
alldata$location<-as.factor(alldata$location)

str(alldata)
summary(alldata$chrondate)
summary(alldata$chrontimes)

# one data frame with each row: one hour - one drop - mean for one season. Season includes "all year"
alldata.perhour<-data.frame(sort(unique(alldata$chrontimes)))
names(alldata.perhour)<-c("chrontimes")
alldata.perhour$meanT<-NA
alldata.perhour$sdT<-NA
alldata.perhour<-merge(alldata.perhour, sort(unique(alldata$location)))
names(alldata.perhour)[names(alldata.perhour)=="y"]<-"location"
alldata.perhour<-merge(alldata.perhour, c("dry", "wet", "all year", "Oct21", "MJ22"))
names(alldata.perhour)[names(alldata.perhour)=="y"]<-"season"


for (i in unique(alldata$location)) {
  for (j in unique(alldata.perhour$season)) {
    for (k in unique(alldata$chrontimes)) {
      if (j == "all year"){
        temp1<- mean(alldata$temp[(alldata$location == i &
                                     alldata$chrontimes == k)],na.rm=T)
        temp2<- sd(alldata$temp[(alldata$location == i &
                                   alldata$chrontimes == k)],na.rm=T)
        temp3<- mean(alldata$humidity[(alldata$location == i &
                                         alldata$chrontimes == k)],na.rm=T)
        temp4<- sd(alldata$humidity[(alldata$location == i &
                                       alldata$chrontimes == k)],na.rm=T)
      } else if (j == "Oct21") {
        temp1<- mean(alldata$temp[(alldata$location == i &
                                     alldata$month == 10 & 
                                     alldata$chrontimes == k)],na.rm=T)
        temp2<- sd(alldata$temp[(alldata$location == i &
                                   alldata$month == 10 & 
                                   alldata$chrontimes == k)],na.rm=T)
        temp3<- mean(alldata$humidity[(alldata$location == i &
                                         alldata$month == 10 & 
                                         alldata$chrontimes == k)],na.rm=T)
        temp4<- sd(alldata$humidity[(alldata$location == i &
                                       alldata$month == 10 & 
                                       alldata$chrontimes == k)],na.rm=T)          
      }
      else if (j == "MJ22") {
        temp1<- mean(alldata$temp[(alldata$location == i &
                                     alldata$chrondate > "05/14/22" & alldata$chrondate < "06/16/22" & 
                                     alldata$chrontimes == k)],na.rm=T)
        temp2<- sd(alldata$temp[(alldata$location == i &
                                   alldata$chrondate > "05/14/22" & alldata$chrondate < "06/16/22" & 
                                   alldata$chrontimes == k)],na.rm=T)
        temp3<- mean(alldata$humidity[(alldata$location == i &
                                         alldata$chrondate > "05/14/22" & alldata$chrondate < "06/16/22" & 
                                         alldata$chrontimes == k)],na.rm=T)
        temp4<- sd(alldata$humidity[(alldata$location == i &
                                       alldata$chrondate > "05/14/22" & alldata$chrondate < "06/16/22" & 
                                       alldata$chrontimes == k)],na.rm=T)         
      }   else   { # if season == dry or wet
        temp1<- mean(alldata$temp[(alldata$location == i &
                                     alldata$season == j & 
                                     alldata$chrontimes == k)],na.rm=T)
        temp2<- sd(alldata$temp[(alldata$location == i &
                                   alldata$season == j & 
                                   alldata$chrontimes == k)],na.rm=T)
        temp3<- mean(alldata$humidity[(alldata$location == i &
                                         alldata$season == j & 
                                         alldata$chrontimes == k)],na.rm=T)
        temp4<- sd(alldata$humidity[(alldata$location == i &
                                       alldata$season == j & 
                                       alldata$chrontimes == k)],na.rm=T)
      } # end of else
      alldata.perhour$meanT[(alldata.perhour$location == i &
                               alldata.perhour$season == j & 
                               alldata.perhour$chrontimes == k)] <-temp1
      alldata.perhour$sdT[(alldata.perhour$location == i &
                             alldata.perhour$season == j &
                             alldata.perhour$chrontimes == k)] <- temp2
      alldata.perhour$meanH[(alldata.perhour$location == i &
                               alldata.perhour$season == j & 
                               alldata.perhour$chrontimes == k)] <-temp3
      alldata.perhour$sdH[(alldata.perhour$location == i &
                             alldata.perhour$season == j &
                             alldata.perhour$chrontimes == k)] <- temp4
    } # end of for chrontimes
  }
}

write.csv(alldata.perhour,file="alldataperhour.csv")

# one data frame, with one row = one time point across all locations, per season
alldata.perhourcombined<-data.frame(sort(unique(alldata$chrontimes)))
names(alldata.perhourcombined)<-c("chrontimes")
alldata.perhourcombined$meanT<-NA
alldata.perhourcombined$sdT<-NA
alldata.perhourcombined$meanH<-NA
alldata.perhourcombined$sdH<-NA
alldata.perhourcombined<-merge(alldata.perhourcombined, sort(unique(alldata.perhour$season)))
names(alldata.perhourcombined)[names(alldata.perhourcombined)=="y"]<-"season"

for (j in unique(alldata.perhour$season)) {
  for (k in unique(alldata.perhour$chrontimes)) {
    if (j == "all year"){
      temp1<- mean(alldata$temp[alldata$chrontimes == k ],na.rm=T)
      temp2<- sd(alldata$temp[alldata$chrontimes == k ],na.rm=T)
      temp3<- mean(alldata$humidity[alldata$chrontimes == k ],na.rm=T)
      temp4<- sd(alldata$humidity[alldata$chrontimes == k ],na.rm=T)
    } else if (j == "Oct21"){
      temp1<- mean(alldata$temp[alldata$chrontimes == k & alldata$month == 10],na.rm=T)
      temp2<- sd(alldata$temp[alldata$chrontimes == k  & alldata$month == 10],na.rm=T)
      temp3<- mean(alldata$humidity[alldata$chrontimes == k  & alldata$month == 10],na.rm=T)
      temp4<- sd(alldata$humidity[alldata$chrontimes == k  & alldata$month == 10],na.rm=T)
    } else if (j == "MJ22"){
      temp1<- mean(alldata$temp[alldata$chrontimes == k &  alldata$chrondate > "05/14/22" & alldata$chrondate < "06/16/22"],na.rm=T)
      temp2<- sd(alldata$temp[alldata$chrontimes == k &  alldata$chrondate > "05/14/22" & alldata$chrondate < "06/16/22"],na.rm=T)
      temp3<- mean(alldata$humidity[alldata$chrontimes == k &  alldata$chrondate > "05/14/22" & alldata$chrondate < "06/16/22"],na.rm=T)
      temp4<- sd(alldata$humidity[alldata$chrontimes == k &  alldata$chrondate > "05/14/22" & alldata$chrondate < "06/16/22"],na.rm=T)
    } else {
      temp1<- mean(alldata$temp[alldata$chrontimes == k & alldata$season==j],na.rm=T)
      temp2<- sd(alldata$temp[alldata$chrontimes == k & alldata$season==j],na.rm=T)
      temp3<- mean(alldata$humidity[alldata$chrontimes == k & alldata$season==j],na.rm=T)
      temp4<- sd(alldata$humidity[alldata$chrontimes == k & alldata$season==j],na.rm=T)
    } # end of else
    alldata.perhourcombined$meanT[alldata.perhourcombined$chrontimes == k & alldata.perhourcombined$season==j] <-temp1
    alldata.perhourcombined$sdT[alldata.perhourcombined$chrontimes == k & alldata.perhourcombined$season==j] <- temp2
    alldata.perhourcombined$meanH[alldata.perhourcombined$chrontimes == k & alldata.perhourcombined$season==j] <-temp3
    alldata.perhourcombined$sdH[alldata.perhourcombined$chrontimes == k & alldata.perhourcombined$season==j] <- temp4
  }
}
####### compute averages ##########

mean(alldata.perhourcombined$meanT[alldata.perhourcombined$season=="all year"]) # 27.0
mean(alldata.perhourcombined$meanT[alldata.perhourcombined$season=="dry"]) # 27.3
mean(alldata.perhourcombined$meanT[alldata.perhourcombined$season=="wet"]) # 26.8
mean(alldata$temp[alldata$month==10], na.rm=T) # 28.0
mean(alldata$temp[alldata$chrondate > "05/14/22" & alldata$chrondate < "06/16/22"], na.rm=T) # 26.5

mean(alldata.perhourcombined$meanH[alldata.perhourcombined$season=="all year"]) # 85.8
mean(alldata.perhourcombined$meanH[alldata.perhourcombined$season=="dry"]) # 84.9
mean(alldata.perhourcombined$meanH[alldata.perhourcombined$season=="wet"]) # 86.6
mean(alldata$humidity[alldata$month==10], na.rm=T) # 83.7
mean(alldata$humidity[alldata$chrondate > "05/14/22" & alldata$chrondate < "06/16/22"], na.rm=T) # 88.6




####### diurnal boxplots per wet & dry season per drop 16 x 3 plots ##########

#pdf(file = "Diurnal.pdf", paper="a4")
#par(mfrow=c(4,2))

# # first: show mean T, mean H, sd T and sd H across all locations
# # temperature
# plot(alldata.perhourcombined$chrontimes, 
#      alldata.perhourcombined$meanT,
#      main = "mean T all year for all locations", xlab="time", ylab="temp in C", 
#      ylim=c(20,40), type="l")
# plot(alldata.perhourcombined$chrontimes[alldata.perhourcombined$season=="wet"], 
#      alldata.perhourcombined$meanT[alldata.perhourcombined$season=="wet"],
#      main = "mean T in wet season for all locations", xlab="time", ylab="temp in C", 
#      ylim=c(20,40), type="l")
#      #, axis (1, at= c(0,6,12,18)))
#                                       # c("00:00:00", "06:00:00", "12:00:00", "18:00:00")))
# plot(alldata.perhourcombined$chrontimes[alldata.perhourcombined$season=="dry"], 
#      alldata.perhourcombined$meanT[alldata.perhourcombined$season=="dry"],
#      main = "mean T in dry season for all locations", xlab="time", ylab="temp in C", 
#      ylim=c(20,40), type="l")
# plot(alldata.perhourcombined$chrontimes, 
#      alldata.perhourcombined$sdT,
#      main = "sd T all year for all locations", xlab="time", ylab="temp in C", 
#      ylim=c(0,5), type="l")
# plot(alldata.perhourcombined$chrontimes[alldata.perhourcombined$season=="wet"], 
#      alldata.perhourcombined$sdT[alldata.perhourcombined$season=="wet"],
#      main = "sd T in wet season for all locations", xlab="time", ylab="temp in C", 
#      ylim=c(0,5), type="l")
# plot(alldata.perhourcombined$chrontimes[alldata.perhourcombined$season=="dry"], 
#      alldata.perhourcombined$sdT[alldata.perhourcombined$season=="dry"],
#      main = "sd T in dry season for all locations", xlab="time", ylab="temp in C", 
#      ylim=c(0,5), type="l")
# 
# # humidity
# plot(alldata.perhourcombined$chrontimes, 
#      alldata.perhourcombined$meanH,
#      main = "mean H all year for all locations", xlab="time", ylab="humidity in %", 
#      ylim=c(0,100), type="l")
# plot(alldata.perhourcombined$chrontimes[alldata.perhourcombined$season=="wet"], 
#      alldata.perhourcombined$meanH[alldata.perhourcombined$season=="wet"],
#      main = "mean H in wet season for all locations", xlab="time", ylab="humidity in %", 
#      ylim=c(0,100), type="l")
# plot(alldata.perhourcombined$chrontimes[alldata.perhourcombined$season=="dry"], 
#      alldata.perhourcombined$meanH[alldata.perhourcombined$season=="dry"],
#      main = "mean H in dry season for all locations", xlab="time", ylab="humidity in %", 
#      ylim=c(0,100), type="l")
# 
# plot(alldata.perhourcombined$chrontimes, 
#      alldata.perhourcombined$sdH,
#      main = "sd H all year for all locations", xlab="time", ylab="humidity in %", 
#      ylim=c(0,100), type="l")
# plot(alldata.perhourcombined$chrontimes[alldata.perhourcombined$season=="wet"], 
#      alldata.perhourcombined$sdH[alldata.perhourcombined$season=="wet"],
#      main = "sd H in wet season for all locations", xlab="time", ylab="humidity in %", 
#      ylim=c(0,100), type="l")
# plot(alldata.perhourcombined$chrontimes[alldata.perhourcombined$season=="dry"], 
#      alldata.perhourcombined$sdH[alldata.perhourcombined$season=="dry"],
#      main = "sd H in dry season for all locations", xlab="time", ylab="humidity in %", 
#      ylim=c(0,100), type="l")
# 
# 
# # second: scatterplots with one dot one location (drop)
# plot(alldata.perhour$chrontimes, 
#      alldata.perhour$meanT,
#      main = "mean T all year", xlab="time", ylab="temp in C", ylim=c(20,40))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="wet"], 
#      alldata.perhour$meanT[alldata.perhour$season=="wet"],
#      main = "mean T in wet season", xlab="time", ylab="temp in C", ylim=c(20,40))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="dry"], 
#      alldata.perhour$meanT[alldata.perhour$season=="dry"],
#      main = "mean T in dry season", xlab="time", ylab="temp in C", ylim=c(20,40))
# 
# plot(alldata.perhour$chrontimes, 
#      alldata.perhour$sdT,
#      main = "sd T all year", xlab="time", ylab="temp in C", ylim=c(0,5))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="wet"], 
#      alldata.perhour$sdT[alldata.perhour$season=="wet"],
#      main = "sd T in wet season", xlab="time", ylab="temp in C", ylim=c(0,5))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="dry"], 
#      alldata.perhour$sdT[alldata.perhour$season=="dry"],
#      main = "sd T in dry season", xlab="time", ylab="temp in C", ylim=c(0,5))
# 
# plot(alldata.perhour$chrontimes, 
#      alldata.perhour$meanH,
#      main = "mean H all year", xlab="time", ylab="humidity in %", ylim=c(40,100))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="wet"], 
#      alldata.perhour$meanH[alldata.perhour$season=="wet"],
#      main = "mean H in wet season", xlab="time", ylab="humidity in %", ylim=c(40,100))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="dry"], 
#      alldata.perhour$meanH[alldata.perhour$season=="dry"],
#      main = "mean H in dry season", xlab="time", ylab="humidity in %", ylim=c(40,100))
# 
# plot(alldata.perhour$chrontimes, 
#      alldata.perhour$sdH,
#      main = "sd H all year", xlab="time", ylab="humidity in %", ylim=c(0,20))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="wet"], 
#      alldata.perhour$sdH[alldata.perhour$season=="wet"],
#      main = "sd H in wet season", xlab="time", ylab="humidity in %", ylim=c(0,20))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="dry"], 
#      alldata.perhour$sdH[alldata.perhour$season=="dry"],
#      main = "sd H in dry season", xlab="time", ylab="humidity in %", ylim=c(0,20))

# repeat only for core seasons
#### Updated plots for paper revisions FIG4 ####
pdf(file = "DiurnalRevisions.pdf", paper="a4")

plot1<-ggplot(alldata.perhour[alldata.perhour$season=="MJ22",],aes(x=as.numeric(chrontimes[season=="MJ22"]*24),
                                       y=meanT[season=="MJ22"], color=location))+
  geom_line()+
  coord_cartesian(ylim=c(20,40))+
  expand_limits(x=0, y=20)+
  scale_x_continuous(breaks=seq(0,23, by=6))+
  scale_y_continuous(breaks=seq(20,40, by=10))+
  scale_color_manual(values=c("Drop4"="dark green","Drop8"="chartreuse 4",
                              "Drop2"="dark olive green","Drop22"="dark olive green 3", 
                              "Drop6"="chartreuse 2","Drop12"="dark cyan","Drop14"="dark khaki",
                              "Drop18"="dark golden rod 3","Drop21"="dark salmon",
                              "Drop17"="brown 1","Drop16"="dark sea green",
                              "Drop15"="coral4","Drop9"="cadetblue","Drop19"="burlywood 3",
                              "Drop1"="dark grey","Drop11"="azure4", guide="none")) + 
  labs(y="temp in C", x="time of day") +
  ggtitle("mean T in core wet season")+
  theme(legend.position="none")
#print(plot1)

plot2<-ggplot(alldata.perhour[alldata.perhour$season=="Oct21",],
              aes(x=as.numeric(chrontimes[season=="Oct21"]*24),
                  y=meanT[season=="Oct21"], color=location))+
  geom_line()+
  coord_cartesian(ylim=c(20,40))+
  expand_limits(x=0, y=20)+
  scale_x_continuous(breaks=seq(0,23, by=6))+
  scale_y_continuous(breaks=seq(20,40, by=10))+
  scale_color_manual(values=c("Drop4"="dark green","Drop8"="chartreuse 4",
                              "Drop2"="dark olive green","Drop22"="dark olive green 3", 
                              "Drop6"="chartreuse 2","Drop12"="dark cyan","Drop14"="dark khaki",
                              "Drop18"="dark golden rod 3","Drop21"="dark salmon",
                              "Drop17"="brown 1","Drop16"="dark sea green",
                              "Drop15"="coral4","Drop9"="cadetblue","Drop19"="burlywood 3",
                              "Drop1"="dark grey","Drop11"="azure4", guide="none")) + 
  labs(y="temp in C", x="time of day") +
  ggtitle("mean T in core dry season")+
  theme(legend.position="none")
#print(plot2)


plot3<-ggplot(alldata.perhour[alldata.perhour$season=="MJ22",],
              aes(x=as.numeric(chrontimes[season=="MJ22"]*24),
                  y=sdT[season=="MJ22"], color=location))+
  geom_line()+
  coord_cartesian(ylim=c(0,4))+
  expand_limits(x=0, y=0)+
  scale_x_continuous(breaks=seq(0,23, by=6))+
  scale_y_continuous(breaks=seq(0,4, by=2))+
  scale_color_manual(values=c("Drop4"="dark green","Drop8"="chartreuse 4",
                              "Drop2"="dark olive green","Drop22"="dark olive green 3", 
                              "Drop6"="chartreuse 2","Drop12"="dark cyan","Drop14"="dark khaki",
                              "Drop18"="dark golden rod 3","Drop21"="dark salmon",
                              "Drop17"="brown 1","Drop16"="dark sea green",
                              "Drop15"="coral4","Drop9"="cadetblue","Drop19"="burlywood 3",
                              "Drop1"="dark grey","Drop11"="azure4", guide="none")) + 
  labs(y="temp in C", x="time of day") +
  ggtitle("sd T in core wet season")+
  theme(legend.position="none")
#print(plot3)

plot4<-ggplot(alldata.perhour[alldata.perhour$season=="Oct21",],
              aes(x=as.numeric(chrontimes[season=="Oct21"]*24),
                  y=sdT[season=="Oct21"], color=location))+
  geom_line()+
  coord_cartesian(ylim=c(0,4))+
  expand_limits(x=0, y=0)+
  scale_x_continuous(breaks=seq(0,23, by=6))+
  scale_y_continuous(breaks=seq(0,4, by=2))+
  scale_color_manual(values=c("Drop4"="dark green","Drop8"="chartreuse 4",
                              "Drop2"="dark olive green","Drop22"="dark olive green 3", 
                              "Drop6"="chartreuse 2","Drop12"="dark cyan","Drop14"="dark khaki",
                              "Drop18"="dark golden rod 3","Drop21"="dark salmon",
                              "Drop17"="brown 1","Drop16"="dark sea green",
                              "Drop15"="coral4","Drop9"="cadetblue","Drop19"="burlywood 3",
                              "Drop1"="dark grey","Drop11"="azure4", guide="none")) + 
  labs(y="temp in C", x="time of day") +
  ggtitle("sd T in core dry season")+
  theme(legend.position="none")
#print(plot4)


# humidity
plot5<-ggplot(alldata.perhour[alldata.perhour$season=="MJ22",],aes(x=as.numeric(chrontimes[season=="MJ22"]*24),
                                                                   y=meanH[season=="MJ22"], color=location))+
  geom_line()+
  coord_cartesian(ylim=c(40,100))+
  expand_limits(x=0, y=40)+
  scale_x_continuous(breaks=seq(0,23, by=6))+
  scale_y_continuous(breaks=seq(40,100, by=30))+
  scale_color_manual(values=c("Drop4"="dark green","Drop8"="chartreuse 4",
                              "Drop2"="dark olive green","Drop22"="dark olive green 3", 
                              "Drop6"="chartreuse 2","Drop12"="dark cyan","Drop14"="dark khaki",
                              "Drop18"="dark golden rod 3","Drop21"="dark salmon",
                              "Drop17"="brown 1","Drop16"="dark sea green",
                              "Drop15"="coral4","Drop9"="cadetblue","Drop19"="burlywood 3",
                              "Drop1"="dark grey","Drop11"="azure4", guide="none")) + 
  labs(y="humidity in %", x="time of day") +
  ggtitle("mean rH in core wet season")+
  theme(legend.position="none")
#print(plot5)

plot6<-ggplot(alldata.perhour[alldata.perhour$season=="Oct21",],
              aes(x=as.numeric(chrontimes[season=="Oct21"]*24),
                  y=meanH[season=="Oct21"], color=location))+
  geom_line()+
  coord_cartesian(ylim=c(40,100))+
  expand_limits(x=0, y=40)+
  scale_x_continuous(breaks=seq(0,23, by=6))+
  scale_y_continuous(breaks=seq(40,100, by=30))+
  scale_color_manual(values=c("Drop4"="dark green","Drop8"="chartreuse 4",
                              "Drop2"="dark olive green","Drop22"="dark olive green 3", 
                              "Drop6"="chartreuse 2","Drop12"="dark cyan","Drop14"="dark khaki",
                              "Drop18"="dark golden rod 3","Drop21"="dark salmon",
                              "Drop17"="brown 1","Drop16"="dark sea green",
                              "Drop15"="coral4","Drop9"="cadetblue","Drop19"="burlywood 3",
                              "Drop1"="dark grey","Drop11"="azure4", guide="none")) + 
  labs(y="humidity in %", x="time of day") +
  ggtitle("mean rH in core dry season")+
  theme(legend.position="none")
#print(plot6)


plot7<-ggplot(alldata.perhour[alldata.perhour$season=="MJ22",],
              aes(x=as.numeric(chrontimes[season=="MJ22"]*24),
                  y=sdH[season=="MJ22"], color=location))+
  geom_line()+
  coord_cartesian(ylim=c(0,20))+
  expand_limits(x=0, y=0)+
  scale_x_continuous(breaks=seq(0,23, by=6))+
  scale_y_continuous(breaks=seq(0,20, by=10))+
  scale_color_manual(values=c("Drop4"="dark green","Drop8"="chartreuse 4",
                              "Drop2"="dark olive green","Drop22"="dark olive green 3", 
                              "Drop6"="chartreuse 2","Drop12"="dark cyan","Drop14"="dark khaki",
                              "Drop18"="dark golden rod 3","Drop21"="dark salmon",
                              "Drop17"="brown 1","Drop16"="dark sea green",
                              "Drop15"="coral4","Drop9"="cadetblue","Drop19"="burlywood 3",
                              "Drop1"="dark grey","Drop11"="azure4", guide="none")) + 
  labs(y="humidity in %", x="time of day") +
  ggtitle("sd rH in core wet season")+
  theme(legend.position="none")
#print(plot7)

plot8<-ggplot(alldata.perhour[alldata.perhour$season=="Oct21",],
              aes(x=as.numeric(chrontimes[season=="Oct21"]*24),
                  y=sdH[season=="Oct21"], color=location))+
  geom_line()+
  coord_cartesian(ylim=c(0,20))+
  expand_limits(x=0, y=0)+
  scale_x_continuous(breaks=seq(0,23, by=6))+
  scale_y_continuous(breaks=seq(0,20, by=10))+
  scale_color_manual(values=c("Drop4"="dark green","Drop8"="chartreuse 4",
                              "Drop2"="dark olive green","Drop22"="dark olive green 3", 
                              "Drop6"="chartreuse 2","Drop12"="dark cyan","Drop14"="dark khaki",
                              "Drop18"="dark golden rod 3","Drop21"="dark salmon",
                              "Drop17"="brown 1","Drop16"="dark sea green",
                              "Drop15"="coral4","Drop9"="cadetblue","Drop19"="burlywood 3",
                              "Drop1"="dark grey","Drop11"="azure4", guide="none")) + 
  labs(y="humidity in %", x="time of day") +
  ggtitle("sd rH in core dry season")+
  theme(legend.position="none")
#print(plot8)

multiplot<-ggarrange(plot1,plot2,plot3,plot4,plot5,plot6,plot7,plot8,
          labels=c("a","b","c","d","e","f","g","h"),ncol=2,nrow=4,
          common.legend = TRUE, legend = "left")
print(multiplot)

##### Core season plots used in paper #####
# plot(alldata.perhour$chrontimes, 
#      alldata.perhour$meanT,
#      # pch=19, col="grey", 
#      cex=0.6,
#      main = "mean T all year", xlab="time of day", ylab="temp in C", ylim=c(20,40),
#      xaxt="n")
# axis(1, at = c(times("0:00:00"),times("6:00:00"),times("12:00:00"),times("18:00:00")),
#      labels = c("0", "6", "12", "18"))
# 
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="MJ22"], 
#      alldata.perhour$meanT[alldata.perhour$season=="MJ22"],
#      cex=0.6,
#      main = "mean T in core wet season", xlab="time of day", ylab="temp in C", ylim=c(20,40),
#      xaxt="n")
# axis(1, at = c(times("0:00:00"),times("6:00:00"),times("12:00:00"),times("18:00:00")),
#      labels = c("0", "6", "12", "18"))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="Oct21"], 
#      alldata.perhour$meanT[alldata.perhour$season=="Oct21"],
#      cex=0.6,
#      main = "mean T in core dry season", xlab="time of day", ylab="temp in C", ylim=c(20,40),
#      xaxt="n")
# axis(1, at = c(times("0:00:00"),times("6:00:00"),times("12:00:00"),times("18:00:00")),
#      labels = c("0", "6", "12", "18"))
# 
# plot(alldata.perhour$chrontimes, 
#      alldata.perhour$sdT,
#      cex=0.6,
#      main = "sd T all year", xlab="time of day", ylab="temp in C", ylim=c(0,5),
#      xaxt="n")
# axis(1, at = c(times("0:00:00"),times("6:00:00"),times("12:00:00"),times("18:00:00")),
#      labels = c("0", "6", "12", "18"))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="MJ22"], 
#      alldata.perhour$sdT[alldata.perhour$season=="MJ22"],
#      cex=0.6,
#      main = "sd T in core wet season", xlab="time of day", ylab="temp in C", ylim=c(0,5),
#      xaxt="n")
# axis(1, at = c(times("0:00:00"),times("6:00:00"),times("12:00:00"),times("18:00:00")),
#      labels = c("0", "6", "12", "18"))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="Oct21"], 
#      alldata.perhour$sdT[alldata.perhour$season=="Oct21"],
#      cex=0.6,
#      main = "sd T in core dry season", xlab="time of day", ylab="temp in C", ylim=c(0,5),
#      xaxt="n")
# axis(1, at = c(times("0:00:00"),times("6:00:00"),times("12:00:00"),times("18:00:00")),
#      labels = c("0", "6", "12", "18"))
# 
# plot(alldata.perhour$chrontimes, 
#      alldata.perhour$meanH,
#      cex=0.6,
#      main = "mean rH all year", xlab="time of day", ylab="humidity in %", ylim=c(40,100),
#      xaxt="n")
# axis(1, at = c(times("0:00:00"),times("6:00:00"),times("12:00:00"),times("18:00:00")),
#      labels = c("0", "6", "12", "18"))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="MJ22"], 
#      alldata.perhour$meanH[alldata.perhour$season=="MJ22"],
#      cex=0.6,
#      main = "mean rH in core wet season", xlab="time of day", ylab="humidity in %", ylim=c(40,100),
#      xaxt="n")
# axis(1, at = c(times("0:00:00"),times("6:00:00"),times("12:00:00"),times("18:00:00")),
#      labels = c("0", "6", "12", "18"))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="Oct21"], 
#      alldata.perhour$meanH[alldata.perhour$season=="Oct21"],
#      cex=0.6,
#      main = "mean rH in core dry season", xlab="time of day", ylab="humidity in %", ylim=c(40,100),
#      xaxt="n")
# axis(1, at = c(times("0:00:00"),times("6:00:00"),times("12:00:00"),times("18:00:00")),
#      labels = c("0", "6", "12", "18"))
# 
# plot(alldata.perhour$chrontimes, 
#      alldata.perhour$sdH,
#      cex=0.6,
#      main = "sd rH all year", xlab="time of day", ylab="humidity in %", ylim=c(0,20),
#      xaxt="n")
# axis(1, at = c(times("0:00:00"),times("6:00:00"),times("12:00:00"),times("18:00:00")),
#      labels = c("0", "6", "12", "18"))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="MJ22"], 
#      alldata.perhour$sdH[alldata.perhour$season=="MJ22"],
#      cex=0.6,
#      main = "sd rH in core wet season", xlab="time of day", ylab="humidity in %", ylim=c(0,20),
#      xaxt="n")
# axis(1, at = c(times("0:00:00"),times("6:00:00"),times("12:00:00"),times("18:00:00")),
#      labels = c("0", "6", "12", "18"))
# plot(alldata.perhour$chrontimes[alldata.perhour$season=="Oct21"], 
#      alldata.perhour$sdH[alldata.perhour$season=="Oct21"],
#      cex=0.6,
#      main = "sd rH in core dry season", xlab="time of day", ylab="humidity in %", ylim=c(0,20),
#      xaxt="n")
# axis(1, at = c(times("0:00:00"),times("6:00:00"),times("12:00:00"),times("18:00:00")),
#      labels = c("0", "6", "12", "18"))




#for ( i in unique(alldata$location)) {
# #  
#   boxplot (alldata$temp[alldata$location == i] ~ 
#              alldata$chrontimes[alldata$location == i],
#            xlab = "time",
#            ylab = "temperature C",
#            main = paste0(i, " for all year"),
#            #xlim=c(min(alldata$chrontimes), max(alldata$chrontimes)),
#            ylim=c(20,45))
#   
#   for (j in unique(alldata$season)) {
#     boxplot (alldata$temp[alldata$location == i & alldata$season==j] ~ 
#                alldata$chrontimes[alldata$location == i & alldata$season==j],
#              xlab = "time",
#              ylab = "temperature C",
#              main = paste0(i, " for season: ", j),
#              #xlim=c(min(alldata$chrontimes), max(alldata$chrontimes)),
#              ylim=c(20,45))
#   }      
# }
# 
# for ( i in unique(alldata$location)) {
#   
#   boxplot (alldata$humidity[alldata$location == i] ~ 
#              alldata$chrontimes[alldata$location == i],
#            xlab = "time",
#            ylab = "humidity in %",
#            main = paste0(i, " for all year"),
#            #xlim=c(min(alldata$chrontimes), max(alldata$chrontimes)),
#            ylim=c(0,100))
#   
#   for (j in unique(alldata$season)) {
#     boxplot (alldata$humidity[alldata$location == i & alldata$season==j] ~ 
#                alldata$chrontimes[alldata$location == i & alldata$season==j],
#              xlab = "time",
#              ylab = "humidity in %",
#              main = paste0(i, " for season: ", j),
#              #xlim=c(min(alldata$chrontimes), max(alldata$chrontimes)),
#              ylim=c(0,100))
#   }      
# }
dev.off()



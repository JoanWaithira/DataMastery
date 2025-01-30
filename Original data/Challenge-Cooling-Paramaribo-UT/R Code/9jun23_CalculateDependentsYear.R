# This script is for observing the seasonal/year cycle.
# it takes the temperature and humidity readings and 
# computes dependent variables per drop location and per date
# daily.av.t   daily average temperature
# daily.av.h   daily average humidity
 
# Not sure yet what to do with these below 
# mean.t.wet / mean.t.dry   mean temperature of wet/dry season (average for this location)
# mean.h.wet / mean.h.dry   mean humidity of wet/dry season (average for this location)


# remove everything that might still be in workspace and load packages
rm(list=ls())
library(tidyverse)
library(chron)
library(ggplot2)
library(ggrepel)
library(ggpubr)

homepath<-"C://Users//SchwarzN//surfdrive - Schwarz, Nina (UT-ITC)@surfdrive.surf.nl//teaching-supervision//teaching_current//2024-SE-DataChallenge//ParamariboData"
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

################### Calculate daily averages and stdev #################

#creating a dataframe with date and location vectors.
drops.year<-expand.grid(unique(alldata.times$chrondate),
                        unique(alldata.times$location))
names(drops.year)<-c("chrondate","location")

#add season
for (i in unique(drops.year$chrondate)){
    drops.year$season[drops.year$chrondate==i]<-
                      as.character(alldata.times$season
                                [alldata.times$chrondate==i])
  }

# compute daily average temperature and humidity

for (i in unique(drops.year$chrondate)){  
  for (j in unique(drops.year$location)){   

  # Daily average temperature for the whole time period
  drops.year$daily.av.t[drops.year$chrondate==i & drops.year$location==j]<-
    mean(alldata.times$temp[alldata.times$chrondate==i & alldata.times$location==j],na.rm=T)
  # Daily average humidity for the whole time period
  drops.year$daily.av.h[drops.year$chrondate==i & drops.year$location==j]<-
    mean(alldata.times$humidity[alldata.times$chrondate==i & alldata.times$location==j], na.rm=T)
  
  # compute sdev of daily average temp and hum
    drops.year$daily.sd.t[drops.year$chrondate==i & drops.year$location==j]<-
      sd(alldata.times$temp[alldata.times$chrondate==i & alldata.times$location==j], na.rm=T)
    
    drops.year$daily.sd.h[drops.year$chrondate==i & drops.year$location==j]<-
      sd(alldata.times$humidity[alldata.times$chrondate==i & alldata.times$location==j], na.rm=T)
  }
}
names(drops.year)
print(drops.year)
#drops.year<-drops.year[,-4]

# write csv file to check if script works 
#write.csv(drops.year, file="yearPerDropCopy.csv")



#################################Cleaning the data####################
####Checking results: writes a csv with each date for all drops with daily.av.t 
# and daily.av.h values for each date and all drops. Values appear correct. 
# Values=NA where daily logs are days without measurements e.g. due to battery
# or have incomplete 24h logs.

drops.year<-na.omit(drops.year)
print(drops.year)
#write.csv(drops.year, file="yearPerDropCLEAN.csv")

#########Calculating the annual average & sd values of temp and humidity per drop ######
# instead of annual average, seasonal average could also be considered.

annual.means<-data.frame(unique(alldata.times$location))
names(annual.means)<-c("location")

  ###Calculate annual means and SD
for (i in unique(annual.means$location)){
  #mean 
  annual.means$annual.t[annual.means$location==i]<-
    mean(drops.year$daily.av.t[drops.year$location==i])

  annual.means$annual.h[annual.means$location==i]<-
    mean(drops.year$daily.av.h[drops.year$location==i])
  #sdev
  annual.means$sd_annual.t[annual.means$location==i]<-
    sd(drops.year$daily.av.t[drops.year$location==i])
  
  annual.means$sd_annual.h[annual.means$location==i]<-
    sd(drops.year$daily.av.h[drops.year$location==i])
}

print(annual.means)

  ###add annual mean and sd to drops.year
#Mean
for (i in unique(drops.year$location)) {
  for (j in unique(drops.year$chrondate)) {
   
    #annual t and h
     drops.year$annual.t[drops.year$location==i & drops.year$chrondate==j]<-
      annual.means$annual.t[annual.means$location==i] 
  
    drops.year$annual.h[drops.year$location==i & drops.year$chrondate==j]<-
      annual.means$annual.h[annual.means$location==i] 
  #sdev annual t and h
    drops.year$sd_annual.t[drops.year$location==i & drops.year$chrondate==j]<-
      annual.means$sd_annual.t[annual.means$location==i] 

    drops.year$sd_annual.h[drops.year$location==i & drops.year$chrondate==j]<-
      annual.means$sd_annual.h[annual.means$location==i] 
  }}

#write.csv(drops.year, file="dropsyear+stats.csv")
 
############# Plotting temp and humidity graphs into pdfs  ##############
library(ggplot2)
library(scales)
library(repr)
library(lubridate) 

drops.year$chrondate<-as.Date(drops.year$chrondate,"%m%d%y" )
 
  ##### Scatter plots: daily values + mean of each location separately ######

par(mar = c(5.1, 4.1, 4.1, 2.1))

  #temperature
pdf(file = "9junggplots_yearTemp_combi.pdf", paper="a4r") 
par(mfrow=c(3,1))
#colors<-c("daily temp"="black","mean daily temp"="blue","sd temp"="red") 
  
for ( i in unique(drops.year$location)){
    plot1<-ggplot()+
      geom_point(data=drops.year[drops.year$location==i,], 
                  aes(x=drops.year$chrondate[drops.year$location==i],
                      y=drops.year$daily.av.t[drops.year$location==i],
                      colour=as.factor(season))) +
      geom_line(data=drops.year[drops.year$location==i,],
                aes(x=drops.year$chrondate[drops.year$location==i],
                    y=drops.year$annual.t[drops.year$location==i],
                    colour="annual mean temp"))+
      coord_cartesian(ylim=c(23,32)) +
      scale_x_date(date_breaks="1 month",date_minor_breaks="1 week",
                   labels=date_format("%b")) +
      scale_y_continuous(breaks=seq(23,32, by=2))+
      geom_ribbon(y=drops.year$annual.t[drops.year$location==i], 
                  ymin=drops.year$annual.t[drops.year$location==i]-
                    drops.year$sd_annual.t[drops.year$location==i],
                  ymax=drops.year$annual.t[drops.year$location==i]+
                    drops.year$sd_annual.t[drops.year$location==i],
                  alpha=.2,colour='red') + 
      labs(y="Daily Temperature C", x="Month", colour="legend") +
      scale_colour_manual(values=c("#D5AF88","#888481","#403A34"))+
      ggtitle(i)
      print(ggarrange(plot1, ncol=1, nrow=1))
      }
  
figure<-ggarrange(plot1,ncol=4, nrow=4)
print(figure)
  dev.off() 

  #humidity
pdf(file = "ggplots_yearHum_combi.pdf", paper="a4r")
par(mfrow=c(3,1))
  #colors<-c("daily hum"="black", "mean daily hum"="blue") 
  
  for ( i in unique(drops.year$location)){
    plot2<-ggplot()+
      geom_point(data=drops.year[drops.year$location==i,], 
                 aes(x=drops.year$chrondate[drops.year$location==i],
                     y=drops.year$daily.av.h[drops.year$location==i],
                     colour=as.factor(season))) +
      geom_line(data=drops.year[drops.year$location==i,],
                aes(x=drops.year$chrondate[drops.year$location==i],
                    y=drops.year$annual.h[drops.year$location==i],
                    colour="annual hum"))+
      coord_cartesian(ylim=c(45,100)) +
      scale_x_date(date_breaks="1 month",date_minor_breaks="1 week",
                   labels=date_format("%b")) +
      scale_y_continuous(breaks=seq(45,100, by=10))+
      labs(y="Daily rel.humidity %", x="Month", colour="legend") +
      scale_colour_manual(values=c('cyan','magenta','blue'))+
      ggtitle(i)
    print(plot2)
  }
    dev.off() 
  
    
  ##### Boxplots per drop for temp and humidity #######  NOT INCLUDED
      #temp
drops.year$location <- as.factor(drops.year$location)
pdf(file="Boxplots_dailyT.pdf", paper="a4r")
  boxplot1<- ggplot(data=drops.year,
                    aes(x=location, 
                        y=daily.av.t),
                    color=location)+
    geom_boxplot(outlier.colour='red')
    print(boxplot1)
   ggsave("boxplots_dailyT.pdf", paper="a4r") 
   dev.off() 
  
   #humidity
drops.year$location <- as.factor(drops.year$location)
pdf(file="Boxplots_dailyH.pdf", paper="a4r")
   boxplot2<- ggplot(data=drops.year,
                     aes(x=location, 
                         y=daily.av.h),
                     color=location)+
     geom_boxplot(outlier.colour='red')
   print(boxplot2)
   ggsave("boxplots_dailyHum.pdf",width=7, height=7,paper="a4r") 
   dev.off() 
   

  ##### Stats plots: all annual average values + sd in 1 figure x location  ##### NOT INCLUDED
    #temp   
pdf(file = "ggplots_yearT_ALL.pdf", paper="a4r")
drops.year$location <- as.factor(drops.year$location)   
  plot3<-ggplot()+
       geom_point(data=drops.year, 
                  aes(x=drops.year$location,
                      y=drops.year$annual.t)) +
      geom_ribbon(aes(x=drops.year$location,y=drops.year$annual.t,
                ymin=(drops.year$annual.t-drops.year$sd_annual.t),
                ymax=(drops.year$annual.t+drops.year$sd_annual.t)), 
                group=1,alpha=.2) +
       coord_cartesian(ylim=c(24,30)) +
       scale_y_continuous(breaks=seq(24,30, by=2))+
       labs(y="Temperature C", x="Location") +
       ggtitle("Annual temp and sdev")
     print(plot3)
   dev.off()   
   
   #Hum   
pdf(file = "ggplots_yearH_ALL.pdf", paper="a4r")
drops.year$location <- as.factor(drops.year$location)   
  plot4<-ggplot()+
     geom_point(data=drops.year, 
                aes(x=drops.year$location,
                    y=drops.year$annual.h)) +
     geom_ribbon(aes(x=drops.year$location,y=drops.year$annual.h,
                     ymin=(drops.year$annual.h-drops.year$sd_annual.h),
                     ymax=(drops.year$annual.h+drops.year$sd_annual.h)), 
                 group=1,alpha=.2) +
     coord_cartesian(ylim=c(50,100)) +
     scale_y_continuous(breaks=seq(50,100, by=10))+
     labs(y="Rel. Humidity %", x="Location") +
     ggtitle("Annual hum and sdev")
   print(plot4)
   dev.off() 
   

  ##### (1) All daily values of all drops in 1 figure   #####  NOT INCLUDED
  #temp
    options(repr.plot.width=20, repr.plot.height=7)
    pdf(file = "Alldrops_xtime.pdf", paper="a4r", 
       options(repr.plot.width=20, repr.plot.height=7))  
   
     plot5<-ggplot()+
     geom_point(data=drops.year,
                aes(x=drops.year$chrondate, y=drops.year$daily.av.t,
                    colour=as.factor(season), 
                    shape=location))+
     coord_cartesian(ylim=c(23,32)) +
     scale_x_date(date_breaks="1 month",date_minor_breaks="1 week",
                  labels=date_format("%b")) +
     scale_y_continuous(breaks=seq(23,32, by=2))+
     labs(y="Daily Temperature C", x="Month", colour="legend") +
     ggtitle("Daily average T all drops")+
     scale_colour_manual(values=c('cyan','blue'))+
     scale_shape_manual(values=c(0,1,2,3,4,5,6,8,9,10,11,12,15,16,17,23,24))
     print(plot5)
  
     dev.off() 
     


 
  ##### (2) Daily and monthly temps averaged over all drops #####

across.drops<-data.frame(unique(alldata.times$chrondate))  #create new dataframe
names(across.drops)<-c("chrondate")
across.drops$chrondate<-as.Date(across.drops$chrondate)

#add season column
for (i in unique(across.drops$chrondate)){
  across.drops$season[across.drops$chrondate==i]<-
    as.character(drops.year$season[drops.year$chrondate==i])
}

###Calculate daily means + sdev TEMP & HUM   ###  INCLUDED
for (i in unique(across.drops$chrondate)){
  #temp
  across.drops$all.daily.t[across.drops$chrondate==i]<-
    mean(drops.year$daily.av.t[drops.year$chrondate==i])

  across.drops$sd_alldaily.t[across.drops$chrondate==i]<-
    sd(drops.year$daily.av.t[drops.year$chrondate==i])
  #humidity
  across.drops$all.daily.h[across.drops$chrondate==i]<-
    mean(drops.year$daily.av.h[drops.year$chrondate==i])

  across.drops$sd_alldaily.h[across.drops$chrondate==i]<-
    sd(drops.year$daily.av.h[drops.year$chrondate==i])
}

###Calculate monthly means + sdev TEMP + HUM  ###  NOT INCLUDED

across.drops$month<- format(across.drops$chrondate, format="%m-%Y")

across.drops$month<- factor(across.drops$month, 
                            levels=c("07-2021","08-2021","09-2021",
                                     "10-2021","11-2021","12-2021",
                                     "01-2022","02-2022","03-2022",
                                     "04-2022","05-2022","06-2022"))

#across.drops$month<- months(across.drops$chrondate)


#aggregate monthly values and add to across.drops dataframe
dfT<-data.frame(aggregate(all.daily.t~month, across.drops, mean))
dfT2<-data.frame(aggregate(all.daily.t~month, across.drops, sd))
dfT3<-merge(dfT,dfT2, by="month")
print(dfT3)

dfH<-data.frame(aggregate(all.daily.h~month, across.drops, mean,))
dfH2<-data.frame(aggregate(all.daily.h~month, across.drops, sd))
dfH3<-merge(dfH,dfH2, by="month")
print(dfH3)

for (i in unique(across.drops$month)) {
  for (j in unique(across.drops$chrondate)) {
   across.drops$all.monthly.t[across.drops$month==i & across.drops$chrondate==j]<-
      dfT3$all.daily.t.x[dfT3$month==i]
   across.drops$sd.monthly.t[across.drops$month==i & across.drops$chrondate==j]<-
      dfT3$all.daily.t.y[dfT3$month==i]
   across.drops$all.monthly.h[across.drops$month==i & across.drops$chrondate==j]<-
     dfH3$all.daily.h.x[dfH$month==i]
   across.drops$sd.monthly.h[across.drops$month==i & across.drops$chrondate==j]<-
     dfH3$all.daily.h.y[dfH3$month==i]
  }}

print(across.drops)

#write.csv(across.drops, file="acrossdrops.csv")

###Plot overall mean temp and humidity x day
#temperature
par(mar = c(5.1, 4.1, 4.1, 2.1))

pdf(file = "ggplots_yearOverallTemp.pdf", paper="a4r")

plot7<-ggplot()+
    geom_errorbar(aes(x=across.drops$chrondate, y=across.drops$all.daily.t,
                    ymin=across.drops$all.daily.t-across.drops$sd_alldaily.t,
                    ymax=across.drops$all.daily.t+across.drops$sd_alldaily.t,
                    colour='sd'))+ 
    geom_point(data=across.drops, 
               aes(x=across.drops$chrondate,
                   y=across.drops$all.daily.t,
                   colour=as.factor(season))) +
    coord_cartesian(ylim=c(24,30.5)) +
    scale_x_date(date_breaks="1 month",date_minor_breaks="1 week",
                 labels=date_format("%b")) +
    scale_y_continuous(breaks=seq(24,30, by=2))+
    labs(y="Daily T (C)", x="Month", colour="legend") +
    scale_colour_manual(values=c("#888481","#D5AF88","#403A34"))
  print(plot7)

  dev.off() 

###Plot overall mean temp and humidity x month  
  #temperature
  pdf(file = "monthlyT_acrossdrops.pdf", paper="a4r")
  
  plot8<-ggplot()+
    geom_point(data=across.drops, 
               aes(x=across.drops$month,
                   y=across.drops$all.monthly.t,
                   colour=as.factor(season))) +
    coord_cartesian(ylim=c(25,29)) +
    scale_y_continuous(breaks=seq(25,29, by=1))+
    geom_errorbar(aes(x=across.drops$month, y=across.drops$all.monthly.t,
                      ymin=across.drops$all.monthly.t-across.drops$sd.monthly.t,
                      ymax=across.drops$all.monthly.t+across.drops$sd.monthly.t,
                      alpha=.1,colour='SD'))+ 
    labs(y="Monthly T overall (C)", x="Month", colour="legend") +
    scale_colour_manual(values=c('cyan','red','blue'))+
    ggtitle("Monthly Temp across drops")
  print(plot8)
  
  dev.off()   
  
############# Land Surface Temperature #################
# (1) Seasonal LST absolute and standardized composite values per location, 
# ordered from low to high  <--- USED IN PAPER
# (2): Barplot met discrete x-as: wet season en dry season voor elk jaar
# Toevoegen Lijn met composite waarden voor wet en dry season
# Y-as: LST standardized    
# Werkt met gemiddelde LSTs van hele image, niet per locatie
# Optie 3: Barplot met discrete x-as: wet season en dry season voor elke drop
# y-as, voor 2021 en 2022. Composite waarden LSTs als lijn 

  ### INCLUDED section 3.2 ## Seasonal composite standardized LST per location
  
  #create dataframe
  seasonal.LSTs<-read.csv("AvLST_300m buffers.csv")
  seasonal.LSTs$season<-as.factor(seasonal.LSTs$season)
  seasonal.LSTs$location<-factor(seasonal.LSTs$location,
                                 levels=c("Drop4","Drop6","Drop18",
                                          "Drop8","Drop17","Drop16",
                                          "Drop12","Drop15","Drop14",
                                          "Drop22","Drop19","Drop9",
                                          "Drop2","Drop21","Drop1",
                                          "Drop11"))    #plot was showing weird order
  seasonal.LSTs$av_LSTsCOMP<-as.numeric(seasonal.LSTs$av_LSTsCOMP,na.rm=T)
  
  print(seasonal.LSTs)
  
  LSTcompplot<- ggplot(seasonal.LSTs,aes(x=location,
                                      y=av_LSTsCOMP,fill=season)) + 
    geom_bar(stat="identity", position="dodge")+
    scale_x_discrete() +
    ggtitle("Average standardized LST of each location 2018-2022 composite") +
    labs(y="Average LSTs (C)")
  
  print(LSTcompplot)
  dev.off()
  
  ### NOT INCLUDED # Seasonal range of LSTs composite per location
  #create dataframe
  seasonal.LSTs2<-read.csv("AvLST_300m buffers.csv")
  seasonal.LSTs2$season<-as.factor(seasonal.LSTs2$season)
  seasonal.LSTs2$location<-factor(seasonal.LSTs2$location,
                                 levels=c("Drop2","Drop9","Drop1",
                                          "Drop19","Drop8","Drop15",
                                          "Drop14","Drop18","Drop22",
                                          "Drop21","Drop11","Drop16",
                                          "Drop12","Drop17","Drop4",
                                          "Drop6"))    #plot was showing weird order
  seasonal.LSTs2$Range_LSTsCOMP<-as.numeric(seasonal.LSTs2$Range_LSTsCOMP,na.rm=T)
  
  LSTrangeplot<- ggplot(seasonal.LSTs2,aes(x=location,
                                         y=Range_LSTsCOMP,fill=season)) + 
    geom_bar(stat="identity", position="dodge")+
    scale_x_discrete() +
    ggtitle("Standardized LST range of each location 2018-2022 composite") +
    labs(y="LSTs range (C)")
  
  print(LSTrangeplot)
  dev.off()
  
  ### Seasonal absolute LST (INCLUDED) and absolute range (NOT INCLUDED)
  
  #create dataframe
  seasonal.LSTa<-read.csv("AvLSTComposite_300m buffers.csv")
  seasonal.LSTa$season<-as.factor(seasonal.LSTa$season)
  seasonal.LSTa$location<-factor(seasonal.LSTa$location,
                                  levels=c("Drop6","Drop4","Drop18",
                                           "Drop17","Drop16","Drop8",
                                           "Drop22","Drop15","Drop14",
                                           "Drop12","Drop9","Drop2",
                                           "Drop21","Drop19","Drop1",
                                           "Drop11"))    #plot was showing weird order
  seasonal.LSTa$absLST_mean<-as.numeric(seasonal.LSTa$absLST_mean,na.rm=T)
  
  LSTa_plot<- ggplot(seasonal.LSTa,aes(x=location,
                                      y=absLST_mean,fill=season,)) + 
    geom_bar(stat="identity", position="dodge")+
    scale_fill_manual(values=c("#A9A09E","#595756"))+
    scale_x_discrete() +
    coord_cartesian(ylim=c(25,36))+
    ggtitle("Seasonal LST 2018-2022 composite") +
    labs(y="LST (C)")
  
  print(LSTa_plot)
  dev.off()
  
## NOT INCLUDED ## Absolute LST range
  #create dataframe
  seasonal.LSTa$location<-factor(seasonal.LSTa$location,
                                 levels=c("Drop9","Drop2","Drop8",
                                          "Drop19","Drop18","Drop15",
                                          "Drop1","Drop22","Drop21",
                                          "Drop14","Drop16","Drop17",
                                          "Drop12","Drop4","Drop11",
                                          "Drop6"))    #plot was showing weird order
  seasonal.LSTa$absLST_range<-as.numeric(seasonal.LSTa$absLST_range,na.rm=T)
  
  LSTa_rangeplot<- ggplot(seasonal.LSTa,aes(x=location,
                                       y=absLST_range,fill=season)) + 
    geom_bar(stat="identity", position="dodge")+
    scale_x_discrete() +
    coord_cartesian(ylim=c(0,8))+
    ggtitle("Seasonal LST range 2018-2022 composite") +
    labs(y="LST range (C)")
  
  print(LSTa_rangeplot)
  
  ### NOT INCLUDED ## (2) Overall averaged across locations seasonal standardized LST per year
# Create dataframe with LSTs averages (across drop locations) for each year
LSTs.years<-read.csv("LSTs_Averagesperyear.csv")

LSTs.years$image_date<-as.Date(LSTs.years$image_date)
LSTs.years$year<-year(LSTs.years$image_date)   #derive year only for x-axis
print(LSTs.years$image_date) #if weird dates shown, check csv format is yyyy-mm-dd 
print(LSTs.years$year)  
LSTs.years$season<-as.factor(LSTs.years$season)

# Barplot of standardized LST averaged across buffer locations per year
names(LSTs.years)

pdf("LSTsacrosslocations_year.pdf", paper="a4r")

LSTplot1<- ggplot(LSTs.years, aes(x=year, y=AvLSTs_ALL, fill=season))+
            geom_bar(stat="identity", position="dodge") +
            ggtitle("Standardized LST averaged across locations") +
            labs(y="Average LSTs (C)")
      print(LSTplot1)  
dev.off()

## NOT INCLUDED ##  
### Seasonal standardized LST per location for 2021,2022 and composite

#create dataframe
seasonal.LSTs<-read.csv("AvLST_300m buffers.csv")
seasonal.LSTs$season<-as.factor(seasonal.LSTs$season)
seasonal.LSTs$location<-factor(seasonal.LSTs$location,
                               levels=c("Drop1","Drop2","Drop4",
                                        "Drop6","Drop8","Drop9",
                                        "Drop11","Drop12","Drop14",
                                        "Drop15","Drop16","Drop17",
                                        "Drop18","Drop19","Drop21",
                                        "Drop22"))    #plot was showing weird order
seasonal.LSTs$av_LSTs2021<-as.numeric(seasonal.LSTs$av_LSTs2021,na.rm=T)

print(seasonal.LSTs)

##Visualize 2021-2022 LSTs per location including composite LSTs average
library(ggpubr)

pdf(file = "LSTsplots_perlocation.pdf", paper="a4r")
par(mfrow=c(3,1))

ggarrange(LSTplot2,LSTplot3,LSTplot4, ncol=1,nrow=3)

LSTplot2<- ggplot(seasonal.LSTs,aes(x=location,
                                    y=av_LSTs2021,fill=season)) + 
  geom_bar(stat="identity", position="dodge")+
  scale_x_discrete() +
  ggtitle("Average standardized LST of each location 2021") +
  labs(y="Average LSTs (C)")


LSTplot3<- ggplot(seasonal.LSTs,aes(x=location,
                                      y=av_LSTs2022,fill=season)) + 
    geom_bar(stat="identity", position="dodge")+
    scale_x_discrete() +
    ggtitle("Average standardized LST of each location 2022") +
    labs(y="Average LSTs (C)")
 
LSTplot4<- ggplot(seasonal.LSTs,aes(x=location,
                                      y=av_LSTsCOMP,fill=season)) + 
    geom_bar(stat="identity", position="dodge")+
    scale_x_discrete() +
    ggtitle("Average standardized LST of each location 2018-2022 composite") +
    labs(y="Average LSTs (C)")
  
print(LSTplot2,LSTplot3,LSTplot4)
  
  dev.off()

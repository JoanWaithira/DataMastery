# This file screens data included in Paramaribodropsall.csv


### always good to check
library(installr)
updateR()

# remove everything that might still be in workspace and load packages
rm(list=ls())
library(tidyverse)
library("PerformanceAnalytics")

homepath<-"C://Users//SchwarzN//Surfdrive//outreach//publications//work-in-progress//LB_climateParamaribo//Data//"
setwd(homepath)


############## read csv files ##############

alldata<-read.csv("Paramaribodropsall.csv")
names(alldata)


############## create overview pdf  ##############
alldata.metric<-select(alldata,
                       elevation, dist.river, dist.commerc, 
                       buff10.lc.tg, buff10.lc.t, buff10.lc.i, 
                       buff300.lc.tg, buff300.lc.t, buff300.lc.i,
                       mean.t.wet, mean.t.dry, mean.t.year, mean.t.oct21, mean.t.mj22,
                       mean.h.wet, mean.h.dry, mean.h.year, mean.h.mj22, mean.h.mj22,
                       min.t.wet.night, min.t.dry.night, min.t.oct21.night, min.t.mj22.night,
                       range.t.wet.night, range.t.dry.night, range.t.oct21.night, range.t.mj22.night,
                       max.t.10he, max.h.10he,
                       av_LSTsCOMP.wet, av_LSTsCOMP.dry) 

summary(alldata.metric)
pdf(file = "Correlations.pdf", paper="special", width=50, height=50)
chart.Correlation(alldata.metric, histogram=TRUE, pch=19)
dev.off()


############## compute correlations among independents and save them as tables ###############
alldata.independent<-select(alldata,
                       elevation, dist.river, dist.commerc, 
                       buff10.lc.tg, buff10.lc.t, buff10.lc.i, 
                       buff300.lc.tg, buff300.lc.t, buff300.lc.i)
require(Hmisc) 

independents.corrcoefficients <- rcorr(as.matrix(alldata.independent), type = "pearson")$r
independents.corrpvalues <- rcorr(as.matrix(alldata.independent), type = "pearson")$P
write.csv(independents.corrcoefficients, file="independents.corrcoefficients.csv")
write.csv(independents.corrpvalues, file="independents.corrpvalues.csv")

############## investigate categorical independents ###############

# spot.surface
# buff10.surface
# buff10.vegstr

pdf(file = "mosaicplots_boxplots.pdf", width=7, height=15)
    #paper="a4")
par(mfrow=c(3,1))
counts<-table(alldata$spot.surface, alldata$buff10.surface)
mosaicplot(counts, xlab='spot surface', ylab='buffer 10 surface',main=' ', las=2)

counts<-table(alldata$spot.surface, alldata$buff10.vegstr)
mosaicplot(counts, xlab='spot surface', ylab='veg structure',main=' ', las=2)

counts<-table(alldata$buff10.surface, alldata$buff10.vegstr)
mosaicplot(counts, xlab='buffer 10 surface', ylab='buffer 10 veg structure',main=' ', las=2)

par(mfrow=c(9,1))
boxplot(alldata$elevation~alldata$buff10.surface,
        ylab="elevation [m]", xlab="surface 10m buffer")
boxplot(alldata$dist.river~alldata$buff10.surface,
        ylab="distance to river [km]", xlab="surface 10m buffer")
boxplot(alldata$dist.commerc~alldata$buff10.surface,
        ylab="distance to comm. centre [km]", xlab="surface 10m buffer")
boxplot(alldata$buff10.lc.i~alldata$buff10.surface,
        ylab="impervious in 10m buffer [%]", xlab="surface 10m buffer")
boxplot(alldata$buff10.lc.tg~alldata$buff10.surface,
        ylab="total green in 10m buffer [%]", xlab="surface 10m buffer")
boxplot(alldata$buff10.lc.t~alldata$buff10.surface,
        ylab="trees in 10m buffer [%]", xlab="surface 10m buffer")
boxplot(alldata$buff300.lc.i~alldata$buff10.surface,
        ylab="impervious in 300m buffer [%]", xlab="surface 10m buffer")
boxplot(alldata$buff300.lc.tg~alldata$buff10.surface,
        ylab="total green in 300m buffer [%]", xlab="surface 10m buffer")
boxplot(alldata$buff300.lc.t~alldata$buff10.surface,
        ylab="trees in 300m buffer [%]", xlab="surface 10m buffer")

boxplot(alldata$elevation~alldata$buff10.vegstr,
        ylab="elevation [m]", xlab="vegetation structure 10m buffer")
boxplot(alldata$dist.river~alldata$buff10.vegstr,
        ylab="distance to river [km]", xlab="vegetation structure 10m buffer")
boxplot(alldata$dist.commerc~alldata$buff10.vegstr,
        ylab="distance to comm. centre [km]", xlab="vegetation structure 10m buffer")
boxplot(alldata$buff10.lc.i~alldata$buff10.vegstr,
        ylab="impervious in 10m buffer [%]", xlab="vegetation structure 10m buffer")
boxplot(alldata$buff10.lc.tg~alldata$buff10.vegstr,
        ylab="total green in 10m buffer [%]", xlab="vegetation structure 10m buffer")
boxplot(alldata$buff10.lc.t~alldata$buff10.vegstr,
        ylab="trees in 10m buffer [%]", xlab="vegetation structure 10m buffer")
boxplot(alldata$buff300.lc.i~alldata$buff10.vegstr,
        ylab="impervious in 300m buffer [%]", xlab="vegetation structure 10m buffer")
boxplot(alldata$buff300.lc.tg~alldata$buff10.vegstr,
        ylab="total green in 300m buffer [%]", xlab="vegetation structure 10m buffer")
boxplot(alldata$buff300.lc.t~alldata$buff10.vegstr,
        ylab="trees in 300m buffer [%]", xlab="vegetation structure 10m buffer")

boxplot(alldata$elevation~alldata$spot.surface,
        ylab="elevation [m]", xlab="surface under logger")
boxplot(alldata$dist.river~alldata$spot.surface,
        ylab="distance to river [km]", xlab="surface under logger")
boxplot(alldata$dist.commerc~alldata$spot.surface,
        ylab="distance to comm. centre [km]", xlab="surface under logger")
boxplot(alldata$buff10.lc.i~alldata$spot.surface,
        ylab="impervious in 10m buffer [%]", xlab="surface under logger")
boxplot(alldata$buff10.lc.tg~alldata$spot.surface,
        ylab="total green in 10m buffer [%]", xlab="surface under logger")
boxplot(alldata$buff10.lc.t~alldata$spot.surface,
        ylab="trees in 10m buffer [%]", xlab="surface under logger")
boxplot(alldata$buff300.lc.i~alldata$spot.surface,
        ylab="impervious in 300m buffer [%]", xlab="surface under logger")
boxplot(alldata$buff300.lc.tg~alldata$spot.surface,
        ylab="total green in 300m buffer [%]", xlab="surface under logger")
boxplot(alldata$buff300.lc.t~alldata$spot.surface,
        ylab="trees in 300m buffer [%]", xlab="surface under logger")
dev.off()

############ 10 June 2023 for paper ################
pdf(file = "location_mosaicplots-new.pdf")
par(mfrow=c(1,1))
counts<-table(alldata$spot.surface, alldata$buff10.surface)
mosaicplot(counts, xlab='spot surface', ylab='buffer 10 surface',main=' ', las=2)

counts<-table(alldata$spot.surface, alldata$buff10.vegstr)
mosaicplot(counts, xlab='spot surface', ylab='veg structure',main=' ', las=2)

counts<-table(alldata$buff10.surface, alldata$buff10.vegstr)
mosaicplot(counts, xlab='buffer 10 surface', ylab='buffer 10 veg structure',main=' ', las=2)
dev.off()


summary(as.factor(alldata$spot.surface))
summary(as.factor(alldata$buff10.surface))
#recode spot.surface and buff10.surface
#"Impervious" "Imp."
#"Vegetation" "Veg."
#"Organic matter" "Org. m."
#"Bare with veg" "Bare + veg"
#"Impervious / bare" "Imp + b"
alldata$spot.surface[alldata$spot.surface=="Impervious"]<-"Imp"
alldata$spot.surface[alldata$spot.surface=="Vegetation"]<-"Veg"
alldata$spot.surface[alldata$spot.surface=="Organic matter"]<-"Org m"
alldata$spot.surface[alldata$spot.surface=="Bare with veg"]<-"B + v"
alldata$spot.surface[alldata$spot.surface=="Impervious / bare"]<-"Imp + b"

alldata$buff10.surface[alldata$buff10.surface=="Impervious"]<-"Imp"
alldata$buff10.surface[alldata$buff10.surface=="Vegetation"]<-"Veg"
alldata$buff10.surface[alldata$buff10.surface=="Organic matter"]<-"Org m"
alldata$buff10.surface[alldata$buff10.surface=="Bare with vegetation"]<-"B + v"
alldata$buff10.surface[alldata$buff10.surface=="Impervious / bare"]<-"Imp + b"

summary(as.factor(alldata$buff10.vegstr))
alldata$buff10.vegstr[alldata$buff10.vegstr=="Forest/trees"]<-"F + t"


pdf(file = "location_boxplots-new.pdf", width=8, height=15)

par(mfrow=c(5,2))
boxplot(alldata$elevation~alldata$buff10.surface,
        ylab="elevation [m]", xlab="surface 10m buffer")
boxplot(alldata$dist.river~alldata$buff10.surface,
        ylab="distance to river [km]", xlab="surface 10m buffer")
boxplot(alldata$dist.commerc~alldata$buff10.surface,
        ylab="distance to comm. centre [km]", xlab="surface 10m buffer")
boxplot(alldata$buff10.lc.i~alldata$buff10.surface,
        ylab="impervious in 10m buffer [%]", xlab="surface 10m buffer")
boxplot(alldata$buff10.lc.tg~alldata$buff10.surface,
        ylab="total green in 10m buffer [%]", xlab="surface 10m buffer")
boxplot(alldata$buff10.lc.t~alldata$buff10.surface,
        ylab="trees in 10m buffer [%]", xlab="surface 10m buffer")
boxplot(alldata$buff300.lc.i~alldata$buff10.surface,
        ylab="impervious in 300m buffer [%]", xlab="surface 10m buffer")
boxplot(alldata$buff300.lc.tg~alldata$buff10.surface,
        ylab="total green in 300m buffer [%]", xlab="surface 10m buffer")
boxplot(alldata$buff300.lc.t~alldata$buff10.surface,
        ylab="trees in 300m buffer [%]", xlab="surface 10m buffer")

plot.new()

boxplot(alldata$elevation~alldata$buff10.vegstr,
        ylab="elevation [m]", xlab="vegetation structure 10m buffer")
boxplot(alldata$dist.river~alldata$buff10.vegstr,
        ylab="distance to river [km]", xlab="vegetation structure 10m buffer")
boxplot(alldata$dist.commerc~alldata$buff10.vegstr,
        ylab="distance to comm. centre [km]", xlab="vegetation structure 10m buffer")
boxplot(alldata$buff10.lc.i~alldata$buff10.vegstr,
        ylab="impervious in 10m buffer [%]", xlab="vegetation structure 10m buffer")
boxplot(alldata$buff10.lc.tg~alldata$buff10.vegstr,
        ylab="total green in 10m buffer [%]", xlab="vegetation structure 10m buffer")
boxplot(alldata$buff10.lc.t~alldata$buff10.vegstr,
        ylab="trees in 10m buffer [%]", xlab="vegetation structure 10m buffer")
boxplot(alldata$buff300.lc.i~alldata$buff10.vegstr,
        ylab="impervious in 300m buffer [%]", xlab="vegetation structure 10m buffer")
boxplot(alldata$buff300.lc.tg~alldata$buff10.vegstr,
        ylab="total green in 300m buffer [%]", xlab="vegetation structure 10m buffer")
boxplot(alldata$buff300.lc.t~alldata$buff10.vegstr,
        ylab="trees in 300m buffer [%]", xlab="vegetation structure 10m buffer")

plot.new()

boxplot(alldata$elevation~alldata$spot.surface,
        ylab="elevation [m]", xlab="surface under logger")
boxplot(alldata$dist.river~alldata$spot.surface,
        ylab="distance to river [km]", xlab="surface under logger")
boxplot(alldata$dist.commerc~alldata$spot.surface,
        ylab="distance to comm. centre [km]", xlab="surface under logger")
boxplot(alldata$buff10.lc.i~alldata$spot.surface,
        ylab="impervious in 10m buffer [%]", xlab="surface under logger")
boxplot(alldata$buff10.lc.tg~alldata$spot.surface,
        ylab="total green in 10m buffer [%]", xlab="surface under logger")
boxplot(alldata$buff10.lc.t~alldata$spot.surface,
        ylab="trees in 10m buffer [%]", xlab="surface under logger")
boxplot(alldata$buff300.lc.i~alldata$spot.surface,
        ylab="impervious in 300m buffer [%]", xlab="surface under logger")
boxplot(alldata$buff300.lc.tg~alldata$spot.surface,
        ylab="total green in 300m buffer [%]", xlab="surface under logger")
boxplot(alldata$buff300.lc.t~alldata$spot.surface,
        ylab="trees in 300m buffer [%]", xlab="surface under logger")
dev.off()





############## compute correlations among dependents and save them as tables ###############

alldata.dependent<-select(alldata,
                          mean.t.year, mean.t.oct21, mean.t.mj22,
                          mean.h.year, mean.h.oct21, mean.h.mj22,
                          min.t.year.night, min.t.oct21.night, min.t.mj22.night,
                          range.t.year.night, range.t.oct21.night, range.t.mj22.night,
                          max.t.10he, max.h.10he,
                          av_LSTsCOMP.wet, av_LSTsCOMP.dry) 
require(Hmisc) 

dependents.corrcoefficients <- rcorr(as.matrix(alldata.dependent), type = "pearson")$r
dependents.corrpvalues <- rcorr(as.matrix(alldata.dependent), type = "pearson")$P
write.csv(dependents.corrcoefficients, file="dependents.corrcoefficients.csv")
write.csv(dependents.corrpvalues, file="dependents.corrpvalues.csv")

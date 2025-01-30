# This file tests the effects of independents onto dependents

### always good to check
library(installr)
updateR()

# remove everything that might still be in workspace and load packages
rm(list=ls())
library(tidyverse)
library("PerformanceAnalytics")
library("psych")

homepath<-"C://Users//SchwarzN//Surfdrive//outreach//publications//workInProgress//LB_climateParamaribo//Data//"
setwd(homepath)


############## read csv files ##############

alldata<-read.csv("Paramaribodropsall.csv")
names(alldata)

############## create overview pdf for metric variables ##############
alldata.metric<-select(alldata,
                       elevation, dist.commerc, 
                       buff10.lc.t, buff10.lc.i, 
                       buff300.lc.t, buff300.lc.i,
                       mean.t.year, 
                       mean.h.year, 
                       min.t.oct21.night, min.t.mj22.night,
                       range.t.oct21.night, range.t.mj22.night,
                       av_LSTsCOMP.dry) 

summary(alldata.metric)



pdf(file = "Influences.pdf", paper="special", width=50, height=50)
chart.Correlation(alldata.metric, histogram=TRUE, pch=19)
dev.off()


#########################################################################################
# Major revision 1 - produce correlations with Hommel adjustment for multiple comparisons
# first: correlations among location variables
alldata.location<-select(alldata,
                         elevation, dist.river, dist.commerc, 
                         buff10.lc.tg, buff10.lc.t, buff10.lc.i, 
                         buff300.lc.tg, buff300.lc.t, buff300.lc.i)
# print(corr.test(alldata.location, adjust="holm")$stars, quote=FALSE)
print(corr.test(alldata.location, adjust="hommel")$stars, quote=FALSE)

# second: correlations among micro climate variables
alldata.dependent<-select(alldata,
                          mean.t.year, mean.t.oct21, mean.t.mj22,
                          mean.h.year, mean.h.oct21, mean.h.mj22,
                          min.t.year.night, min.t.oct21.night, min.t.mj22.night,
                          range.t.year.night, range.t.oct21.night, range.t.mj22.night,
                          max.t.10he, max.h.10he,
                          av_LSTsCOMP.wet, av_LSTsCOMP.dry) 
write.csv(print(corr.test(alldata.dependent, adjust="hommel")$stars, quote=FALSE), file="corr_depend_Hommel.csv", )

# third: correlations independent and  micro climate variables
alldata.selected<-select(alldata,
                       elevation, dist.commerc, 
                       buff10.lc.t, buff300.lc.t, buff300.lc.i,
                       mean.t.year, 
                       mean.h.oct21, mean.h.mj22,
                       min.t.oct21.night, min.t.mj22.night,
                       range.t.oct21.night, range.t.mj22.night,
                       max.h.10he,
                       av_LSTsCOMP.dry) 
write.csv(print(corr.test(alldata.selected, adjust="hommel")$stars, quote=FALSE), file="corr_selected_Hommel.csv", )


############## correlations with metric variables ##############

require(Hmisc) 

influences.corrcoefficients <- rcorr(as.matrix(alldata.metric), type = "pearson")$r
influences.corrpvalues <- rcorr(as.matrix(alldata.metric), type = "pearson")$P
write.csv(influences.corrcoefficients, file="influences.corrcoefficients.csv")
write.csv(influences.corrpvalues, file="influences.corrpvalues.csv")


# categorical variables ###################
summary(as.factor(alldata$spot.surface))
alldata$spot.surface<-as.factor(alldata$spot.surface)
levels(alldata$spot.surface)
levels(alldata$spot.surface)[levels(alldata$spot.surface)=='Organic matter'] <- 'Org. mat.'
levels(alldata$spot.surface)[levels(alldata$spot.surface)=='Impervious'] <- 'Imperv.'
levels(alldata$spot.surface)[levels(alldata$spot.surface)=='Bare with veg'] <- 'Bare + veg.'
levels(alldata$spot.surface)[levels(alldata$spot.surface)=='Vegetation'] <- 'Veg.'
levels(alldata$spot.surface)


summary(as.factor(alldata$buff10.vegstr))
alldata$buff10.vegstr.label<-alldata$buff10.vegstr
alldata$buff10.vegstr.label[alldata$buff10.vegstr.label=="none"]<-"None\n(N=4)"
alldata$buff10.vegstr.label[alldata$buff10.vegstr.label=="Only trees"]<-"Only trees\n(N=4)"
alldata$buff10.vegstr.label[alldata$buff10.vegstr.label=="Forest/trees"]<-"Forest/trees\n(N=5)"
alldata$buff10.vegstr.label[alldata$buff10.vegstr.label=="Grass/shrub"]<-"Grass/shrub\n(N=3)"
alldata$buff10.vegstr.label<-as.factor(alldata$buff10.vegstr.label)
summary(alldata$buff10.vegstr.label)

# summary(as.factor(alldata$buff10.vegstr))
# alldata$buff10.vegstr.label<-alldata$buff10.vegstr
# alldata$buff10.vegstr.label[alldata$buff10.vegstr.label=="none"]<-"None \n N=4"
# alldata$buff10.vegstr.label[alldata$buff10.vegstr.label=="Only trees"]<-"Only trees \n N=4"
# alldata$buff10.vegstr.label[alldata$buff10.vegstr.label=="Forest/trees"]<-"Forest/trees \n N=5"
# alldata$buff10.vegstr.label[alldata$buff10.vegstr.label=="Grass/shrub"]<-"Grass/shrub \n N=3"
# alldata$buff10.vegstr.label<-as.factor(alldata$buff10.vegstr.label)
# summary(alldata$buff10.vegstr.label)

summary(as.factor(alldata$spot.surface))
alldata$spot.surface.label<-as.character(alldata$spot.surface)
alldata$spot.surface.label[alldata$spot.surface.label=="Bare"]<-"Bare\n(N=3)"
alldata$spot.surface.label[alldata$spot.surface.label=="Bare + veg."]<-"Bare + veg\n(N=5)"
alldata$spot.surface.label[alldata$spot.surface.label=="Imperv."]<-"Imperv.\n(N=4)"
alldata$spot.surface.label[alldata$spot.surface.label=="Org. mat."]<-"Org. mat.\n(N=2)"
alldata$spot.surface.label[alldata$spot.surface.label=="Veg."]<-"Veg.\n(N=2)"
alldata$spot.surface.label<-as.factor(alldata$spot.surface.label)
summary(alldata$spot.surface.label)

# summary(as.factor(alldata$spot.surface))
# alldata$spot.surface.label<-as.character(alldata$spot.surface)
# alldata$spot.surface.label[alldata$spot.surface.label=="Bare"]<-"Bare \n N=3"
# alldata$spot.surface.label[alldata$spot.surface.label=="Bare + veg."]<-"Bare + veg \n N=5"
# alldata$spot.surface.label[alldata$spot.surface.label=="Imperv."]<-"Imperv. \n N=4"
# alldata$spot.surface.label[alldata$spot.surface.label=="Org. mat."]<-"Org. mat. \n N=2"
# alldata$spot.surface.label[alldata$spot.surface.label=="Veg."]<-"Veg. \n N=2"
# alldata$spot.surface.label<-as.factor(alldata$spot.surface.label)
# summary(alldata$spot.surface.label)

# boxplots with categorical variables ###################
pdf(file = "Influences_boxplots-revision1.pdf", height=35, width=10)
par(mfrow=c(9,2))
par(mar = c(13, 7, 4, 2) + 0.1) # margins of the plot
# original was c(12, 4, 4, 2) + 0.1)
par(mgp=c(3,1,0))

boxplot(alldata$mean.t.year~alldata$buff10.vegstr.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Mean annual temp [ºC]", line = 5, cex.lab=2.1)
title(xlab="Vegetation structure 10 m buffer", line = 11, cex.lab=2.1)
boxplot(alldata$mean.t.year~alldata$spot.surface.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Mean annual temp [ºC]", line = 5, cex.lab=2.1)
title(xlab="Surface under logger", line = 11, cex.lab=2.1)


boxplot(alldata$mean.h.oct21~alldata$buff10.vegstr.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Mean humidity dry [%]", line = 5, cex.lab=2.1)
title(xlab="Vegetation structure 10 m buffer", line = 11, cex.lab=2.1)
boxplot(alldata$mean.h.oct21~alldata$spot.surface.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Mean humidity dry [%]", line = 5, cex.lab=2.1)
title(xlab="Surface under logger", line = 11, cex.lab=2.1)

boxplot(alldata$mean.h.mj22~alldata$buff10.vegstr.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Mean humidity wet [%]", line = 5, cex.lab=2.1)
title(xlab="Vegetation structure 10 m buffer", line = 11, cex.lab=2.1)
boxplot(alldata$mean.h.mj22~alldata$spot.surface.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Mean humidity wet [%]", line = 5, cex.lab=2.1)
title(xlab="Surface under logger", line = 11, cex.lab=2.1)

boxplot(alldata$min.t.oct21.night~alldata$buff10.vegstr.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Min night temp. dry [ºC]", line = 5, cex.lab=2.1)
title(xlab="Vegetation structure 10 m buffer", line = 11, cex.lab=2.1)
boxplot(alldata$min.t.oct21.night~alldata$spot.surface.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Min night temp. dry [ºC]", line = 5, cex.lab=2.1)
title(xlab="Surface under logger", line = 11, cex.lab=2.1)

boxplot(alldata$min.t.mj22.night~alldata$buff10.vegstr.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Min night temp. wet [ºC]", line = 5, cex.lab=2.1)
title(xlab="Vegetation structure 10 m buffer", line = 11, cex.lab=2.1)
boxplot(alldata$min.t.mj22.night~alldata$spot.surface.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Min night temp. wet [ºC]", line = 5, cex.lab=2.1)
title(xlab="Surface under logger", line = 11, cex.lab=2.1)

boxplot(alldata$range.t.oct21.night~alldata$buff10.vegstr.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Range night temp. dry [ºC]", line = 5, cex.lab=2.1)
title(xlab="Vegetation structure 10 m buffer", line = 11, cex.lab=2.1)
boxplot(alldata$range.t.oct21.night~alldata$spot.surface.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Range night temp. dry [ºC]", line = 5, cex.lab=2.1)
title(xlab="Surface under logger", line = 11, cex.lab=2.1)

boxplot(alldata$range.t.mj22.night~alldata$buff10.vegstr.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Range night temp. wet [ºC]", line = 5, cex.lab=2.1)
title(xlab="Vegetation structure 10 m buffer", line = 11, cex.lab=2.1)
boxplot(alldata$range.t.mj22.night~alldata$spot.surface.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Range night temp. wet [ºC]", line = 5, cex.lab=2.1)
title(xlab="Surface under logger", line = 11, cex.lab=2.1)

boxplot(alldata$max.h.10he~alldata$buff10.vegstr.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Max humidity extremes [%]", line = 5, cex.lab=2.1)
title(xlab="Vegetation structure 10 m buffer", line = 11, cex.lab=2.1)
boxplot(alldata$max.h.10he~alldata$spot.surface.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Max humdity extremes [%]", line = 5, cex.lab=2.1)
title(xlab="Surface under logger", line = 11, cex.lab=2.1)

boxplot(alldata$av_LSTsCOMP.dry~alldata$buff10.vegstr.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Land surface temp. dry [ºC]", line = 5, cex.lab=2.1)
title(xlab="Vegetation structure 10 m buffer", line = 11, cex.lab=2.1)
boxplot(alldata$av_LSTsCOMP.dry~alldata$spot.surface.label, ylab="", xlab="",las=2, cex.axis=2)
title(ylab="Land surface temp. dry [ºC]", line = 5, cex.lab=2.1)
title(xlab="Surface under logger", line = 11, cex.lab=2.1)

dev.off()


## Kruskal-Wallis test to compare more than two groups, alternative to one-way ANOVA, non-parametric

kruskal.test(mean.t.year ~ buff10.vegstr,  data=alldata)
pairwise.wilcox.test(alldata$mean.t.year, alldata$buff10.vegstr,
                     p.adjust.method = "BH") # BH  Benjamini & Hochberg (1995) correction less conservative than Bonferroni
# p-value = 0.01835
# Forest/trees Grass/shrub none 
# Grass/shrub 0.071        -           -    
#   none        0.048        0.823       -    
#   Only trees  0.048        0.857       0.823

kruskal.test(mean.t.year ~ spot.surface,  data=alldata)
#p-value = 0.09884
pairwise.wilcox.test(alldata$mean.t.year, alldata$spot.surface,
                     p.adjust.method = "BH") 
# Bare Bare + veg. Imperv. Org. mat.
# Bare + veg. 0.50 -           -       -        
#   Imperv.     0.86 0.44        -       -        
#   Org. mat.   0.50 0.44        0.44    -        
#   Veg.        0.86 0.86        0.76    0.56   
kruskal.test(min.t.oct21.night ~ buff10.vegstr,  data=alldata)
# p-value = 0.2529
kruskal.test(min.t.oct21.night ~ spot.surface,  data=alldata)
# p-value = 0.1353

kruskal.test(min.t.mj22.night ~ buff10.vegstr,  data=alldata)
# p-value = 0.5424
kruskal.test(min.t.mj22.night ~ spot.surface,  data=alldata)
# p-value = 0.05541
pairwise.wilcox.test(alldata$min.t.mj22.night, alldata$spot.surface,
                     p.adjust.method = "BH") 
# Bare Bare + veg. Imperv. Org. mat.
# Bare + veg. 0.40 -           -       -        
#   Imperv.     0.48 0.40        -       -        
#   Org. mat.   0.55 0.48        0.48    -        
#   Veg.        0.40 0.40        0.40    0.48     
kruskal.test(range.t.oct21.night ~ buff10.vegstr,  data=alldata)
# p-value = 0.7399
kruskal.test(range.t.oct21.night ~ spot.surface,  data=alldata)
# p-value = 0.391

kruskal.test(range.t.mj22.night ~ buff10.vegstr,  data=alldata)
# p-value = 0.4289
kruskal.test(range.t.mj22.night ~ spot.surface,  data=alldata)
# p-value = 0.66

kruskal.test(av_LSTsCOMP.dry ~ buff10.vegstr,  data=alldata)
# p-value = 0.7846
kruskal.test(av_LSTsCOMP.dry ~ spot.surface,  data=alldata)
# p-value = 0.342

summary(alldata$elevation)

######### Major revision 1 ######################
# First: new Kruskal-Wallis-Tests for humidity
kruskal.test(mean.h.oct21 ~ buff10.vegstr,  data=alldata)
# Kruskal-Wallis chi-squared = 8.7792, df = 3, p-value = 0.03238
kruskal.test(mean.h.mj22 ~ buff10.vegstr,  data=alldata)
# Kruskal-Wallis chi-squared = 8.4728, df = 3, p-value = 0.03719
kruskal.test(max.h.10he ~ buff10.vegstr,  data=alldata)
# Kruskal-Wallis chi-squared = 1.4906, df = 3, p-value = 0.6845

kruskal.test(mean.h.oct21 ~ spot.surface,  data=alldata)
# Kruskal-Wallis chi-squared = 9.5625, df = 4, p-value = 0.04848
kruskal.test(mean.h.mj22 ~ spot.surface,  data=alldata)
# Kruskal-Wallis chi-squared = 8.9838, df = 4, p-value = 0.06151
kruskal.test(max.h.10he ~ spot.surface,  data=alldata)
# Kruskal-Wallis chi-squared = 7.7555, df = 4, p-value = 0.101

# Second: repeat all significant Kruskall-Wallis tests with 
# Wilcoxon with Hommel adjustment instead of BH

pairwise.wilcox.test(alldata$mean.t.year, alldata$buff10.vegstr,
                     p.adjust.method = "hommel") 
              #Forest/trees Grass/shrub none 
#Grass/shrub   0.143        -           -    
#  none        0.079        0.857       -    
#  Only trees  0.079        0.857       0.857

pairwise.wilcox.test(alldata$mean.h.oct21, alldata$buff10.vegstr,
                     p.adjust.method = "hommel") 
#             Forest/trees Grass/shrub none
#  Grass/shrub 0.23         -           -   
#  none        0.14         0.40        -   
#  Only trees  0.23         0.40        0.40

pairwise.wilcox.test(alldata$mean.h.mj22, alldata$buff10.vegstr,
                     p.adjust.method = "hommel") 
#              Forest/trees Grass/shrub none
#  Grass/shrub 0.14         -           -   
#  none        0.13         1.00        -   
#  Only trees  0.13         1.00        1.00
pairwise.wilcox.test(alldata$mean.h.oct21, alldata$spot.surface,
                     p.adjust.method = "hommel") 
#              Bare Bare + veg. Imperv. Org. mat.
#  Bare + veg. 0.69 -           -       -        
#  Imperv.     1.00 0.29        -       -        
#  Org. mat.   1.00 0.80        0.80    -        
#  Veg.        1.00 1.00        1.00    1.00


### major revision 1 - only illustration purposes
summary(lm(alldata$mean.t.year ~ alldata$buff10.lc.t), p.adjust.method = "hommel")
# Coefficients:
#                   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)          27.4680     0.1377 199.448  < 2e-16 ***
#   alldata$buff10.lc.t  -1.4475     0.3021  -4.792 0.000287 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 0.4081 on 14 degrees of freedom
# Multiple R-squared:  0.6213,	Adjusted R-squared:  0.5942 
# F-statistic: 22.96 on 1 and 14 DF,  p-value: 0.0002868

# coefficient is -1.4 for share of trees in 10m buffer and mean annual temp
# share ranges from 0.1 to 1







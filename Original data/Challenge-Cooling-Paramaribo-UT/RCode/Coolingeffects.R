# This file produces additional scatterplots for cooling effects.


### always good to check
library(installr)
updateR()

# remove everything that might still be in workspace and load packages
rm(list=ls())
library(chron)
library(tidyverse)


homepath<-"C://Users//SchwarzN//Surfdrive//outreach//publications//work-in-progress//LB_climateParamaribo//Data//"
setwd(homepath)
# getwd()


############## read csv file ##############
alldata<-read.csv("Paramaribodropsall.csv")

# check whether all is correct format -> turn into chron object & factor again
str(alldata)

####### individual scatterplots per wet & dry season ##########
# these could theoretically be combined into one graph 
# see here https://bootstrappers.umassmed.edu/bootstrappers-courses/pastCourses/rCourse_2014-09/resources/helpfulGuides/Rfigurelayout.pdf

# pdf(file = "Cooling2.pdf")
pdf(file = "Cooling2_a.pdf", width=4, height=3.2)
par(mfrow=c(1,1))
plot(alldata$Dtemp1PM, 
     alldata$Dtemp6AM,
     cex= 3 * alldata$buff300.lc.t, pch=19, col="grey",
     main = "a) Diurnal cooling dry season", 
     xlab="1PM mean T", ylab="6AM mean T", 
     text(alldata$Dtemp1PM, alldata$Dtemp6AM, alldata$DropID, pos=3, offset=0.2, cex=0.8),
     xlim=c(27,33), # could start also at 28
     ylim=c(23,26), # could start also at 22
     yaxt="n",
     xaxt="n"
)
axis(2, at=c(23, 24, 25, 26),labels=c("23", "24", "25", "26"), col.axis="black", las=2)
axis(1, at=c(27:33),labels=c("27", "28", "29", "30", "31", "32", "33"), col.axis="black", las=1)
dev.off()

pdf(file = "Cooling2_b.pdf", width=4, height=3.2)
par(mfrow=c(1,1))
plot(alldata$Wtemp1PM, 
     alldata$Wtemp6AM,
     cex= 3 * alldata$buff300.lc.t, pch=19, col="grey",
     main = "b) Diurnal cooling wet season", 
     xlab="1PM mean T", ylab="6AM mean T", 
     text(alldata$Wtemp1PM, alldata$Wtemp6AM, alldata$DropID, pos=3, offset=0.2, cex=0.8),
     xlim=c(27,33), # 6
     ylim=c(23,26), # 3
     yaxt="n",
     xaxt="n"
)
axis(2, at=c(23, 24, 25, 26),labels=c("23", "24", "25", "26"), col.axis="black", las=2)
axis(1, at=c(27:33),labels=c("27", "28", "29", "30", "31", "32", "33"), col.axis="black", las=1)
dev.off()

pdf(file = "Cooling2_c.pdf", width=4, height=3.5)
par(mfrow=c(1,1))
plot(alldata$range.t.oct21.night,
     alldata$min.t.oct21.night, 
     cex= 3 * alldata$buff300.lc.t, pch=19, col="grey",
     main = "c) Nighttime cooling dry season", 
     ylab="Nighttime min T", xlab="Nighttime range T", 
     text(alldata$range.t.oct21.night, alldata$min.t.oct21.night, alldata$DropID, pos=3, offset=0.2, cex=0.8),
     ylim=c(23,26),
     xlim=c(3,8),
     yaxt="n",
     xaxt="n"
)
axis(2, at=c(23, 24, 25, 26),labels=c("23", "24", "25", "26"), col.axis="black", las=2)
axis(1, at=c(3:8),labels=c(3:8), col.axis="black", las=1)
dev.off()

pdf(file = "Cooling2_d.pdf", width=4, height=3.5)
plot(alldata$range.t.mj22.night,
     alldata$min.t.mj22.night, 
     cex= 3 * alldata$buff300.lc.t, pch=19, col="grey",
     main = "d) Nighttime cooling wet season", 
     ylab="Nighttime min T", xlab="Nighttime range T", 
     text(alldata$range.t.mj22.night, alldata$min.t.mj22.night, alldata$DropID, pos=3, offset=0.2, cex=0.8),
     ylim=c(21,24),
     xlim=c(3,8),
     yaxt="n",
     xaxt="n"
)
axis(2, at=c(21:24),labels=c(21:24), col.axis="black", las=2)
axis(1, at=c(3:8),labels=c(3:8), col.axis="black", las=1)
dev.off()

pdf(file = "Cooling2_e.pdf", width=4, height=4.5)
plot(alldata$max.t.10he, 
     alldata$max.h.10he,
     cex= 3 * alldata$buff300.lc.t, pch=19, col="grey",
     text(alldata$max.t.10he, alldata$max.h.10he, alldata$DropID, pos=3, offset=0.2, cex=0.8),
     main = "e) Hot extremes", 
     xlab="Max T in hot extremes", ylab="Max humidity in hot extremes", 
     ylim=c(90,102),
     xlim=c(30, 45),
     yaxt="n",
     xaxt="n"
)
axis(1, at=c(30, 35, 40, 45),labels=c("30", "35", "40", "45"), col.axis="black", las=1)
axis(2, at=c(90, 95, 100),labels=c("90", "95", "100"), col.axis="black", las=2)
dev.off()

pdf(file = "Cooling2_f.pdf", width=4, height=4.5)
plot(alldata$av_LSTsCOMP.wet, 
     alldata$av_LSTsCOMP.dry,
     cex= 3 * alldata$buff300.lc.t, pch=19, col="grey",
     text(alldata$av_LSTsCOMP.wet, alldata$av_LSTsCOMP.dry, alldata$DropID, pos=3, offset=0.2, cex=0.8),
     main = "f) Average stand. LST", 
     xlab="Wet season", ylab="Dry season", 
     ylim=c(-1.5,2),
     xlim=c(-1.5,2),
     yaxt="n",
     xaxt="n"
)
axis(2, at=c(-1:2),labels=c(-1:2), col.axis="black", las=2)
axis(1, at=c(-1:2),labels=c(-1:2), col.axis="black", las=1)
dev.off()

pdf(file = "Cooling2_legend.pdf", width=4, height=3.2)
par(mfrow=c(1,1))
plot(alldata$Dtemp1PM,
     alldata$Dtemp6AM,
     cex= 3 * alldata$buff300.lc.t, pch=19, col="white",
     xlim=c(27,33), # could start also at 28
     ylim=c(23,26), # could start also at 22
     yaxt="n",
     xaxt="n", xlab=" ", ylab="", bty="n"
)
# axis(2, at=c(23, 24, 25, 26),labels=c("23", "24", "25", "26"), col.axis="black", las=2)
# axis(1, at=c(27:33),labels=c("27", "28", "29", "30", "31", "32", "33"), col.axis="black", las=1)
legend(x="bottomleft", title="tree coverage", legend=c("10%", "50%"), 
       pt.cex= c(1, 1.5), pch=c(19, 19), col="grey", horiz=T
       #, bty='n' removes the box
       )
dev.off()


####### first scatterplots per wet & dry season ##########

pdf(file = "Cooling.pdf", paper="a4")

# Panel plot
par(mfrow=c(3,2))

plot(alldata$Dtemp1PM, 
     alldata$Dtemp6AM,
     cex= 3 * alldata$buff300.lc.t, pch=19,
     main = "a) Diurnal cooling dry season", 
     xlab="1PM mean T", ylab="6AM mean T", 
     text(alldata$Dtemp1PM, alldata$Dtemp6AM, alldata$DropID, pos=1),
     xlim=c(27,33),
     ylim=c(23,26),
     asp=1
     #type="l"
)

plot(alldata$Wtemp1PM, 
     alldata$Wtemp6AM,
     cex= 3 * alldata$buff300.lc.t, pch=19,
     main = "b) Diurnal cooling wet season", 
     xlab="1PM mean T", ylab="6AM mean T", 
     text(alldata$Wtemp1PM, alldata$Wtemp6AM, alldata$DropID, pos=1),
     xlim=c(27,33),
     ylim=c(23,26)
     #type="l"
)


plot(alldata$min.t.oct21.night, 
     alldata$range.t.oct21.night,
     cex= 3 * alldata$buff300.lc.t, pch=19,
     main = "c) Nighttime cooling dry season", 
     xlab="Nighttime min T", ylab="Nighttime range T", 
     text(alldata$min.t.oct21.night, alldata$range.t.oct21.night, alldata$DropID, pos=1),
     xlim=c(21.5,25.5),
     ylim=c(3,8)
     #type="l"
)

plot(alldata$min.t.mj22.night, 
     alldata$range.t.mj22.night,
     cex= 3 * alldata$buff300.lc.t, pch=19,
     main = "d) Nighttime cooling wet season", 
     xlab="Nighttime min T", ylab="Nighttime range T", 
     text(alldata$min.t.mj22.night, alldata$range.t.mj22.night, alldata$DropID, pos=1),
     xlim=c(21.5,25.5),
     ylim=c(3,8)
     #type="l"
)



plot(alldata$max.t.10he, 
     alldata$max.h.10he,
     cex= 3 * alldata$buff300.lc.t, pch=19,
     text(alldata$max.t.10he, alldata$max.h.10he, alldata$DropID, pos=1),
     main = "e) Hot extremes", 
     xlab="Max T in hot extremes", ylab="Max humidity in hot extremes", 
     ylim=c(90,102),
     xlim=c(30, 44)
     #type="l"
)

plot(alldata$av_LSTsCOMP.wet, 
     alldata$av_LSTsCOMP.dry,
     cex= 3 * alldata$buff300.lc.t, pch=19,
     text(alldata$av_LSTsCOMP.wet, alldata$av_LSTsCOMP.dry, alldata$DropID, pos=1),
     main = "f) Average stand. land surface temperatures", 
     xlab="Land surface T wet season", ylab="Land surface T dry season", 
     ylim=c(-2,2),
     xlim=c(-2,2)
     #type="l"
)

# individual plots
par(mfrow=c(1,1))

plot(alldata$min.t.year.night, 
     alldata$range.t.year.night,
     cex= 3 * alldata$buff300.lc.t, pch=19,
     main = "Nighttime cooling year", 
     xlab="Nighttime min. T", ylab="Nighttime range T", 
     ylim=c(3,12),
     xlim=c(20, 26),
     text(alldata$min.t.year.night, alldata$range.t.year.night, alldata$location, pos=1)
     #type="l"
)

plot(alldata$min.t.mj22.night, 
     alldata$range.t.mj22.night,
     cex= 3 * alldata$buff300.lc.t, pch=19,
     main = "Nighttime cooling wet season", 
     xlab="Nighttime min T", ylab="Nighttime range T", 
     text(alldata$min.t.mj22.night, alldata$range.t.mj22.night, alldata$location, pos=1),
     xlim=c(20,26),
     ylim=c(3,12)
     #type="l"
)

plot(alldata$min.t.oct21.night, 
     alldata$range.t.oct21.night,
     cex= 3 * alldata$buff300.lc.t, pch=19,
     main = "Nighttime cooling dry season", 
     xlab="Nighttime min T", ylab="Nighttime range T", 
     text(alldata$min.t.oct21.night, alldata$range.t.oct21.night, alldata$location, pos=1),
     xlim=c(20,26),
     ylim=c(3,12)
     #type="l"
)

plot(alldata$max.t.10he, 
     alldata$max.h.10he,
     cex= 3 * alldata$buff300.lc.t, pch=19,
     text(alldata$max.t.10he, alldata$max.h.10he, alldata$location, pos=1),
     main = "Hot extremes", 
     xlab="Max T in hot extremes", ylab="Max humidity in hot extremes", 
     ylim=c(90,102),
     xlim=c(30, 44)
     #type="l"
)




dev.off()

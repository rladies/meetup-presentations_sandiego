library(data.table)
library(ggmap)
library(ggplot2)

traffic <- fread("traffic_counts_datasd.csv")

# Traffic Date (cuts off time)
traffic[,count_date:=as.Date(count_date)]
traffic <- unique(traffic, by="id")

# Create unique for Street & Limit
traffic[,StreetLimit:=paste(street_name,limits,sep="__")]

# Look at the Busiest Street Chunks
traffic[,.(StreetSum=sum(as.numeric(total_count))),by="StreetLimit"][order(-StreetSum)][1:25]

# North & South
traffic[northbound_count!="" | southbound_count!="",direction:="North-South"]
traffic[eastbound_count!=""| westbound_count!="",direction:="East-West"]

# Sum NS & EW by Year
traffic[,year:=year(count_date)]
traffic[,weekday:=weekdays(count_date)]

traffic_yearSum = traffic[,.(count= sum(as.numeric(total_count))),by=c("direction","year")]

# Looking at if the total counts of EW & NS traffic change over time
p <- ggplot(data=traffic_yearSum[direction%in%c("East-West", "North-South") & !(year%in%c(2017,2018))], aes(x=year, y=count,fill=direction))+geom_bar(stat="identity",position="dodge")
p <- p +theme_bw()
p

idByYear = traffic[,.(idCount = length(id)),by=c("year")][order(year)]

# Looking at if the ratio EW & NS traffic change over time
traffic_yearSum_cast <- dcast(traffic_yearSum, year~direction)

traffic_yearSum_cast[,DirRatio:=`East-West`/`North-South`]

p <- ggplot(data=traffic_yearSum_cast[ !(year%in%c(2016,2017,2018))],
            aes(x=year, y=DirRatio))+geom_bar(stat="identity", color="black", fill="blue")
p <- p +theme_bw()
p <- p + ylab("Ratio of Total E-W to Total N-S Counts")
p

# Count by Weekday
traffic_weekday <- traffic[,.(cars_counted=sum(as.numeric(total_count)), chunks_Meausred=uniqueN(StreetLimit)),by=c("weekday")]


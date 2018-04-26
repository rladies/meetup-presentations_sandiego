##Set the working data directory##
setwd("/Users/elkepatton/Documents/Analytics/Hackathon")
counts <- read.csv("traffic_counts_datasd.csv")
dictionary <- read.csv("traffic_counts_dictionary_datasd.csv")

## Create Year variable from count_date
counts$yearstr <- substr(counts$count_date,0,4)
## Subset data into a specific table for traffic on 'CASS ST'
cass <- counts[counts$street_name == 'CASS ST',  ]
## Force order on the cross streets
cass$limits <- ordered(cass$limits, levels = c("REED AV - THOMAS AV","THOMAS AV - GRAND AV", "GRAND AV - HORNBLEND ST", "DIAMOND ST - MISSOURI ST", "LORING ST - OPAL ST", "TURQUOISE ST - AGATE ST"))

## Plot Data
ggplot(data = cass) +
  geom_point(aes(color=cass$yearstr), size=2) +
  aes(cass$limits, cass$northbound_count) +
  ggtitle("Northbound Traffic Counts on Cass Street") +
  xlab("Cross Street") +
  ylab("Northbound Traffic") +
  theme_classic() +
  theme(axis.text.x = element_text(angle=60, hjust =1)) +
  theme(plot.title = element_text(hjust = 0.5)) +
  guides(color=guide_legend("Count Year"))

ggplot(data = cass) +
  geom_point(aes(color=cass$yearstr), size=2) +
  aes(cass$limits, cass$southbound_count) +
  ggtitle("Southbound Traffic Counts on Cass Street") +
  xlab("Cross Street") +
  ylab("Southbound Traffic") +
  theme_classic() +
  theme(axis.text.x = element_text(angle=60, hjust =1)) +
  theme(plot.title = element_text(hjust = 0.5)) +
  guides(color=guide_legend("Count Year"))

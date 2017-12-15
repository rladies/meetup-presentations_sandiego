## Epigraph: Fit the Second - The Bellman's Speech (excerpt) 

> "What's the good of Mercator's North Poles and Equators,  
> Tropics, Zones, and Meridian Lines?"  
> So the Bellman would cry: and the crew would reply  
> "They are merely conventional signs!"  
>  
> from *The Hunting of the Snark* by Lewis Carroll

## Prolog: Introduction

This tutorial covers how to use ggplot2 to add features to maps. It will make the most sense to people who have some experience using ggplot2, but it should be fairly self-contained. 

## Act 1: Things to Install

tl;dr the only package you really *need* to play along with the map parts of this tutorial is **ggplot2**. The other packages are used to prepare the data, but since everything is complicated, I'm providing pre-cleaned data. If you don't want to deal with an installation saga, install **ggplot2**, download the data, and skip ahead to the next act.

I'd really like to tell you that all you need to do is to use the package installer in your R client and install a few packages; however, that won't be the case.

First off, a general note. **Whenever installing packages, be sure that you know where they are coming from.** I use the CRAN mirror https://mirrors.nics.utk.edu/cran because I trust the National Institute for Computational Sciences at least as much as the other mirrors. In just a moment, I'm going to tell you that you might have to install some packages from source, from GitHub. Keep in mind that there is a risk when doing this, and you should only install packages from developers who you trust. Sometimes GitHub can be that stranger offering you candy and claiming to have puppies in the van.

When I install packages, I check the box for **Install Dependencies**. 

We'll be using the following packages:
* **ggplot2** is part of the **tidyverse** and you may have it installed already. You might need to reinstall it. We'll get to that later.
* **ggmap** lets us add features to a base map. It also gives us some access to the Google Maps API. When using the Google Maps API, you are agreeing to its terms of service.
* **gpclib** is the General Polygon Clipper Library for R. It has a restrictive license, which is fine for this tutorial but might not be something that you want for other things that you're working on. If you are OK with using **gpclib** with its license restrictions, you can issue the command `gpclibPermit()` to accept the terms.
* **rgeos** serves the same purpose as **gpclib** when it comes to fortifying dataframes, but without the restrictive license. Can be harder to install (see below). You only need one of **gpclib** or **rgeos**.
* **rgdal** is the Geospatial Data Abstraction Library.
* **dplyr** can be used for `left_join()` to combine the boundaries of regions with the value of a variable on those regions. You could also use `merge()` and re-sort the data. **dplyr** causes R to segfault on my computer. YMMV.

### ggmap

If you are lucky, this will work for you. Install **ggmap** and run the following code:

```
library(ggmap)

san.diego <- get_map(location = c(-117.4, 32.6, -117.0, 32.8), maptype="toner", source="stamen")
ggmap(san.diego)
```

If you see a black and white map of San Diego, then this worked brilliantly, and you can continue on to the next section.

However, if you got the error [`GeomRasterAnn was built with an incompatible version of ggproto`](https://github.com/dkahle/ggmap/issues/135), then you can try:
1. Reinstall **ggmap** with `install.packages("ggmap")` then reinstall **ggplot2** with `install.packages("ggplot2")`, quit R, reopen it, and hope that it works.
2. If your development environment allows you to build packages from source, you can try: `devtools::install_github("dkahle/ggmap")`. (Remember what I said about installing code from source from GitHub?) On my Mac, before that command would work I needed to:
    * install the **curl** package (including its dependencies)  
    * install the **devtools** package

If that still doesn't work, there is probably an issue about which (if any) compilers you have installed. If you are unwilling to do battle with compilers, just wait it out until the **ggproto** issues are fixed and the next version of **ggmap** is released on CRAN.

### **gpclib** and **rgeos**

If you are willing to accept the **gpclib** license, install **gpclib** and accept the license with `gpclibPermit()`.

After that, insteall **rgdal**.

### **rgeos** and **rgdal**

If you aren't willing to accept the **gpclib** license, then install **rgeos** from source and then install **rgdal** from source.

```
install.packages('rgeos', type='source')
install.packages('rgdal', type='source')
```

### **dplyr**

This one you can simply install from your package installer. Or if you're really rocking the command line in R, go ahead and `install.packages('dplyr')`.

As I mentioned before, **ggplot2** is the only one of these that you really **need** for this tutorial.

NB: The `fortify()` function that we will use to convert spatial data to dataframes is on its way out. In the future, you may have to use the `tidy()` function from the **broom** package.

### The Data

* flights.csv
* limited_include_tracts.csv
* ACS_15_5YR_B25077.csv
* limited_ca_roads.csv
* sandiego_parks_fort.csv
* sandiego_water_fort.csv

## Act 2: Dots on a Plane

We'll be looking at some flight tracking data from three flights from San Diego to Chicago on July 15, 2017. We can start by plotting `(lon, lat)` pairs. There is nothing particularly mappy about these first examples; we could be working with any type of data that has *(x, y)* coordinates. Data are from http://www.flightaware.com.

```
flights <- read.csv(file="flights.csv", colClasses=c("POSIXct", "numeric", "numeric", "numeric", "factor"))
ggplot(data=flights) + geom_point(aes(x=lon, y=lat))
```

We can also plot other features of the data, including the time, the altitude, or the flight number. For example, we might wonder if the flight path varies based on the time of day or the airline, and we can view these on our plot.

```
ggplot(data=flights) + geom_point(aes(x=lon, y=lat, color=time), size=1)
```

Maybe we're only interested in the paths of the planes over Point Loma and Ocean Beach, so we don't want to plot all the points for the entire trip from San Diego to Chicago. We can *limit* the extent of our plot with `xlim` and `ylim`. When using **ggplot2**, we can have a lot of options of how to call `xlim` and `ylim`. I'm choosing to do it as part of a call to `coord_map()`, which tells the plot that our coordinates are longitude and latitude. Depending on the extent of your plot, how close your region is to the poles, and other factors, you might or might not see a difference between using a map projection and using rectangular coordinates. `coord_map()` will default to the mercator projection.

```
ggplot(data=flights) + geom_point(aes(x=lon, y=lat, color=time), size=1) + coord_map(xlim=c(-117.4, -117.0), ylim=c(32.6, 32.8))
```

Using `xlim` and `ylim` will only draw the part of the plot that we specify, but all the features will be calculated from all the data. This paradigm will come in handy when we shade in polygons; if we're coloring in census tracts based on some feature and one of the census tracts extends beyond the edge of our plot, we want our plot to crop the polygon after rendering it.

One serious drawback here is that we can't see any of the local features, so it's hard to know which neighborhoods these planes are flying over. We can easily add a base map layer with **ggmap**.

```
library(ggmap)

san.diego <- get_map(location = c(-117.4, 32.6, -117.0, 32.8), maptype="toner", source="stamen")
ggmap(san.diego) + geom_point(data=flights, aes(x=lon, y=lat, color=time), size=1)
```

You'll probably get a warning along the lines of

> Warning message:  
> Removed 859 rows containing missing values (geom_point). 

This just means that 859 of the data points are outside the extent of our map.

It's hard to see the black dots against the black ocean, so we can change the color scheme.

```
ggmap(san.diego) + geom_point(data=flights, aes(x=lon, y=lat, color=time), size=3) + scale_color_gradient(low="#efb402", high="#ef02df", trans="time")
```

Or we could use a different background for our map.

```
san.diego2 <- get_map(location = c(-117.4, 32.6, -117.0, 32.8), maptype="watercolor", source="stamen")  
ggmap(san.diego2) + geom_point(data=flights, aes(x=lon, y=lat, color=time), size=1)
```

See `?get_map` for more information about the available types of maps.

One last note on putting dots on maps: There are several services that will convert street addresses to latitude and longitude (including the `geocode()` function in **ggmap**). Use of these APIs is usually subject to agreeing to terms and conditions.

## Act 3: Coloring Regions

The tools built into **ggplot2** are really good at coloring regions that don't have holes in them. They work well for regions designed by GIS nerds (such as census tracts). They don't work as well for regions with holes (such as the German state of Lower Saxony) or that come in multiple pieces (such as the City of San Diego, depending how its encoded).

We'll use `geom_map()` to color in our regions because it can deal gracefully with regions whose boundaries extend beyond our plot window. We could use `geom_polygon()`, but we'd need to be a lot more careful about the boundaries of our regions. There is an unofficial `geom_holygon()` that claims to work for polygons with holes.

Let's color in the census tracts in our map. We'll start by coloring all of them red, and later we'll color them in based on the median price of a home in each tract.

I've prepped the data already, so we can read it in with 

```
census.tracts.fort <- read.csv(file="limited_include_tracts.csv", colClasses=c("numeric", "numeric", "integer", "logical", "character", "character", "character"))
```

We can try to add the census tracts to the map with 

```
ggmap(san.diego) + geom_map(data=census.tracts.fort, map=census.tracts.fort, aes(x=long, y=lat, map_id=id), fill="red")
```

but we will see that this is not at all what we want. The census tracts clobber the underlying map. We could set the alpha to let the map show through.

```
ggmap(san.diego) + geom_map(data=census.tracts.fort, map=census.tracts.fort, aes(x=long, y=lat, map_id=id), fill="red", alpha=1/3)
```

We might be able to live with this, depending on our purposes in making a map. Let's color our census tracts based on the median home price, see how that looks, and then consider what our other options might be.

Aside: Don't worry if you see the warning 
> Warning: Ignoring unknown aesthetics: x, y

### American Community Survey + American Factfinder

The spreadsheet of median home prices came from the census. You can use their [American Factfinder](https://factfinder.census.gov/) tool to download this (and related) data. The variable that we are interested in is in the column named **HD01_VD01**. I'm going to discard the regions with no data because I don't want to color them separately in my plot. Also, this spreadsheet has two header rows, and I like the first one, so I'm going to omit the second one.

```
median.price.all.rows <- readLines("ACS_15_5YR_B25077.csv")
median.price.one.header <- median.price.all.rows[-2]
median.price.frame <- read.csv(textConnection(median.price.one.header), header=TRUE, colClasses = c("character", "character", "character", "numeric", "numeric"))
median.price.frame <- median.price.frame[!is.na(median.price.frame$HD01_VD01),]
```

We can then combine the boundaries of the regions with the values on each region. We can do this with a `merge()` (and then reordering the data) or we can use a `left_join()` from **dplyr**. But **dplyr** crashes R on my computer, so I'm reluctant to use it.

```
median.price.by.tract <- merge(x=census.tracts.fort, y=median.price.frame, by.x="id", by.y="GEO.id2")
median.price.by.tract <- median.price.by.tract[order(median.price.by.tract[,4]),]
```

And now we can add them to our map.

```
ggmap(san.diego) + geom_map(data=median.price.by.tract, map=median.price.by.tract, aes(x=long, y=lat, map_id=id, fill=HD01_VD01), alpha=1/3)
```

This still isn't great. The more opaque the census tracts are, the more they obliterate the underlying map. The more transparent they are, the harder they are to see. We can do better, but we will need even more data.

You shouldn't be surprised that we encountered conflict in Act 3.

## Act 4: Ceci N'est Pas une Carte (The map is not the territory.)

Not only does **ggplot2** have metaphorical layers (the geom, the aes, etc.), but it also draws the components of the plot in the order in which they appear in the call. We'll fill in the census tracts, the water, the parks, and then the roads.

The map is made of the following datasets:
* The shapefile for the parks (source: City of San Diego)
* The shapefile for the water (source: US Census)
* The shapefile for the roads (source: US Census)
* The shapefile for the census tracts (source: US Census)
* Median home values for each census tract (source: US Census)
* Paths of three airliners (Source: FlightAware.com)

I've converted the shapefiles to dataframes which I have then saved as CSV files. I've also trimmed down the file size by excluding features that are outside of our plotting window; the original files will have all the data for the entire city or the entire state.

We can open these with

```
ca.roads.fort <- read.csv(file="limited_ca_roads.csv", colClasses=c("numeric", "numeric", "integer", "character", "character", "character"))
sandiego.parks.fort <- read.csv(file="sandiego_parks_fort.csv", colClasses=c("numeric", "numeric", "integer", "logical", "character", "character", "character"))
sandiego.water.fort <- read.csv(file="sandiego_water_fort.csv", colClasses=c("numeric", "numeric", "integer", "logical", "character", "character", "character"))
```

We'll start by drawing in the census tracts.

```
ggplot(data=median.price.by.tract, aes(x=long, y=lat)) + geom_map(map=median.price.by.tract, aes(map_id=id, fill=HD01_VD01)) + coord_map(xlim=c(-117.4, -117.0), ylim=c(32.6, 32.8))
```

We can change the colors by adding on something like `+ scale_fill_continuous(low="red", high="yellow")`.

Next, we can overlay the water.

```
ggplot(data=median.price.by.tract, aes(x=long, y=lat)) + geom_map(map=median.price.by.tract, aes(map_id=id, fill=HD01_VD01))  + geom_map(data=sandiego.water.fort, map=sandiego.water.fort, aes(map_id=id), color="#a4c1e8", fill="#a4c1e8") + scale_fill_continuous(low="red", high="yellow") + coord_map(xlim=c(-117.4, -117.0), ylim=c(32.6, 32.8))
```

We notice that the water only extends a short distance from the coastline. We'll `annotate` our map with some water-colored rectangles to fill in the rest of the space. (We could also post-process our map in a vector graphics program to color in the rest of the water.)

```
ggplot(data=median.price.by.tract, aes(x=long, y=lat)) + geom_map(map=median.price.by.tract, aes(map_id=id, fill=HD01_VD01))  + geom_map(data=sandiego.water.fort, map=sandiego.water.fort, aes(map_id=id), color="#a4c1e8", fill="#a4c1e8") + annotate("rect", xmin=-117.4, xmax=-117.29, ymin=-Inf, ymax=Inf, fill="#a4c1e8") + annotate("rect", xmin=-117.3, xmax=-117.2, ymin=-Inf, ymax=32.65, fill="#a4c1e8") + scale_fill_continuous(low="red", high="yellow") + coord_map(xlim=c(-117.4, -117.0), ylim=c(32.6, 32.8))
```

Next we add the parks and the roads.

```
ggplot(data=median.price.by.tract, aes(x=long, y=lat)) + geom_map(map=median.price.by.tract, aes(map_id=id, fill=HD01_VD01))  + geom_map(data=sandiego.water.fort, map=sandiego.water.fort, aes(map_id=id), color="#a4c1e8", fill="#a4c1e8") + annotate("rect", xmin=-117.4, xmax=-117.29, ymin=-Inf, ymax=Inf, fill="#a4c1e8") + annotate("rect", xmin=-117.3, xmax=-117.2, ymin=-Inf, ymax=32.65, fill="#a4c1e8") + geom_map(data=sandiego.parks.fort, map= sandiego.parks.fort, aes(map_id=id), color="#93c1a2", fill="#93c1a2") + geom_path(data=ca.roads.fort, aes(x=long, y=lat, group=group)) + scale_fill_continuous(low="red", high="yellow") + coord_map(xlim=c(-117.4, -117.0), ylim=c(32.6, 32.8))
```

Finally, we add in the paths of the flights and clean up our plot a bit.

```
ggplot(data=sandiego.water.fort, aes(x=long, y=lat)) + geom_map(data=median.price.by.tract, map=median.price.by.tract, aes(map_id=id, fill=HD01_VD01)) + geom_map(map=sandiego.water.fort, aes(map_id=id), color="#a4c1e8", fill="#a4c1e8") + annotate("rect", xmin=-117.4, xmax=-117.29, ymin=-Inf, ymax=Inf, fill="#a4c1e8") + annotate("rect", xmin=-117.3, xmax=-117.2, ymin=-Inf, ymax=32.65, fill="#a4c1e8") + geom_map(data=sandiego.parks.fort, map= sandiego.parks.fort, aes(map_id=id), color="#93c1a2", fill="#93c1a2") + geom_path(data=ca.roads.fort, aes(x=long, y=lat, group=group)) + geom_point(data=flights, aes(x=lon, y=lat, shape=flight), size=3) + coord_map(xlim=c(-117.4, -117.0), ylim=c(32.6, 32.8)) + scale_fill_continuous(low="#8b35a5", high="#f98704", name="Median home price") + theme_void()
```

Why did I change the `data=` argument for this last one? Because it works this way and it didn't work the other way. I was getting the error 

> Error in seq_len(nrow(data) - 1) :
> argument must be coercible to non-negative integer

when I had the other data as the `data`. and it works (for me) this way.

## Act 5: Summary and more information

**ggplot2** is a versatile package for plotting data, and we can use its tools for plotting dots, lines, regions, and other features to make maps. Since it's not a dedicated GIS tool, it's not going to be able to do everything that you want to do with maps. But if your regions don't have holes in them (and you can tame your shapefiles), it can be quite useful.

I found the following site helpful when I was getting started making maps in R: http://www.kevjohnson.org/making-maps-in-r/

### Where the boundaries of the regions really come from

**I've pre-processed all of this data into CSV files, so you don't need to do these steps for this tutorial.**

The raw data for the boundaries of the census tracts are **TIGER/Line Shapefiles** from the US Census. The original files are much too large for me to include with these materials. You can find them at https://www.census.gov/geo/maps-data/data/tiger-line.html. We'll start out with the shapefile with the boundaries of all of the census tracts in California (state \#6). You'll download a zipped folder called  **tl_2016_06_tract**.

To read the shapefile into R, you would put this folder (unzipped) in your working directory and then read it with:

```
census.tracts <- readOGR(dsn="tl_2016_06_tract", layer="tl_2016_06_tract")
```

The first argument is the name of the folder; the second argument is the name of the shapefile in the folder (without the file extension).

If the folder is not in your working directory, you need to give the *entire path* to it, without using any abbreviations or shortcuts, such as ~/. For example, I might say `census.tracts <- readOGR(dsn="/Users/szczepanski/maps/data/tl_2016_06_tract", layer="tl_2016_06_tract")`.

Next we need to convert it into a dataframe.

```
census.tracts.fort <- fortify(census.tracts, region="GEOID")
```

The water and roads data from the next act also came from the census (and would be opened and processed the same way).

```
sandiego.water <- readOGR(dsn="tl_2016_06073_areawater", layer="tl_2016_06073_areawater")
sandiego.water.fort <- fortify(sandiego.water)

ca.roads <- readOGR(dsn = "tl_2016_06_prisecroads", layer="tl_2016_06_prisecroads")
ca.roads.fort <- fortify(ca.roads, region="FULLNAME")
```

Since roads are linear, we plot them with `geom_path()` instead of `geom_map()`.

The parks data came from the [City of San Diego](https://data.sandiego.gov/datasets/park-locations/). This is encoded differently from how the census encodes their data. The city uses the World Geodetic System 1984 (WGS84) for their geospatial data. So we convert it first to latitude-longitude format and then fortify the dataframe.

```
sandiego.parks <- readOGR(dsn="CITY.PARKS_datasd", layer="CITY_PARKS")
sandiego.parks.ll <- spTransform(sandiego.parks, CRS("+proj=longlat +datum=WGS84"))

sandiego.parks.fort <- fortify(sandiego.parks.ll, region="OBJECTID")
```

We can do a lot more with our **ggplot2** maps. For example, we can add names of features with `geom_text()` or `geom_label()`. If it's a something that can be plotted on the *(x, y)* plane, we can probably put it on a map!
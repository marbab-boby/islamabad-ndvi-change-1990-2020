# NDVI and vegetation change in Islamabad Capital Territory, 1990 vs 2020
# Landsat 5 (1990) and Landsat 8 (2020), clipped to the ICT boundary.
# The Landsat bands (cut to the ICT area) are in the data folder.
# Run from the repository folder:  source("ndvi_change.R", print.eval = TRUE)

#below are the libraries
library(raster)
library(sf)
library(RStoolbox)
library(ggplot2)
library(rasterVis)

scene_20 = file.path("data", "LC08_L1TP_150037_20200629_20200823_02_T1")
scene_90 = file.path("data", "LT05_L1TP_150037_19900611_20200916_02_T1")

#Now we upload the shape file
ICT = shapefile(file.path("data", "ICT_boundary", "ICT.shp"))

#first we upload the bands of landsat 8 of 2020
band_20 = function(n) raster(file.path(scene_20, paste0("LC08_L1TP_150037_20200629_20200823_02_T1_B", n, ".TIF")))
band1_20 = band_20(1)
band2_20 = band_20(2)
band3_20 = band_20(3)
band4_20 = band_20(4)
band5_20 = band_20(5)
band6_20 = band_20(6)
band7_20 = band_20(7)
band9_20 = band_20(9)

#now we stack the bands of data set of landsat 8(2020)
image_20 = stack(band1_20, band2_20, band3_20, band4_20, band5_20, band6_20, band7_20, band9_20)

#Now we plot the stacked image
#(here hist and lin is used for contrast and T or F for showing x&y axes or not)
plotRGB(image_20 , main = 'Stacked image of 2020', r= 4, g = 3, b =2, axes = T, stretch = "hist"  )

#This will plot the shape file on the stacked image
plot(ICT, add= T, axes = F)

#There image is crop means shapefile is cut in rectangle
clipped_Image20 = crop(image_20, ICT)
plotRGB(clipped_Image20, r= 4, g = 3, b =2, axes = T, stretch = "lin", main = "Clipped Image of 2020")

#There image is masked means shapefile is cut as shapefile is given
masked_Image20 = mask(clipped_Image20, ICT)
plotRGB(masked_Image20, r= 4, g = 3, b =2, axes = T, stretch = "lin", main = "Masked Image of 2020")

# Here as we are required to find out the ndvi of shapefile so we used its masked image
# Landsat 8: band 5 = near infrared, band 4 = red
ndvi_20 = (masked_Image20[[5]] - masked_Image20[[4]])/(masked_Image20[[5]] + masked_Image20[[4]])
plot(ndvi_20, main = "Ndvi for 2020" , axes = T)

#here we find out the vegetation of 2020 (NDVI above 0.2)
veg_20 <- reclassify(ndvi_20, cbind(-Inf, 0.2, NA))
plot(veg_20, main="VEGETATION IN 2020")


#####################################################################################################
#Second dataset: 1990, landsat 5

#first we upload the bands of landsat 5 of 1990
band_90 = function(n) raster(file.path(scene_90, paste0("LT05_L1TP_150037_19900611_20200916_02_T1_B", n, ".TIF")))
band1_90 = band_90(1)
band2_90 = band_90(2)
band3_90 = band_90(3)
band4_90 = band_90(4)
band5_90 = band_90(5)
band6_90 = band_90(6)
band7_90 = band_90(7)

##now we stack the bands of data set of landsat 5(1990)
image_90 = stack(band1_90, band2_90, band3_90, band4_90, band5_90, band6_90, band7_90)

#Now we plot the stacked image
plotRGB(image_90, r= 3, g = 2, b =1, axes = T, stretch = "hist", main = "Stacked image of 1990")

plot(ICT, add= T,axes = F)

# here clipping is done
clipped_Image90 = crop(image_90, ICT)
plotRGB(clipped_Image90, r= 3, g = 2, b =1, axes = T, stretch = "hist", main = "Clipped Image of 1990")

#here masked is done
masked_Image90 = mask(clipped_Image90, ICT)
plotRGB(masked_Image90, r= 3, g = 2, b =1, axes = T, stretch = "hist", main = "Masked Image of 1990")

# ndvi is find out
# Landsat 5: band 4 = near infrared, band 3 = red
ndvi_90 = (masked_Image90[[4]] - masked_Image90[[3]])/(masked_Image90[[4]] + masked_Image90[[3]])
plot(ndvi_90, main = "Ndvi for 1990" , axes = T)

#here we find out the vegetation of 1990 (NDVI above 0.2)
veg_90 <- reclassify(ndvi_90, cbind(-Inf, 0.2, NA))
plot(veg_90, main="VEGETATION IN 1990")


#####################################################################################################
#Comparison

#here ndvi both 2020 & 1990 is presented along side
ndvi_both = stack(ndvi_20,ndvi_90)
plot(ndvi_both, main="NDVI    for    2020    and     1990")

#Difference between ndvi of 2020 & 1990
difference = ndvi_20 - ndvi_90
plot(difference, main = "Ndvi difference of 2020 & 1990" )

#here we show different
veg_diff = stack(veg_20, veg_90 )
plot(veg_diff, main = "Vegetation of 2020 & 1990")

#Here we introduced the break sequence  and color regions
breaks <- seq(-1, 1, by = 0.1)
cols <- colorRampPalette(c("red", "lightgreen", "darkgreen"))

# levelplot of ndvi difference
levelplot(difference, at = breaks, col.regions = cols)

##Display BOXplot of NDVI
boxplot(difference, outcol="green", ylab="NDVI")

# input for gplot
# vegetated area = number of vegetated pixels x pixel area (30 m x 30 m), in square km
areaVegCover_90=cellStats(!is.na(veg_90),"sum")*xres(veg_90)*yres(veg_90)/1e6
areaVegCover_20=cellStats(!is.na(veg_20),"sum")*xres(veg_20)*yres(veg_20)/1e6
areaDiff=areaVegCover_20-areaVegCover_90
data=data.frame(Years=c("1990","1990","2020","2020"),Area=c(areaDiff,areaVegCover_90,areaVegCover_20,0))

# it  gives the values
data

#it plot the gplot
ggplot(data=data,mapping=aes(x=Years,y=Area,fill=Area))+geom_col()+geom_text(aes(label = c("Difference","1990","","2020")), vjust = -0.2)+ggtitle("Vegetation Cover in Islamabad (sq km)")

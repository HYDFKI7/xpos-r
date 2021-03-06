##
 # FILE AgMIP_fct.r
 # AUTHOR olivier olivier
 # https://r-forge.r-project.org/projects/xpos-r/
 ###############################################################################
# AgMIP specific fct

# INIT ALL OVER
source('/home/olivier/Desktop/Optimisation/xpos-r/ClimateDataTools/ClimFormats/dataRead.r')
source('/home/olivier/Desktop/Optimisation/xpos-r/ClimateDataTools/ClimFormats/dataWrite.r')
source('/home/olivier/Desktop/Optimisation/xpos-r/ClimateDataTools/ClimFormats/dataPerturbe.r')
source('/home/olivier/Desktop/Optimisation/xpos-r/ClimateDataTools/Climatology/climFuture.r')
source('/home/olivier/Desktop/Optimisation/xpos-r/ClimateDataTools/Climatology/climAgro.r')
#inFo <- '/home/olivier/Desktop/wine_shared/13_pro_START/MetData/Downscaling/RCP85_Full'
inFo <- '/home/olivier/Desktop/Wine-shared/Projects/2013-2014_FFC/Climate/Future_DS/CSAGo/RCP8.5'
#outFo <- '/home/olivier/Desktop/wine_shared/13_pro_START/MetData/Downscaling/RCP85_Split'
outFo <- '/home/olivier/Desktop/Wine-shared/Projects/2013-2014_FFC/Climate/Future_DS/SPLIT/RCP8.5'
#inGCM <- '/home/olivier/Desktop/wine_shared/12_AgMIP/BOT-AMIIP/E_RCP45_split'
#outFo <- '/home/olivier/Desktop/wine_shared/12_AgMIP/BOT-AMIIP/F_fut45'
#inObs <- '/home/olivier/Desktop/wine_shared/12_AgMIP/BOT-AMIIP/C_presCorrectedObs/North/Control'
#oID <- '183-PAN2.txt'

 ###############################################################################
 ###############################################################################
agmip_period<-function(per)
{
	switch(per,{	# 1 - control
			start<-as.Date("1980-01-01")
			end<-as.Date("2010-12-31")
			folder<-"1980_2010"
		},{	# 2 - near future
			start<-as.Date("2010-01-01")
			end<-as.Date("2040-12-31")
			folder<-"2010_2040"
		},{	# 3 - mid century
			start<-as.Date("2040-01-01")
			end<-as.Date("2070-12-31")
			folder<-"2040_2070"
		},{	# 4 - end century # do not take after 2094 for downscaled data
			# be carefull, not only the same number of year, but needs the same number of days (different number of leap years?)
			start<-as.Date("2069-01-01")	# start<-as.Date("2068-12-31")
			end<-as.Date("2099-12-31")	# end<-as.Date("2099-12-31")
			folder<-"2069_2099"		# folder<-"2069_2099"
		}
	)

return(list("start"=start,"end"=end,"folder"=folder))
}

 ###############################################################################
 ###############################################################################
# CMIP5 style
# split CMIP5 continuous into AgMIP periods
agmip_splitPeriods <- function(inFolder=inFo,outFolder=outFo)
{
	gcm_t <- list.files(inFolder)
	for(r in 1:length(gcm_t)){
		# not for ncep
#		if(r == grep("ncep",gcm_t)) next		
		tmpOut <- paste(outFolder,gcm_t[r],sep="/")	
		if(!file.exists(tmpOut))	dir.create(tmpOut,showWarnings=TRUE,recursive=FALSE,mode="0777")

		tmpIn <- paste(inFolder,gcm_t[r],sep="/")
		sta_t <- list.files(paste(tmpIn,"ppt",sep="/"))
		for(s in 1:length(sta_t)){
			print(paste("",gcm_t[r],sta_t[s],sep=" > "),quote=F)
			# read it
			metD <- read_oldCSAGformat(tmpIn,sta_t[s])				# requires dataRead.r
			# AgMIP periods are defined above
			con <- pert_period(metD,agmip_period(1)$start,agmip_period(1)$end)	# requires dataPerturbe.r
			fu1 <- pert_period(metD,agmip_period(2)$start,agmip_period(2)$end)	#
			fu2 <- pert_period(metD,agmip_period(3)$start,agmip_period(3)$end)	#
			fu3 <- pert_period(metD,agmip_period(4)$start,agmip_period(4)$end)	#
			# write it
			tmpOutCon <- paste(tmpOut,agmip_period(1)$folder,sep="/");	if(!file.exists(tmpOutCon))	dir.create(tmpOutCon,showWarnings=TRUE,recursive=FALSE,mode="0777")
			tmpOutFu1 <- paste(tmpOut,agmip_period(2)$folder,sep="/");	if(!file.exists(tmpOutFu1))	dir.create(tmpOutFu1,showWarnings=TRUE,recursive=FALSE,mode="0777")
			tmpOutFu2 <- paste(tmpOut,agmip_period(3)$folder,sep="/");	if(!file.exists(tmpOutFu2))	dir.create(tmpOutFu2,showWarnings=TRUE,recursive=FALSE,mode="0777")	
			tmpOutFu3 <- paste(tmpOut,agmip_period(4)$folder,sep="/");	if(!file.exists(tmpOutFu3))	dir.create(tmpOutFu3,showWarnings=TRUE,recursive=FALSE,mode="0777")	
			write_oldCSAGformat(con,tmpOutCon)					# requires dataWrite.r
			write_oldCSAGformat(fu1,tmpOutFu1)					# requires dataWrite.r
			write_oldCSAGformat(fu2,tmpOutFu2)					# requires dataWrite.r
			write_oldCSAGformat(fu3,tmpOutFu3)					# requires dataWrite.r
		}
	}

rm(gcm_t,r,tmpOut,sta_t,s,con,fu1,fu2,fu3,tmpOutCon,tmpOutFu1,tmpOutFu2,tmpOutFu3)
}

 ###############################################################################
 ###############################################################################
agmip_pertObs <- function(inFoGCM=inGCM,inFoObs=inObs,outFolder=outFo,obsID=oID,check=FALSE)
{
	# for every GCM-RCP
	rcp_t <- list.files(inFoGCM)
	for(r in 1:length(rcp_t)){
		print(paste("    > ",rcp_t[r],sep=""),quote=F)
		tmpOut1 <- paste(outFolder,rcp_t[r],sep="/")	
		if(!file.exists(tmpOut1))	dir.create(tmpOut1,showWarnings=TRUE,recursive=FALSE,mode="0777")

		# for every time period
		tmpIn1 <- paste(inFoGCM,rcp_t[r],sep="/")
		tPe_t <- list.files(tmpIn1)
		for(t in 1:length(tPe_t)){
			# which agmip period
			if(t == grep(agmip_period(1)$folder,tPe_t)) next	# no need to change control	
			if(t == grep(agmip_period(2)$folder,tPe_t)) agPeriod <- 2
			if(t == grep(agmip_period(3)$folder,tPe_t)) agPeriod <- 3
			if(t == grep(agmip_period(4)$folder,tPe_t)) agPeriod <- 4

			print(paste("",rcp_t[r]," > ",tPe_t[t],sep=""),quote=F)
			tmpOut2 <- paste(tmpOut1,tPe_t[t],sep="/")	
			if(!file.exists(tmpOut2))	dir.create(tmpOut2,showWarnings=TRUE,recursive=FALSE,mode="0777")
			tmpIn2 <- paste(tmpIn1,tPe_t[t],sep="/")

			# compute stat change for that GCM-RCP for that time period
			cha <- future_mtChange(read_oldCSAGformat(paste(tmpIn1,agmip_period(1)$folder,sep="/"),obsID),read_oldCSAGformat(tmpIn2,obsID))
			print(round(cha,digits=1))

			# perturb every stations in there
			sta_t <- list.files(paste(inFoObs,"ppt",sep="/"))
			for(s in 1:length(sta_t)){
				print(paste("",rcp_t[r]," > ",tPe_t[t]," > ",sta_t[s],sep=""),quote=F)
				# read it
				obsD <- read_oldCSAGformat(inFoObs,sta_t[s])				# requires dataRead.r

				# update dates
				obsD$period$start <- agmip_period(agPeriod)$start
				obsD$period$end <- agmip_period(agPeriod)$end

				# perturbe temp and rain
				obsD <- pert_temp(obsD,cha[1,],cha[2,],cha[4,],check)
				obsD <- pert_facRain(obsD,cha[3,],check)

				# update tav and amp
				obsD <- agro_tavamp(obsD)						# requires climAgro.r

				# check length (may be more/less leap years?)
				if (length(obsD$data$date)!=(difftime(obsD$period$end,obsD$period$start,units='days')+1)){
					if (length(obsD$data$date)==(difftime(obsD$period$end,obsD$period$start,units='days')+2)){
						print("#### you are trying to fit a 30 years period (01-01 until 12-31) with another 30 years period (01-01 until 12-31 as well) but with different amount of leap years so that it crashes. play with the start or end of the one you can play with",quote=F)
						browser()
	
					}else{
						print(paste("####","WARNING","data lenght issue in AgMIP_fct.r",sep=" > "),quote=F)
						browser()
					}
				}

				# write it
				write_oldCSAGformat(obsD,tmpOut2)					# requires dataWrite.r
			}
		}
	}

rm(rcp_t,r)
}

###############################################################################
###############################################################################
### AgMIP plots
agmip_plot <- function(metD_obs, metD_p1, metD_p2=NULL, metD_p3=NULL)
{
	x <- 1:length(metD_obs$data$date)
#	mainTitle <- "Bloemfontein - SA-AMIIP fast track - 30 years"
#	mainTitle <- "Nkayi - SA-CLIP fast track - 30 years"
#	mainTitle <- "Linyanti - Caprivi - Namibia - 30 years - RCP 8.5"

	# tmin
#	plot(	x,y=metD_p3$data$tmin,type="l", lwd=.5, col="yellow", xlab="day", ylab="Minimum daily temperatures (oC)",main=mainTitle)#
#	lines(	x,y=metD_p2$data$tmin,type="l", lwd=.5, col="red")
#	lines(	x,y=metD_p1$data$tmin,type="l", lwd=.5, col="green")
#	lines(	x,y=metD_obs$data$tmin,type="l", lwd=.5, col="blue")
	# tmax
#	plot(	x,y=metD_p3$data$tmax,type="l", lwd=.5, col="yellow", xlab="day", ylab="Maximum daily temperatures (oC)",main=mainTitle)
#	lines(	x,y=metD_p2$data$tmax,type="l", lwd=.5, col="red")
#	lines(	x,y=metD_p1$data$tmax,type="l", lwd=.5, col="green")
#	lines(	x,y=metD_obs$data$tmax,type="l", lwd=.5, col="blue")
	# legend
#	legend(	"topleft",
#		legend=c("historical (1980-2010)","BNU-ESM (2010-2040)","BNU-ESM (2040-2070)","BNU-ESM (2070-2100)"),
#		col=c("blue","green","red","yellow"),
#		lty=c(1,1,1,1)
#	);

	# rain-obs
#	plot(	x,y=metD_obs$data$rain,type="l", lwd=.5, col="blue", xlab="day", ylab="Daily rainfall (mm)",main=mainTitle)
#	legend(	"topright",
#		legend=c("MERRA (1980-2010)"),
#		col=c("blue"),
#		lty=c(1)
#	);

	# rain - difference
#	plot(	x,y=(metD_p3$data$rain-metD_obs$data$rain),type="l", lwd=.5, col="yellow", xlab="day", ylab="Daily rainfall difference from baseline (mm)",main=mainTitle)
#	lines(	x,y=(metD_p2$data$rain-metD_obs$data$rain),type="l", lwd=.5, col="red")
#	lines(	x,y=(metD_p1$data$rain-metD_obs$data$rain),type="l", lwd=.5, col="green")
#	legend(	"bottomleft",
#		legend=c("BNU-ESM (2010-2040)","BNU-ESM (2040-2070)","BNU-ESM (2070-2100)"),
#		col=c("green","red","yellow"),
#		lty=c(1,1,1)
#	);

}

 ###############################################################################
 ###############################################################################
# version 2 take my baseline, and create a AgMIP baseline
#inFi <- '/home/olivier/Desktop/wine_shared/12_pro_AgMIP/RZA-AMIIP/G_formatCon/CropModelFormat/Control/fs01.WTH'
#sID <- 'SAV2'
#outFo <- '/home/olivier/Desktop/wine_shared/12_pro_AgMIP/AgMIP_baselineAMIIP/ToRun'
agmip_formatBaseline<-function(inFile=inFi,staID=sID,outFolder=outFo)
{
	# read the APSIM (check it reads sRad)
	tmp <-read_DSSATformat(inFile)

	# cut down to 1980-2009 only
#	tmp_cut <- pert_period(tmp,as.Date("1980-01-01"),as.Date("2009-12-31"))
	
	# change what need to be changed
	tmp$station$id <- staID
	tmp <- agro_tavamp(tmp)
	tmp$clim$wndht <- -99

	# save as AgMIP format
	write_AgMIPformat(tmp,paste(outFolder,"/",staID,"0XXX.AgMIP",sep=''))
}

 ###############################################################################
 ###############################################################################
### TMP
## TRANSLATE
translate <- function(inFolder=inFo,outFolder=outFo)
{
	lat <- -18.75
	lon <- 28.75
	alt <- 1200
	col <- 5
	id <- 'nkayi'
	comm <-'GCM watch grid -18.5,-19 28.5,29'
	sDate <- as.Date('1960-01-01')
	eDate <- as.Date('2100-12-31')

	fiName<-list.files(paste(inFolder,'ppt',sep="/"))
	stName <-strsplit(fiName,'\\.')
	for (f in 1:length(fiName)){
		gcm <- stName[[f]][5]
		outTmp <- paste(outFolder,gcm,sep="/")
		if(!file.exists(outTmp))	dir.create(outTmp,showWarnings=TRUE,recursive=FALSE,mode="0777")

		metD <- read_ASCIIformat(inFolder,gcm,col,lat,lon,alt,sDate,eDate,id,comm)
		write_oldCSAGformat(metD,outTmp)
	}


rm(lat,lon,alt,col,comm,sDate,eDate,gcm,id,f,metD)
}

 ###############################################################################
 ###############################################################################
# make AgMIP space separated, in a format for QuAD
# for AgMIP files in a Folder
inFolder<-""
AgMIP_reFormat <- function(inFolder,outFolder)
{
	file_l <- list.files(inFolder)
	
	for (f in 1:length(file_l)){
		# read the AgMIP
		if(strsplit(file_l[f],split="\\.")[[1]][2]!="AgMIP"){	next;}
		tmp <-read_AgMIPformat(paste(inFolder,file_l[f],sep="/"))
#browser()
#		# read DSSAT format
#		if(strsplit(file_l[f],split="\\.")[[1]][2]!="WTH"){	next;}
#		tmp <-read_DSSATformat(paste(inFolder,file_l[f],sep="/"))

		# save as AgMIP reFormat
		write_AgMIPformat(tmp,paste(outFolder,file_l[f],sep="/"))	
	}
}


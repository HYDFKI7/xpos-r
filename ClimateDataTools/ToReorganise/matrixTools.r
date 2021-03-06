##
 # FILE matrixTools.r
 # AUTHOR olivier crespo
 # https://r-forge.r-project.org/projects/xpos-r/ClimateDataTools/AgMIP
 #####################################################################
 # Here we assume we have a data map stored as a matrix
 # where left to right columns are west to east longitudes
 # and top to bottom rows are north to south latitudes
 # I'LL CALL THIS MATRIX THE top-north left-west matrix
 #####################################################################

## read *.mat matlab formatted matrices
####################################################################
# read and save and clear objects, as they are quite big
# NB.	you need R.matlab library
# 	assumes there is ONLY matlab formatted *.mat matrices, if not just make another folder with ONLY those
#	remember than when you load the rData file, the object name is 'wdc'
####################################################################
mat_translate <- function(path2in)
{	library('R.matlab')
	file <- list.files(path2in)

	for (f in 1:length(file)){
		fName <- strsplit(file[f],split=".");
		tmp <- readMat(paste(path2in,file[f],sep=""))
		wdc <- tmp[[1]]
		save(wdc,file=paste(path2in,paste(fName[1:(length(fName)-1)],"rData",sep="."),sep=""))
		rm(tmp)
		rm(wdc)		
	}
}

# rotate matrix by 45 degrees
####################################################################
# problem is that a basic plot read row a X and col as Y
# so that a visually oriented matrix (north at the top, west on the left)
# is plotted north on the left and west at bottom
# RETURN a matrix which can be ploted with image(mat) for instance 
####################################################################
mat_rotate45 <- function(mat)
{
	if (dim(mat)[1]>1){
		new<-array(NA,dim=dim(mat))
		for (i in 1:dim(mat)[1]){
			new[i,]<-mat[((dim(mat)[1])-i+1),]
		}
	}else{
		new<-mat
	}
return<-(t(new))
}


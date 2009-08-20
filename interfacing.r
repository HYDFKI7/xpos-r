##
 # FILE interfacing.r
 # AUTHOR olivier crespo
 # DATE june 2009 - july 2009
 ####################################################################

##
 # initializations
 ####################################################################
source("apsimInterface.r");
source("rwfileOp.r");
decNo <- 2;

## set decisions manually in apsim_interface.r
decSpe <- apsim_init(decNo);
decS <- decSpe$decS;
decNam <- decSpe$decNam;
path2Outputs <- decSpe$path2out;

## change decision variables in .sim
file.copy(paste(path2Outputs,"initFile.sim",sep=""),paste(path2Outputs,"noYearFile.sim",sep=""),overwrite=TRUE);
changeVar(	decNam[1,1],	decS[2,1],	paste(path2Outputs,"noYearFile.sim",sep=""),paste(path2Outputs,"noYearFile.sim",sep=""));
changeVar(	decNam[1,2],	decS[2,2],	paste(path2Outputs,"noYearFile.sim",sep=""),paste(path2Outputs,"noYearFile.sim",sep=""));

## change pertubation variables in .sim
# startYear and endYear define the length of the time period simulated (has to be included in the met file)
file.copy(paste(path2Outputs,"noYearFile.sim",sep=""),paste(path2Outputs,"fileToSimulate.sim",sep=""),overwrite=TRUE);
changeVar(	"var_startYear",		"1998",	paste(path2Outputs,"fileToSimulate.sim",sep=""),paste(path2Outputs,"fileToSimulate.sim",sep=""));
changeVar(	"var_endYear",		"2003",	paste(path2Outputs,"fileToSimulate.sim",sep=""),paste(path2Outputs,"fileToSimulate.sim",sep=""));

## run simulation for all .sim files
apsim_simulate(path2Outputs,"fileToSimulate");

## read outputs from .out files
# take out only the last year results
temp <- apsim_readOutputs(path2Outputs,"simulation");
out <- temp[dim(temp)[1],];

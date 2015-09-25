

############################################
##                                        ##
##         Investing by numbers           ##
##   a quantitative trading strategy by   ##
##         Mathieu Bouville, PhD          ##
##      <mathieu.bouville@gmail.com>      ##
##                                        ##
##      CAPE.r generates a strategy       ##
##    based on the cyclically adjusted    ##
##     price-to-earnings ratio (CAPE)     ##
##                                        ##
############################################



#default values of parameters
setCAPEdefaultValues <- function() {
   # at the beginning of the data (for the first 'years' years), 
   #    earnings are averaged over (years-cheat) instead of 'years'
   def$CAPEcheat       <<- 4
   
   ## CAPE strategy with hysteresis 1
   def$CAPEyears_hy1   <<-  6L
   def$CAPEcheat_hy1   <<-  0   # given how small 'years' is, we need no 'cheat' at all
   def$CAPEavgOver_hy1 <<- 16L 
   def$hystLoopWidthMidpoint1 <<- 16.
   def$hystLoopWidth1  <<- 16
   def$slope1          <<-  3.
   typical$CAPE_hy1    <<- paste0("CAPE", def$CAPEyears_hy1, "avg", def$CAPEavgOver_hy1, "_hy_", 
                                  def$hystLoopWidthMidpoint1, "_", def$hystLoopWidth1, "_", def$slope1)
   ## CAPE strategy with hysteresis 2
   def$CAPEyears_hy2   <<- 10L
   def$CAPEcheat_hy2   <<- def$CAPEcheat
   def$CAPEavgOver_hy2 <<- 32L           #34L
   def$hystLoopWidthMidpoint2 <<- 19.
   def$hystLoopWidth2  <<-  7.            # 6.4
   def$slope2          <<-  2.
   typical$CAPE_hy2    <<- paste0("CAPE", def$CAPEyears_hy2, "avg", def$CAPEavgOver_hy2, "_hy_", 
                                  def$hystLoopWidthMidpoint2, "_", def$hystLoopWidth2, "_", def$slope2)

   ## CAPE strategy with hysteresis 3
   def$CAPEyears_hy3   <<-  6.5
   def$CAPEcheat_hy3   <<-  0
   def$CAPEavgOver_hy3 <<- 24
   def$hystLoopWidthMidpoint3 <<- 16.5
   def$hystLoopWidth3  <<- 11.8
   def$slope3          <<-  2.8
   typical$CAPE_hy3    <<- paste0("CAPE", def$CAPEyears_hy3, "avg", def$CAPEavgOver_hy3, "_hy_", 
                                  def$hystLoopWidthMidpoint3, "_", def$hystLoopWidth3, "_", def$slope3)
   
   ## CAPE strategy without hysteresis
   def$CAPEyears_NH1   <<-  4L   # optimized with costs = 2%
   def$CAPEcheat_NH1   <<-  0
   def$CAPEavgOver_NH1 <<- 36L
   def$CAPEbearish1    <<- 15L
   def$CAPEbullish1    <<- 15L
   typical$CAPE_NH1 <<- paste0("CAPE", def$CAPEyears_NH1, "avg", def$CAPEavgOver_NH1, "_NH_", 
                                def$CAPEbearish1, "_", def$CAPEbullish1)

   def$CAPEyears_NH2   <<- 1.5
   def$CAPEcheat_NH2   <<- 0
   def$CAPEavgOver_NH2 <<- 38L
   def$CAPEbearish2    <<- 14.5
   def$CAPEbullish2    <<- 14.5
   typical$CAPE_NH2 <<- paste0("CAPE", def$CAPEyears_NH2, "avg", def$CAPEavgOver_NH2, "_NH_", 
                               def$CAPEbearish2, "_", def$CAPEbullish2)
# This corresponds to : (i) CAPEbearish = CAPEbullish, which means a strategy either all in or all out;
   #    (ii) a high value of the threshold (21), which leads to a high average stock allocation.
   
   def$initialOffset  <<- max( (def$CAPEyears_hy1-def$CAPEcheat)*12 + def$CAPEavgOver_hy1, 
                               (def$CAPEyears_NH -def$CAPEcheat)*12 + def$CAPEavgOver_NH)
   def$CAPEstrategies <<- c(typical$CAPE_hy1, typical$CAPE_NH, typical$CAPE_NH, typical$CAPE_NH)
}


## calculating CAPE
calcCAPE <- function(years=def$CAPEyears, cheat=def$CAPEcheat) {
  CAPEname <- paste0("CAPE", years)
  if (!(CAPEname %in% colnames(dat))) {
     addNumColToDat(CAPEname)
     months <- 12*years
     for(i in 1:(months-12*cheat)) { dat[i, CAPEname] <<- NA }
     for(i in (months-12*cheat+1):numData) 
       dat[i, CAPEname] <<- dat$price[i] / mean(dat$earnings[1:(i-1)], na.rm=T)
     for(i in (months+1):numData) 
        dat[i, CAPEname] <<- dat$price[i] / mean(dat$earnings[(i-months):(i-1)], na.rm=T)
  }
}


## Average CAPE over 'avgOver' months
calcAvgCAPE <- function(years=def$CAPEyears, cheat=def$CAPEcheat, avgOver=def$CAPEavgOver) {
   CAPEname <- paste0("CAPE", years)
   if (!(CAPEname %in% colnames(dat))) 
      calcCAPE(years=years, cheat=cheat)
   if( avgOver>0 && !(paste0(CAPEname,"avg",avgOver) %in% colnames(dat)) ) {
      avgCAPEname <- paste0(CAPEname,"avg",avgOver)
      addNumColToDat(avgCAPEname)
      #   message(paste0("NB: dat$", avgCAPEname, " has average of ", CAPEname, "over ", avgOver, " *months*."))
      for(i in 1:(avgOver-1)) dat[i, avgCAPEname] <<- NA # not enough data to calculate average
      for(i in avgOver:numData) dat[i, avgCAPEname] <<- mean(dat[(i-avgOver+1):i, CAPEname])
   }
}


## Calculate CAPE signal, to be used to calculate allocation
calcCAPEsignal <- function(CAPEname, bearish=def$CAPEbearish, bullish=def$CAPEbullish, 
                           signalMin=def$signalMin, signalMax=def$signalMax, 
                           startIndex=def$startIndex, strategyName="") {
   
   requireColInDat(CAPEname)   
   if(strategyName=="") strategyName <- paste0(CAPEname, "_NH_", bearish, "_", bullish)
   calcSignalForStrategy(strategyName, input=dat[, CAPEname], bearish=bearish, bullish=bullish,
                         signalMin=signalMin, signalMax=signalMax, startIndex=startIndex ) 
}


createCAPEstrategy <- function(years=def$CAPEyears, cheat=def$CAPEcheat, avgOver=0, 
                               hysteresis=F, 
                               bearish=def$CAPEbearish1, bullish=def$CAPEbullish1, 
                               hystLoopWidthMidpoint=def$hystLoopWidthMidpoint2, 
                               hystLoopWidth=def$hystLoopWidth2, slope=def$slope2,
                               signalMin=def$signalMin, signalMax=def$signalMax,
                               strategyName="", type="", 
                               futureYears=def$futureYears, costs=def$tradingCost, 
                               coeffTR=def$coeffTR, coeffVol=def$coeffVol, coeffDD2=def$coeffDD2, force=F) {

   if (avgOver>0)
      CAPEname <- paste0("CAPE", years, "avg", avgOver)
   else CAPEname <- paste0("CAPE", years)
   
   if (!(CAPEname %in% colnames(dat)))
      calcAvgCAPE(years=years, cheat=cheat, avgOver=avgOver)
   startIndex <- (years-cheat)*12 + avgOver + 1
   
   if(hysteresis) {
      if(strategyName=="") 
         strategyName <- paste0(CAPEname, "_hy_", hystLoopWidthMidpoint, "_", hystLoopWidth, "_", slope)
   } else {
      if(strategyName=="") strategyName <- paste0(CAPEname, "_NH_", bearish, "_", bullish)
      if (bearish==bullish) bullish = bearish - 1e-3 # bear==bull creates problems
   }
   
   ## if data do not exist yet or we force recalculation:
   if (!(strategyName %in% colnames(TR)) | !(strategyName %in% colnames(alloc)) | force) { 
      if(hysteresis)          
         calcCAPEsignalWithHysteresis(CAPEname, hystLoopWidth=hystLoopWidth, 
                                      hystLoopWidthMidpoint=hystLoopWidthMidpoint, slope=slope,
                                      signalMin=signalMin, signalMax=signalMax,
                                      startIndex=startIndex, strategyName=strategyName)
      else
         calcCAPEsignal(CAPEname, bearish=bearish, bullish=bullish, signalMin=signalMin, signalMax=signalMax,
                        startIndex=startIndex, strategyName=strategyName)
      calcAllocFromSignal(strategyName)
      addNumColToTR(strategyName)
      calcStrategyReturn(strategyName, startIndex)
   }  
   
   index <- which(parameters$strategy == strategyName)
   if ( !(strategyName %in% parameters$strategy) | force) {
      if ( !(strategyName %in% parameters$strategy) ) {
         parameters[nrow(parameters)+1, ] <<- NA
         parameters$strategy[nrow(parameters)] <<- strategyName
      }   
      if (type=="") {
         if (hysteresis) type <- "CAPE_hy"
         else type <- "CAPE_NH"
      }
     
      index <- which(parameters$strategy == strategyName)
      
      parameters$strategy[index]   <<- strategyName
      parameters$type[index]       <<- type
      if (type=="training") {
         if (hysteresis) parameters$subtype[index] <<- "CAPE_hy"
         else parameters$subtype[index] <<- "CAPE_NH"
      } 
         
      parameters$startIndex[index] <<- startIndex
      parameters$avgOver[index]    <<- avgOver
      if (hysteresis) {
         parameters$name1[index]   <<- "hystLoopWidthMidpoint"
         parameters$value1[index]  <<-  hystLoopWidthMidpoint
         parameters$name2[index]   <<- "hystLoopWidthMidpoint"
         parameters$value2[index]  <<-  hystLoopWidthMidpoint
         parameters$name3[index]   <<- "slope"
         parameters$value3[index]  <<-  slope
      } else {
         parameters$bearish[index] <<- bearish
         parameters$bullish[index] <<- bullish
      }      
   }
   calcStatisticsForStrategy(strategyName=strategyName, futureYears=futureYears, costs=costs,
                             coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
   statsIndex      <- which(stats$strategy == strategyName)
   stats$type[statsIndex]    <<- parameters$type[index]
   stats$subtype[statsIndex] <<- parameters$subtype[index]
}



## CAPE without hysteresis

calcOptimalCAPEwithoutHysteresis <- function
      (minYears, maxYears, byYears, cheat, minAvgOver, maxAvgOver, byAvgOver, 
       minBear, maxBear, byBear, minDelta, maxDelta, byDelta, 
       futureYears, costs, minTR, maxVol, maxDD2, minTO, minScore,
       coeffTR, coeffMed=def$coeffMed, coeffFive=def$coeffFive, coeffVol, coeffDD2, 
       xMinVol, xMaxVol, xMinDD2, xMaxDD2, countOnly,
       CPUnumber, col, plotType, nameLength, plotEvery, force) {
   
   lastTimePlotted <- proc.time()
   counterTot <- 0; counterNew <- 0
   
   # creating ranges that allow to sample the parameter space broadly initially
   rangeYears   <- createRange(minYears,   maxYears,   byYears)
   rangeAvgOver <- createRange(minAvgOver, maxAvgOver, byAvgOver)
   rangeBear    <- createRange(minBear,    maxBear,    byBear)
   rangeDelta   <- createRange(minDelta,   maxDelta,   byDelta)
   
   for (delta in rangeDelta) {
      if (!countOnly && minDelta!=maxDelta) print(paste("  * Starting delta =", delta))
      
      for (bear in rangeBear) {
         if (!countOnly && minBear!=maxBear) print(paste("      Starting bear =", bear))
         bull = bear - delta
         
         for (years in rangeYears) {
            if (!countOnly)  calcCAPE(years=years, cheat=cheat)
            if (!countOnly && minDelta==maxDelta && minBear==maxBear && minYears!=maxYears) 
               print(paste("      Starting years =", years))
            
            for (avgOver in rangeAvgOver) {
               if (!countOnly)  calcAvgCAPE(years=years, cheat=cheat, avgOver=avgOver)
               #if (!countOnly && minDelta==maxDelta && minYears==maxYears && minAvgOver!=maxAvgOver) 
                  #print(paste("     Starting avgOver =", avgOver))
               
               strategyName <- paste0("CAPE", years, "avg", avgOver, "_NH_", bear, "_", bull)
               
               #print(strategyName)
               counterTot  <- counterTot + 1 
               if(countOnly) {
                  if ( !(strategyName %in% colnames(TR)) | !(strategyName %in% colnames(alloc)) )
                     counterNew  <- counterNew + 1
               } else {
                  createCAPEstrategy(years=years, cheat=cheat, avgOver=avgOver, strategyName=strategyName, 
                                     bearish=bear, bullish=bull, signalMin=def$signalMin, signalMax=def$signalMax,
                                     hysteresis=F, type="training", futureYears=futureYears, force=force)
                  showSummaryForStrategy(strategyName, futureYears=futureYears, costs=costs, 
                                         minTR=minTR, maxVol=maxVol, maxDD2=maxDD2, minTO=minTO, 
                                         minScore=minScore, coeffTR=coeffTR, coeffMed=coeffMed, coeffFive=coeffFive, 
                                         coeffVol=coeffVol, coeffDD2=coeffDD2, 
                                         nameLength=nameLength, force=F)
               }
               if ( !countOnly && (summary(proc.time())[[1]] - lastTimePlotted[[1]] ) > plotEvery ) { 
                  # we replot only if it's been a while
                  plotAllReturnsVsTwo(col=col, trainingPlotType=plotType, 
                                      xMinVol=xMinVol, xMaxVol=xMaxVol, xMinDD2=xMinDD2, xMaxDD2=xMaxDD2)
                  lastTimePlotted <- proc.time()
               }
            }
         }
      }
   }
   if(countOnly)
      print (paste0("Running ", counterTot, " parameter sets (", counterNew, " new)"))
}

searchForOptimalCAPEwithoutHysteresis <-function(cheat=def$CAPEcheat_NH, 
         minYears=   9L,  maxYears=  11L,  byYears=  1L, 
         minAvgOver=31L,  maxAvgOver=36L,  byAvgOver=1L, 
         minBear=   20.4, maxBear=   21.6, byBear=   0.2, 
         minDelta=   0,   maxDelta=   0.4, byDelta=  0.2, 
         futureYears=def$futureYears, costs=def$tradingCost+def$riskAsCost, 
         minTR=0, maxVol=def$maxVol, maxDD2=def$maxDD2, minTO=5, minScore=11.3,
         coeffTR=def$coeffTR, coeffMed=def$coeffMed, coeffFive=def$coeffFive, 
         coeffVol=def$coeffVol, coeffDD2=def$coeffDD2, 
         xMinVol=13.5, xMaxVol=18, xMinDD2=5, xMaxDD2=9.,       
         CPUnumber=def$CPUnumber, col=F, plotType="symbols", nameLength=27, plotEvery=def$plotEvery, 
         referenceStrategies=typical$CAPE_NH1, force=F) {
   
   if (dataSplit != "training") 
      warning("Doing training in '", dataSplit, "' mode.", immediate.=T)
   if (costs < 1/100) 
      warning("costs = ", costs*100, "%.", immediate.=T)
   message("Parametrization will take place over ", 
           floor(dat$numericDate[1]), "-", floor(dat$numericDate[numData]), ".")
   
   cleanUpStrategies()
   
   # calculate how many parameters sets will be run
   calcOptimalCAPEwithoutHysteresis(minYears, maxYears, byYears, cheat, 
                                    minAvgOver, maxAvgOver, byAvgOver, minBear, maxBear, byBear, minDelta, maxDelta, byDelta, 
                                    futureYears, costs, minTR, maxVol, maxDD2, minTO, minScore,
                                    coeffTR, coeffMed=coeffMed, coeffFive=coeffFive, coeffVol, coeffDD2, 
                                    xMinVol, xMaxVol, xMinDD2, xMaxDD2, countOnly=T,
                                    CPUnumber, col, plotType, nameLength, plotEvery, force)
   dashes <- displaySummaryHeader(futureYears=futureYears, nameLength=nameLength)
   
   # actually calculating
   calcOptimalCAPEwithoutHysteresis(minYears, maxYears, byYears, cheat, 
       minAvgOver, maxAvgOver, byAvgOver, minBear, maxBear, byBear, minDelta, maxDelta, byDelta, 
       futureYears, costs, minTR, maxVol, maxDD2, minTO, minScore,
       coeffTR, coeffMed=coeffMed, coeffFive=coeffFive, coeffVol, coeffDD2, 
       xMinVol, xMaxVol, xMinDD2, xMaxDD2, countOnly=F,
       CPUnumber, col, plotType, nameLength, plotEvery, force)
   
   print(dashes)
   if( length(referenceStrategies) > 0 )
      for ( i in 1:length(referenceStrategies) )
         showSummaryForStrategy(referenceStrategies[i], nameLength=nameLength, costs=costs) 
   plotAllReturnsVsTwo(col=col, costs=costs, trainingPlotType=plotType,
                       xMinVol=xMinVol, xMaxVol=xMaxVol, xMinDD2=xMinDD2, xMaxDD2=xMaxDD2)
}



## CAPE with hysteresis

# Calculate CAPE signal based on an hysteresis loop
# There can be no call to calcSignalForStrategy() because this is not a state function: 
#   the signal depends on the direction (CAPE increasing or decreasing), not just on the value of the CAPE
calcCAPEsignalWithHysteresis <- function(CAPEname, hystLoopWidthMidpoint=def$hystLoopWidthMidpoint2, 
                                         hystLoopWidth=def$hystLoopWidth2, slope=def$slope2,
                                         signalMin=def$signalMin, signalMax=def$signalMax, 
                                         startIndex=def$startIndex, strategyName="") {
   
   bullish <- hystLoopWidthMidpoint - hystLoopWidth/2 + (0.5-signalMin)*slope
   bearish <- hystLoopWidthMidpoint + hystLoopWidth/2 - (signalMax-0.5)*slope
   
   if (bearish < bullish - slope*(signalMax-signalMin) )
      stop("bearish (", bearish, ") cannot be smaller than bullish-slope*(signalMax-signalMin) (", 
           bullish-slope*(signalMax-signalMin), ").")
   
   requireColInDat(CAPEname)
   if(strategyName=="") 
      strategyName <- paste0(CAPEname, "_hy_", hystLoopWidthMidpoint, "_", hystLoopWidth, "_", slope)
   
   addNumColToSignal(strategyName)
   CAPEinput <- dat[, CAPEname]
   
   dateRange <- startIndex:numData
   if( sum(is.na(CAPEinput[dateRange])) > 0) # there should be no NA after startIndex
      stop("Input contains NA after startIndex (", startIndex, ").")   
   processedCAPE <- numeric(numData)
   
   ## Initializing CAPEgoingUp
   if ( CAPEinput[startIndex] <= (bullish+bearish)/2 ) # if CAPE is low, 
      processedCAPE[startIndex] <- signalMax           # we consider that we should be in stocks
   else 
      processedCAPE[startIndex] <- signalMin
   
   for (i in (startIndex+1):numData) {
      if( CAPEinput[i]<bearish & processedCAPE[i-1]>signalMax-0.01 )
         processedCAPE[i] <- processedCAPE[i-1]
      else if( CAPEinput[i]>bullish & processedCAPE[i-1]<signalMin+0.01 ) 
         processedCAPE[i] <- processedCAPE[i-1]
      else {
         processedCAPE[i] <- processedCAPE[i-1] - (CAPEinput[i]-CAPEinput[i-1]) * slope
         if (processedCAPE[i] <= signalMin) processedCAPE[i] <- signalMin
         if (processedCAPE[i] >= signalMax) processedCAPE[i] <- signalMax
      }
   } 
   signal[1:(startIndex-1), strategyName] <<- NA
   signal[dateRange, strategyName] <<- processedCAPE[dateRange]
}

calcOptimalCAPEwithHysteresis <- function(minYears, maxYears, byYears, cheat, 
       minAvgOver, maxAvgOver, byAvgOver, minMid, maxMid, byMid, 
       minWidth, maxWidth, byWidth, minSlope, maxSlope, bySlope, 
       futureYears, costs, minTR, maxVol, maxDD2, minTO, minScore,
       coeffTR, coeffMed=def$coeffMed, coeffFive=def$coeffFive, coeffVol, coeffDD2, 
       xMinVol, xMaxVol, xMinDD2, xMaxDD2, countOnly,
       CPUnumber, col, plotType, nameLength, plotEvery, force) {
   
   counterTot <- 0; counterNew <- 0
   lastTimePlotted <- proc.time()

   # creating ranges that allow to sample the parameter space broadly initially
   rangeYears   <- createRange(minYears, maxYears, byYears)
   rangeAvgOver <- createRange(minAvgOver, maxAvgOver, byAvgOver)
   rangeMid     <- createRange(minMid,   maxMid, byMid)
   rangeWidth   <- createRange(minWidth, maxWidth, byWidth)
   rangeSlope   <- createRange(minSlope, maxSlope, bySlope)
   
   for (mid in rangeMid) {
      if (!countOnly && minMid!=maxMid) print(paste("  * Starting mid =", mid))
      
      for (years in rangeYears) {
         if(!countOnly) 
            calcCAPE(years=years, cheat=cheat)
         for (avgOver in rangeAvgOver) {
            if(!countOnly) 
               calcAvgCAPE(years=years, cheat=cheat, avgOver=avgOver)
            if (avgOver>0)
               CAPEname <- paste0("CAPE", years, "avg", avgOver)
            else CAPEname <- paste0("CAPE", years)
            
            for (width in rangeWidth) {      
               for (slope in rangeSlope) {
                  strategyName <- paste0(CAPEname, "_hy_", mid, "_", width, "_", slope)
                  
                  counterTot <- counterTot + 1 
                  if(countOnly) {
                     if ( !(strategyName %in% colnames(TR)) | !(strategyName %in% colnames(alloc)) )
                        counterNew <- counterNew + 1                  
                  } else {
                     createCAPEstrategy(years=years, cheat=cheat, avgOver=avgOver, strategyName=strategyName, 
                                        hystLoopWidthMidpoint=mid, hystLoopWidth=width, slope=slope,
                                        signalMin=def$signalMin, signalMax=def$signalMax,
                                        hysteresis=T, type="training", futureYears=futureYears, force=force)
                     showSummaryForStrategy(strategyName, futureYears=futureYears, costs=costs, 
                                            minTR=minTR, maxVol=maxVol, maxDD2=maxDD2, minTO=minTO, minScore=minScore, 
                                            coeffTR=coeffTR, coeffMed=coeffMed, coeffFive=coeffFive, 
                                            coeffVol=coeffVol, coeffDD2=coeffDD2, 
                                            nameLength=nameLength, force=F)
                  }
                  
                  if ( !countOnly && (summary(proc.time())[[1]] - lastTimePlotted[[1]] ) > plotEvery ) { 
                     # we replot only if it's been a while
                     plotAllReturnsVsTwo(col=col, trainingPlotType=plotType,
                                         xMinVol=xMinVol, xMaxVol=xMaxVol, xMinDD2=xMinDD2, xMaxDD2=xMaxDD2)
                     lastTimePlotted <- proc.time()
                  }
               }
            }
         }
      }
   }
   if(countOnly)
      print (paste0("Running ", counterTot, " parameter sets (", counterNew, " new)"))
}


searchForOptimalCAPEwithHysteresis <-function(
         minYears=  10L,  maxYears=  10L,  byYears=  1L, cheat=2, 
         minAvgOver=33L,  maxAvgOver=35L,  byAvgOver=1L, 
         minMid=    19.0, maxMid=    19.6, byMid=    0.2, 
         minWidth=   5.8, maxWidth=   7.2, byWidth=  0.2,
         minSlope=   2.0, maxSlope=   2.6, bySlope=  0.2, 
         futureYears=def$futureYears, costs=def$tradingCost+def$riskAsCost, 
         minTR=0, maxVol=def$maxVol, maxDD2=def$maxDD2, minTO=5, minScore=16,
         coeffTR=def$coeffTR, coeffMed=def$coeffMed, coeffFive=def$coeffFive,
         coeffVol=def$coeffVol, coeffDD2=def$coeffDD2, 
         xMinVol=11.5, xMaxVol=18.5, xMinDD2=7, xMaxDD2=10.5,
         CPUnumber=def$CPUnumber, col=F, plotType="symbols", 
         nameLength=28, plotEvery=def$plotEvery, 
         referenceStrategies=c(typical$CAPE_hy1, typical$CAPE_hy2, typical$CAPE_hy3), force=F) {
   
   if (dataSplit != "training") 
      warning("Doing training in '", dataSplit, "' mode.", immediate.=T)
   if (costs < 1/100) 
      warning("costs = ", costs*100, "%.", immediate.=T)
   message("Parametrization will take place over ", 
           floor(dat$numericDate[1]), "-", floor(dat$numericDate[numData]), ".")
   
   cleanUpStrategies()
    
   # calculate how many parameters sets will be run
   calcOptimalCAPEwithHysteresis(minYears, maxYears, byYears, cheat, 
      minAvgOver, maxAvgOver, byAvgOver, minMid, maxMid, byMid, 
      minWidth, maxWidth, byWidth, minSlope, maxSlope, bySlope, 
      futureYears, costs, minTR, maxVol, maxDD2, minTO, minScore,
      coeffTR, coeffMed, coeffFive, coeffVol, coeffDD2, 
      xMinVol, xMaxVol, xMinDD2, xMaxDD2, countOnly=T,
      CPUnumber, col, plotType, nameLength, plotEvery, force)
   
   dashes <- displaySummaryHeader(futureYears=futureYears, nameLength=nameLength)
   
   # actually calculating
   calcOptimalCAPEwithHysteresis(minYears, maxYears, byYears, cheat, 
       minAvgOver, maxAvgOver, byAvgOver, minMid, maxMid, byMid, 
       minWidth, maxWidth, byWidth, minSlope, maxSlope, bySlope, 
       futureYears, costs, minTR, maxVol, maxDD2, minTO, minScore,
       coeffTR, coeffMed, coeffFive, coeffVol, coeffDD2, 
       xMinVol, xMaxVol, xMinDD2, xMaxDD2, countOnly=F,
       CPUnumber, col, plotType, nameLength, plotEvery, force)   

   print(dashes)
   for ( i in 1:length(referenceStrategies) )
      showSummaryForStrategy(referenceStrategies[i], nameLength=nameLength, 
                             coeffTR=coeffTR, coeffMed=coeffMed, coeffFive=coeffFive, 
                             coeffVol=coeffVol, coeffDD2=coeffDD2, costs=costs)
   plotAllReturnsVsTwo(col=col, trainingPlotType=plotType, costs=costs,
                       xMinVol=xMinVol, xMaxVol=xMaxVol, xMinDD2=xMinDD2, xMaxDD2=xMaxDD2)
}



searchForThreeOptimalCAPE <-function(plotType="symbols", force=F) {
   print("searching for optimal CAPE strategy with hysteresis 1...")
   searchForOptimalCAPEwithHysteresis( minYears=   6L,  maxYears=   6L,  byYears=  1L, 
                                       minAvgOver=15L,  maxAvgOver=16L,  byAvgOver=1L, 
                                       minMid =   16,   maxMid =   16,   byMid =   1, 
                                       minWidth=  13,   maxWidth=  17,   byWidth=  0.5,
                                       minSlope=   1.5, maxSlope=   3.5, bySlope=  0.5, 
                                       maxVol=19, maxDD2=7.5, minScore=12 )
   
   print("")
   print("searching for optimal CAPE strategy with hysteresis 2...")
   searchForOptimalCAPEwithHysteresis(   cheat=6, 
                                         minYears=   8L,  maxYears=  24L,  byYears=   4L, 
                                         minAvgOver=12L,  maxAvgOver=36L,  byAvgOver=12L, 
                                         minMid=    10,   maxMid=    22,   byMid=     2, 
                                         minWidth=   2,   maxWidth=  10,   byWidth=   4,
                                         minSlope=   1,   maxSlope=   5,   bySlope=   2,
                                         plotEvery=30, coeffTR=0.7, coeffMed=0.15, coeffFive=0.15, minScore=12)
      
   print("")
   print("searching for optimal CAPE strategy without hysteresis...")
   searchForOptimalCAPEwithoutHysteresis()
   
   #plotReturnAndAlloc("CAPE6avg16_hy_16_16_3", "CAPE10avg32_hy_19_7_2", , )
   }


plotFutureReturnVsCAPE <- function(CAPEname1=paste0("CAPE", def$CAPEyears_hy2),
                                   CAPEname2=paste0("CAPE", def$CAPEyears_hy2, "avg", def$CAPEavgOver_hy2),
                                   #CAPEname2=paste0("CAPE", def$CAPEyears, "avg", def$CAPEavgOver2),
                                   col1="blue", col2="red", showFit=T, complete=T,
                                   futureYears=def$futureYears, 
                                   minCAPE=1.5, maxCAPE=44, minTR="", maxTR="", 
                                   figureTitle="", logScale="", #logScale is either "" or "x"
                                   pngOutput=F, pngWidth=def$pngWidth, pngHeight=def$pngHeight, 
                                   pngName=paste0("figures/return_over_next_", 
                                                  futureYears, "_years_vs_CAPE.png") ) {
   
   if(pngOutput)
      png(file=pngName, width=pngWidth, height=pngHeight)
   
   para <- parametrizeFutureReturnPlot("", yLabel="", futureYears, minTR, maxTR) 
   yLabel <- paste("stock", para[[1]]); minTR <- as.numeric(para[[2]]); maxTR <- as.numeric(para[[3]])
         
   if (futureYears==10) 
      returnVect <- 100 * next10yrs[, "stocks"]
   else if (futureYears==15) 
      returnVect <- 100 * next15yrs[, "stocks"]
   else if (futureYears==20) 
      returnVect <- 100 * next20yrs[, "stocks"]
   else if (futureYears==30) 
      returnVect <- 100 * next30yrs[, "stocks"]
   else stop("futureYears = ", futureYears, " years is not available.")
   
   dateRange <- 1:numData
   if ( complete ) {
      ## adjust dateRange based on complete data
      i <- 1
      while ( ( CAPEname1 != "" && is.na(dat[i, CAPEname1]) ) | 
              ( CAPEname2 != "" && is.na(dat[i, CAPEname2]) ) |
                is.na(returnVect[i]) ) 
         i <- i+1
      j <- numData
      while ( ( CAPEname1 != "" && is.na(dat[j, CAPEname1]) ) | 
              ( CAPEname2 != "" && is.na(dat[j, CAPEname2]) ) |
                is.na(returnVect[j]) ) 
         j <- j-1
      dateRange <- i:j
   }
   
   par(mar=c(4.2, 4.2, 1.5, 1.5))
   if (figureTitle != "") par( oma = c( 0, 0, 1.5, 0 ) )
   if (logScale!="x") {
      xRange <- c(minCAPE, maxCAPE)
      xLabel<-"CAPE"
   } else {
      xRange <- c(5, 46)
      xLabel<-"CAPE (log scale)"
   }
   yRange <- c(minTR, maxTR)
   
   if( CAPEname1 != "" ) {   
      plot(dat[dateRange, CAPEname1], returnVect[dateRange], col=col1, 
           xlim=xRange, ylim=yRange, xlab=xLabel, ylab=yLabel, log=logScale)
      if (showFit) {
         if (logScale=="x")
            fit1 <- lm( returnVect[dateRange] ~ log10(dat[dateRange, CAPEname1]), na.action=na.omit)
         else fit1 <- lm( returnVect[dateRange] ~ dat[dateRange, CAPEname1], na.action=na.omit)
         abline(fit1, col=col1, lwd=2)
      }
      par(new=T)
   }
   if( CAPEname2 != "" ) {
      plot(dat[dateRange, CAPEname2], returnVect[dateRange], col=col2, 
           xlim=xRange, ylim=yRange, xlab="", ylab="", log=logScale)
      if (showFit) {
         if (logScale=="x")
            fit2 <- lm( returnVect[dateRange] ~ log10(dat[dateRange, CAPEname2]), na.action=na.omit)
         else fit2 <- lm( returnVect[dateRange] ~ dat[dateRange, CAPEname2], na.action=na.omit)
         abline(fit2, col=col2, lwd=2)
      }
   }
   
   if( CAPEname1 != "" ) {
      if( CAPEname2 != "" )
         legend( "topright", c(CAPEname1, CAPEname2), bty="n", col=c(col1, col2), pch=1)
      else legend( "topright", c(CAPEname1), bty="n", col=c(col1), pch=1)
   } else legend( "topright", c(CAPEname2), bty="n", col=c(col2), pch=1)
   par(new=F)

   if (figureTitle != "") title( figureTitle, outer = TRUE )
   par(oma = c( 0, 0, 0, 0 ))
   
   if(pngOutput) {
      dev.off()
      print( paste0("png file (", pngWidth, " by ", pngHeight, ") written to: ", pngName) )
   }   
   
#    plot(dat[dateRange, CAPEname1], resid(fit1))
# xVals <- seq(1, 50, by = 1)
# newdata <- data.frame("CAPE10" = xVals)
# p1 <- predict(fit1, newdata, interval = ("confidence"))
# print( (p1[,2]) )
# lines(xVals, p1[,2]); lines(xVals, p1[,3])
   
}


## OBSOLETE
searchForOptimalMetaCAPE <-function(stratName1=def$CAPEstrategies[[1]], stratName2=def$CAPEstrategies[[2]], 
                                    stratName3=def$CAPEstrategies[[3]], stratName4="",
                            minF1=20, maxF1=80, dF1=20, minF2=minF1, maxF2=maxF1, dF2=dF1, minF3=minF1, maxF3=maxF1, 
                            futureYears=def$FutureYears, tradingCost=def$TradingCost, cutoffScore=17, force=F) {

#    for(f1 in seq(minF1, maxF1, by=dF1)) 
#       for(f2 in seq(minF2, maxF2, by=dF2)) {
#          f4 <- 0   
#          f3 <- round(100 - f1 - f2)
#          #name = paste0("metaCAPE", "_", f1, "_", f2, "_", f3, "_",  f4)
#          displayName <- paste0(f1, "_", f2, "_", f3)
#          strategyName <- paste0("metaCAPE", displayName)
#          #print(name)
#          if ((f3 > minF3 - 1e-6) & (f3 < maxF3 + 1e-6)) {
#             calcMultiStrategyReturn(name1=stratName1, name2=stratName2, name3=stratName3, name4=stratName4, 
#                  f1/100, f2/100, f3/100, f4/100, strategyName=strategyName, 10*12, delta="", force=force)
#             showSummaryStrategy(strategyName, futureYears=futureYears, tradingCost=tradingCost, 
#                 cutoffScore=cutoffScore, displayName=displayName, force=force)
#          }
#       }
#    showSummaryStrategy("CAPE10avg24",  futureYears=futureYears, 
#       tradingCost=tradingCost, displayName="CAPE10  ", force=F)
#    showSummaryStrategy("balanced40_25_10_25", futureYears=futureYears, 
#       tradingCost=tradingCost, displayName="balanced", force=F)
}


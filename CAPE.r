
#default values of parameters
setCAPEdefaultValues <- function() {
   def$CAPEyears     <<- 10
   def$CAPEcheat     <<- 2
   def$CAPEavgOver   <<- 24
   def$initialOffset <<- (def$CAPEyears-def$CAPEcheat)*12 + def$CAPEavgOver
   
   def$CAPEbearishThreshold <<- 12.6
   def$CAPEbullishThreshold <<- 18.7
   
   def$CAPEstrategies <<- c("CAPE10_22_22", "CAPE10_16_16", "CAPE10_16_24", "stocks")
}


## calculating CAPE
calcCAPE <- function(years=def$CAPEyears, cheat=def$CAPEcheat) {
  CAPEname <- paste0("CAPE", years, "_", cheat)
  addNumColToDat(CAPEname)
  months <- 12*years
  for(i in 1:(months-12*cheat)) { dat[i, CAPEname] <<- NA }
  for(i in (months-12*cheat+1):numData) 
    dat[i, CAPEname] <<- dat$price[i] / mean(dat$earnings[1:(i-1)], na.rm=T)
  for(i in (months+1):numData) 
     dat[i, CAPEname] <<- dat$price[i] / mean(dat$earnings[(i-months):(i-1)], na.rm=T)
}


## Average CAPE over 'avgOver' months
calcAvgCAPE <- function(years=def$CAPEyears, cheat=def$CAPEcheat, avgOver=def$CAPEavgOver) {
   CAPEname <- paste0("CAPE", years, "_", cheat)
   if (!(CAPEname %in% colnames(dat))) 
      calcCAPE(years=years, cheat=cheat)
   avgCAPEname <- paste0(CAPEname,"avg",avgOver)
   addNumColToDat(avgCAPEname)
   #   message(paste0("NB: dat$", avgCAPEname, " has average of ", CAPEname, "over ", avgOver, " *months*."))
   for(i in 1:(avgOver-1)) dat[i, avgCAPEname] <<- NA # not enough data to calculate average
   for(i in avgOver:numData) dat[i, avgCAPEname] <<- mean(dat[(i-avgOver+1):i, CAPEname])  
}


## Normalize CAPE
normalizeCAPE <- function(CAPEname="CAPE10_2avg24", startIndex=def$startIndex, 
                          bearishThreshold=def$CAPEbearishThreshold, bullishThreshold=def$CAPEbullishThreshold, strategyName="") {

   if(strategyName=="") strategyName <- paste0(CAPEname, "_", bearishThreshold, "_", bullishThreshold)  
   requireColInDat(CAPEname)
   addNumColToNormalized(strategyName)
   
   normalized[1:(startIndex-1), strategyName] <<- NA  
   dateRange <- startIndex:numData
   normalized[dateRange, strategyName] <<- 2 * (dat[dateRange, CAPEname]-bullishThreshold) / (bearishThreshold-bullishThreshold) - 1
   # at bullishThreshold, alloc will be 95% and at bearishThreshold, alloc will be 5%
}


createCAPEstrategy <- function(years=def$CAPEyears, cheat=def$CAPEcheat, avgOver=def$CAPEavgOver, 
                               bearishThreshold=def$bearishThreshold, bullishThreshold=def$bullishThreshold,
                               futureYears=def$FutureYears, strategyName="", force=F) {

   CAPEname <- paste0("CAPE", years, "_", cheat, "avg", avgOver)
   if (!(CAPEname %in% colnames(dat)))
      calcAvgCAPE(years=years, cheat=cheat, avgOver=avgOver)     
   startIndex <- (years-cheat)*12 + avgOver + 1
#    warning("Using \'def$CAPEcheat' as parameter in createCAPEstrategy().")
   
   if(strategyName=="") strategyName <- paste0(CAPEname, "_", bearishThreshold, "_", bullishThreshold)  
   
   if (!(strategyName %in% colnames(TR)) | !(strategyName %in% colnames(alloc)) | force) { # if data do not exist yet or we force recalculation:   
      normalizeCAPE(CAPEname, startIndex, bearishThreshold, bullishThreshold, strategyName)
      calcAllocFromNorm(strategyName)
      addNumColToTR(strategyName)
      calcStrategyReturn(strategyName, startIndex)
   }  
   
   if ( !(strategyName %in% parameters$strategy) | force) {
      if ( !(strategyName %in% parameters$strategy) ) {
         parameters[nrow(parameters)+1, ] <<- NA
         parameters$strategy[nrow(parameters)] <<- strategyName
      }
      index <- which(parameters$strategy == strategyName)
      
      parameters$strategy[index] <<- strategyName
      parameters$type[index] <<- "CAPE"
      parameters$startIndex[index] <<- startIndex
      parameters$bearishThreshold[index] <<-  bearishThreshold
      parameters$bullishThreshold[index] <<-  bullishThreshold
   }
   calcStatisticsForStrategy(strategyName=strategyName, futureYears=futureYears, tradingCost=tradingCost, force=force)
   stats$type[which(stats$strategy == strategyName)] <<- parameters$type[which(parameters$strategy == strategyName)]
}



compareCAPE <-function(minCAPElow=4, maxCAPElow=28, byCAPElow=4, mindCAPE=0, maxdCAPE=28, bydCAPE=4, maxCAPEhigh=32, 
                       cutoffScore=17, force=F) {
   for ( CAPElow in seq(minCAPElow, maxCAPElow, by=byCAPElow) )       
      for ( dCAPE in seq(mindCAPE, maxdCAPE, by=bydCAPE) ) {
         CAPEhigh <- CAPElow + dCAPE
         if (CAPEhigh < maxCAPEhigh + 1e-6) {
            strategyName <- paste0("CAPE10_", CAPElow, "_", CAPEhigh)
            if (dCAPE < 1e-1) CAPEhigh <- CAPElow + 1e-1 # CAPEhigh = CAPElow would not work
            
            calcCAPEstrategyReturn(inputStrategyName="CAPE10avg24", strategyName=name, offset=10*12, 
                                   CAPElow=CAPElow, CAPEhigh=CAPEhigh, allocLow=1, allocHigh=0, force=force)
            showSummaryStrategy(strategyName, futureYears=futureYears, tradingCost=tradingCost, cutoffScore=cutoffScore, force=F)
         }  
      }
   showSummaries(futureYears=futureYears, tradingCost=tradingCost, detailed=F, force=F)
}

optimizeMetaCAPE <-function(stratName1=def$CAPEstrategies[[1]], stratName2=def$CAPEstrategies[[2]], stratName3=def$CAPEstrategies[[3]], stratName4="",
                            minF1=20, maxF1=80, dF1=20, minF2=minF1, maxF2=maxF1, dF2=dF1, minF3=minF1, maxF3=maxF1, 
                            futureYears=def$FutureYears, tradingCost=def$TradingCost, cutoffScore=17, force=F) {

   for(f1 in seq(minF1, maxF1, by=dF1)) 
      for(f2 in seq(minF2, maxF2, by=dF2)) {
         f4 <- 0   
         f3 <- round(100 - f1 - f2)
         #name = paste0("metaCAPE", "_", f1, "_", f2, "_", f3, "_",  f4)
         displayName <- paste0(f1, "_", f2, "_", f3)
         strategyName <- paste0("metaCAPE", displayName)
         #print(name)
         if ((f3 > minF3 - 1e-6) & (f3 < maxF3 + 1e-6)) {
            calcMultiStrategyReturn(name1=stratName1, name2=stratName2, name3=stratName3, name4=stratName4, 
                                    f1/100, f2/100, f3/100, f4/100, strategyName=strategyName, 10*12, delta="", force=force)
            showSummaryStrategy(strategyName, futureYears=futureYears, tradingCost=tradingCost, cutoffScore=cutoffScore, displayName=displayName, force=force)
         }
      }
   showSummaryStrategy("CAPE10avg24",  futureYears=futureYears, tradingCost=tradingCost, displayName="CAPE10  ", force=F)
   showSummaryStrategy("balanced40_25_10_25", futureYears=futureYears, tradingCost=tradingCost, displayName="balanced", force=F)
}


#Plotting
plotCAPEreturn <- function(stratName1=def$CAPEstrategies[[1]], stratName2=def$CAPEstrategies[[2]], stratName3=def$CAPEstrategies[[3]], stratName4=def$CAPEstrategies[[4]], 
                           startYear=1885, endYear=2014, minTR=.9, maxTR=10000, normalize=T, showAlloc=T) {
   plotReturn(stratName1=stratName1, stratName2=stratName2, stratName3=stratName3, stratName4=stratName4, 
              startYear=startYear, endYear=endYear, minTR=minTR, maxTR=maxTR, normalize=normalize, showAlloc=showAlloc)
}

plotCAPEfutureReturn <- function(stratName1=def$CAPEstrategies[[1]], stratName2=def$CAPEstrategies[[2]], stratName3=def$CAPEstrategies[[3]], stratName4=def$CAPEstrategies[[4]], 
                                 years=def$FutureYears, startYear=1885, endYear=2014-years, minTR=0, maxTR=.2, normalize=F, showAlloc=F) {
   plotFutureReturn(stratName1=stratName1, stratName2=stratName2, stratName3=stratName3, stratName4=stratName4,
                    years=years, startYear=startYear, endYear=endYear, minTR=minTR, maxTR=maxTR, normalize=normalize, showAlloc=showAlloc)
}

plotCAPEbothReturns <- function(stratName1=def$CAPEstrategies[[1]], stratName2=def$CAPEstrategies[[2]], stratName3=def$CAPEstrategies[[3]], stratName4=def$CAPEstrategies[[4]], 
                            years=def$FutureYears, startYear=1885, endYear=2014, minTR1=.9, maxTR1=10000, minTR2=0, maxTR2=.2) {
   plotBothReturns(stratName1=stratName1, stratName2=stratName2, stratName3=stratName3, stratName4=stratName4,
                               years=years, startYear=startYear, endYear=endYear, minTR1=minTR1, maxTR1=maxTR1, minTR2=minTR2, maxTR2=maxTR2) 
}

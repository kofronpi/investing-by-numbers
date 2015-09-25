
############################################
##                                        ##
##         Investing by numbers           ##
##   a quantitative trading strategy by   ##
##         Mathieu Bouville, PhD          ##
##      <mathieu.bouville@gmail.com>      ##
##                                        ##
##     utils.r has general functions      ##
##    (i.e. those not in another file)    ##
##                                        ##
############################################


# Add numeric column to DF if column does not already exist
addNumColToDat    <- function(colName) {
   if (!colName %in% colnames(dat)) dat[, colName] <<- numeric(numData)
}
addNumColToSignal <- function(colName) {
   if (!colName %in% colnames(signal)) signal[, colName] <<- numeric(numData)
}
addNumColToAlloc  <- function(colName) {
   if (!colName %in% colnames(alloc)) alloc[, colName] <<- numeric(numData)
}
addNumColToTR     <- function(colName) {
   if (!colName %in% colnames(TR)) TR[, colName] <<- numeric(numData)
}

# Stop if column does not exist in DF
requireColInDat    <- function(colName) {
   if (!colName %in% colnames(dat)) stop(paste0("dat$", colName, " does not exist."))
}
requireColInSignal <- function(colName) {
   if (!colName %in% colnames(signal)) stop(paste0("signal$", colName, " does not exist."))
}
requireColInAlloc  <- function(colName) {
   if (!colName %in% colnames(alloc)) stop(paste0("alloc$", colName, " does not exist."))
}
requireColInTR     <- function(colName) {
   if (!colName %in% colnames(TR)) stop(paste0("TR$", colName, " does not exist."))
}

calcNext5YrsReturn  <- function(strategyName, force=F) {
   if (!strategyName %in% colnames(next5yrs) | force) {
      next5yrs[, strategyName] <<- numeric(numData)
      months <- 12*5
      exponent <- 1/5
      
      next5yrs[1:(numData-months), strategyName] <<- 
         (TR[1:(numData-months)+months, strategyName] / TR[1:(numData-months), strategyName]) ^ exponent - 1
      next5yrs[(numData-months+1):numData, strategyName] <<- NA
   }
   median5 <- median(next5yrs[, strategyName], na.rm=T)
   five5 <- quantile(next5yrs[, strategyName], .05, na.rm=T)[[1]]
   return( c(median=median5, five=five5) )
}
calcNext10YrsReturn <- function(strategyName, force=F) {
   if (!strategyName %in% colnames(next10yrs) | force) {
      next10yrs[, strategyName] <<- numeric(numData)
      months <- 12*10
      exponent <- 1/10
      
      next10yrs[1:(numData-months), strategyName] <<- 
         (TR[1:(numData-months)+months, strategyName] / TR[1:(numData-months), strategyName]) ^ exponent - 1
      next10yrs[(numData-months+1):numData, strategyName] <<- NA
   }
   median10 <- median(next10yrs[, strategyName], na.rm=T)
   five10 <- quantile(next10yrs[, strategyName], .05, na.rm=T)[[1]]
   return( c(median=median10, five=five10) )
}
calcNext15YrsReturn <- function(strategyName, force=F) {
   if (!strategyName %in% colnames(next15yrs) | force) {
      next15yrs[, strategyName] <<- numeric(numData)
      months <- 12*15
      exponent <- 1/15
      
      next15yrs[1:(numData-months), strategyName] <<- 
         (TR[1:(numData-months)+months, strategyName] / TR[1:(numData-months), strategyName]) ^ exponent - 1
      next15yrs[(numData-months+1):numData, strategyName] <<- NA
   }
   median15 <- median(next15yrs[, strategyName], na.rm=T)
   five15 <- quantile(next15yrs[, strategyName], .05, na.rm=T)[[1]]
   return( c(median=median15, five=five15) )
}
calcNext20YrsReturn <- function(strategyName, force=F) {
   if (!strategyName %in% colnames(next20yrs) | force) {
      next20yrs[, strategyName] <<- numeric(numData)
      months <- 12*20
      exponent <- 1/20

      next20yrs[1:(numData-months), strategyName] <<- 
         (TR[1:(numData-months)+months, strategyName] / TR[1:(numData-months), strategyName]) ^ exponent - 1
      next20yrs[(numData-months+1):numData, strategyName] <<- NA
   }
   median20 <- median(next20yrs[, strategyName], na.rm=T)
   five20 <- quantile(next20yrs[, strategyName], .05, na.rm=T)[[1]]
   return( c(median=median20, five=five20) )
}
calcNext30YrsReturn <- function(strategyName, force=F) {
   if (!strategyName %in% colnames(next30yrs) | force) {
      next30yrs[, strategyName] <<- numeric(numData)
      months <- 12*30
      exponent <- 1/30

      next30yrs[1:(numData-months), strategyName] <<- 
         (TR[1:(numData-months)+months, strategyName] / TR[1:(numData-months), strategyName]) ^ exponent - 1
      next30yrs[(numData-months+1):numData, strategyName] <<- NA
   }
   median30 <- median(next30yrs[, strategyName], na.rm=T)
   five30 <- quantile(next30yrs[, strategyName], .05, na.rm=T)[[1]]
   return( c(median=median30, five=five30) )
}
calcNextReturns     <- function(strategyName, force=F) {
   if ( !exists("next5yrs") || dim(next5yrs)[[1]] != dim(dat)[[1]] )
      next5yrs  <<- data.frame(date = dat$date, numericDate = dat$numericDate)
   calcNext5YrsReturn(strategyName, force)

   if ( !exists("next10yrs") || dim(next10yrs)[[1]] != dim(dat)[[1]] ) 
      next10yrs  <<- data.frame(date = dat$date, numericDate = dat$numericDate)
   calcNext10YrsReturn(strategyName, force)

   if ( !exists("next15yrs") || dim(next15yrs)[[1]] != dim(dat)[[1]] ) 
      next15yrs  <<- data.frame(date = dat$date, numericDate = dat$numericDate)
   calcNext15YrsReturn(strategyName, force)
   
   if ( !exists("next20yrs") || dim(next20yrs)[[1]] != dim(dat)[[1]] ) 
      next20yrs  <<- data.frame(date = dat$date, numericDate = dat$numericDate)
   calcNext20YrsReturn(strategyName, force)
   
   if ( !exists("next30yrs") || dim(next30yrs)[[1]] != dim(dat)[[1]] ) 
      next30yrs  <<- data.frame(date = dat$date, numericDate = dat$numericDate)
   calcNext30YrsReturn(strategyName, force)
}

calcStatsFutureReturnsAnnualized<- function(strategyName, force=F) {
   calcNextReturns(strategyName, force)
   print( "            min., low 5%, low 25%, median, hi 25%, hi 5%, max." )
   pc <- round (quantile(next5yrs[strategyName], probs=c(0, .05, .25, .5, .75, 0.95, 1), na.rm=T)*100, 2)
   print( paste0(" 5 years: ", pc[1], "%, ", pc[2], "%, ", pc[3], "%, ", pc[4], "%, ", pc[5], "%, ", pc[6], "%, ", pc[7], "%" ) )
   pc <- round (quantile(next10yrs[strategyName], probs=c(0, .05, .25, .5, .75, 0.95, 1), na.rm=T)*100, 2)
   print( paste0("10 years:  ", pc[1], "%, ", pc[2], "%, ", pc[3], "%, ", pc[4], "%, ", pc[5], "%, ", pc[6], "%, ", pc[7], "%" ) )
   pc <- round (quantile(next15yrs[strategyName], probs=c(0, .05, .25, .5, .75, 0.95, 1), na.rm=T)*100, 2)
   print( paste0("15 years:  ", pc[1], "%,  ", pc[2], "%, ", pc[3], "%, ", pc[4], "%,  ", pc[5], "%, ", pc[6], "%, ", pc[7], "%" ) )
   pc <- round (quantile(next20yrs[strategyName], probs=c(0, .05, .25, .5, .75, 0.95, 1), na.rm=T)*100, 2)
   print( paste0("20 years:  ", pc[1], "%,  ", pc[2], "%, ", pc[3], "%, ", pc[4], "%,  ", pc[5], "%, ", pc[6], "%, ", pc[7], "%" ) )
   pc <- round (quantile(next30yrs[strategyName], probs=c(0, .05, .25, .5, .75, 0.95, 1), na.rm=T)*100, 2)
   print( paste0("30 years:   ", pc[1], "%,  ", pc[2], "%, ", pc[3], "%, ", pc[4], "%,  ", pc[5], "%,  ", pc[6], "%, ", pc[7], "%" ) )
}
calcStatsNextReturns<- function(strategyName, initialAmount=100, force=F) {
   calcNextReturns(strategyName, force)
   print( "            min., low 5%, low 25%, median, hi 25%, hi 5%, max." )
   pc <- round( ((1+quantile( next5yrs["stocks"], probs=c(0, .05, .25, .5, .75, 0.95, 1), na.rm=T)) ^  5 - 1) * initialAmount, 0)
   print( paste0(" 5 years:   $", pc[1], ",   $", pc[2], ",   $", pc[3], ",   $", pc[4], ",   $", pc[5], ",   $", pc[6], ",   $", pc[7] ) )
   pc <- round( ((1+quantile(next10yrs["stocks"], probs=c(0, .05, .25, .5, .75, 0.95, 1), na.rm=T)) ^ 10 - 1) * initialAmount, 0)
   print( paste0("10 years:   $", pc[1], ",   $", pc[2], ",   $", pc[3], ",   $", pc[4], ",   $", pc[5], ",   $", pc[6], ",   $", pc[7] ) )
   pc <- round( ((1+quantile(next15yrs["stocks"], probs=c(0, .05, .25, .5, .75, 0.95, 1), na.rm=T)) ^ 15 - 1) * initialAmount, 0)
   print( paste0("15 years:   $", pc[1], ",     $", pc[2], ",   $", pc[3], ",   $", pc[4], ",   $", pc[5], ",    $", pc[6], ",   $", pc[7] ) )
   pc <- round( ((1+quantile(next20yrs["stocks"], probs=c(0, .05, .25, .5, .75, 0.95, 1), na.rm=T)) ^ 20 - 1) * initialAmount, 0)
   print( paste0("20 years:    $", pc[1], ",     $", pc[2], ",   $", pc[3], ",   $", pc[4], ",   $", pc[5], ",    $", pc[6], ",    $", pc[7] ) )
   pc <- round( ((1+quantile(next30yrs["stocks"], probs=c(0, .05, .25, .5, .75, 0.95, 1), na.rm=T)) ^ 30 - 1) * initialAmount, 0)
   print( paste0("30 years:    $", pc[1], ",    $", pc[2], ",   $", pc[3], ",   $", pc[4], ",   $", pc[5], ",    $", pc[6], ",    $", pc[7] ) )
}


calcFutureStockReturns <- function( years=seq(.5, 35, by=.5), force=F ) {
   if ( !exists("futureStockReturns") || force)
      futureStockReturns  <<- data.frame(date = dat$date, numericDate = dat$numericDate)
   
   for (year in years) {
      yearName <- toString(year)
      futureStockReturns[, yearName] <<- numeric(numData)
      months <- 12*year; exponent <- 1/year;
      
      futureStockReturns[1:(numData-months), yearName] <<- 
         (TR[1:(numData-months)+months, "stocks"] / TR[1:(numData-months), "stocks"]) ^ exponent - 1
      futureStockReturns[(numData-months+1):numData, yearName] <<- NA
   }
}
calcStockStats <- function( years=seq(.5, 35, by=.5), force=F ) {
   calcFutureStockReturns(years, force)
   stockStats <<- data.frame( "min"    = numeric(), 
                              "low1"   = numeric(), 
                              "low5"   = numeric(), 
                              "low25"  = numeric(), 
                              "median" = numeric(), 
                              "high25" = numeric(), 
                              "high5"  = numeric(), 
                              "high1"  = numeric(), 
                              "max"    = numeric(),
                              "proba.real.loss" = numeric() )
   for (year in years) {
      yearName <- toString(year)
      pc <- quantile(futureStockReturns[yearName], probs=c(0, .01, .05, .25, .5, .75, 0.95, .99, 1), na.rm=T)
      stockStats[yearName, 1:9] <<- ( pc )
      stockStats[yearName, 10]   <<- sum(futureStockReturns[yearName] < 0, na.rm=T) / sum(!is.na(futureStockReturns[yearName]) )
   }
}


## calculating future annualized return of strategies
calcStrategyFutureReturn <- function(strategyName, futureYears = numeric(), force=F) {
   if (futureYears==5)
      median_five <-  calcNext5YrsReturn(strategyName, force)
   else if (futureYears==10)
      median_five <- calcNext10YrsReturn(strategyName, force)
   else if (futureYears==15)
      median_five <- calcNext15YrsReturn(strategyName, force)
   else if (futureYears==20)
      median_five <- calcNext20YrsReturn(strategyName, force)
   else if (futureYears==30)
      median_five <- calcNext30YrsReturn(strategyName, force)
   else stop("No data frame \'calcNext", futureYears, "YrsReturn\' exists.")
   return(median_five)
   # NB: median_five is about the median and the 5% risk, nothing to do with 5 years
}

 
## Calculating real returns of constant allocation
calcTRconstAlloc <- function(stockAllocation = 70L, strategyName="", force=F) { # parameter is stock allocation in %
   if(stockAllocation<0 | stockAllocation>100) stop("Stock allocation must be between 0 and 100 (percents).")
   #   if(stockAllocation != floor(stockAllocation)) stop("Stock allocation must be an integer.")
   
   if (strategyName == "") {
      if (stockAllocation == 100) { strategyName <- "stocks" }
      else if (stockAllocation == 0) { strategyName <- "bonds" }
      else { strategyName <- paste0("constantAlloc", stockAllocation, "_", 100-stockAllocation) }
   } 
   
   if (!strategyName %in% colnames(TR) | force) {
      if (!strategyName %in% colnames(TR)) TR[, strategyName] <<- numeric(numData)
      
      stockAllocation <- stockAllocation / 100
      
      TR[1, strategyName] <<- 1
      for(i in 2:numData) 
         TR[i, strategyName] <<- TR[i-1, strategyName] * ( 
            stockAllocation * dat$TR[i] / dat$TR[i-1] + 
               (1-stockAllocation) * dat$bonds[i] / dat$bonds[i-1]  )
   }
   #calcTRnetOfTradingCost(strategyName, futureYears=futureYears, force=force)       
}


createConstAllocStrategy <- function(stockAllocation = 70L, strategyName="", costs,
                                     futureYears=def$futureYears, force=F) { # parameter is stock allocation in %

   if(stockAllocation<0 | stockAllocation>100) stop("Stock allocation must be between 0 and 100 (percents).")
   #   if(stockAllocation != floor(stockAllocation)) stop("Stock allocation must be an integer.")
   
   if (strategyName == "") {
      if (stockAllocation == 100) { strategyName <- "stocks" }
      else if (stockAllocation == 0) { strategyName <- "bonds" }
      else { strategyName <- paste0("constantAlloc", stockAllocation, "_", 100-stockAllocation) }
   } 

   addNumColToSignal(strategyName)
   signal[, strategyName] <<- stockAllocation/100
      
   TRconstAllocName <- calcTRconstAlloc(stockAllocation=stockAllocation, strategyName=strategyName, force=force) 
   
   if ( !(strategyName %in% stats$strategy) ) {
      index <- nrow(stats)+1 # row where the info will be added
      stats[index, ] <<- NA
      stats$strategy[index] <<- strategyName
      stats$type[index] <<- "constantAlloc"
      stats$avgStockAlloc[index] <<- stockAllocation/100
      stats$latestStockAlloc[index] <<- stockAllocation/100
      stats$turnover[index] <<- Inf
   }   
   calcStatisticsForStrategy(strategyName, futureYears=futureYears, costs=costs, force=force)
}


calcStrategyReturn <- function(strategyName, startIndex) {
   TR[1:(startIndex-1), strategyName] <<- NA
   TR[startIndex, strategyName] <<- 1
   for(i in (startIndex+1):numData) 
      TR[i, strategyName] <<- TR[i-1, strategyName] * ( 
         alloc[i-1, strategyName] * dat$monthlyDifference[i] + dat$bondsMonthly[i] ) 
   # alloc * (stocks-bonds) + bonds = alloc * stocks + (1-alloc) * bonds
}



## Calculating signal -- same function for all strategies (except CAPE with hysteresis)
calcSignalForStrategy <- function(
         strategyName,             # the signal will be written to signal[, strategyName]
         input,                    # data from which the signal will be calculated
         allocSource="stocks",     # the allocation when in the market (default = stocks)
         bearish,                  # value of the input at which allocation = 0
         bullish,                  # value of the input at which allocation = 1
         yoyoOffset=1L,            # how far back we look (default must be 1 for backward compatibility)
         yoyoPenalty=0,
         signalMin=def$signalMin,  # the values of the signal will be between...
         signalMax=def$signalMax,  # signalMin and signalMax
         startIndex=def$startIndex # where the signal starts (NA before that)
         ) {          # between 0 and 1 (default must be 0 for backward compatibility)
      
   dateRange <- startIndex:numData
   if( sum(is.na(input[dateRange])) > 0) # there should be no NA after startIndex
     stop("Input contains NA after startIndex (", startIndex, ").")
   
   isZero <- tan ( pi * (   -signalMin  / (signalMax - signalMin) - 1/2 ) ) 
   isOne  <- tan ( pi * ( (1-signalMin) / (signalMax - signalMin) - 1/2 ) )
   a <- (isOne-isZero) / (bullish-bearish)
   b <- isOne - a * bullish
   
   addNumColToSignal(strategyName)
   signal[1:(startIndex-1), strategyName] <<- NA  
   signal[dateRange, strategyName] <<- ( atan( a * input[dateRange] + b ) / pi + .5 ) # this is between 0 and 1
   if(length(allocSource)>1 || allocSource!="stocks") # we rescale based on allocSource
      signal[dateRange, strategyName] <<- signal[dateRange, strategyName] * allocSource[dateRange] +
               (1 - signal[dateRange, strategyName] ) * ( 1 - allocSource[dateRange] )
   signal[dateRange, strategyName] <<- signal[dateRange, strategyName] * (signalMax - signalMin) + signalMin
   
   ## Avoiding a yoyo effect (buying then selling then buying, etc. every month)
   scale <- yoyoPenalty / (signalMax - signalMin)^2
   if (yoyoPenalty!=0 && yoyoOffset!=1)
      for (i in (startIndex+yoyoOffset):numData) {
         delta <- (signal[i-1, strategyName] - signal[i-yoyoOffset, strategyName]) * 
            (signal[i,   strategyName] - signal[i-1, strategyName])
         # delta = [ s_(n-off) - s_(n-1) ] * [ s_(n-1) - s_n ]
         # if s_(n-off)=1, s_(n-1)=0 and s_n=1 (yoyo effect to be avoided)      then delta=-1
         # if s_(n-off)=1, s_(n-1)=1 and s_n=0 (unobjectionable drop in signal) then delta= 0
         
         delta <- min(delta, 0) * scale
         # normalizes delta between -yoyoPenalty and 0
         # if delta>0 then we continue a buy or sell trend (unobjectionable)
         
         signal[i, strategyName] <<- signal[i, strategyName] + 
            delta * ( signal[i, strategyName] - signal[i-1, strategyName] )
         # if yoyoPenalty=1 and delta<0 then signal[i, strategyName] <- signal[i-1, strategyName]
         # if yoyoPenalty=0 or  delta=0 then signal[i, strategyName] is untouched
      }
}


## Calculating allocation (between 0 and 1) from signal -- same function for all strategies
## signal < 0 is _very_ bearish, but we do not go short
## signal > 1 is _very_ bullish, but we do not use leverage
calcAllocFromSignal <- function(strategyName) {
   requireColInSignal(strategyName)
   addNumColToAlloc(strategyName)
   for(i in 1:numData)
      alloc[i, strategyName] <<- max( min( signal[i, strategyName], 1), 0)
}


calcSMAofStrategy <- function(inputStrategyName, avgOver=3L, futureYears=def$futureYears,
                              medianAlloc=def$medianAlloc, interQuartileAlloc=def$interQuartileAlloc, 
                              strategyName="", force=F) {
   if (strategyName=="") strategyName <- paste0(name, "_SMA", avgOver)

   if (!(inputStrategyName %in% colnames(alloc)))  stop(paste0("alloc$", inputStrategyName, " does not exist."))
   
   if (!(strategyName %in% colnames(TR)) | !(strategyName %in% colnames(alloc)) | force) { # if data do not exist yet or we force recalculation:   
      if (!(strategyName %in% colnames(alloc))) alloc[, strategyName] <<- numeric(numData)
      if (!(strategyName %in% colnames(TR))) TR[, strategyName] <<- numeric(numData)
      
      signal[1:(avgOver-1), strategyName] <<- NA
      for (i in avgOver:numData) 
         signal[i, strategyName] <<- mean( signal[(i-avgOver+1):i, inputStrategyName], na.rm=F )
      calcAllocFromSignal(strategyName, medianAlloc, interQuartileAlloc)
      startIndex <- sum(is.na(alloc[, strategyName]))+1
      calcStrategyReturn( strategyName, startIndex )
   }
   
   if ( !(strategyName %in% parameters$strategy) | force) {
      if ( !(strategyName %in% parameters$strategy) ) {
         parameters[nrow(parameters)+1, ] <<- NA
         parameters$strategy[nrow(parameters)] <<- strategyName
      }
      index <- which(parameters$strategy == strategyName)
      inputIndex <- which(parameters$strategy == inputStrategyName)
      
      parameters$strategy[index] <<- strategyName
      parameters$type[index] <<- parameters$type[inputIndex]
      parameters$subtype[index] <<- parameters$subtype[inputIndex]
      parameters$startIndex[index] <<- startIndex
      
      parameters$inputStrategyName1[index] <<- inputStrategyName
      parameters$medianAlloc[index] <<-  medianAlloc
      parameters$interQuartileAlloc[index] <<-  interQuartileAlloc
      parameters$name1[index] <<-  "SMA of strategy"
      parameters$name2[index] <<- "avgOver"
      parameters$value2[index] <<-  avgOver     
   }
   calcStatisticsForStrategy(strategyName=strategyName, futureYears=futureYears, force=force)
   stats$type[which(stats$strategy == strategyName)] <<- parameters$type[which(parameters$strategy == strategyName)]
   stats$subtype[which(stats$strategy == strategyName)] <<- parameters$subtype[which(parameters$strategy == strategyName)]
   
#    warning("Strategy ", strategyName, ", created by calcSMAofStrategy(), has no entry in either \'parameters\' or \'stats\'.")
}

## Modern portfolio theory (Markowitz)
# MPT <- function(input1, input2) { 
# }

regression <- function(x, y) { # y = a + b x
   b <- cov(x,y) / var(x)
   a <- mean(y) - b * mean(x)
   return( c(a, b) )
}

createRange <- function (minValue, maxValue, byValue) {
   if (minValue == maxValue) # does not require byValue to make sense
      return (minValue)
   else if ( abs(byValue) > abs(maxValue-minValue) )   # does not require byValue to be of the correct sign
      return (minValue)
   else {
      minValue <- round(minValue, 4) # cleaning to avoid that min=0.2000001, max=0.4, by=0.2 not include 0.4
      maxValue <- round(maxValue, 4)
      byValue  <- round(byValue, 4)
      return ( c( seq(minValue, maxValue, by=2*byValue), 
                  seq(minValue+byValue, maxValue, by=2*byValue) ) )
   }   
}

deleteStrategy <- function(stratName, warnings=T) {
   # delete strategy from DFs where it is entered as a column
   index <- which( colnames(signal) == stratName )
   if(length(index) > 0) 
      signal[index] <<- NULL
   else if (warnings) warning(paste("Strategy", stratName, "cannot be found in 'signal'.") )
   
   index <- which( colnames(alloc) == stratName )
   if(length(index) > 0) 
      alloc[index] <<- NULL
   else if (warnings) warning(paste("Strategy", stratName, "cannot be found in 'alloc'.") )
   
   index <- which( colnames(TR) == stratName )
   if(length(index) > 0) 
      TR[index] <<- NULL
   else if (warnings) warning(paste("Strategy", stratName, "cannot be found in 'TR'.") )
   
   index <- which( colnames(DD) == stratName )
   if(length(index) > 0) 
      DD[index] <<- NULL
   else if (warnings) warning(paste("Strategy", stratName, "cannot be found in 'DD'.") )
      
   
   # delete strategy from DFs where it is entered as a row
   index <- which(stats$strategy == stratName)
   if (length(index) > 0)    
      stats <<- stats[-index, ] 
   else if (warnings) warning(paste("Strategy", stratName, "cannot be found in 'stats'.") )

   index <- which(parameters$strategy == stratName)
   if (length(index) > 0)    
      parameters <<- parameters[-index, ]
   else if (warnings) warning(paste("Strategy", stratName, "cannot be found in 'parameters'.") )
   
   
   # delete strategy from nextNyears DF
   if (def$futureYears==5) {
      index             <- which( colnames(next5yrs) == stratName )
      if (length(index) > 0)    
         next5yrs[index]  <<- NULL
      else if (warnings) warning(paste("Strategy", stratName, "cannot be found in 'next5yrs'.") )
   }
   else if (def$futureYears==10) {
      index             <- which( colnames(next10yrs) == stratName )
      if (length(index) > 0)    
         next10yrs[index] <<- NULL
      else if (warnings) warning(paste("Strategy", stratName, "cannot be found in 'next10yrs'.") )
   }
   else if (def$futureYears==15) {
      index             <- which( colnames(next15yrs) == stratName )
      if (length(index) > 0)    
         next15yrs[index] <<- NULL
      else if (warnings) warning(paste("Strategy", stratName, "cannot be found in 'next15yrs'.") )
   }            
   else if (def$futureYears==20) {
      index             <- which( colnames(next20yrs) == stratName )
      if (length(index) > 0)    
         next20yrs[index] <<- NULL
      else if (warnings) warning(paste("Strategy", stratName, "cannot be found in 'next20yrs'.") )
   }            
   else if (def$futureYears==30) {
      index             <- which( colnames(next30yrs) == stratName )
      if (length(index) > 0)    
         next30yrs[index] <<- NULL
      else if (warnings) warning(paste("Strategy", stratName, "cannot be found in 'next30yrs'.") )
   }                    
}

## Interrupting parameter searches can create a problem with the strategy being calculated,
##    which will crash subsequent runs.
cleanUpStrategies <- function(warnings=F) {
   counter <- 0 # number of entries deleted
   
   # looking for strategies for which 'signal' is incomplete
   for ( i in (12:dim(signal)[[2]]) ) # starting after constant allocations
      if ( is.na(signal[numData, i]) || signal[numData, i]==0 ) {
         stratName <- colnames(signal[i])
         print(paste("Strategy", stratName, "will be deleted (signal = 0).") )        
         deleteStrategy(stratName, warnings=warnings)
         counter   <- counter+1  
      }
   
   # looking for strategies for which 'signal' is complete, but 'TR' is not
   for ( i in (18:dim(TR)[[2]]) )
      if ( TR[numData, i]==0 ) {
         stratName <- colnames(TR[i])
         print(paste("Strategy", stratName, "will be deleted (TR = 0).") )        
         deleteStrategy(stratName, warnings=warnings)
         counter   <- counter+1
      }

   # looking for strategies for which 'TR' is complete, but not DD
   for ( i in (15:dim(DD)[[2]]) )
      if ( DD[numDD-2, i]==0 && DD[numDD-1, i]==0 && DD[numDD, i]==0 ) {
         stratName <- colnames(DD[i])
         print(paste("Strategy", stratName, "will be deleted (DD = 0).") )        
         deleteStrategy(stratName, warnings=warnings)
         counter   <- counter+1 
      }
   
   # looking for strategies for which 'DD' is complete, but 'stats' is not
   for ( i in (7:dim(stats)[[1]]) )
      if ( is.na(stats$score[i] )) {
         stratName <- stats$strategy[i]
         print(paste("Strategy", stratName, "will be deleted (score = NA).") )        
         deleteStrategy(stratName, warnings=warnings)
         counter   <- counter+1 
      }
   
   # looking for empty entries in 'parameters'
   for ( i in (1:dim(parameters)[[1]]) )
      if ( is.na(parameters$strategy[i] )) {
         parameters <<- parameters[-i, ]
         print(paste("Empty entry will be deleted from 'parameters'.") )        
      }

   # looking for strategies for which 'stats' is complete, but 'parameters' is not
   for ( i in (1:dim(parameters)[[1]]) )
      if ( is.na(parameters$startIndex[i] )) {
         stratName <- parameters$strategy[i]
         print(paste("Strategy", stratName, "will be deleted (startIndex = NA).") )        
         deleteStrategy(stratName, warnings=warnings)
         counter   <- counter+1 
      }
   
   #print( paste("entries deleted:", counter) )
}

   
calcStatisticsForStrategy <- function(strategyName, futureYears=def$futureYears, 
                                      costs=def$tradingCost+def$riskAsCost, 
                                      coeffTR=def$coeffTR, coeffMed=def$coeffMed, coeffFive=def$coeffFive,
                                      coeffVol=def$coeffVol, coeffDD2=def$coeffDD2, force=F) {
   
   dateRange <- def$startIndex:numData
   if ( !(strategyName %in% stats$strategy) ) {
      stats[nrow(stats)+1, ] <<- NA
      stats$strategy[nrow(stats)] <<- strategyName
   }
   index <- which(stats$strategy == strategyName)
   if(length(index) > 1) 
      stop("There are ", length(index), " entries for ", strategyName, " in stats$strategy.")
   
   medianName <- paste0("median", futureYears)
   fiveName <- paste0("five", futureYears)
   if (!medianName %in% colnames(stats)) {
      if (futureYears != def$futureYears)
         stop( paste0("stats$", medianName, " does not exist (probably because futureYears != def$futureYears.") )
      else stop(paste0("stats$", medianName, " does not exist (probably because def$futureYears got changed by hand).\n",
                       "This can happen when running start() with a new value of 'futureYears' without using \'force=T\'.") )
   }
   
   if ( is.na(stats$score[index]) | force) {
      # if data do not exist (we use 'score' to test this as it requires a lot of other data) yet or we force recalculation:   
      
      median_five <- calcStrategyFutureReturn(strategyName, futureYears, force=force)
      stats[index, medianName]<<- median_five[[1]]
      stats[index, fiveName]  <<- median_five[[2]]
      
      if (!(strategyName %in% colnames(DD)) | force) 
         CalcAllDrawdowns(strategyName, force=force)
      stats$DD2[index]        <<- mean( abs(DD[, strategyName])^def$DDpower )
      
      indexPara <- which(parameters$strategy == strategyName)     
      if ( length(indexPara) > 0 ) { # otherwise we are probably dealing with a constant allocation
         startIndex <- parameters$startIndex[indexPara]
         if(!is.na(startIndex))
            def$startIndex <<- max(def$startIndex, startIndex) # update def$startIndex if need be
         else warning("startIndex = ", startIndex)
         def$startYear  <<- max(def$startYear, (def$startIndex-1)/12+def$dataStartYear )
         def$plotStartYear <<- max(def$plotStartYear, def$startYear)
      }
      dateRange <- def$startIndex:numData
      
      #       time1 <- proc.time()      
      fit <- numeric(numData)
      fitPara <- regression(TR$numericDate[dateRange], log(TR[dateRange, strategyName]))
      a <- fitPara[[1]]
      b <- fitPara[[2]]
      fit[dateRange] <- log(TR[dateRange, strategyName]) - (a + b * TR$numericDate[dateRange])
      fit2 <- numeric(numData)
      fit2[dateRange] <- fit[dateRange] - fit[dateRange-12] # requires startIndex to be at least 13
      
      stats$TR[index]         <<- exp(b)-1
      stats$volatility[index] <<- sd(fit2[dateRange], na.rm=T)
      #       print( c( "Time for fit:", round(summary(proc.time())[[1]] - time1[[1]] , 2) ) )
      
      if ( (strategyName %in% colnames(alloc)) ) {# this means we are NOT dealing with constant allocation (e.g. stocks)
         stats$avgStockAlloc[index]    <<- mean(alloc[dateRange, strategyName], na.rm=T)
         stats$latestStockAlloc[index] <<- alloc[numData, strategyName]     
         dateRange2 <- def$startIndex:(numData-1)
         turnover <- numeric(numData)
         turnover[1:def$startIndex] <- NA
         turnover[dateRange2+1] <- abs(alloc[dateRange2+1, strategyName] - alloc[dateRange2, strategyName])
         stats$turnover[index] <<- 1/12/mean(turnover[dateRange2+1], na.rm=F)
      } 
      stats$invTurnover[index] <<- 1/stats$turnover[index]

      stats$netTR0.5[index] <<- stats$TR[index] - 0.5/100/stats$turnover[index]
      stats$netTR1[index]   <<- stats$TR[index] - 1  /100/stats$turnover[index]
      stats$netTR2[index]   <<- stats$TR[index] - 2  /100/stats$turnover[index]
      stats$netTR3[index]   <<- stats$TR[index] - 3  /100/stats$turnover[index]
      stats$netTR4[index]   <<- stats$TR[index] - 4  /100/stats$turnover[index]
      stats$netTR6[index]   <<- stats$TR[index] - 6  /100/stats$turnover[index]
      stats$netTR8[index]   <<- stats$TR[index] - 8  /100/stats$turnover[index]
      stats$netTR10[index]  <<- stats$TR[index] -10  /100/stats$turnover[index]
   }

   stats$score[index] <<- 250 * (  coeffTR  * ( stats$TR[index] - 9/100 )
                                 + coeffMed * ( stats[index, medianName]-  9/100 )
                                 + coeffFive* ( stats[index, fiveName]  -  3/100 )
                                 - coeffVol * ( stats$volatility[index] - 14/100 )
                                 - coeffDD2 * ( stats$DD2[index] - 6/100 )
                                 - costs * ( stats$invTurnover[index] - 1/1.2 ) ) + 15
   ## 1. The coefficients coeffVol and coeffDD2 make it possible to 'convert' vol and DD2 into return equivalents.
   ## 2. I subtract off constants to reduce the variation of the score when coefficients are changed
   ## 3. TR, median and five are gross of costs (drawdowns too); turnover cost is subtracted of through invTurnover
}

displaySummaryHeader <- function(futureYears=def$futureYears, nameLength=def$nameLength) {
   if (def$DDpower==2)
      DD2label <- " DD^2  "
   else if (def$DDpower==1.5)
      DD2label <- "DD^1.5 "
   else if ( abs(def$DDpower-4/3) < 0.01 )
      DD2label <- "DD^4/3 "
   else if ( abs(def$DDpower-5/3) < 0.01 )
      DD2label <- "DD^5/3 "
   else
      DD2label <- str_pad(paste("DD^",def$DDpower), 7)
   
   print(paste0(str_pad("strategy", nameLength, side="right"), "|  TR   ", futureYears, 
                " yrs: med, 5%| vol. alloc: avg, now|TO yrs |", DD2label, "| score") )
   dashes <- paste0(str_pad("", nameLength, pad="-"), 
                    "+-------+--------------+-------+-------------+-------+-------+------")
   print(dashes)
   return(dashes)
}

showSummaryForStrategy <- function(strategyName, displayName="", futureYears=def$futureYears, 
                                   costs=def$tradingCost+def$riskAsCost, 
                                   minTR=0, maxVol=Inf, maxDD2=Inf, minTO=0, minScore=-Inf, 
                                   coeffTR=def$coeffTR, coeffMed=def$coeffMed, coeffFive=def$coeffFive,
                                   coeffVol=def$coeffVol, coeffDD2=def$coeffDD2, 
                                   coeffEntropy=0, nameLength=def$nameLength, force=F) {
   
   if ( !(strategyName %in% stats$strategy) )
      calcStatisticsForStrategy(strategyName, futureYears=futureYears, costs=costs,
                                coeffTR=coeffTR, coeffMed=coeffMed, coeffFive=coeffFive,
                                coeffVol=coeffVol, coeffDD2=coeffDD2, force=T) 
   else  # if force==F then we only recalculate the score (quick)
      calcStatisticsForStrategy(strategyName, futureYears=futureYears, costs=costs, 
                                coeffTR=coeffTR, coeffMed=coeffMed, coeffFive=coeffFive,
                                coeffVol=coeffVol, coeffDD2=coeffDD2, force=force) 

   index <- which(stats$strategy == strategyName)
   medianName <- paste0("median", futureYears)
   fiveName <- paste0("five", futureYears)
   if(displayName=="") displayName <- strategyName
   
   TO         <- stats$turnover[index]
   TOcost     <- costs/TO
   TO         <- round(TO, 2) # rounded for display, but not to calculate TOcost
   
   avgAlloc   <- round( 100*stats$avgStockAlloc[index], 0 )
   latestAlloc<- round( 100*stats$latestStockAlloc[index], 0 )  

   ret        <- round( 100*(stats$TR[index] - TOcost), 2 )
   vol        <- round( 100*stats$volatility[index], 1 )
   med        <- round( 100*(stats[index, medianName] - TOcost), 1 )
   five       <- round( 100*(stats[index, fiveName] - TOcost), 1 )
   DD2        <- round( 100*stats$DD2[index], 1 )

   score      <- stats$score[index] 
   #    if(coeffEntropy > 0)
   #       score   <- score + coeffEntropy * (stats$entropy[index] - 1) 

   if (round(ret,2)%%1 == 0) retPad = ".  "    # no decimals
   else if (round(10*ret,1)%%1 == 0) retPad = "0"  # single decimal
      else retPad = ""
   
   if (vol>=10) volPad1 = ""
      else volPad1 = " "
   if (vol%%1 == 0) volPad2 = ". "
      else volPad2 = ""
   
   if (med>=10) medPad1 = ""
      else medPad1 = " "
   if (med%%1 == 0) medPad2 = ". "
      else medPad2 = ""
   
   if ( five < 0 ) fivePad1 = ""   # allow room for the minus sign
      else fivePad1 = " " 
   if ( abs(five)%%1 == 0) fivePad2 = ". " # no decimals
      else fivePad2 = ""
   
   if (avgAlloc == 100) avgAllocPad = ""
      else avgAllocPad = " "
   
   if ( is.na(latestAlloc) ) latestAllocPad = " "
      else if (latestAlloc < 10-1e-6) latestAllocPad = "  "
      else if (latestAlloc == 100) latestAllocPad = ""
      else latestAllocPad = " "
   
   if( is.infinite(TO) ) {
      TOpad1 = " "
      TOpad2 = " "
   }
   else {
      if (TO>=10) TOpad1 = ""
         else TOpad1 = " "
      if (TO%%1 == 0) TOpad2 = ".  " # no decimals
      else if (round(10*TO,1)%%1 == 0) TOpad2 = "0" # single decimal
      else TOpad2 = ""
   }
   
   if(DD2>=10) DD2Pad1=""
      else DD2Pad1 = " "
   if (DD2%%1 == 0) DD2Pad2 = ". " # no decimals
      else DD2Pad2 = ""
   
   if (score>=10) scorePad1 = ""
      else scorePad1 = " "
   if (round(score,2)%%1 == 0) scorePad2 = ".00" # no decimals
   else if ( round(10*score,1)%%1 == 0 ) scorePad2 = "0" # single decimal
   else scorePad2 = ""
   
   if(ret>minTR & vol<maxVol & DD2<maxDD2 & TO>minTO & score>minScore) 
      print(paste0(str_pad(displayName, nameLength, side = "right"), "| ", 
                   ret, retPad, "% | ", 
                   medPad1, med, medPad2, "%, ", fivePad1, five, fivePad2, "% | ",
                   volPad1, vol, volPad2, "% |  ",
                   avgAllocPad, round(avgAlloc), "%, ", latestAllocPad, round(latestAlloc), "% | ",
                   TOpad1, TO, TOpad2, " | ",
                   DD2Pad1, DD2, DD2Pad2, "% | ", 
                   scorePad1, round(score, 2), scorePad2) )
}

showSummaries <- function(futureYears=def$futureYears, costs=def$tradingCost+def$riskAsCost, 
                          costsTechnical=def$tradingCost+def$riskAsCostTechnical, 
                          coeffTR=def$coeffTR, coeffVol=def$coeffVol, coeffDD2=def$coeffDD2, detailed=T, force=F) {
   # force pertains only to showSummaryForStrategy, not to calc...StrategyReturn (these are all set to F)

   if (costsTechnical < costs) {
      warning("costsTechnical (", costsTechnical*100, "%) < costs (", costs*100, "%). ",
              "costsTechnical set to ", costs*100, "%.", immediate.=T)
      costsTechnical <- costs
   }
      
   dashes <- displaySummaryHeader(futureYears=futureYears, nameLength=def$nameLength)
   
   showSummaryForStrategy("stocks", displayName="stocks", futureYears=futureYears, costs=costs, 
                          coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
   if(detailed) {
      showSummaryForStrategy("constantAlloc80_20", displayName="80% stock 20% bond", futureYears=futureYears, costs=costs, 
                             coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)

      print(dashes)
      ## Technical strategies
      {
         if(doStrat$Boll1) 
            showSummaryForStrategy(typical$Boll1,      displayName="Bollinger 1 **", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$Boll2)      
            showSummaryForStrategy(typical$Boll2,      displayName="Bollinger 2 **", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$SMA1)      
            showSummaryForStrategy(typical$SMA1,       displayName="SMA 1", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)   
         if(doStrat$SMA2)      
            showSummaryForStrategy(typical$SMA2,       displayName="SMA 2", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)   
         if(doStrat$reversal1)      
            showSummaryForStrategy(typical$reversal1,  displayName="reversal 1", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$reversal2)      
            showSummaryForStrategy(typical$reversal2,  displayName="reversal 2 **", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
      }
      print(dashes) 
      
      ## Value strategies
      {
         if(doStrat$CAPE_hy1)      
            showSummaryForStrategy(typical$CAPE_hy1,     displayName="CAPE hysteresis 1", futureYears=futureYears, costs=costs, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$CAPE_hy2)      
            showSummaryForStrategy(typical$CAPE_hy2,     displayName="CAPE hysteresis 2", futureYears=futureYears, costs=costs, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$CAPE_hy3)      
            showSummaryForStrategy(typical$CAPE_hy3,     displayName="CAPE hysteresis 3", futureYears=futureYears, costs=costs, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$CAPE_NH1)      
            showSummaryForStrategy(typical$CAPE_NH1,      displayName="CAPE no hyster. 1 ", futureYears=futureYears, costs=costs, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$CAPE_NH2)      
            showSummaryForStrategy(typical$CAPE_NH2,      displayName="CAPE no hyster. 2", futureYears=futureYears, costs=costs, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$detrended1)      
            showSummaryForStrategy(typical$detrended1, displayName="detrended 1 **", futureYears=futureYears, costs=costs, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$detrended2)      
            showSummaryForStrategy(typical$detrended2, displayName="detrended 2 **", futureYears=futureYears, costs=costs, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
      }
      print(dashes)
      
      ## Hybrid strategies
      {
         if(doStrat$Boll_CAPE1)      
            showSummaryForStrategy(typical$Boll_CAPE1, displayName="Boll(CAPE) 1", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$Boll_CAPE2)      
            showSummaryForStrategy(typical$Boll_CAPE2, displayName="Boll(CAPE) 2 **", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$Boll_detrended1)      
            showSummaryForStrategy(typical$Boll_detrended1, displayName="Boll(detrended)", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$SMA_CAPE1)      
            showSummaryForStrategy(typical$SMA_CAPE1, displayName="SMA(CAPE) 1", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$SMA_CAPE2)      
            showSummaryForStrategy(typical$SMA_CAPE2, displayName="SMA(CAPE) 2", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$reversal_CAPE1) 
            showSummaryForStrategy(typical$reversal_CAPE1, displayName="reversal(CAPE) 1 **", 
                                   futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$reversal_CAPE2)      
            showSummaryForStrategy(typical$reversal_CAPE2, displayName="reversal(CAPE) 2 **", 
                                   futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$Boll_Boll1)      
            showSummaryForStrategy(typical$Boll_Boll1, displayName="Boll(Boll) 1", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$Boll_Boll2)      
            showSummaryForStrategy(typical$Boll_Boll2, displayName="Boll(Boll) 2", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
         if(doStrat$Boll_balanced1)      
            showSummaryForStrategy(typical$Boll_balanced1, displayName="Boll(balanced) **", futureYears=futureYears, costs=costsTechnical, 
                                   coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
      }
      print(dashes)
   }
   
   ## Combined strategies
   {
   showSummaryForStrategy(typical$technical,    displayName="technical", futureYears=futureYears, costs=costsTechnical, 
                          coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
   showSummaryForStrategy(typical$value,        displayName="value", futureYears=futureYears, costs=costs, 
                          coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
   showSummaryForStrategy(typical$hybrid,       displayName="hybrid", futureYears=futureYears, costs=costsTechnical, 
                          coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
   showSummaryForStrategy(typical$balanced,     displayName="balanced", futureYears=futureYears, costs=costs, 
                          coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
   showSummaryForStrategy("balanced50",         displayName="balanced 50-50", futureYears=futureYears, costs=costs, 
                           coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
}
   print(dashes)
}

findStrategiesOnCriteria <- function(minTR=0, maxVol=Inf, maxDD2=Inf, minTO=0, minScore=-Inf, 
                                     futureYears=def$futureYears, costs=def$tradingCost+def$riskAsCost, 
                                     coeffTR=def$coeffTR, coeffMed=def$coeffMed, coeffFive=def$coeffFive,
                                     coeffVol=def$coeffVol, coeffDD2=def$coeffDD2, 
                                     nameLength=36, force=F) {
   dashes <- displaySummaryHeader(futureYears=futureYears, nameLength=nameLength)
   for ( i in 1:dim(stats)[[1]] ) 
      showSummaryForStrategy(strategyName=stats$strategy[i], futureYears=def$futureYears, costs=costs, 
                             minTR=minTR, maxVol=maxVol, maxDD2=maxDD2, minTO=minTO, minScore=minScore, 
                             coeffTR=coeffTR, coeffMed=coeffMed, coeffFive=coeffFive, 
                             coeffVol=coeffVol, coeffDD2=coeffDD2, 
                             nameLength=nameLength, force=force)     
}



calcBondAsAgeStrategy <- function(totalYears=def$futureYears, years=c(0, 30, Inf), allocations=c(0.75, 0.45, 0.45), 
                                  strategyName="", force=F) {
   if (! totalYears %in% c(5,10,15,20,30))
      stop("totalYears must be one of 5, 10, 15, 20 or 30.")
   months   <- 12*totalYears
   exponent <-  1/totalYears
   
   if ( length(years) != length(allocations) )
      stop("years and allocations must have the same length.")
   for (j in 2:length(years) )
      if (years[j-1] >= years[j]) 
         stop("years must be given in strictly increasing order.")
   for (j in 1:length(years) ) 
      if (allocations[j] < 0 || allocations[j] > 1) 
         stop("allocations must take values between 0 and 1.")
   
   allocation <- vector("numeric", length=months-1)
   
   for(i in 1:months)
      for (j in 1:(length(years)-1) )
         if ( (i >= years[j]*12+1) && (i < years[j+1]*12+1) )
            allocation[i] <- allocations[j] + (allocations[j+1] - allocations[j]) * 
      (i - (years[j]*12+1) ) / (years[j+1]*12 - years[j]*12)
   
   print(paste0("average allocation: ", round(mean(allocation)*100,1), "%"))
   if(strategyName=="") {
      strategyName <- paste0("bondAsAge_", round(mean(allocation)*100,1))
      print(paste0("strategyName: ", strategyName, 
                   " (average allocation: ", round(mean(allocation)*100,1), "%)"))
   } else    print(paste0("average allocation: ", round(mean(allocation)*100,1), "%"))

   for (startIndex in 1:(numData-months) ) {
      value <- 1
     
      for( i in 0:(months-1) )
         value <- value * ( allocation[i+1] * dat$monthlyDifference[startIndex+i+1] + dat$bondsMonthly[startIndex+i+1] ) 
      # alloc * (stocks-bonds) + bonds = alloc * stocks + (1-alloc) * bonds
      
      if (totalYears == 5)
         next5yrs[startIndex,  strategyName] <<- value ^ exponent - 1
      else if (totalYears == 10)
         next10yrs[startIndex, strategyName] <<- value ^ exponent - 1
      else if (totalYears == 15)
         next15yrs[startIndex, strategyName] <<- value ^ exponent - 1
      else if (totalYears == 20)
         next20yrs[startIndex, strategyName] <<- value ^ exponent - 1
      else if (totalYears == 30)
         next30yrs[startIndex, strategyName] <<- value ^ exponent - 1
   }
}


allocFromRate <- function(rate, min=0, max=1, overAlloc=1) {
   allocation <- (rate-.020)/.046*overAlloc
   if (allocation < min) allocation <- min
   else if (allocation > max) allocation <- max
   return(allocation)
}

calcDynamicStrategy <- function(target, totalYears=def$futureYears, 
                                spread=0.4, minAlloc=0, maxAlloc=1, speedup=2, overAlloc=1.05,
                                strategyName="", force=F) {
   if (! totalYears %in% c(5,10,15,20,30))
      stop("totalYears must be one of 5, 10, 15, 20 or 30.")
   months   <- 12*totalYears
   exponent <-  1/totalYears
   if (spread < 0)  stop("spread cannot be negative.")
   if (spread == 0) warning("spread=0 means a constant allocation.", immediate.=T)
   
   rate <- round((target^exponent-1)*100,1)
   allocation <- round(allocFromRate(rate/100, min=0, max=1)*100,0)
      
   if (rate>8)
      warning("The target of ", target, " corresponds to a real return of ", rate, "% p.a. ", 
              "You are insane.", immediate.=T)
   else if (rate>6.6)
      warning("The target of ", target, " corresponds to a real return of ", rate, "% p.a. (more than stocks). ", 
              "You are quite optimistic.", immediate.=T)
   else print(paste0("The target of ", target, " corresponds to a real return of ", rate, "% p.a., ", 
                     "i.e. an allocation of ", allocation, "% stocks." ) )

   min <- allocation/100 - spread; 
   if (min < minAlloc) min <- minAlloc
   max <- allocation/100 + spread
   if (max > maxAlloc) max <- maxAlloc
   
   if(strategyName=="") {
      strategyName <- paste0("active_", totalYears, "yr_", rate,"pc_", 
                             round(speedup,1), "_", spread*100, "pc")
      print(paste0("strategyName: ", strategyName, " (allocation between ", min*100, "% and ", max*100, "%)."))
   }
    
   totalAlloc <- 0; numAlloc   <- 0; # to calculate the average allocation
   success    <- 0; numAttempt <- 0; # to calculate the success rate
   
   for (startIndex in 1:(numData-months) ) {
      value <- 1

      for( i in 0:(months-1) ) {
         rate <- (target/value)^(12/(months-i)*speedup)-1 # annual growth rate to meet target
         allocation <- allocFromRate(rate, min, max, overAlloc)
         totalAlloc <- totalAlloc + allocation
         numAlloc   <- numAlloc + 1
         
#          value <- value * ( allocation * TR[startIndex+i+1, typical$balanced]/TR[ startIndex+i, typical$balanced] + 
#                                (1-allocation) * TR$bonds[startIndex+i+1]/TR$bonds[startIndex+i] )
         value <- value * ( allocation * dat$monthlyDifference[startIndex+i+1] + dat$bondsMonthly[startIndex+i+1] )
      }
      numAttempt <- numAttempt + 1
      if (value >= target) success <- success + 1
      
      if (totalYears == 5)
         next5yrs[startIndex,  strategyName] <<- value ^ exponent - 1
      else if (totalYears == 10)
         next10yrs[startIndex, strategyName] <<- value ^ exponent - 1
      else if (totalYears == 15)
         next15yrs[startIndex, strategyName] <<- value ^ exponent - 1
      else if (totalYears == 20)
         next20yrs[startIndex, strategyName] <<- value ^ exponent - 1
      else if (totalYears == 30)
         next30yrs[startIndex, strategyName] <<- value ^ exponent - 1
   }
   print(paste0("success rate: ", round((success/numAttempt)*100,1), "% reach the target of ", target))
   print(paste0("average allocation: ", round((totalAlloc/numAlloc)*100,1), "%"))
}




# not to be used anymore
calcTRnetOfTradingCost <- function(strategyName, tradingCost=def$tradingCost+def$riskAsCost, force=F) {
   warning("calcTRnetOfTradingCost() should not be used anymore.")
   #    requireColInTR(strategyName)
   #    index <- which(stats$strategy == strategyName)
   #    
   #    cost <- tradingCost/stats$turnover[index]/12
   #     
   #    if ( !(strategyName %in% colnames(alloc)) ) {# this means we ARE dealing with constant allocation (e.g. stocks)
   #       if (tradingCost == 0.02)
   #          netTR2[, strategyName] <<- TR[, strategyName] # no trading, no trading cost
   #       else if(tradingCost == 0.04)
   #          netTR4[, strategyName] <<- TR[, strategyName] 
   #       else stop("No data frame \'netTR", round(tradingCost*100), "\' exists.")
   #    } else {
   #       if (tradingCost == 0.02) {
   #          if (!(strategyName %in% colnames(netTR2)) | force) {
   #             startIndex <- parameters$startIndex[which(parameters$strategy == strategyName)]      
   #             netTR2[1 : (startIndex-1), strategyName] <<- NA
   #             netTR2[startIndex, strategyName] <<- 1
   #             for(i in (startIndex+1):numData) netTR2[i, strategyName] <<- netTR2[i-1, strategyName] * 
   #                ( TR[i, strategyName] / TR[i-1, strategyName] - cost )
   #          }
   #       } else if(tradingCost == 0.04) {
   #          if (!(strategyName %in% colnames(netTR4)) | force) {
   #             startIndex <- parameters$startIndex[which(parameters$strategy == strategyName)]
   #             netTR4[1 : (startIndex-1), strategyName] <<- NA
   #             netTR4[startIndex, strategyName] <<- 1
   #             for(i in (startIndex+1):numData) netTR4[i, strategyName] <<- netTR4[i-1, strategyName] * 
   #                ( TR[i, strategyName] / TR[i-1, strategyName] - cost )
   #          }
   #       } else stop("No data frame \'netTR", round(tradingCost*100), "\' exists.")
   #    }
}

## not used
calcTurnoverAndTRnetOfTradingCost <- function(strategyName, futureYears=def$futureYears, 
                                              tradingCost=def$tradingCost+def$riskAsCost, force=F) {
   warning("calcTurnoverAndTRnetOfTradingCost() should not be used anymore.")
   
   #       time1 <- proc.time()      
   #    if ( (strategyName %in% colnames(alloc)) ) {# this means we are not dealing with constant allocation (e.g. stocks)
   #       dateRange <- def$startIndex:(numData-1)
   #       index <- which(stats$strategy == strategyName)
   # 
   #       turnover <- numeric(numData)
   #       turnover[1:def$startIndex] <- NA
   #       turnover[dateRange+1] <- abs(alloc[dateRange+1, strategyName] - alloc[dateRange, strategyName])
   #       stats$turnover[index] <<- 1/12/mean(turnover[dateRange+1], na.rm=F)
   #       
   #       if (tradingCost == 0.02) {
   #          netTR2[def$startIndex, strategyName] <<- 1
   #          for(i in dateRange+1)
   #             netTR2[i, strategyName] <<-  netTR2[i-1, strategyName] * 
   #             ( TR[i, strategyName] / TR[i-1, strategyName] - tradingCost*turnover[i] )
   #          stats$netTR2[index] <<- exp( regression(netTR2$numericDate[dateRange+1], log(netTR2[dateRange+1, strategyName]))[[2]] ) - 1
   #       }
   #       else if(tradingCost == 0.04)  {
   #          netTR4[def$startIndex, strategyName] <<- 1
   #          for(i in (def$startIndex+1) : numData )
   #             netTR4[i, strategyName] <<-  netTR4[i-1, strategyName] * 
   #             ( TR[i, strategyName] / TR[i-1, strategyName] - tradingCost*turnover[i] )
   #          stats$netTR4[index] <<- exp( regression(netTR4$numericDate[dateRange+1], log(netTR4[dateRange+1, strategyName]))[[2]] ) - 1    
   #       } else stop("No data frame \'netTR", round(tradingCost*100), "\' exists.")
   #       
   #    } else { # constant allocation: no trading, no cost
   #       if (tradingCost == 0.02) 
   #          netTR2[, strategyName] <<- TR[, strategyName]
   #       else if(tradingCost == 0.04) 
   #          netTR4[, strategyName] <<- TR[, strategyName]
   #       else stop("No data frame \'netTR", round(tradingCost*100), "\' exists.")
   #    }
   #    
   #       print( c( "Time for turnover:", round(summary(proc.time())[[3]] - time1[[3]] , 2) ) )   
}

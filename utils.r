
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


createConstAllocStrategy <- function(stockAllocation = 70L, strategyName="", 
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
   calcStatisticsForStrategy(strategyName, futureYears=futureYears, costs=0, force=force)
}


calcStrategyReturn <- function(strategyName, startIndex) {
   TR[1:(startIndex-1), strategyName] <<- NA
   TR[startIndex, strategyName] <<- 1
   for(i in (startIndex+1):numData) 
      TR[i, strategyName] <<- TR[i-1, strategyName] * ( 
         alloc[i-1, strategyName] * dat$monthlyDifference[i] + dat$bondsMonthly[i] ) # alloc * (stocks-bonds) + bonds = alloc * stocks + (1-alloc) * bonds
}



## Calculating signal -- same function for all strategies
calcSignalForStrategy <- function(strategyName, # the signal will be written to signal[, strategyName]
                                  input, # vector containing the data from which the signal will be calculated
                                  bearish, # value of the input at which allocation = 0
                                  bullish, # value of the input at which allocation = 1
                                  signalMin=def$signalMin, # the values of the signal will be between...
                                  signalMax=def$signalMax, # signalMin and signalMax
                                  startIndex=def$startIndex # where the signal starts (NA before that)
                                  ) {   
      
   dateRange <- startIndex:numData
   if( sum(is.na(input[dateRange])) > 0) # there should be no NA after startIndex
     stop("Input contains NA after startIndex (", startIndex, ").")
   
   isZero <- tan ( pi * ( -signalMin / (signalMax - signalMin) - 1/2 ) ) 
   isOne <- tan ( pi * ( (1-signalMin) / (signalMax - signalMin) - 1/2 ) )
   a <- (isOne-isZero) / (bullish-bearish)
   b <- isOne - a * bullish
   
   addNumColToSignal(strategyName)
   signal[1:(startIndex-1), strategyName] <<- NA  
   signal[dateRange, strategyName] <<- ( atan( a * input[dateRange] + b ) / pi + .5 ) * 
      (signalMax - signalMin) + signalMin
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


deleteStrategy <- function(stratName) {
   # delete strategy from DFs where it is entered as a column
   index <- which( colnames(signal) == stratName )
   if(length(index) > 0) 
      signal[index] <<- NULL
   else warning(paste("Strategy", stratName, "cannot be found in 'signal'.") )
   
   index <- which( colnames(alloc) == stratName )
   if(length(index) > 0) 
      alloc[index] <<- NULL
   else warning(paste("Strategy", stratName, "cannot be found in 'alloc'.") )
   
   index <- which( colnames(TR) == stratName )
   if(length(index) > 0) 
      TR[index] <<- NULL
   else warning(paste("Strategy", stratName, "cannot be found in 'TR'.") )
   
   index <- which( colnames(DD) == stratName )
   if(length(index) > 0) 
      DD[index] <<- NULL
   else warning(paste("Strategy", stratName, "cannot be found in 'DD'.") )
      
   
   # delete strategy from DFs where it is entered as a row
   index <- which(stats$strategy == stratName)
   if (length(index) > 0)    
      stats <<- stats[-index, ] 
   else warning(paste("Strategy", stratName, "cannot be found in 'stats'.") )

   index <- which(parameters$strategy == stratName)
   if (length(index) > 0)    
      parameters <<- parameters[-index, ]
   else warning(paste("Strategy", stratName, "cannot be found in 'parameters'.") )
   
   
   # delete strategy from nextNyears DF
   if (def$futureYears==5) {
      index             <- which( colnames(next5yrs) == stratName )
      if (length(index) > 0)    
         next5yrs[index]  <<- NULL
      else warning(paste("Strategy", stratName, "cannot be found in 'next5yrs'.") )
   }
   else if (def$futureYears==10) {
      index             <- which( colnames(next10yrs) == stratName )
      if (length(index) > 0)    
         next10yrs[index] <<- NULL
      else warning(paste("Strategy", stratName, "cannot be found in 'next10yrs'.") )
   }
   else if (def$futureYears==15) {
      index             <- which( colnames(next15yrs) == stratName )
      if (length(index) > 0)    
         next15yrs[index] <<- NULL
      else warning(paste("Strategy", stratName, "cannot be found in 'next15yrs'.") )
   }            
   else if (def$futureYears==20) {
      index             <- which( colnames(next20yrs) == stratName )
      if (length(index) > 0)    
         next20yrs[index] <<- NULL
      else warning(paste("Strategy", stratName, "cannot be found in 'next20yrs'.") )
   }            
   else if (def$futureYears==30) {
      index             <- which( colnames(next30yrs) == stratName )
      if (length(index) > 0)    
         next30yrs[index] <<- NULL
      else warning(paste("Strategy", stratName, "cannot be found in 'next30yrs'.") )
   }                    
}

## Interrupting parameter searches can create a problem with the strategy being calculated,
##    which will crash subsequent runs.
cleanUpStrategies <- function() {
   counter <- 0 # number of entries deleted
   for ( i in (1:dim(TR)[[2]]) )
      if ( is.na(TR[numData, i]) || TR[numData, i]==0 ) {
         stratName <- colnames(TR[i])
         print(paste(stratName, "has a problem: TR = 0.") )        
         deleteStrategy(stratName)
         counter   <- counter+1   # increment
      }

   for ( i in (1:dim(stats)[[1]]) )
      if ( is.na(DD[numDD, i]) || (DD[numDD-2, i]==0 && DD[numDD-1, i]==0 && DD[numDD, i]==0) ) {
         stratName <- colnames(DD[i])
         print(paste(stratName, "has a problem: DD = 0.") )        
         deleteStrategy(stratName)
         counter   <- counter+1   # increment
      }
   
   print( paste("entries deleted:", counter) )
   
   if (dim(stats)[[1]] == 0)      stop("Oh my God you killed stats. You bastard!")
   if (dim(parameters)[[1]] == 0) stop("Oh my God you killed parameters. You bastard!")
}

   
calcStatisticsForStrategy <- function(strategyName, futureYears=def$futureYears, costs, 
                                      coeffTR=def$coeffTR, coeffVol=def$coeffVol, coeffDD2=def$coeffDD2, force=F) {
   
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
      stats$DD2[index]        <<- sum(DD[, strategyName]^2)
      
      indexPara <- which(parameters$strategy == strategyName)     
      if ( length(indexPara) > 0 ) { # otherwise we are probably dealing with a constant allocation
         startIndex <- parameters$startIndex[indexPara]
         def$startIndex <<- max(def$startIndex, startIndex) # update def$startIndex if need be
         def$startYear  <<- max(def$startYear, (startIndex-1)/12+def$dataStartYear )
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
         stats$invTurnover[index] <<- 1/stats$turnover[index]
      } 
      stats$netTR0.5[index] <<- stats$TR[index] - 0.5/100/stats$turnover[index]
      stats$netTR1[index]   <<- stats$TR[index] - 1  /100/stats$turnover[index]
      stats$netTR2[index]   <<- stats$TR[index] - 2  /100/stats$turnover[index]
   }
   stats$score[index] <<- 200 * (   coeffTR  * (stats$TR[index] - 0.07)
                                 - coeffVol * (stats$volatility[index] - 0.14)
                                 - coeffDD2 * (stats$DD2[index] - 1.5) / 100
                                 + (1-coeffTR)/2 * ( stats[index, medianName] + stats[index, fiveName] - 0.05)
                                 - costs * (1/stats$turnover[index]-1/3) ) + 10
   ## 1. The coefficients coeffVol and coeffDD2 make it possible to 'convert' vol and DD2 into return equivalents.
   ## 2. I subtract off constants to reduce the variation of the score when coefficients change
}

showSummaryForStrategy <- function(strategyName, displayName="", futureYears=def$futureYears, costs, 
                                   minTR=0, maxVol=Inf, maxDD2=Inf, minTO=0, minScore=-Inf, 
                                   coeffTR=def$coeffTR, coeffVol=def$coeffVol, coeffDD2=def$coeffDD2, 
                                   coeffEntropy=0, nameLength=10, force=F) {
   
   library(stringr)
   
   if ( !(strategyName %in% stats$strategy) )
      calcStatisticsForStrategy(strategyName, futureYears=futureYears, costs=costs,
                                coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=T) 
   else  # if force==F then we only recalculate the score (quick)
      calcStatisticsForStrategy(strategyName, futureYears=futureYears, costs=costs, 
                                coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force) 

   index <- which(stats$strategy == strategyName)
   medianName <- paste0("median", futureYears)
   fiveName <- paste0("five", futureYears)
   if(displayName=="") displayName <- strategyName
   
   TO <- stats$turnover[index]
   TOcost <- costs / TO
   
   avgAlloc <- 100*stats$avgStockAlloc[index]
   latestAlloc <- 100*stats$latestStockAlloc[index]    

   ret  <- 100*(stats$TR[index] - TOcost) 
   vol  <- 100*stats$volatility[index]
   med  <- 100*(stats[index, medianName] - TOcost) 
   five <- round(100*(stats[index, fiveName] - TOcost), 1)
   DD2  <- stats$DD2[index]
   score<- stats$score[index] 
   if(coeffEntropy > 0)
      score <- score + coeffEntropy * (stats$entropy[index] - 1) 

   if (ret%%1 == 0) retPad = "   "    # no decimals
   else if (round(10*ret,1)%%1 == 0) retPad = " "  # single decimal
      else retPad = ""
   
   if (round(vol,1)%%1 == 0) volPad = "  "
      else volPad = ""
   if (round(med,1)%%1 == 0) medPad = "  "
      else medPad = ""
   
   if ( five < 0 ) fivePad1 = ""   # allow room for the minus sign
      else fivePad1 = " " 
   if ( abs(five)%%1 == 0) fivePad2 = "  " # no decimals
      else fivePad2 = ""
   
   if (avgAlloc == 100) avgAllocPad = ""
      else avgAllocPad = " "
   
   if ( is.na(latestAlloc) ) latestAllocPad = " "
      else if (latestAlloc < 10-1e-6) latestAllocPad = "  "
      else if (latestAlloc == 100) latestAllocPad = ""
      else latestAllocPad = " "
   
   if( is.infinite(TO) ) {
      TOpad1 = " "
      TOpad2 = ""
   }
   else {
      if (TO>=10) TOpad1 = ""
         else TOpad1 = " "
      if (round(TO, 1)%%1 == 0) TOpad2 = "  " # no decimals
         else TOpad2 = ""
   }
   
   if ((round(DD2,2))%%1 == 0) DD2Pad = "   " # no decimals
   else if ((10*round(DD2,2))%%1 == 0) DD2Pad = " " # single decimal
      else DD2Pad = ""
   
   if (score>=10) scorePad = ""
   else scorePad = " "
   
   if(ret>minTR & vol<maxVol & DD2<maxDD2 & TO>minTO & score>minScore) 
      print(paste0(str_pad(displayName, nameLength, side = "right"), " | ", 
                   round(ret,2), retPad, "% |   ", 
                   round(med,1), medPad, "%,", fivePad1, five, fivePad2, "% | ",
                   round(vol,1), volPad, "% |  ",
                   avgAllocPad, round(avgAlloc), "%, ", latestAllocPad, round(latestAlloc), "% | ",
                   TOpad1, round(TO, 1), TOpad2, " | ",
                   round(DD2,2), DD2Pad, " | ", 
                   scorePad, round(score,2) ) )
}

showSummaries <- function(futureYears=def$futureYears, costs=def$tradingCost, 
                          coeffTR=def$coeffTR, coeffVol=def$coeffVol, coeffDD2=def$coeffDD2, detailed=T, force=F) {
   # force pertains only to showSummaryForStrategy, not to calc...StrategyReturn (these are all set to F)

   print(paste0("* Statistics of the strategies (costs = ", round(100*costs,2), "% per year of turnover):"))
   print(paste0("strategy   |  TR   ", futureYears, " yrs: med, 5%| vol. alloc: avg, now|TO yrs| DD^2 | score") )
   print("-----------+-------+--------------+-------+-------------+------+------+------")
   
   showSummaryForStrategy("stocks", displayName="stocks    ", futureYears=futureYears, costs=0, 
                          coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
   
   if(detailed) {
      showSummaryForStrategy("constantAlloc80_20", displayName="80_20     ", futureYears=futureYears, costs=0, 
                             coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
      print("-----------+-------+--------------+-------+-------------+------+------+------")
      showSummaryForStrategy(def$typicalCAPE1,     displayName="CAPE no h.", futureYears=futureYears, costs=costs, 
                             coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
      showSummaryForStrategy(def$typicalCAPE2,     displayName="CAPE hyst ", futureYears=futureYears, costs=costs, 
                             coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
      showSummaryForStrategy(def$typicalDetrended1,displayName="detrended1", futureYears=futureYears, costs=costs, 
                             coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
      showSummaryForStrategy(def$typicalDetrended2,displayName="detrended2", futureYears=futureYears, costs=costs, 
                             coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
      print("-----------+-------+--------------+-------+-------------+------+------+------")
      showSummaryForStrategy(def$typicalBoll,      displayName="Bollinger ", futureYears=futureYears, costs=costs, 
                             coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
      showSummaryForStrategy(def$typicalSMA1,       displayName="SMA 1     ", futureYears=futureYears, costs=costs, 
                             coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)   
      showSummaryForStrategy(def$typicalSMA2,       displayName="SMA 2     ", futureYears=futureYears, costs=costs, 
                             coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)   
      showSummaryForStrategy(def$typicalReversal,  displayName="reversal  ", futureYears=futureYears, costs=costs, 
                             coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
      print("-----------+-------+--------------+-------+-------------+------+------+------")
   }
   showSummaryForStrategy(def$typicalValue,        displayName="value     ", futureYears=futureYears, costs=costs, 
                          coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
   showSummaryForStrategy(def$typicalTechnical,    displayName="technical ", futureYears=futureYears, costs=costs, 
                          coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
   showSummaryForStrategy(def$typicalBalanced,     displayName="balanced  ", futureYears=futureYears, costs=costs, 
                          coeffTR=coeffTR, coeffVol=coeffVol, coeffDD2=coeffDD2, force=force)
   print("")
}



# not to be used anymore
calcTRnetOfTradingCost <- function(strategyName, tradingCost=def$tradingCost, force=F) {
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
calcTurnoverAndTRnetOfTradingCost <- function(strategyName, futureYears=def$futureYears, tradingCost=def$tradingCost, force=F) {
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

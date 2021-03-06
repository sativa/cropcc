# cropsv 
evapoTranspiration <- function(root, soilD, srFUFR, srSOIL, 
                               srSUBPET, SWBsv, tabFunction, cropsv)
{
  
  #---------- cropsv Data
  DSLR   <- cropsv@DSLR[length(cropsv@DSLR)]
  FLDLOS <- cropsv@FLDLOS[length(cropsv@FLDLOS)]
  WEEDCV <- cropsv@WEEDCV[length(cropsv@WEEDCV)]
  
  #---------- root Data
  ZRT1   <- root@ZRT1[length(root@ZRT1)]
  ZRT2   <- root@ZRT2[length(root@ZRT2)]
  ZRT3   <- root@ZRT3[length(root@ZRT3)]
  
  #---------- soilD Data
  SAND1 <- soilD@SAND1
  TKL1  <- soilD@TKL1
  TKL2  <- soilD@TKL2
  TKL3  <- soilD@TKL3
  
  #---------- srFUFR Data
  WSE1 <- srFUFR@WSE1[length(srFUFR@WSE1)]
  WSE2 <- srFUFR@WSE2[length(srFUFR@WSE2)]
  WSE3 <- srFUFR@WSE3[length(srFUFR@WSE3)]
  
  #---------- srSOIL Data
  WCAD1 <- srSOIL@WCAD1[length(srSOIL@WCAD1)]
  WCAD2 <- srSOIL@WCAD2[length(srSOIL@WCAD2)]
  WCAD3 <- srSOIL@WCAD3[length(srSOIL@WCAD3)]
  
  #---------- srSUBPET Data
  PEVAP  <- srSUBPET@PEVAP[length(srSUBPET@PEVAP)]
  PTRANS <- srSUBPET@PTRANS[length(srSUBPET@PTRANS)]
  
  #---------- SWBsv Data
  AWF1  <- SWBsv@AWF1[length(SWBsv@AWF1)]
  AWF2  <- SWBsv@AWF2[length(SWBsv@AWF2)]
  AWF3  <- SWBsv@AWF3[length(SWBsv@AWF3)]
  
  PNDEVP <- SWBsv@PNDEVP[length(SWBsv@PNDEVP)]
  POND   <- SWBsv@POND[length(SWBsv@POND)]
  
  WL1   <- SWBsv@WL1[length(SWBsv@WL1)]
  WL2   <- SWBsv@WL2[length(SWBsv@WL2)]
  WL3   <- SWBsv@WL3[length(SWBsv@WL3)]
  
  WLFL1 <- SWBsv@WLFL1[length(SWBsv@WLFL1)]
  
  #---------- tabFunction Data
  EDPTFT <- tabFunction@EDPTFT
  EESTAB <- tabFunction@EESTAB
  
  #========================== TRANSPIRATION
  ERLB  <- ZRT1* AFGEN(EDPTFT, AWF1) + ZRT2* AFGEN(EDPTFT, AWF2)
                                     + ZRT3* AFGEN(EDPTFT, AWF3)                   #== effective rooting depth
  TRRM  <- PTRANS*FLDLOS / (ERLB + 1e-10)                                          #== transpiration load per unit of effective root zone layer
  
  TRWL1 <- TRRM*WSE1*ZRT1* AFGEN(EDPTFT, AWF1)
  TRWL2 <- TRRM*WSE2*ZRT2* AFGEN(EDPTFT, AWF2)
  TRWL3 <- TRRM*WSE3*ZRT3* AFGEN(EDPTFT, AWF3)
  
  ATRANS <- TRWL1 + TRWL2 + TRWL3
  #TATRAN <- ATRANS + TATRAN #FJAV: Defined, Line 356: TATRAN = INTGRL(ZERO, ATRANS), but NOT-USED in FST  #== cumulative transpiration
  
  #------------------------------------ EVAPORATION
  PEVAPC <- PEVAP - PEVAP*AMIN1(0.95, WEEDCV)                   #== potential evaporation of the crop
  
  DSLRRT <- INSW(POND - 0.5, 1, -(DSLR - 1))
  DSLR   <- DSLR + DSLRRT

  EVSD   <- AMAX1(0, AMIN1(PEVAPC, PEVAPC / (DSLR + 0.001)^0.5))
  EVSH   <- AMAX1(0, AMIN1(PEVAPC, (WL1 - WCAD1*TKL1) + WLFL1))
  AEVAP  <- INSW(POND - 0.5, EVSD, EVSH)                                       #== actual evaporation
  EES    <- AFGEN(EESTAB, SAND1)                                               #== texture-specific exponential function
  
  FEVL1  <- AMAX1(WL1 - WCAD1*TKL1, 0.1)*exp(-EES*(0.5*TKL1))                  #== fraction of water for evaporation allocated
  FEVL2  <- AMAX1(WL2 - WCAD2*TKL2, 0.1)*exp(-EES*(TKL1 + (0.5*TKL2)))         #== fraction of water for evaporation allocated
  FEVL3  <- AMAX1(WL3 - WCAD3*TKL3, 0.1)*exp(-EES*(TKL1 + TKL2 + (0.5*TKL3)))  #== fraction of water for evaporation allocated
  
  AEVAPC <- LIMIT(0, AEVAP, AEVAP - PNDEVP)
  
  EVSW1 <- AEVAPC*FEVL1 / (FEVL1 + FEVL2 + FEVL3)
  EVSW2 <- AEVAPC*FEVL2 / (FEVL1 + FEVL2 + FEVL3)
  EVSW3 <- AEVAPC*FEVL3 / (FEVL1 + FEVL2 + FEVL3)
  
  TAEVAP <- AEVAP                      #Line 378: TAEVAP  = INTGRL(ZERO, AEVAP)
  ETDAY  <- ATRANS + AEVAP
  ETSUM  <- ETDAY                      #Line 380: ETSUM = INTGRL(ZERO, ETDAY)                 #== cumulative evapotranspiration                          
    
  #-----
  j <- length(cropsv@ATRANS) + 1
  
  cropsv@ATRANS[j] <- ATRANS 
  cropsv@DSLR[j]   <- DSLR
  
  cropsv@ETDAY[j]  <- ETDAY
  
  cropsv@EVSW1[j]  <- EVSW1
  cropsv@EVSW2[j]  <- EVSW2
  cropsv@EVSW3[j]  <- EVSW3
  
  cropsv@TRWL1[j]  <- TRWL1
  cropsv@TRWL2[j]  <- TRWL2
  cropsv@TRWL3[j]  <- TRWL3
  
  return(cropsv)
}
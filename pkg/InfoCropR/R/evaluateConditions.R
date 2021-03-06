evaluateConditions <- function(crop, cropsv, phenology)
{
  
  POTATO <- crop@POTATO
  LAI <- cropsv@LAI[length(cropsv@LAI)]
  
  #---------- cropsv Data
  FROST <- cropsv@FROST[length(cropsv@FROST)]
  
  #---------- phenology Data
  DS     <- phenology@DS[length(phenology@DS)]
  GFD    <- phenology@GFD[length(phenology@GFD)]
  SINKLT <- phenology@SINKLT[length(phenology@SINKLT)]
  
  FPOTAT <- INSW(POTATO - 1, 10, INSW(DS - 0.75, 10, 
                                      INSW(LAI - 0.08, -1, 1)))
  
  
  #===========
#   condition <- ifelse(DS     > 2.01, TRUE, FALSE)
#   condition <- ifelse(FPOTAT < 0,    TRUE, FALSE)
#   condition <- ifelse(FROST  > 7,    TRUE, FALSE)
#   condition <- ifelse(GFD    > 60,   TRUE, FALSE)
#   condition <- ifelse(SINKLT < 0,    TRUE, FALSE) 
  
  condition <- FALSE
  if (DS > 2.01) {
    condition <- TRUE
  } else 
    if (FPOTAT < 0) {
      condition <- TRUE
    } else
      if (FROST > 7) {
        condition <- TRUE
      } else
        if (GFD > 60) {
          condition <- TRUE
        } else
          if (SINKLT < 0) {condition <- TRUE} 
  
  #-----------
  return(condition)
}
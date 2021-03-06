.analysisReport <- function()
{
  
  la <- get("la")
  tl <- as.matrix(read.delim(system.file("external/MultilanguageAnalysisReport.txt", package="ClimMob"), header=FALSE, encoding="UTF-8"))
  colnames(tl) <- NULL
    
  if(!exists("myData", envir=.GlobalEnv)){
    
    gmessage(tl[1,la], title="Error", icon="error")
    return()
    
  }
  
  if(!exists("rankingsVars", envir=.GlobalEnv)){
    
    gmessage(tl[2,la], title="Error", icon="error")
    return()
    
  }
  
  myData <- get("myData")
  observeridVar <- get("observeridVar")
  itemsgivenVars <- get("itemsgivenVars")
  rankingsVars <- get("rankingsVars")
  explanatoryVars <- get("explanatoryVars")
  questionVar <- get("questionVar")
  questionsAnalyzed <- get("questionsAnalyzed")
  models <- get("models")
  
  w5 <- gwindow(title=tl[3,la], visible=FALSE, parent=c(0,0)) 
  group1 <- ggroup(horizontal=FALSE, spacing= 10, container=w5)
  
  ttitle <- glabel(tl[4,la], container=group1)
  font(ttitle) <- list(size=16)
  
  g2 <- glabel(tl[5,la], container=group1)
  font(g2) <- list(size=12)
  a1 <- gfilebrowse(text=tl[6,la], type="selectdir", container=group1)
  svalue(a1) <- getwd()
  group2 <- ggroup(horizontal=TRUE, spacing=10, container=group1, expand=TRUE)
  g3 <- glabel(tl[7,la], container=group2)
  font(g3) <- list(size=12)
  setfilename <- gtext(text=".doc", container=group2, width=2, height=1)
  size(setfilename) <- c(250,20)
  #addHandlerChanged(setfilename, handler=function(h,...) {assign(filenameReport, svalue(h$obj), env=.GlobalEnv)})
  
  group3 <- ggroup(horizontal=TRUE, spacing=10, container=group1, expand=TRUE)
  addSpring(group3)
  b <- gbutton(tl[8,la], container=group3, handler = function(h, ...){
   
    setwd(svalue(a1))
    n <- length(models)
    
    #filenameReport <- get("filenameReport")
    
    rtf <- RTF(svalue(setfilename), font.size=12) 
    addPng(rtf, system.file("external/ClimMob-logo.png", package="ClimMob"), width=3.9, height=2.2)
    addParagraph(rtf, "\n")
    addHeader(rtf, title=.Unicodify(tl[9,la]))
    addParagraph(rtf, paste(tl[10,la], Sys.info()[["user"]], sep=""))
    addParagraph(rtf, "\n")
    addParagraph(rtf, .Unicodify(tl[11,la]))
    addParagraph(rtf, "\n")
    addParagraph(rtf, .Unicodify(tl[12,la]))
    addParagraph(rtf, "\n")   
    addParagraph(rtf, .Unicodify(tl[13,la]))    
    addParagraph(rtf, "\n")
    addParagraph(rtf, .Unicodify(tl[14,la]))    
    addParagraph(rtf, "\n")
    addParagraph(rtf, .Unicodify(tl[15,la]))
    addParagraph(rtf, "\n")
    
    uniqueObs <- unique(as.character(unlist(myData[,observeridVar])))
    uniqueItems <- unique(as.character(unlist(myData[,itemsgivenVars])))
    lq <- length(models)
    varsNamesForTable <- .Unicodify(tl[16:19,la])
    varsValuesForTable <- c(
      length(uniqueObs), 
      length(itemsgivenVars),
      lq,
      length(uniqueItems)
    )
  
    varsTable <- data.frame(varsNamesForTable,varsValuesForTable)
    colnames(varsTable) <- .Unicodify(tl[20:21,la])  
    addTable(rtf, varsTable)
    addParagraph(rtf, "\n")
    addParagraph(rtf, paste(" ", .Unicodify(tl[22,la]), "\n", sep="")) #Table with item types
    
    #Exclude variables that produce errors  
    te <- vector(length=length(models))
    for(k in 1:length(models)) te[k] <- inherits(models[[k]], "try-error")
    varPred <- which(!te) 
    
    itemtypes <- as.data.frame(as.matrix(labels(models[[varPred[1]]]$data$pc)))
    colnames(itemtypes) <- .Unicodify(tl[23,la])
    addTable(rtf, itemtypes)
    
    addParagraph(rtf, "\n")
    
    if(lq > 1)
    {
      
      addParagraph(rtf, .Unicodify(tl[24,la])) #Table with questions
      addParagraph(rtf, "\n")
      qA <- as.data.frame(as.matrix(questionsAnalyzed))
      colnames(qA) <- .Unicodify(tl[25,la])
      addTable(rtf, qA)
      
    }
    addParagraph(rtf, "\n")
    
    addParagraph(rtf, .Unicodify(tl[26,la]))
    addPageBreak(rtf)
    #models is a list of 1 or more bttree models

    for(i in 1:lq)
    {
      
      if(lq>1){addParagraph(rtf, .Unicodify(questionsAnalyzed[i]))}
      
      #Insert exception if the model does not exist (=error).
      if(!inherits(models[[i]], "try-error"))
      {
        
        table_i <- worth(models[[i]])
        if(is.null(dim(table_i))){Node <- names(table_i)} else{Node <- rownames(table_i)}
        table_i <- round(table_i, digits=3)
        table_i <- data.frame(Node, table_i)
        
        addParagraph(rtf, "\n")
        addTable(rtf, table_i, font.size=9, row.names=FALSE, NA.string="-")
        addParagraph(rtf, "\n")
        addPlot(rtf, plot.fun=plot, width=6, height=6, res=400, models[[i]])
        addPageBreak(rtf)
        addParagraph(rtf, .Unicodify(paste(capture.output(summary(models[[i]])), collapse="\n")))
        
      } else {
        
        #TODO Some text sayihg that the model was not constructed.
        
      }
      
      
      addPageBreak(rtf)
      
    }
    
    #References don't need .Unicodify
    addParagraph(rtf, tl[27,la])
    addParagraph(rtf, tl[28,la])  
    addParagraph(rtf, tl[29,la])
    addParagraph(rtf, tl[30,la])  
    addParagraph(rtf, tl[31,la])  
    addParagraph(rtf, tl[32,la])
  
    done(rtf)
    
    dispose(w5)
    
    gmessage("Report created.", title="Done", icon="info") #TODO Should get this from the file rather than EN only!
    
    dispose(w5)
    
  })
  
  font(b) <- list(size=12)
  
  visible(w5) <- TRUE
                 
}
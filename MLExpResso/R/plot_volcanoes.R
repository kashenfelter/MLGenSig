#' @title Visulisations for methylation and expression.
#'
#' @description Function \code{plot_volcanoes} generate a dashboard with volcano plots for expression and methylation. Also it adds a tables with basic statistics.
#'
#' @param condition.e condition for  expression
#' @param condition.m condition for methylation
#' @param data.e data for expression
#' @param data.m data for methylation
#' @param gene gene name
#' @param test.e list of tests results for expression
#' @param test.m list of tests results for methylation
#' @param values logical value, TRUE if we want p-values and log fold for chosen gene
#'
#' @return A plot of class ggplot.
#'
#'@importFrom gridExtra tableGrob
#'@importFrom grid textGrob
#'@importFrom grid gpar
#'@importFrom gridExtra grid.arrange
#'@importFrom edgeR cpm
#'@importFrom grid grid.rect
#'
#'@seealso volcano_plot, gene_stats
#'@export

plot_volcanoes <- function(condition.e, condition.m, data.e,data.m, gene, test.e=list(), test.m=list(), values=FALSE){
  if(class(test.e)!="list"){
    test.e <- list(test.e)
  }
  if(class(test.m)!="list"){
    test.m <- list(test.m)
  }
  
  names.e <- names(test.e)
  names.m <- names(test.m)
  if(length(names.e)==0){
    names.e <- rep("",times=length(test.e))
  }
  if(length(names.m)==0){
    names.m <- rep("",times=length(test.m))

  }
  mytheme <- gridExtra::ttheme_default(
    core = list(fg_params=list(cex = 1.8,col=c("#e41a1c","#377eb8","#4daf4a","#984ea3","#ff7f00","#ffff33","#a65628","#f781bf")), bg_params=list(fill=c("white"))),
    colhead = list(fg_params=list(cex = 1.8), bg_params=list(fill=c("white"))),
    rowhead = list(fg_params=list(cex = 1.8, fontface = "bold")))


  data.e.cpm <- as.data.frame(cpm(data.e))
  s.e <- tableGrob(t(gene_stats(data.e.cpm ,condition.e , gene, 0)), theme = mytheme)
  data.m.map <- aggregate_probes(data.m)
  s.m <- tableGrob(t(gene_stats(data.m.map,condition.m , gene, 2)), theme = mytheme)

  title.e <- textGrob("Expression (cpm)", just = "centre", gp=gpar(fontsize = 25))
  title.m <- textGrob("Methylation",  just = "centre", gp=gpar(fontsize = 25))

  title <- textGrob(gene, gp=gpar(fontsize = 25), x = unit(1.1, "npc"))
  blank <- textGrob("", gp=gpar(fontsize = 25))

  plist <- list(title, blank, title.m, title.e, s.m, s.e)
  if((length(test.e) + length(test.m)) > 0 ){
  l.e <- length(test.e)
  l.m <- length(test.m)

  for(i in 1:max(l.e, l.m)){
    if(i>l.e){
      plist[[length(plist)+1]] <- grid.rect(gp=gpar(col="white"))
    }else{
      plist[[length(plist)+1]] <- plot_volcano(test.e[[i]], ngen = gene,ylog=TRUE,title=names.e[i], line=0.05, values=values)
    }

    if(i>l.m){
      plist[[length(plist)+1]] <- grid.rect(gp=gpar(col="white"))
    }
    else{
      plist[[length(plist)+1]] <- plot_volcano(test.m[[i]], ngen = gene, title=names.m[i], ylog=TRUE, line=0.05, values=values)
    }

  }
  }
  heights.plots <- rep(130,max(length(test.e), length(test.m)))
  heights.g <- unit(c(20,10,30, heights.plots), "mm")
  grid.arrange(grobs = plist, ncol=2, heights=heights.g)

}

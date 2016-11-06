library(shiny)
library(wordcloud2)
library(profr)
file<-"fun1_rprof.out"
Rprof(file)
runApp("app.R")
Rprof(NULL)
#显示日志
summaryRprof(file)


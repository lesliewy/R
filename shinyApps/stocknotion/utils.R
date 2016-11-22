
indexes <<- list("上证指数" = "1A0001",
                 "深证成指" = "399001",
                 "创业板指" = "399006")

corrNotionData <- function(code, begindate, enddate){
  dfIndex <- indexQuery(code, begindate, enddate)
  dfNotions <- notionQuery(begindate, enddate)
  # 对数组框按照factor分组. 把TRADE_DATE的factor去掉，不需要
  dfNotions$TRADE_DATE <- as.character(dfNotions$TRADE_DATE)
  groupNotions <- split(dfNotions, dfNotions$NOTION_NAME)
  
  # 注意参数的传递
  cordata = lapply(groupNotions, calOneCor, dfIndex)
  # 将list转成data.frame
  result = {}
  for(i in cordata){
    result <- rbind(result, i)
  }
  # 发现按t值排序和按相关系数排序结果一样
  result <- result[order(result$cor, decreasing=TRUE), ]
  return(result)
}

calOneCor <- function(dfNotion, dfIndex){
  # 大盘和板块的日期必须一致
  intersectdates <- intersect(dfNotion$TRADE_DATE, dfIndex$TRADE_DATE)
  
  dfnotion1 <- dfNotion[which(dfNotion$TRADE_DATE %in% intersectdates), ]
  dfIndex1 <- dfIndex[which(dfIndex$TRADE_DATE %in% intersectdates),]
  cordata <- cor.test(dfnotion1$CHANGE_PCT, dfIndex1$CHANGE_PCT,method="pearson")
  data <- data.frame(notionName=c(as.character(dfNotion$NOTION_NAME)[1]), p.value=round(c(cordata$p.value), 10), cor=round(c(cordata$estimate), 10), 
                     t=round(c(cordata$statistic), 10), alternative=c(cordata$alternative), method=c(cordata$method))
  return(data)
}
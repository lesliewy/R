library(hash)

Chinese2Digits <- function(chinese){
  map <- hash(c("零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "百", "千", "万", "亿"), c(0:10, 100, 1000, 10000, 100000000))
  total <- 0
  r <- 1                           #表示单位：个十百千...
  for (i in seq(nchar(chinese), 1, -1)){
    val <- values(map, substr(chinese, i, i))
    #应对 十三 十四 十*之类
    if (val >= 10 && i == 1){
      if (val > r){
        r = val
        total = total +  val
      } else{
        r = r * val
        #total =total +  r * x
      }
    }else if(val >= 10){
      if (val > r){
        r = val
      }else{
        r = r * val
      }
    }else{
      total = total +  r * val
    }
  }
  return(total)
} 
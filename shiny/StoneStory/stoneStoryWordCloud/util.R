library(hash)

GetWords <- function (begin, end, showwords, type) {
  # character类型, 必须转换
  showwords <- as.integer(showwords)
  print(paste("begin:", begin," end:",end," showwords:", showwords, "type:", type))
  wordfreqall <- NULL
  freqdirpath <- "/home/leslie/MyProject/R/StoneStory/freq/"
  for(i in begin:end){
    freqname <- paste(freqdirpath, grep(paste("^第", i, "回", sep=""), list.files(freqdirpath), value=TRUE), sep="")
    # stringsAsFactors 方便后面处理, 否则has.key()那里报错
    wordfreq <- read.table(freqname, header=TRUE, stringsAsFactors=FALSE);
    print(paste(freqname,nrow(wordfreq)))
    wordfreqall <- rbind(wordfreqall, wordfreq)
  }
  print(paste("wordfreqall:", nrow(wordfreqall)))
  
  # 不用了这个方法，没办法再将tapply返回的array转成data.frame
  # wordfreqsum <- tapply(wordfreqall$次数, wordfreqall$词语, sum)
  
  h <- hash()
  for(i in 1:nrow(wordfreqall)){
    k <- wordfreqall[i, 1]
    v <- wordfreqall[i, 2]
    if(has.key(k, h)){
      .set(h, k, values(h, keys=k) + v)
    }else{
      .set(h, k, v)
    }
  }
  words <- keys(h)
  count <- values(h, USE.NAMES = FALSE)
  wordfreqsum <- data.frame(words, count)
  print(head(words, n = 5))
  print(head(count, n = 5))
  print(head(wordfreqsum, n = 5))
  
  # 过滤掉一个字的
  wordfreq1 <- wordfreqsum[nchar(as.vector(wordfreqsum[[1]])) > 1, ]
  if(type == "person"){
    all <- GetPersons()
    # 使用which过滤，all必须是list
    wordfreq1 <- wordfreq1[which(wordfreq1$words %in% all), ]
  }
  # sort
  wordfreq2 <- head(wordfreq1[order(wordfreq1[,2], decreasing=T),], n = showwords)
  return(wordfreq2)
}

GetPersons <- function(){
  data <- read.table("/home/leslie/MyProject/R/StoneStory/dicts/人名.txt", col.names = "name", header = FALSE, stringsAsFactors = FALSE)
  list <- as.list(data$name)
  return(list)
}
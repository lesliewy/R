# 加载需要的package
initmongodb <- function(){
  library(rmongodb)
}

allCates <- c("先秦", "汉朝", "魏晋", "南北朝", "隋朝", "唐朝", "宋朝", "金朝", "辽朝","元朝", "明朝", "清朝", "近当代")

# 获取mongo连接
getConn <- function(){
  #本地连接，不要参数
  con <- mongo.create()
  print(paste("mongo connected: ", mongo.is.connected(con)))
  return(con);
}

# db and collection
db<-"poetry"
ns <- "poetry.poem"

#关闭数据库连接.
closeConn <- function(con){
  mongo.destroy(con)
}

categoryAuthorsQuery <- function(){
  conn <- getConn();
  pipe1 <- mongo.bson.from.JSON('{"$project":{"categoryname":"$category.name", "authorname" : "$author.name", "_id":0}}')
  pipe2 <- mongo.bson.from.JSON('{"$group" :{"_id":{"categoryname":"$categoryname"}, "totalauthors": {"$sum" : 1}}}')
  cmdlist <- list(pipe1, pipe2)
  res <- mongo.aggregation(conn, ns, cmdlist)
  r <- mongo.bson.to.Robject(res)
  l <- lapply(r$result, function(x){data.frame(categoryname=x[[1]], totalauthors = x[[2]])})
  # 将list转成data.frame
  result = {}
  for(i in l){
    result <- rbind(result, i)
  }
  # order by Time
  o <- ordered(result$categoryname, levels = allCates)
  result <- result[order(o), ]
  
  closeConn(conn)
  return(result)
}

categoryPoemsQuery <- function(){
  conn <- getConn();
  pipe1 <- mongo.bson.from.JSON('{"$project":{"categoryname":"$category.name", "poems" : {"$size":"$poems"}, "_id":0}}')
  pipe2 <- mongo.bson.from.JSON('{"$group" : {"_id":{"categoryname":"$categoryname"}, "totalpoems":{"$sum" : "$poems"} }}')
  cmdlist <- list(pipe1, pipe2)
  res <- mongo.aggregation(conn, ns, cmdlist)
  r <- mongo.bson.to.Robject(res)
  l <- lapply(r$result, function(x){data.frame(categoryname=x[[1]], totalpoems = x[[2]])})
  # 将list转成data.frame
  result = {}
  for(i in l){
    result <- rbind(result, i)
  }
  # order by Time
  o <- ordered(result$categoryname, levels = allCates)
  result <- result[order(o), ]
  
  closeConn(conn)
  return(result)
}

authorPoemsByCate <- function(categories){
  print("this is authorPoemsByCate")
  conn <- getConn();
  categoriesCond <- buildCateCond(categories)
  #rmongo的问题，$in中必须是>1的参数
  if(length(categories) > 1){
    pipe1Str <- paste('{"$match" : {"category.name" : {"$in" : [', categoriesCond, ']}}}', sep="")
  }else if(length(categories) == 1){
    pipe1Str <- paste('{"$match" : {"category.name" : ', categoriesCond, '}}', sep="")
  }
  
  print(pipe1Str)
  pipe1 <- mongo.bson.from.JSON(pipe1Str)
  pipe2 <- mongo.bson.from.JSON('{"$project" : {"category.name" : 1, "author.name" : 1, "author.numofpoems": 1, "numofpoems" : {"$size" : "$poems"}, "_id" : 0}}')
  pipe3 <- mongo.bson.from.JSON('{"$sort" : {"numofpoems": -1}}')
  cmdlist <- list(pipe1, pipe2, pipe3)
  res <- mongo.aggregation(conn, ns, cmdlist)
  r <- mongo.bson.to.Robject(res)
  # rbind 对于稍大数据量速度太慢, 2000条都要7,8秒
  # l <- lapply(r$result, function(x){data.frame(categoryname=x$category, authorname=x$author$name, numofpoems = x$numofpoems)})
  # result = {}
  # for(i in l){
  #   result <- rbind(result, i, deparse.level = 0, stringsAsFactors=FALSE, make.row.names=FALSE)
  # }
  categoryname <- c()
  authorname <- c()
  numofpoems <- c()
  for(x in r$result){
    categoryname <- c(categoryname, x$category)
    authorname <- c(authorname, x$author$name)
    numofpoems <- c(numofpoems, x$numofpoems)
  }
  result <- data.frame(categoryname=categoryname, authorname = authorname, numofpoems=numofpoems)
  closeConn(conn)
  return(result)
}

buildCateCond <- function(categories){
  b <- ""
  for(i in categories){
    b <- paste(b, '"', i, '",', sep="")
  }
  b <- substr(b, 1, nchar(b)-1)
  return(b)
}

initmongodb()
# 加载需要的package
initmongolite <- function(){
  library(mongolite)
}

allCates <- c("先秦", "汉朝", "魏晋", "南北朝", "隋朝", "唐朝", "宋朝", "金朝", "辽朝","元朝", "明朝", "清朝", "近当代")

# 获取mongo连接
getConn <- function(){
  #本地连接，不要参数
  con <- mongo("poem", "poetry", url = "mongodb://poetry:poetry123@127.0.0.1:27017/poetry")
  return(con);
}

#关闭数据库连接.
closeConn <- function(con){
  rm(con)
  gc()
}

categoryAuthorsQuery <- function(){
  conn <- getConn();
  result <- conn$aggregate('[{"$project":{"categoryname":"$category.name", "authorname" : "$author.name", "_id":0}},
                 {"$group" :{"_id":{"categoryname":"$categoryname"}, "totalauthors": {"$sum" : 1}}}]')
  
  # rmongodb 方式
  #pipe1 <- mongo.bson.from.JSON('{"$project":{"categoryname":"$category.name", "authorname" : "$author.name", "_id":0}}')
  #pipe2 <- mongo.bson.from.JSON('{"$group" :{"_id":{"categoryname":"$categoryname"}, "totalauthors": {"$sum" : 1}}}')
  #cmdlist <- list(pipe1, pipe2)
  #res <- mongo.aggregation(conn, ns, cmdlist)
  #r <- mongo.bson.to.Robject(res)
  # 将list转成data.frame, mongolite package 不需要，res就是data.frame
  #l <- lapply(r$result, function(x){data.frame(categoryname=x[[1]], totalauthors = x[[2]])})
  #result = {}
  #for(i in l){
  #  result <- rbind(result, i)
  #}
  
  # 修改列名，以前是result$'_id'$categoryname
  result <- data.frame(categoryname=result$'_id'$categoryname, totalauthors=result$totalauthors)
  # order by Time
  o <- ordered(result$categoryname, levels = allCates)
  result <- result[order(o), ]
  closeConn(conn)
  # 添加总共
  d1 <- data.frame(categoryname=c("总共"), totalauthors=c(sum(result$totalauthors)))
  result <- rbind(result, d1)
  # 显示行号，不显示其他的
  row.names(result) <- NULL
  return(result)
}

categoryPoemsQuery <- function(){
  conn <- getConn();
  result <- conn$aggregate('[{"$project":{"categoryname":"$category.name", "poems" : {"$size":"$poems"}, "_id":0}},
                 {"$group" : {"_id":{"categoryname":"$categoryname"}, "totalpoems":{"$sum" : "$poems"}}}]')
  
  # rmongodb 方式
  #pipe1 <- mongo.bson.from.JSON('{"$project":{"categoryname":"$category.name", "poems" : {"$size":"$poems"}, "_id":0}}')
  #pipe2 <- mongo.bson.from.JSON('{"$group" : {"_id":{"categoryname":"$categoryname"}, "totalpoems":{"$sum" : "$poems"} }}')
  #cmdlist <- list(pipe1, pipe2)
  #res <- mongo.aggregation(conn, ns, cmdlist)
  #r <- mongo.bson.to.Robject(res)
  # 将list转成data.frame, mongolite package 不需要，res就是data.frame
  #l <- lapply(r$result, function(x){data.frame(categoryname=x[[1]], totalpoems = x[[2]])})
  #result = {}
  #for(i in l){
  #  result <- rbind(result, i)
  #}
  
  # 修改列名，以前是result$'_id'$categoryname
  result <- data.frame(categoryname=result$'_id'$categoryname, totalpoems=result$totalpoems)
  
  # order by Time
  o <- ordered(result$categoryname, levels = allCates)
  result <- result[order(o), ]
  closeConn(conn)
  # 添加总共
  d1 <- data.frame(categoryname=c("总共"), totalpoems=c(sum(result$totalpoems)))
  result <- rbind(result, d1)
  # 显示行号，不显示其他的
  row.names(result) <- NULL
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
#  pipe1 <- mongo.bson.from.JSON(pipe1Str)
#  pipe2 <- mongo.bson.from.JSON('{"$project" : {"category.name" : 1, "author.name" : 1, "author.numofpoems": 1, "numofpoems" : {"$size" : "$poems"}, "_id" : 0}}')
#  pipe3 <- mongo.bson.from.JSON('{"$sort" : {"numofpoems": -1}}')
#  cmdlist <- list(pipe1, pipe2, pipe3)
#  res <- mongo.aggregation(conn, ns, cmdlist)
#  r <- mongo.bson.to.Robject(res)
  
  # rbind 对于稍大数据量速度太慢, 2000条都要7,8秒
  # l <- lapply(r$result, function(x){data.frame(categoryname=x$category, authorname=x$author$name, numofpoems = x$numofpoems)})
  # result = {}
  # for(i in l){
  #   result <- rbind(result, i, deparse.level = 0, stringsAsFactors=FALSE, make.row.names=FALSE)
  # }
  
  aggrestr <- paste('[', pipe1Str, ',' ,
                    '{"$project" : {"category.name" : 1, "author.name" : 1, "author.numofpoems": 1, "numofpoems" : {"$size" : "$poems"}, "_id" : 0}}', ',',
                    '{"$sort" : {"numofpoems": -1}}',
                    ']', sep="")
  result <- conn$aggregate(aggrestr)
  
  categoryname <- result$category$name
  authorname <- result$author$name
  numofpoems <- result$numofpoems
  
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

initmongolite()
# 加载需要的package
InitMysql <- function(){
        library(RMySQL)
}

# 获取数据库连接
GetConn <- function(){
    con <- dbConnect(MySQL(),
        user='root', # 用户名
        password='mysql', # 密码
        dbname='mysql', # 要使用的数据库名称
        host="localhost") # 主机地址
#    dbListTables(con) # 列出所有数据库中的表
    return(con);
}

#关闭数据库连接.
CloseConn <- function(con){
    dbDisconnect(con);
}

industryHotResult <- function(){
    conn <- GetConn();

#    baseSql <- "SELECT * FROM ST_INDUSTRY_HOT WHERE TRADE_DATE LIKE '2015-10-08%'";
    baseSql <- "SELECT A.TRADE_DATE, A.RANK, A.INDUSTRY_NAME, A.CHANGE_PCT, B.INDEX_NAME, B.CHANGE_PCT INDEX_PCT FROM ST_INDUSTRY_HOT A, ST_INDEX B WHERE A.TRADE_DATE = B.TRADE_DATE AND (A.TRADE_DATE LIKE '2015-10-08%' OR A.TRADE_DATE LIKE '2015-10-09%') AND B.INDEX_NAME='上证指数'";
    industryHotResult <- dbGetQuery(conn, baseSql); 
    result <- data.frame(industryHotResult);

    CloseConn(conn); 
    return (result);
}

StockNotionQuery <- function(code, begindate, enddate){
  conn <- GetConn();
  
  basesql <- paste("SELECT A.TRADE_DATE, A.NOTION_NAME, B.CHANGE_PCT NOTION_CHANGE_PCT, A.STOCK_NAME,A.CHANGE_PCT FROM ST_NOTION_HOT_STOCKS A, ST_NOTION_HOT B WHERE A.TRADE_DATE=B.TRADE_DATE AND A.NOTION_NAME=B.NOTION_NAME AND A.STOCK_CODE='", code, "' AND A.TRADE_DATE >= '", begindate, "' AND A.TRADE_DATE <= '", enddate, "'", sep = "");
  print(basesql)
  sqlresult <- dbGetQuery(conn, basesql); 
  result <- data.frame(sqlresult);
  
  CloseConn(conn); 
  return (result);
}

InitMysql()
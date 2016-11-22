# 加载需要的package
initMysql <- function(){
        library(RMySQL)
}

# 获取数据库连接
getConn <- function(){
    con <- dbConnect(MySQL(),
        user='root', # 用户名
        password='mysql', # 密码
        dbname='mysql', # 要使用的数据库名称
        host="localhost") # 主机地址
#    dbListTables(con) # 列出所有数据库中的表
    return(con);
}

#关闭数据库连接.
closeConn <- function(con){
    dbDisconnect(con);
}

industryHotResult <- function(){
    conn <- getConn();

#    baseSql <- "SELECT * FROM ST_INDUSTRY_HOT WHERE TRADE_DATE LIKE '2015-10-08%'";
    baseSql <- "SELECT A.TRADE_DATE, A.RANK, A.INDUSTRY_NAME, A.CHANGE_PCT, B.INDEX_NAME, B.CHANGE_PCT INDEX_PCT FROM ST_INDUSTRY_HOT A, ST_INDEX B WHERE A.TRADE_DATE = B.TRADE_DATE AND (A.TRADE_DATE LIKE '2015-10-08%' OR A.TRADE_DATE LIKE '2015-10-09%') AND B.INDEX_NAME='上证指数'";
    industryHotResult <- dbGetQuery(conn, baseSql); 
    result <- data.frame(industryHotResult);

    closeConn(conn); 
    return (result);
}

stockNotionQuery <- function(code, begindate, enddate){
  conn <- getConn();
  
  basesql <- paste("SELECT A.TRADE_DATE, A.NOTION_NAME, B.CHANGE_PCT NOTION_CHANGE_PCT, A.STOCK_NAME,A.CHANGE_PCT",
                   "  FROM ST_NOTION_HOT_STOCKS A, ST_NOTION_HOT B ",
                   " WHERE A.TRADE_DATE = B.TRADE_DATE AND A.NOTION_NAME = B.NOTION_NAME ",
                   " AND A.CODE='", code, "' AND A.TRADE_DATE >= '", begindate, "' AND A.TRADE_DATE <= '", enddate, "'", sep = "");
  print(basesql)
  sqlresult <- dbGetQuery(conn, basesql); 
  df <- data.frame(sqlresult);
  
  closeConn(conn); 
  return (df);
}

indexQuery <- function(code, begindate, enddate){
  print("this is in indexQuery()")
  conn <- getConn();
  sql <- paste("SELECT TRADE_DATE, CHANGE_PCT FROM ST_INDEX WHERE INDEX_CODE='", code, "' AND TRADE_DATE >='",begindate, "' AND TRADE_DATE <= '", enddate, "'", sep = "")
  sqlresult <- dbGetQuery(conn, sql); 
  result <- data.frame(sqlresult, stringsAsFactors = False);
  
  closeConn(conn);
  return (result);
}

notionQuery <- function(begindate, enddate){
  conn <- getConn()
  sql <- paste(" SELECT NOTION_NAME, TRADE_DATE, CHANGE_PCT FROM ST_NOTION_HOT ",
               " WHERE TRADE_DATE >= '", begindate, "' AND TRADE_DATE <= '", enddate, "' ORDER BY NOTION_NAME, TRADE_DATE", sep = "")
  sqlresult <- dbGetQuery(conn, sql) 
  df <- data.frame(sqlresult)
  closeConn(conn);
  return(df)
}

initMysql()
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

initMysql()
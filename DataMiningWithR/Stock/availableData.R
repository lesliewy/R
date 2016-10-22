# TODO: Add comment
# 
# Author: leslie
###############################################################################

# 2. 可用的数据.

# 0. R中时间的处理.
# 多元时间序列: 在同一个时间点上观测了多个变量，包括：Open, High, Low, Close, Volumn 和 AdjClose(调整了股票分割，分红，配股等之后的价格).
# xts 和 zoo 可以用来处理多元时间序列的数据. 其中xts扩展了zoo.
# xts() 第一个参数接受时间序列数据. 第二个参数是时间标签，可以是R时间类的任何一种：POSIXct类, Date类.
library(xts);  
x1 <- xts(rnorm(100), seq(as.POSIXct("2000-01-01"), len = 100, by = "day"))   
x2 <- xts(rnorm(100), seq(as.POSIXct("2000-01-01 13:00"), len = 100, by = "min"))
x3 <- xts(rnorm(3), as.Date(c("2005-01-01", "2005-01-10", "2005-01-12")))

x1[as.POSIXct("2000-01-04")]
x1["2000-01-05"]
x1["20000105"]
x1["2000-04"]
x1["2000-03-27/"]               # "/" 表示某个时间段，可以用在开始、中间、末尾.  末尾表示该时间开始.
x1["2000-02-26/2000-03-03"]
x1["/20000103"]

# 多元时间序列还可以如下建立.
mts.vals <- matrix(round(rnorm(25),2),5,5)
colnames(mts.vals) <- paste('ts',1:5,sep='')
mts <- xts(mts.vals,as.POSIXct(c('2003-01-01','2003-01-04',
                  '2003-01-05','2003-01-06','2003-02-16')))

index(mts)      # 获取任意xts对象的时间标签信息.
time(x3)
coredata(mts)   # 获取时间序列的观测值.

# 载入本书的包DMwR, 自动获取标普500指数.
library(DMwR);
data(GSPC);

# 1. 从CSV文件读取数据.
GSPC <- as.xts(read.zoo('sp500.csv',header=T))      # 不需要library(zoo), 因为xts依赖于zoo, library(xts)时已经载入了zoo.
   # 第一列是时间标签，zoo就可以读取.   as.xts() 把zoo转换为xts.  sp500.csv 保存在当前运行R的目录中.

# 2. 从网站上获取数据.
#  利用tseries包中的get.hist.quote()函数.
library(tseries)
GSPC <- as.xts(get.hist.quote("^GSPC",start="1970-01-02",
            quote=c("Open", "High", "Low", "Close","Volume","AdjClose")))
head(GSPC)
GSPC <- as.xts(get.hist.quote("^GSPC",
            start="1970-01-02",end='2009-09-15',
            quote=c("Open", "High", "Low", "Close","Volume","AdjClose")))
# 利用quantmod包中的getSymbols(). 该包提供金融数据分析的功能.
library(quantmod)
getSymbols('^GSPC')   # 从不同网站或本地数据库提取符号所对应的交易数据, 默认返回与符号同名的xts对象.
# 修改列名.
getSymbols('^GSPC',from='1970-01-01',to='2009-09-15')
colnames(GSPC) <- c("Open", "High", "Low", "Close","Volume","AdjClose")
# 设置数据源: IBM数据从yahoo网站获取, USDEUR(美元和欧元)的汇率数据从Oanda网站获取.
setSymbolLookup(IBM=list(name='IBM',src='yahoo'),
      USDEUR=list(name='USD/EUR',src='oanda',
            from=as.Date('2009-01-01')))
getSymbols(c('IBM','USDEUR'))
head(IBM)
head(USDEUR)

# 3. 从MYSQL数据库读取数据.
library(DBI)
library(RMySQL)
drv <- dbDriver("MySQL")
ch <- dbConnect(drv,dbname="Quotes","myusername","mypassword")
allQuotes <- dbGetQuery(ch,"select * from gspc")
GSPC <- xts(allQuotes[,-1],order.by=as.Date(allQuotes[,1]))
head(GSPC)
dbDisconnect(ch)
dbUnloadDriver(drv)


setSymbolLookup(GSPC=list(name='gspc',src='mysql',
            db.fields=c('Index','Open','High','Low','Close','Volume','AdjClose'),
            user='xpto',password='ypto',dbname='Quotes'))
getSymbols('GSPC')


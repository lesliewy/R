# TODO: Add comment
# 
# Author: leslie
###############################################################################

# 3. 定义预测任务.

library(DMwR);       # 本书自己的包，里面包含数据.
library(quantmod);   # HLC()  candleChart()都在这个包里.
# 1.预测什么
# 指标变量T用来找出在k天内，日平均价格明显高于目标变化的那些日期的变化之和.大的正T值意味着有几天的日平均报价高于今天收盘价的p%. 大的负T值表明
# 价格可能下降，可以进行卖出. 如果T值接近于0，则可能是价格平稳或涨跌互现。
T.ind <- function(quotes,tgt.margin=0.025,n.days=10) {
   v <- apply(HLC(quotes),1,mean)                       # 从价格对象中提取最高价、最低价、收盘价.
   
   r <- matrix(NA,ncol=n.days,nrow=NROW(quotes))
   ## The following statment is wrong in the book (page 109)!
   for(x in 1:n.days) r[,x] <- Next(Delt(Cl(quotes),v,k=x),x)     # next()按时间平移一个序列; Delt()用于计算价格序列的百分比收益或对数收益
   
   x <- apply(r,1,function(x) sum(x[x > tgt.margin | x < -tgt.margin]))
   if (is.xts(quotes)) xts(x,time(quotes)) else x
}
# T指标的图形化.
candleChart(last(GSPC,'3 months'),theme='white',TA=NULL)      # 绘制最后3个月标准普尔500指数的蜡烛图
avgPrice <- function(p) apply(HLC(p),1,mean)
addAvgPrice <- newTA(FUN=avgPrice,col=1,legend='AvgPrice')    # newTA 在quantmod包中, 绘制新的指标并加入已有的图中.
addT.ind <- newTA(FUN=T.ind,col='red',legend='tgtRet')
addAvgPrice(on=1)  # 将on参数设为1，意味着该指标被绘制在第一个图形窗口中,即蜡烛图上.
addT.ind()
# 2. 预测变量是什么
# 从TTR包中选出有代表性的技术指标. 对这些指标做获得单一值的处理.
myATR <- function(x) ATR(HLC(x))[,'atr']
mySMI <- function(x) SMI(HLC(x))[,'SMI']
myADX <- function(x) ADX(HLC(x))[,'ADX']
myAroon <- function(x) aroon(x[,c('High','Low')])$oscillator
myBB <- function(x) BBands(HLC(x))[,'pctB']
myChaikinVol <- function(x) Delt(chaikinVolatility(x[,c("High","Low")]))[,1]
myCLV <- function(x) EMA(CLV(HLC(x)))[,1]
myEMV <- function(x) EMV(x[,c('High','Low')],x[,'Volume'])[,2]
myMACD <- function(x) MACD(Cl(x))[,2]
myMFI <- function(x) MFI(x[,c("High","Low","Close")], x[,"Volume"])
mySAR <- function(x) SAR(x[,c('High','Close')]) [,1]
myVolat <- function(x) volatility(OHLC(x),calc="garman")[,1]
# 用训练集数据结构构建随机森林模型.
library(randomForest)
data.model <- specifyModel(T.ind(GSPC) ~ Delt(Cl(GSPC),k=1:10) + 
            myATR(GSPC) + mySMI(GSPC) + myADX(GSPC) + myAroon(GSPC) + 
            myBB(GSPC)  + myChaikinVol(GSPC) + myCLV(GSPC) + 
            CMO(Cl(GSPC)) + EMA(Delt(Cl(GSPC))) + myEMV(GSPC) + 
            myVolat(GSPC)  + myMACD(GSPC) + myMFI(GSPC) + RSI(Cl(GSPC)) +
            mySAR(GSPC) + runMean(Cl(GSPC)) + runSD(Cl(GSPC)))              # 用specifyModel 来设定并获取建模数据集.
set.seed(1234)
rf <- buildModel(data.model,method='randomForest',
      training.per=c(start(GSPC),index(GSPC["1999-12-31"])),
      ntree=50, importance=T)                                               # buildModel()使用得到的模型规范, 获得有相应数据的模型.
   # 通过training.per来指定建立模型所用的数据(这里使用的是前30年的数据)。 目前该函数包含了多个内置模型，包括随机森林.
   # 设置importance = TRUE, 这样随机森林将估计变量的重要性.

# 使用buildModel()中没有的模型来建模, 可以使用modelData()来获取数据，然后将zoo对象转为矩阵或数据框供自己的建模函数使用.
#ex.model <- specifyModel(T.ind(IBM) ~ Delt(Cl(IBM),k=1:3))
#data <- modelData(ex.model,data.window=c('2009-01-01','2009-08-10'))
#m <- myFavourateModellingTool(ex.model@model.formula, as.data.frame(data))

# 检查变量的重要性.
varImpPlot(rf@fitted.model,type=1)  # 参数是随机森林和想绘制的得分. 泛型函数buildModel()返回作为结果产生的quantmod对象插槽(fitted.model)
   # 即为所获得的模型. buildModel()返回的模型对象将是quantmod对象的一个属性.

# 确定一个接界限值来选择重要性评分高的变量子集.
imp <- importance(rf@fitted.model,type=1)    # 得到每个变量具体的重要性分数(这是第一个得分)
rownames(imp)[which(imp > 10)]

# 利用变量重要性的信息, 得到最终用于建立模型的数据集.
data.model <- specifyModel(T.ind(GSPC) ~ Delt(Cl(GSPC),k=1) + myATR(GSPC) 
            + myADX(GSPC) +    myEMV(GSPC) + myVolat(GSPC)  + myMACD(GSPC) 
            + mySAR(GSPC) + runMean(Cl(GSPC)) )

# 3. 预测任务
# 构造预测模型和所应用的数据结构.
Tdata.train <- as.data.frame(modelData(data.model,
            data.window=c('1970-01-02','1999-12-31')))         # 用于模型训练阶段
Tdata.eval <- na.omit(as.data.frame(modelData(data.model,
                  data.window=c('2000-01-01','2009-09-15'))))  # 用于模型评价阶段
Tform <- as.formula('T.ind.GSPC ~ .')

# 4. 模型评价准则





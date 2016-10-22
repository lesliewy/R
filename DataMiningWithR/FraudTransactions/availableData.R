# TODO: Add comment
# 
# Author: leslie
###############################################################################

# 2. 可用的数据.
# a. 加载数据.
#load('sales.Rdata')    # 第一种方法：导入文件.

library(DMwR)          # 第二种方法: 导入包.
data(sales)
head(sales)

# b. 探索数据集
summary(sales)
nlevels(sales$ID)       # 销售员ID的个数.
nlevels(sales$Prod)     # 销售产品ID的个数.
length(which(is.na(sales$Quant) & is.na(sales$Val)))    # 产品销售的数量和总价值都缺失的记录数.
sum(is.na(sales$Quant) & is.na(sales$Val))              # 另一种表示.
table(sales$Insp)/nrow(sales)*100     # 检查Insp(ok:公司检查过且认为有效; fraud: 发现交易欺诈; unkn: 未经审查)列的分布情况.

totS <- table(sales$ID)
totP <- table(sales$Prod)
barplot(totS,main='Transactions per salespeople',names.arg='',xlab='Salespeople',
      ylab='Amount')    # 每个销售人员报告的数量
barplot(totP,main='Transactions per product',names.arg='',xlab='Products',
      ylab='Amount')    # 每个产品报告的数量.

sales$Uprice <- sales$Val/sales$Quant     # 单位产品价格.
summary(sales$Uprice)

attach(sales)
upp <- aggregate(Uprice,list(Prod),median,na.rm=T)      # 每个产品的单位价格的中位数
topP <- sapply(c(T,F),function(o) 
         upp[order(upp[,2],decreasing=o)[1:5],1])       # 得到5个最昂贵(最便宜)的产品
colnames(topP) <- c('Expensive','Cheap')
topP


tops <- sales[Prod %in% topP[1,],c('Prod','Uprice')]      # %in%: 测试一个值是否属于一个集合.
tops$Prod <- factor(tops$Prod)
boxplot(Uprice ~ Prod,data=tops,ylab='Uprice',log="y")


vs <- aggregate(Val,list(ID),sum,na.rm=T)
scoresSs <- sapply(c(T,F),function(o) 
         vs[order(vs$x,decreasing=o)[1:5],1])
colnames(scoresSs) <- c('Most','Least')
scoresSs


sum(vs[order(vs$x,decreasing=T)[1:100],2])/sum(Val,na.rm=T)*100
sum(vs[order(vs$x,decreasing=F)[1:2000],2])/sum(Val,na.rm=T)*100


qs <- aggregate(Quant,list(Prod),sum,na.rm=T)
scoresPs <- sapply(c(T,F),function(o) 
         qs[order(qs$x,decreasing=o)[1:5],1])
colnames(scoresPs) <- c('Most','Least')
scoresPs
sum(as.double(qs[order(qs$x,decreasing=T)[1:100],2]))/
      sum(as.double(Quant),na.rm=T)*100
sum(as.double(qs[order(qs$x,decreasing=F)[1:4000],2]))/
      sum(as.double(Quant),na.rm=T)*100


out <- tapply(Uprice,list(Prod=Prod),
      function(x) length(boxplot.stats(x)$out))


out[order(out,decreasing=T)[1:10]]


sum(out)
sum(out)/nrow(sales)*100

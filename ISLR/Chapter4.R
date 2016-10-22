# Chapter 4 Lab: Logistic Regression, LDA, QDA, and KNN
# 分类.

# The Stock Market Data

library(ISLR)
names(Smarket)
dim(Smarket)                 # 显示Smarket的行数和列数
summary(Smarket)
pairs(Smarket)
cor(Smarket)                 # 报错，第9列Direction是定性的.需要去掉.
cor(Smarket[,-9])            # 计算所有预测变量两两之间相关系数的矩阵.
   # 可以发现，前几日的投资回报(Lag1 - Lag5)与当日的投资回报(Today)的相关系数接近于0, 也就是说相关性很小，
   # 唯一一对强相关的是Year和Volumn, 通过画图也可以观察到Volumn随着时间一直在增长.
attach(Smarket)
plot(Volume)                 # 相关于plot(Smarket$Volume) 

# Logistic Regression
# 逻辑斯蒂回归
glm.fit=glm(Direction~Lag1+Lag2+Lag3+Lag4+Lag5+Volume,data=Smarket,family=binomial)  # 广义线性回归。 binomial 要求执行逻辑斯蒂回归.
summary(glm.fit)          # 负系数表明是负相关，即如果市场昨天是投资回报是正的，今天就是负的.  最小的p值是Lag1的0.15, 但是仍然太大, 不能说明
   # Direction 和 Lag1之间有确切关系. 
coef(glm.fit)             # 获取拟合模型的系数.
summary(glm.fit)$coef     # 通过 glm 获取相关信息. 
summary(glm.fit)$coef[,4] 
glm.probs=predict(glm.fit,type="response")  # response明确告诉R输出概率P(Y=1|X), 而不输出其他信息, 比如分对数. 这里没有提供数据集给predict
   # 所以计算的是模型的训练数据的概率.
glm.probs[1:10]           # 输出前10个.   注意这里输出的是上涨的概率.  可以通过contrasts()看出来. 1 代表的是上涨.
contrasts(Direction)
glm.pred=rep("Down",1250)     # 产生1250个Down元素.
glm.pred[glm.probs>.5]="Up"   # 将预测上涨概率超过0.5的元素转为Up
table(glm.pred,Direction)     # 产生混淆矩阵来判断多少天预测正确了. 对角线上的是预测正确的. 这里预测正确了145天下跌，507天上涨.
(507+145)/1250                # 0.5216
mean(glm.pred==Direction)     # 同样是 0.5216    不过这个预测率是不正确的，因为训练模型和预测模型都是同一数据集.
train=(Year<2005)             # 1250个布尔向量
Smarket.2005=Smarket[!train,] # 获取2005年的观测数据.
dim(Smarket.2005)
Direction.2005=Direction[!train]  
glm.fit=glm(Direction~Lag1+Lag2+Lag3+Lag4+Lag5+Volume,data=Smarket,family=binomial,subset=train)   # 这次训练数据是2005年以前的.
glm.probs=predict(glm.fit,Smarket.2005,type="response")   # 测试数据是2005年的， 预测2005年的.
glm.pred=rep("Down",252)             # 和前面一样.
glm.pred[glm.probs>.5]="Up"
table(glm.pred,Direction.2005)
mean(glm.pred==Direction.2005)   # 预测正确率 0.48
mean(glm.pred!=Direction.2005)   # 预测错误率 0.52
glm.fit=glm(Direction~Lag1+Lag2,data=Smarket,family=binomial,subset=train)    # 根据cor()，去除极不相关的几个变量, 保留 Lag1 Lag2
   # 加入与响应变量预测无关的预测变量会造成错误率变大, 因为会增大模型方差, 但不会相应的降低模型偏差. 
glm.probs=predict(glm.fit,Smarket.2005,type="response")
glm.pred=rep("Down",252)
glm.pred[glm.probs>.5]="Up"
table(glm.pred,Direction.2005)
mean(glm.pred==Direction.2005)   # 预测正确率 0.56
106/(106+76)
predict(glm.fit,newdata=data.frame(Lag1=c(1.2,1.5),Lag2=c(1.1,-0.8)),type="response")  # 在特定的Lag1 Lag2 下预测投资回报率. 

# Linear Discriminant Analysis
# 线性判别分析(LDA)
library(MASS)   # lda 在 MASS中.
lda.fit=lda(Direction~Lag1+Lag2,data=Smarket,subset=train)  # 49.2%的训练观测对应市场下降的时期,50.8% 对应着市场上涨时期.
   # Group means: 类平均值. 即每类中每个预测变量的平均值. 这里表明当市场上涨时，前两天的投资回报趋向负值，当市场下跌时，前两天的投资回报趋向正值.
   # 线性判别系数: 线性判别函数中Lag1 Lag2 的组合系数. 用来形成LDA的决策准则. 也就是说如果 -0.642 * Lag1 - 0.514 * Lag2 很大，则LDA分类器
   # 预测市场上涨，如果很小，LDA分类器预测下跌. 
lda.fit
plot(lda.fit)    # 对每个观测值计算 -0.642 * Lag1 - 0.514 * Lag2 获得.
lda.pred=predict(lda.fit, Smarket.2005)   # 包含3个元素 class, posterior, x
   # class: 存储LDA关于市场动向的预测.
   # posterior: 是一个矩阵, 其中第k列是观测属于第k类的后验概率. 
   # x: 线性判别.
names(lda.pred)
lda.class=lda.pred$class
table(lda.class,Direction.2005)
mean(lda.class==Direction.2005)
sum(lda.pred$posterior[,1]>=.5)   # 后验概率50%，结果包含在lda.pred$class中
sum(lda.pred$posterior[,1]<.5)
lda.pred$posterior[1:20,1]
lda.class[1:20]
sum(lda.pred$posterior[,1]>.9)    # 后验概率90%, 希望对市场下跌的预测非常准，也就是说预测市场下跌而市场确实以很大可能性下跌
   # 2005年没有一天满足，事实上，2005年最高的下跌后验概率为 52.02%

# Quadratic Discriminant Analysis
# 二次判别分析(QDA)
qda.fit=qda(Direction~Lag1+Lag2,data=Smarket,subset=train)   # 包含类平均值，但是不包含线性判别系数. 因为QDA分类器是一个二次函数, 
   # 不是预测变量的线性函数.
qda.fit
qda.class=predict(qda.fit,Smarket.2005)$class
table(qda.class,Direction.2005)
mean(qda.class==Direction.2005)  # 正确率59.9%，表明QDA所假设的二次型比LDA和逻辑斯蒂回归的线性假设更接近真实的股票市场. 

# K-Nearest Neighbors
# K最近邻法
library(class)                     # knn所在的库
train.X=cbind(Lag1,Lag2)[train,]   # 与训练数据相关的预测变量矩阵. 
test.X=cbind(Lag1,Lag2)[!train,]   # 与预测数据相关的预测变量矩阵. 
train.Direction=Direction[train]   # 训练观测类标签.
set.seed(1)
knn.pred=knn(train.X,test.X,train.Direction,k=1)
table(knn.pred,Direction.2005)
(83+43)/252                        # 0.5   k=1的模型过于光滑.
knn.pred=knn(train.X,test.X,train.Direction,k=3)  
table(knn.pred,Direction.2005)
mean(knn.pred==Direction.2005)     # 0.536 之后随着k的增加,结果不会有改进.
   # 对这个数据而言，QDA提供了目前为止研究模型中最好的结果


# An Application to Caravan Insurance Data

dim(Caravan)
attach(Caravan)
summary(Purchase)
348/5822
standardized.X=scale(Caravan[,-86])
var(Caravan[,1])
var(Caravan[,2])
var(standardized.X[,1])
var(standardized.X[,2])
test=1:1000
train.X=standardized.X[-test,]
test.X=standardized.X[test,]
train.Y=Purchase[-test]
test.Y=Purchase[test]
set.seed(1)
knn.pred=knn(train.X,test.X,train.Y,k=1)
mean(test.Y!=knn.pred)
mean(test.Y!="No")
table(knn.pred,test.Y)
9/(68+9)
knn.pred=knn(train.X,test.X,train.Y,k=3)
table(knn.pred,test.Y)
5/26
knn.pred=knn(train.X,test.X,train.Y,k=5)
table(knn.pred,test.Y)
4/15
glm.fit=glm(Purchase~.,data=Caravan,family=binomial,subset=-test)
glm.probs=predict(glm.fit,Caravan[test,],type="response")
glm.pred=rep("No",1000)
glm.pred[glm.probs>.5]="Yes"
table(glm.pred,test.Y)
glm.pred=rep("No",1000)
glm.pred[glm.probs>.25]="Yes"
table(glm.pred,test.Y)
11/(22+11)


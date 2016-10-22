# Chapter 3 Lab: Linear Regression
library(MASS)                         # 包含Boston数据集
library(ISLR)

# Simple Linear Regression
fix(Boston)
names(Boston)
lm.fit=lm(medv~lstat)                 # 报错，需要指明 data
lm.fit=lm(medv~lstat,data=Boston)
attach(Boston)                        # 绑定Boston数据.
lm.fit=lm(medv~lstat)                 # attach() 后，不再报错.
lm.fit
summary(lm.fit)                       # 可以看到系数(lstat Estimate),截距(Intercept Estimate), R2统计量, F统计量等
names(lm.fit)                         # 列出lm.fit中可以获取的参数名称.
lm.fit$coefficients                   # 获取系数
coef(lm.fit)                          # 获取系数.
confint(lm.fit)                       # 计算带置信区间线性回归模型. 默认 level = 0.95
confint(lm.tv, level=0.95)            # 计算系数, 指定置信区间 (1 - level) / 2,  这里是 2.5% - 97.5%
confint(lm.tv, level=0.9)             # 计算系数, 指定置信区间 5% - 95%
predict(lm.fit)                       # 计算线性回归模型的值，就是lstat对应的线性回归线上的值,也就是confint(lm.tv, level=0.95)edv值.
predict(lm.fit,data.frame(lstat=(c(5,10,15))), interval="confidence")   # 计算置信区间. 指定了 lstat 值.
predict(lm.fit,data.frame(lstat=(c(5,10,15))), interval="prediction")   # 计算预测区间. 指confint(lm.tv, level=0.95)定了 lstat 值.
# 置信区间与预测区间有相同的中心点，不过预测区间的范围要宽得多.

plot(lstat,medv)                            # 绘制点.
abline(lm.fit)                              # 绘制直线，参数是lm.fit,就绘制最小二乘回归线. 之前必须先调用 plot()
abline(lm.fit,lwd=3)                        # 回归线的宽度.
abline(lm.fit,lwd=3,col="red")              # 回归线的颜色
plot(lstat,medv,col="red")                  # 指定点的颜色.
plot(lstat,medv,pch=20)                     # 20 代表 实心黑点
plot(lstat,medv,pch="+")                    # + 号绘制点。默认是圆圈.
plot(1:20,1:20,pch=1:20)                    # 用不同符号(pch)绘制20个点.

par(mfrow=c(2,2))                           # 设置 2 * 2 个pannel. 可以同时显示4幅图.
plot(lm.fit)                                # 4幅诊断图, 如果没有上面的par()，将一幅一幅显示.
plot(predict(lm.fit), residuals(lm.fit))    # 计算线性回归拟合的残差.
plot(predict(lm.fit), rstudent(lm.fit))     # 计算线性回归的学生化残差.
plot(hatvalues(lm.fit))
which.max(hatvalues(lm.fit))

# Multiple Linear Regression

lm.fit=lm(medv~lstat+age,data=Boston)
summary(lm.fit)
lm.fit=lm(medv~.,data=Boston)              # Boston 数据集中除medv外所有的变量.
summary(lm.fit)
library(car)
vif(lm.fit)                                # 计算方差膨胀因子.
lm.fit1=lm(medv~.-age,data=Boston)         # Boston 数据集中除medv, age 外所有的变量.
summary(lm.fit1)
lm.fit1=update(lm.fit, ~.-age)             # 效果和 medv ~.-age 一样.

# Interaction Terms                        # 交互项

summary(lm(medv~lstat*age,data=Boston))

# Non-linear Transformations of the Predictors     # 预测变量的非线性变换.

lm.fit2=lm(medv~lstat+I(lstat^2))
summary(lm.fit2)
lm.fit=lm(medv~lstat)
anova(lm.fit,lm.fit2)
par(mfrow=c(2,2))
plot(lm.fit2)
lm.fit5=lm(medv~poly(lstat,5))
summary(lm.fit5)
summary(lm(medv~log(rm),data=Boston))

# Qualitative Predictors

fix(Carseats)
names(Carseats)
lm.fit=lm(Sales~.+Income:Advertising+Price:Age,data=Carseats)
summary(lm.fit)
attach(Carseats)
contrasts(ShelveLoc)

# Writing Functions

LoadLibraries
LoadLibraries()
LoadLibraries=function(){
 library(ISLR)
 library(MASS)
 print("The libraries have been loaded.")
 }
LoadLibraries
LoadLibraries()
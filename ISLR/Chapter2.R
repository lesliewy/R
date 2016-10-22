# Chapter 2
adv <- read.table("Advertising.csv", header=T, sep=',', col.names=c('num', 'tv', 'radio', 'newspaper', 'sales')) # 读取广告数据。

# 简单线性回归: 最小二乘回归.
lm.tv <- lm(sales ~ tv, data=adv)
lm.radio <- lm(sales ~ radio, data=adv)
lm.newspaper <- lm(sales ~ newspaper, data=adv)

confint(lm.tv, level = 0.9)   # 计算带置信区间的线性回归的系数.   置信区间是 (1-level)/2  -  1 - (1-level)/2
confint(lm.radio, level = 0.9) 
confint(lm.newspaper, level = 0.9) 

summary(lm.tv)
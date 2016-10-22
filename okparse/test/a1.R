x <- c(1600,1610,1650,1680,1700,1700,1780,1500,1640,
	 1400,1700,1750,1640,1550,1600,1620,1640,1600,
	 1740,1800,1510,1520,1530,1570,1640,1600)              #输入x
a <- factor(c(rep(1,7),rep(2,5),rep(3,8),rep(4,6)))   #输入因子
lamp <- data.frame(x=x,a=a)                          #弄成数据框
plot(x~a,data=lamp)                             #画个箱线图看看
lamp.aov <- aov(x ~a, data=lamp)                #做方差分析
result <- summary(lamp.aov)
print(result);

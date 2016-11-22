source("db.R")
industryHotResult <- industryHotResult();

#print(industryHotResult)    # 输出到终端.
#industryHotResult[, c("CHANGE_PCT", "INDEX_PCT")];                                 # 选择CHANGE_PCT 和 INDEX_PCT 两列数据.
#industryHotResult[industryHotResult$CHANGE_PCT > 6, c("CHANGE_PCT", "INDEX_PCT")]; # 选择 CHANGE_PCT >6 时的, CHANGE_PCT、INDEX_PCT 两列数据.

changePct = industryHotResult$CHANGE_PCT
# 用Q-Q图来检验mxPH是否为正态分布.
if(FALSE){
   library(car);   
   par(mfrow=c(1,2));   # 设置图形系统参数. mfrow 将图形输出窗口设置为1行2列的区域，可以得到两个并列的图形.
   
   hist(changePct, prob=T, xlab='', ylim=0:1, main='Histogram of change_pct value'); # 设置X轴标题为空, 提供Y轴合理的取值范围.
   lines(density(changePct, na.rm=T));     # 绘制平滑版本的直方图(变量分布的核密度估计), na.rm=T, 表示不考虑NA值. rug(jitter(changePct));     #  在直方图的x轴绘制数据真实值,可以直观观察到两个异常值，显著低于其他值. rug() 进行绘图，jitter()对要绘制的原始值进行随机排列, 避免两个值相等的可能性，
                                # 因而避免两个标记重合在一起而导致可视化检查时一些值被“掩盖”
   qq.plot(changePct, main='Normal QQ plot of CHANGE_PCT');  # 绘制 Q-Q 图, 它绘制变量值和正态分布的理论分数(黑色实线)的散点图。
        # 同时给出正态分布的95%置信区间的带状图(虚线). 图上有几个小点在虚线之外，它们不服从正态分布.
   par(mfrow=c(1,1));
}

boxplot(changePct, ylab = "Orthophosphate (CHANGE_PCT)");    # 绘制箱图. 箱图边界表示变量的第一个四分位数和第三个四分位数，框内的水平线
rug(jitter(changePct), side = 2);                      # side = 2 将实际值绘制在Y轴.
abline(h = mean(changePct, na.rm = T), lty = 2);       # 在变量的均值位置绘制一条水平线，lty=2表示虚线. 均值由mean()计算.
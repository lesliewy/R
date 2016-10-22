# TODO: Add comment
# 
# Author: leslie
###############################################################################

# 数据可视化和摘要

# 统计摘要. 对于名义变量, 给出每个可能取值的频数; 对于数值变量，给出均值、中位数、四分位数及极值等; NA's 表示缺失值的个数;
#summary(algae);

# 通过直方图发现 mxPH 非常符合正太分布，需要更进一步的检验。
# 绘制变量mxPH的直方图.  prob=T 给出每个取值区间的概率，如果没有，给出频数.
#hist(algae$mxPH, prob=T);

# 用Q-Q图来检验mxPH是否为正态分布.
#library(car);    # 包含qq.plot
#par(mfrow=c(1,2));   # 设置图形系统参数. mfrow 将图形输出窗口设置为1行2列的区域，可以得到两个并列的图形.
#hist(algae$mxPH, prob=T, xlab='', main='Histogram of maximum pH value', ylim=0:1); # 设置X轴标题为空, 提供Y轴合理的取值范围.
#lines(density(algae$mxPH, na.rm=T));     # 绘制平滑版本的直方图(变量分布的核密度估计), na.rm=T, 表示不考虑NA值.
#rug(jitter(algae$mxPH));     #  在直方图的x轴绘制数据真实值,可以直观观察到两个异常值，显著低于其他值. rug() 进行绘图，jitter()对要绘制的原始值进行随机排列, 避免两个值相等的可能性，
                             # 因而避免两个标记重合在一起而导致可视化检查时一些值被“掩盖”
#qq.plot(algae$mxPH, main='Normal QQ plot of maximum pH');  # 绘制 Q-Q 图, 它绘制变量值和正态分布的理论分数(黑色实线)的散点图。
     # 同时给出正态分布的95%置信区间的带状图(虚线). 图上有几个小点在虚线之外，它们不服从正态分布.
#par(mfrow=c(1,1));

# 另一个数据检查，使用箱图检查: 给出变量的中心趋势，给出变量的发散情况以及离群值.
# 通过oPO4的箱图可以看到，大部分水样的oPO4值比较低，因此分布为正偏(非正态分布)
#boxplot(algae$oPO4, ylab = "Orthophosphate (oPO4)");    # 绘制箱图. 箱图边界表示变量的第一个四分位数和第三个四分位数，框内的水平线
#   # 是变量的中位数. 设r是变量的四分位距, 箱图上方的小横线是 <= 第三个四分位数 + 1.5 * r, 箱图下方的小横线是 >= 第一个四分位数 - 1.5 * r
#   # 通常认为小横线以外的值都是离群值. 箱图不仅给出了变量的中心趋势，也给出了变量的发散情况和离群值.
#rug(jitter(algae$oPO4), side = 2);                      # side = 2 将实际值绘制在Y轴.
#abline(h = mean(algae$oPO4, na.rm = T), lty = 2);       # 在变量的均值位置绘制一条水平线，lty=2表示虚线. 均值由mean()计算.

# 图形方式确定有离群值的方法.
#plot(algae$NH4, xlab = "");    # 绘制变量的所有值.
#abline(h = mean(algae$NH4, na.rm = T), lty = 1);   # 均值.
#abline(h = mean(algae$NH4, na.rm = T) + sd(algae$NH4, na.rm = T), lty = 2);  # 均值 + 1个标准差.
#abline(h = median(algae$NH4, na.rm = T), lty = 3);  # 中位数
#identify(algae$NH4);              # 交互式，可以点击图形中的点, 显示该点在数据框中的行号，右击结束.

# 命令方式确定离群值
#algae[!is.na(algae$NH4) & algae$NH4 > 19000,];   # is.na() 判断是否为NA

# 条件绘图：分布依赖于其他变量。使用lattice箱图.
#library(lattice);  
#bwplot(size ~ a1, data=algae, ylab='River Size', xlab='Algal A1');   # 对变量size的每个值绘制a1.  可以发现在规模较小的河流中, 海藻a1的频率较高.

# 条件绘图之分位箱图: 给出更多信息.
#library(Hmisc);  # 没办法安装 Hmisc 包. 
#bwplot(size ~ a1, data=algae, panel=panel.bpplot, probs=seq(.01,.49,by=.01), datadensity=TRUE, ylab='River Size', xlab='Algal A1');   # 对变量size的每个值绘制a1.  可以发现在规模较小的河流中, 海藻a1的频率较高.





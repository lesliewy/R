# TODO: Add comment
# 
# Author: leslie
###############################################################################

# 每条记录由11个变量组成。前三个是名义变量：水样收集的季节，收集样品的河流的大小，河水的速度。
# 其他8个变量：最大PH值，最小含氧量(O2), 平均氯化物含量(cl), 平均硝酸盐含量(NO3), 平均氨含量(NH4), 平均正磷酸盐含量(oPO4),
#            平均磷酸盐含量(PO4), 平均叶绿素含量
# 还有7种不同有害藻类在相应水样中的频率数目.

# 本书中加载数据的两种方法
# 第一种方法: 载入DMwR包，就直接有了一个名为algae的数据框. 这个数据框包含200个观测值.
library(DMwR);
head(algae);   # 显示前6行
algae[1:3,];   # 显示前三行, 注意那个","
algae[1:3];    # 显示所有行的前3列
algae[1:3, 5]; # 显示前三行的第5列元素.


# 第二种方法: read.table
# algae <- read.table('Analysis.txt', header=F, dec='.', col.names=c('season', 'size', 'speed', 'mxPH', 'mnO2', 'Cl', 
#            'NO3', 'NH4', 'oPO4', 'PO4', 'Chla', 'a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7'), 
#            na.strings=c('XXXXXXX'));
# header=F: 第一行不包含变量名.   dec='.':  数值使用.分隔小数位.  col.names 给变量提供一个名称向量. 
#na.strings表示该字符串被解释为未知值, R内补用NA来表示.

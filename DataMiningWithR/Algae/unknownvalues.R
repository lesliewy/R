# TODO: Add comment
# 
# Author: leslie
###############################################################################

# 数据缺失.

# data(algae);   # 如果修改algae中的值，需要重新读取.

# 1. 剔除缺失值
#algae[!complete.cases(algae),];      # 显示包含NA值的行. complete.cases() 判断数据框的行中是否包含NA值. 不包含，返回 TRUE
#nrow(algae[!complete.cases(algae),]);  # 行数.
#algae <- na.omit(algae);             # 剔除包含NA值的所有行.
#algae <- algae[-c(62, 199),]         # 剔除掉指定行.
#apply(algae, 1, function(x) sum(is.na(x)));   # 统计数据框中每一行包含NA值的个数. 
#   # apply() 是元函数. 可以把一个函数应用到数据框的每一行.  is.na()判断是否是NA值. sum 将TRUE，FALSE 相加，在R中TRUE是1， FALSE是0.

# 2. 使用最高频率值来填补缺失值.
# 使用代表中心趋势的值来填补：平均值、中位数、众数等.
# 正态分布一般使用平均值; 偏态分布或者有离群值的变量一般使用中位数;
#algae[48, "mxPH"] <- mean(algae$mxPH, na.rm = T);   # mxPH近似正态分布，使用平均值替换掉第48行中的mxPH变量.
#algae[is.na(algae$Chla), "Chla"] <- median(algae$Chla, na.rm = T);   # Chla是偏态分布，分布偏向于较低的值，使用中位数来替换掉缺失值.

# 3. 通过变量的相关关系来填补缺失值.
#cor(algae[, 4:18], use = "complete.obs");  # 输出变量间的相关值矩阵. use = "complet.obs" 会忽略所有包含NA的记录. 相关值在 1(或-1)
#   # 周围表示相应的两个变量之间有强正(或负)线性相关关系.
#symnum(cor(algae[, 4:18], use = "complete.obs"));   #  改善后的相关矩阵. 下面部分是符号代表的值，越高相关性越大. 可以发现 NH4 和 NO3 之间，PO4 和 oPO4之间具有相关性，
#   # NH4 和 NO3之间的不是特别明显(0.72). 而PO4 和 oPO4 之间的相关性很高(大于0.9), 可以据此找出函数关系.
#   symnum 中的值可能不准确，准确的值看cor()中的.

# 已发现 PO4 和 oPO4高度相关(大于0.9)，所以要找出其线性关系. 使用lm找出 PO4 和 oPO4之间的关系.
#data(algae);
#algae <- algae[-manyNAs(algae),];   # 去掉含有给定数目NA值的行.
#lm(PO4 ~ oPO4, data = algae);       # lm()可以用来获取 Y = A0 + A1X1 + A2X2 + ... +ANXN的线性模型, 根据输出结果，PO4 和 oPO4
#   # 的线性模型是 PO4 = 42.897 + 1.293 ＊ oPO4
#  所以只要知道其中一个，可以根据此关系计算另一个.

# 构造函数，根据 oPO4的值计算PO4的值.
#data(algae)
#algae <- algae[-manyNAs(algae),]
#fillPO4 <- function(oP) {
#   if (is.na(oP)) return(NA)
#   else return(42.897 + 1.293 * oP)
#}
#algae[is.na(algae$PO4),'PO4'] <- sapply(algae[is.na(algae$PO4),'oPO4'],fillPO4) # 填补变量 PO4缺失值的向量. oPO4作为 fillPO4的参数.

# 变量和名义变量之间的关系来填补缺失值.
#histogram(~mxPH | season, data = algae); # 在变量season条件下的变量mxPH的直方图.
   # 发现每个季节图形相似，说明季节堆mxPH值没有显著影响.
   # histogram 是lattice包中的，hist 是graphics包中的.
#algae$season <- factor(algae$season, levels = c("spring", "summer", "autumn", "winter"));  # 转换数据框中因子季节标签的顺序,
#   # 这样可以使直方图中的季节值为自然时间顺序. 默认情况下，把名义变量转换为因子时，按照字母顺序排列.
#histogram(~mxPH | size, data = algae);
#histogram(~mxPH | size * speed, data = algae);  # 河流大小和速度的所有组合的mxPH值的变化.
#stripplot(size ~ mxPH | speed, data = algae, jitter = T);  # 另一种方式展示全组合的情况，使用的是具体值.
   # stripplot 展示具体值，比histogram更清楚些.

# 4. 通过探索案例之间的相似性来填补缺失值.
# 两个案例之间的距离计算，找到与有缺失值的案例最近距离的10个案例。然后，第一种方法，使用这10个案例中变量的中位数来填充；第二种方法, 采用这些最
# 相似数据的加权平均值。权重大小随着距离的增大而减小。
# algae <- knnImputation(algae, k = 10);  # 加权平均值填补
# algae <- knnImputation(algae, k = 10, meth = "median");   # 中位数填补


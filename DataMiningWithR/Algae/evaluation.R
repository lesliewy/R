# TODO: Add comment
# 
# Author: leslie
###############################################################################

# 模型的评价和选择.

# 多种标准来评价模型，其中最流行的是计算模型的预测性能: 通过将目标变量的预测值和实际值进行比较.
# 一种度量方法是平均绝对误差(MAE).
#lm.predictions.a1 <- predict(final.lm, clean.algae);
#rt.predictions.a1 <- predict(rt.a1, algae);           # 获得两个模型的预测值.
#
#(mae.a1.lm <- mean(abs(lm.predictions.a1 - algae[, "a1"])))
#(mae.a1.rt <- mean(abs(rt.predictions.a1 - algae[, "a1"])))    # 计算平均绝对误差.
# 标准化后的平均绝对误差(NMSE)来判断模型的MAE得分的好坏, 计算模型预测性能和基准模型的预测性能之间的比率. 通常采用目标变量的平均值来作为基准.
# NMSE的取值为0-1， 越小越好，大于1，意味着还不如简单的把所有个案的平均值作为预测值.
#(nmse.a1.lm <- mean((lm.predictions.a1 - algae[, 'a1'])^2) / mean((mean(algae[, 'a1']) - algae[, 'a1'])^2))
#(nmse.a1.rt <- mean((rt.predictions.a1 - algae[, 'a1'])^2) / mean((mean(algae[, 'a1']) - algae[, 'a1'])^2))

# 可视化地查看模型的预测值.
#old.par <- par(mfrow=c(1,2))
#plot(lm.predictions.a1,algae[,'a1'],main="Linear Model",
#      xlab="Predictions",ylab="True Values")
#abline(0,1,lty=2)    # 穿过原点，代表x坐标和y坐标相等的点集. 如果预测值和真实值相等，将落在该线上.
#plot(rt.predictions.a1,algae[,'a1'],main="Regression Tree",
#      xlab="Predictions",ylab="True Values")
#abline(0,1,lty=2)
#par(old.par)

# 可交互的可视化, 查看值在数据框中的行.
plot(lm.predictions.a1,algae[,'a1'],main="Linear Model",
      xlab="Predictions",ylab="True Values")
abline(0,1,lty=2)
algae[identify(lm.predictions.a1,algae[,'a1']),]



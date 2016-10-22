# TODO: Add comment
# 
# Author: leslie
###############################################################################

# 4. 预测模型.
# 建模工具
# a, 人工神经网络(ANN): 经常在金融预测中使用，因为它可以处理高度非线性问题。
# a1, 用神经网络处理回归问题.
set.seed(1234)    # nnet()以在区间[-0.5, 0.5]之间的随机值来设置结点之间链接的初始权重，所以两次连续运行相同参数的输入，得到的结果可能不一致。
   # 通过设置种子值，来保证和本书的结果一致.
library(nnet)     # nnet 包实现了前馈神经网络，这种神经网络是最常用的.
norm.data <- scale(Tdata.train)   # 因为人工神经网络对预测问题中变量的尺度非常敏感，为了避免受变量尺度的影响，先进行数据的标准化处理，使所有变量
   # 均具有零均值和标准差为1.
nn <- nnet(Tform,norm.data[1:1000,],size=10,decay=0.01,maxit=1000,linout=T,trace=F)   # Tform 是模型的函数形式；norm.data是训练集
   # 数据，用于建立模型；size 来指定隐藏层中结点个数; decay控制反向传播算法权重的更新率; maxit 控制权重收敛过程中所允许使用的最大迭代次数;
   # linout = T 告诉函数处理的是回归问题; trace = F 避免一些和优化过程有关的结果被输出。
norm.preds <- predict(nn,norm.data[1001:2000,]) # 获得测试数据集的神经网络预测值.
preds <- unscale(norm.preds,norm.data) # 在本书包DMwR中，将标准化数据转换为原来尺度的数据。

# 评估人工神经网络模型预测测试集信号的准确性
sigs.nn <- trading.signals(preds,0.1,-0.1)   # 给出买入和卖出信号的临界值，将预测数值转换成信号.
true.sigs <- trading.signals(Tdata.train[1001:2000,'T.ind.GSPC'],0.1,-0.1)
sigs.PR(sigs.nn,true.sigs)  # 基于事件的预测任务通常由决策精确度指标和回溯精确度指标来衡量。决策精确度衡量模型给出的事件信号的正确百分比，
   # 回溯精确度值模型给出的事件信号占事实存在的百分比.   预测精确度(precision)较小说明意味着该模型频繁给出错误信号.

# a2,用神经网络处理分类问题.
set.seed(1234)
library(nnet)
signals <- trading.signals(Tdata.train[,'T.ind.GSPC'],0.1,-0.1)
norm.data <- data.frame(signals=signals,scale(Tdata.train[,-1]))
nn <- nnet(signals ~ .,norm.data[1:1000,],size=10,decay=0.01,maxit=1000,trace=F)
preds <- predict(nn,norm.data[1001:2000,],type='class')  # type='class' 用于获得测试集个案的类标签，而不是概率的估计值.

sigs.PR(preds,norm.data[1001:2000,1])

# b, 支持向量机(SVM)
# b1, 用支持向量机处理回归问题.
library(e1071)   # 包含支持向量机函数 svm()
sv <- svm(Tform,Tdata.train[1:1000,],gamma=0.001,cost=100)
s.preds <- predict(sv,Tdata.train[1001:2000,])
sigs.svm <- trading.signals(s.preds,0.1,-0.1)
true.sigs <- trading.signals(Tdata.train[1001:2000,'T.ind.GSPC'],0.1,-0.1)
sigs.PR(sigs.svm,true.sigs)

# b2, 用支持向量机处理分类问题. 
library(kernlab)  # 这次使用 kernlab 包.
data <- cbind(signals=signals,Tdata.train[,-1])
ksv <- ksvm(signals ~ .,data[1:1000,],C=10)     # C 用来指定违反约束的不同损失。其他参数都使用默认值，例如，分类时的默认参数是径向基核函数.
ks.preds <- predict(ksv,data[1001:2000,])
sigs.PR(ks.preds,data[1001:2000,1])

# c, 多元自适应回归样条(MARS)
# MARS 只适用于回归问题.
library(earth)
e <- earth(Tform,Tdata.train[1:1000,])
e.preds <- predict(e,Tdata.train[1001:2000,])
sigs.e <- trading.signals(e.preds,0.1,-0.1)
true.sigs <- trading.signals(Tdata.train[1001:2000,'T.ind.GSPC'],0.1,-0.1)
sigs.PR(sigs.e,true.sigs)




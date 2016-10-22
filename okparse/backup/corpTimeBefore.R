initMysql();

#timeInterval <- c("0.0", "0.10", "0.20", "0.30", "0.40", "0.50", "0.60", "1.10", "1.20", "1.30", "1.40", "1.50", "1.60", "2.10", "2.20", "2.30", "2.40", "2.50", "2.60");
#timeInterval <- c("0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "0.10");
timeInterval <- c("0.0", "0.60", "1.60", "2.60", "3.60", "4.60", "5.60", "6.60", "7.60", "8.60", "9.60", "10.60", "11.60");
timeIntervalm <- timeInterval[2:length(timeInterval)];
print(timeIntervalm);

#corpName <- "澳门彩票";
corpName <- "威廉.希尔";
#corpName <- "立博";
#corpName <- "博天堂";
#corpName <- "金宝博(188bet)";
result <- corpTimeBefore(timeInterval,corpName);

#for(i in 1:length(timeIntervalm)){
#      print(paste(timeInterval[i], "-", timeInterval[i+1], ": ", result[i]));
#}

# 绘图
col1 <- 2;
col2 <- 4;
col3 <- 5;
typeAll <- "b";
pchAll <- 16;

plot(timeIntervalm, result, type=typeAll, main=paste("time before match", corpName), xlab="time", ylab="times", col=col1, lab=c(20,20,10), pch=pchAll);

# 添加图例
legend("topright",c("次数"), pch=c("o"), col=c(col1), cex=1);


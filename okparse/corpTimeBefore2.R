initMysql();

#corpNames <- c("99家平均", "澳门彩票");
corpNames <- c("99家平均", "澳门彩票", "威廉.希尔", "立博", "博天堂", "Interwetten", "金宝博(188bet)", "12bet.com");

#matchNames <- c("英超", "英甲", "英联杯");
matchNames <- c("英超", "英甲", "英联杯", "英冠", "西甲", "西乙", "葡超", "意甲", "意乙", "德甲", "德乙", "法甲", "法乙", "荷甲", "挪甲", "美职", "J联赛", "欧洲杯", "欧冠", "世界杯");

corpTimeBefore2(corpNames, matchNames);

#for(i in 1:length(timeIntervalm)){
#      print(paste(timeInterval[i], "-", timeInterval[i+1], ": ", result[i]));
#}

# 绘图
col1 <- 2;
col2 <- 4;
col3 <- 5;
typeAll <- "b";
pchAll <- 16;

#plot(timeIntervalm, result, type=typeAll, main=paste("time before match", corpName), xlab="time", ylab="times", col=col1, lab=c(20,20,10), pch=pchAll);

# 添加图例
#legend("topright",c("次数"), pch=c("o"), col=c(col1), cex=1);


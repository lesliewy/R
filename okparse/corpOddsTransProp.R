initMysql();

#corpName <- "威廉.希尔";
#corpName <- "立博";
#corpName <- "澳门彩票";
#corpName <- "博天堂";
#corpName <- "金宝博(188bet)";
#corpName <- "99家平均";
#corpName <- "Interwetten";
#corpName <- "12bet.com";

#corpName <- "必发";
#corpName <- "SNAI";
#corpName <- "betcity";
#corpName <- "Coral";
#corpName <- "Oddset";
#corpName <- "Iceland";
#corpName <- "PMU";
#corpName <- "Islenskar Getraunir";
#corpName <- "Iceland";
corpName <- "Inteltek";

matchNames <- c("英甲", "英超", "欧冠", "世界杯", "德甲", "法甲", "意甲", "西甲", "俄超");

resultFlag <- "win";
#resultFlag <- "even";
#resultFlag <- "nega";

corpOddsTransProp(corpName, matchNames, resultFlag);
#print(paste("timeBefore: ", result$timeBefore));
#print(paste("hostOdds: ", result$hostOdds)); 
#print(paste("evenOdds: ", result$evenOdds)); 
#print(paste("visitingOdds: ", result$visitingOdds)); 
# 绘图
#col1 <- 2;
#col2 <- 4;
#col3 <- 5;
#typeAll <- "b";
#pchAll <- 16;
#
#pdf(paste(corpName, "_", okMatchId, ".pdf"));
#plot(result$timeBefore, result$hostOdds, type=typeAll, main=paste("euro odds change:", corpName), xlab="TIME", ylab="ODDS", col=col1, lab=c(20,40,10), pch=pchAll);
# 可能需要在 plot() 中指定 ylim, 否则有可能看不到 even visiting 的线条;
#lines(result$timeBefore, result$evenOdds, type=typeAll, col=col2, pch=pchAll);
#lines(result$timeBefore, result$visitingOdds, type=typeAll, col=col3, pch=pchAll);

# 添加图例
#legend("topright",c("Host", "Even", "Visiting"), pch=c("o","o","o"), col=c(col1, col2, col3), cex=1);
#dev.off();


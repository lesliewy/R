initMysql();

allOdds <- seq(from=1.00, to=5.00, by=0.1);
allOddsm <- c(allOdds[2:length(allOdds)]);
print(allOddsm);

#corpNames <- c("威廉.希尔");
corpNames <- c("威廉.希尔", "立博", "Interwetten");
#corpNames <- c("威廉.希尔", "澳门彩票", "博天堂");
#corpNames <- c("威廉.希尔", "12bet.com", "金宝博(188bet)");

resultFlag <- "win";
#resultFlag <- "even";
#resultFlag <- "nega";

#leagueName <- "";
#leagueName <- "英超";
#leagueName <- "意甲";
leagueName <- "西甲";
result <- corpsOddsCompare(allOdds,corpNames,resultFlag, leagueName);
print(result);

# 绘图
col1 <- 2;
col2 <- 4;
col3 <- 5;
typeAll <- "b";
pchAll <- 16;
plot(allOddsm, result[,2], type=typeAll, main=corpNames, sub=resultFlag, xlab="odds", ylab="probability", col=col1, lab=c(50,20,10), xlim=c(1,5),ylim=c(0,1.0), pch=pchAll);
lines(allOddsm, result[,3], type=typeAll, col=col2, pch=pchAll);
lines(allOddsm, result[,4], type=typeAll, col=col3, pch=pchAll);

# 添加图例
legend("topright",corpNames, pch=c("o","o", "o"), col=c(col1, col2, col3), cex=1);


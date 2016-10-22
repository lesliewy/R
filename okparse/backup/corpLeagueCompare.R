initMysql();

allOdds <- seq(from=1.00, to=5.00, by=0.1);
allOddsm <- c(allOdds[2:length(allOdds)]);

#corpName <- "威廉.希尔";
corpName <- "立博";

resultFlag <- "win";

leagueNames <- c("英超", "意甲", "西甲");
result <- corpLeagueCompare(allOdds,corpName, resultFlag, leagueNames);
print(result);

# 绘图
col1 <- 2;
col2 <- 4;
col3 <- 5;
typeAll <- "b";
pchAll <- 16;
plot(result[, 1], result[, 2], type=typeAll, main=paste(corpName, leagueNames), xlab="odds", ylab="probability", col=col1, lab=c(50,20,10), xlim=c(1,5),ylim=c(0,1.0), pch=pchAll);
lines(result[, 1], result[, 3], type=typeAll, col=col2, pch=pchAll);
lines(result[, 1], result[, 4], type=typeAll, col=col3, pch=pchAll);

# 添加图例
legend("topright",c(leagueNames[1],leagueNames[2],leagueNames[3]), pch=c("o","o","o"), col=c(col1, col2, col3), cex=1);


initMysql();

allOdds <- seq(from=1.00, to=3.00, by=0.1);
allOddsm <- c(allOdds[2:length(allOdds)]);
print(allOddsm);

corpName <- "威廉.希尔";
result <- corpOddsAllResult(allOdds,corpName);
print(result);

# 绘图
colWin <- 2;
colEven <- 4;
colNega <- 5;
typeAll <- "b";
pchAll <- 16;
plot(allOddsm, result$win, type=typeAll, main=corpName, xlab="odds", ylab="probability", col=colWin, lab=c(50,20,10), xlim=c(1,5),ylim=c(0,1.0), pch=pchAll);
#axis(side=1,at=c(1.1,1.2,2.1),labels=c("a","b","c"));
lines(allOddsm, result$even, type=typeAll, col=colEven, pch=pchAll);
lines(allOddsm, result$nega, type=typeAll, col=colNega, pch=pchAll);

# do.call() 将list 转为vector
#lines(density(do.call(c,resultWin)), col=2);

# 添加图例
legend("topright",c("胜","平","负"), pch=c("o","o","o"), col=c(colWin, colEven, colNega), cex=1);


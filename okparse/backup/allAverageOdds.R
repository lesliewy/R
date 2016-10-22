initMysql();

allOdds <- seq(from=1.00, to=5.00, by=0.1);
allOddsm <- c(allOdds[2:length(allOdds)]);
print(allOddsm);

resultWin <- allAverageOdds(allOdds,"win");
resultEven <- allAverageOdds(allOdds,"even");
resultNega <- allAverageOdds(allOdds,"nega");
print(resultEven);

# 绘图
colWin <- 2;
colEven <- 4;
colNega <- 5;
typeAll <- "b";
pchAll <- 16;
plot(allOddsm, resultWin, type=typeAll, main="all average", xlab="odds", ylab="probability", col=colWin, lab=c(50,20,10), xlim=c(1,5),ylim=c(0,1.0), pch=pchAll);
#axis(side=1,at=c(1.1,1.2,2.1),labels=c("a","b","c"));
lines(allOddsm, resultEven, type=typeAll, col=colEven, pch=pchAll);
lines(allOddsm, resultNega, type=typeAll, col=colNega, pch=pchAll);

# do.call() 将list 转为vector
#lines(density(do.call(c,resultWin)), col=2);

# 添加图例
legend("topright",c("胜","平","负"), pch=c("o","o","o"), col=c(colWin, colEven, colNega), cex=1);


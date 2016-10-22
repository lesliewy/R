#select a.OK_URL_DATE, a.MATCH_SEQ, a.OK_MATCH_ID, a.MATCH_NAME, a.HOST_GOALS, a.VISITING_GOALS from LOT_MATCH a, (select OK_MATCH_ID from LOT_ODDS_EURO_CHANGE where ODDS_CORP_NAME='澳门彩票' and ODDS_TIME > '2014-07-01 01:00:00' group by          OK_MATCH_ID having count(*) < 10 and count(*) > 3) b, LOT_ODDS_EURO c where a.OK_MATCH_ID=b.OK_MATCH_ID and a.OK_MATCH_ID=c.OK_MATCH_ID and c.ODDS_CORP_NAME='澳门彩票' and c.HOST_ODDS < c.VISITING_ODDS
# 查询某个公司赔率变化情况, 只查询变化次数少于10的, 并生成pdf文件.
euroOddsChangeQuery1 <- function(oddsCorpName, resultFlag){
    begin <- Sys.time();
    conn <- getConn();
    if(resultFlag == "win"){
       resultFlagQuery = "HOST_GOALS > VISITING_GOALS";
    }
    if(resultFlag == "even"){
       resultFlagQuery = "HOST_GOALS = VISITING_GOALS";
    }
    if(resultFlag == "nega"){
        resultFlagQuery = "HOST_GOALS < VISITING_GOALS";
    }

    baseSql <- paste("select a.OK_URL_DATE, a.MATCH_SEQ, a.OK_MATCH_ID, a.MATCH_NAME, a.HOST_GOALS, a.VISITING_GOALS, a.HOST_TEAM_NAME, a.VISITING_TEAM_NAME, c.INIT_HOST_ODDS, c.HOST_ODDS from LOT_MATCH a, (select            OK_MATCH_ID from LOT_ODDS_EURO_CHANGE where ODDS_CORP_NAME=\'", oddsCorpName, "\' and ODDS_TIME > '2014-07-01 01:00:00' group by                 OK_MATCH_ID having count(*) < 10 and count(*) > 0) b, LOT_ODDS_EURO c where a.OK_MATCH_ID=b.OK_MATCH_ID and a.OK_MATCH_ID=c.         OK_MATCH_ID and c.ODDS_CORP_NAME=\'", oddsCorpName, "\' and c.HOST_ODDS < c.VISITING_ODDS", " and ", resultFlagQuery, sep="");
    dbResult <- dbGetQuery(conn, baseSql);
    if(length(dbResult) <= 0){
        print("no values... ");
        return();   
    }
    okUrlDates <- dbResult[[1]];
    matchSeqs <- dbResult[[2]];
    okMatchIds <- dbResult[[3]];
    matchNames <- dbResult[[4]];
    hostGoals <- dbResult[[5]];
    visitingGoals <- dbResult[[6]];
    hostTeamName <- dbResult[[7]];
    visitingTeamName <- dbResult[[8]];
    initHostOdds <- dbResult[[9]];
    hostOdds <- dbResult[[10]];

#    library(Cairo)  
#    CairoPDF("pentagram.pdf");  
#    par(family = "simsun")  

    # 设置目录, 存在的话会先删除
    dirPath <- paste("/home/leslie/MyProject/OkParse/charts/euroOddsChange_odds/", oddsCorpName, "_", resultFlag, sep="");
    print(dirPath);
    if(!file.exists(dirPath)){
       dir.create(dirPath);
    }else{
       unlink(dirPath, recursive=TRUE); 
       dir.create(dirPath);
    }

    # 遍历所有的记录;
    for(i in 1:length(okUrlDates)){
        result <- euroOddsChange1(oddsCorpName, okMatchIds[i]); 
        # 查询 LOT_TRANS_PROP;
        transPropSql <- paste("select HOST_BF from LOT_TRANS_PROP where id=", okMatchIds[i], sep="");
	hostBf <- dbGetQuery(conn, transPropSql);
        if(length(hostBf) == 0){
            hostBf = 0;
	}
        # 绘图
        col1 <- 2;
        col2 <- 4;
        col3 <- 5;
        typeAll <- "b";
        pchAll <- 16;

	# pdf 文件里无法显示中文的问题.
        pdf(file=paste(dirPath, "/", matchNames[i], "_", okUrlDates[i], "_", matchSeqs[i], "_", okMatchIds[i], "_",  hostOdds[i], "_", initHostOdds[i], "_", hostBf, "_", hostGoals[i], ":", visitingGoals[i], ".pdf", sep=""));
        plot(result$timeBefore, result$hostOdds, type=typeAll, main=paste("Euro Odds Change: ", hostTeamName[i], " ", hostGoals[i], "-", visitingGoals[i], " ", visitingTeamName[i], sep=""), xlab="TIME", ylab="ODDS", col=col1, lab=c(20,20,10), pch=pchAll);
        
        legend("topright",c("Host", "Even", "Visiting"), pch=c("o","o","o"), col=c(col1, col2, col3), cex=1);
        dev.off();
    }
    closeConn(conn);
    end <- Sys.time();
    print(paste("eclipsed time: ", (end - begin), " s."));
}

# select ODDS_CORP_NAME from LOT_ODDS_EURO_CHANGE where OK_MATCH_ID=677927 group by ODDS_CORP_NAME having count(*) < 10;
# 指定 ok_match_id, 生成赔率变化小于10的公司的赔率变化图.
euroOddsChangeQuery2 <- function(okMatchId){
    conn <- getConn();

    baseSql <- paste("select ODDS_CORP_NAME from LOT_ODDS_EURO_CHANGE where OK_MATCH_ID=", okMatchId, " group by ODDS_CORP_NAME having count(*) < 10", sep = "");
    dbResult <- dbGetQuery(conn, baseSql);
    oddsCorpNames <- dbResult[[1]];
    
    matchSql <- paste("select HOST_GOALS, VISITING_GOALS, MATCH_NAME from LOT_MATCH where OK_MATCH_ID=", okMatchId, sep="");
    matchResult <- dbGetQuery(conn, matchSql);
    hostGoals <- matchResult[[1]];
    visitingGoals <- matchResult[[2]];
    matchName <- matchResult[[3]];
    # 查询 LOT_TRANS_PROP;
    transPropSql <- paste("select HOST_BF from LOT_TRANS_PROP where id=", okMatchId, sep="");
    hostBf <- dbGetQuery(conn, transPropSql);
    if(length(hostBf) == 0){
        hostBf = 0;
    }

    if(hostGoals[1] > visitingGoals[1]){
        resultFlag = "win";
    }
    if(hostGoals[1] == visitingGoals[1]){
        resultFlag = "even";
    }
    if(hostGoals[1] < visitingGoals[1]){
        resultFlag = "nega";
    }
    dirPath = paste("/home/leslie/MyProject/OkParse/charts/euroOddsChange_match/", matchName, "_",  okMatchId, "_", hostBf, "_", resultFlag, sep = "");
    if(!file.exists(dirPath)){
       dir.create(dirPath);
    }else{
       unlink(dirPath, recursive=TRUE); 
       dir.create(dirPath);
    }
    print(dirPath);
    for(i in 1:length(oddsCorpNames)){
        result <- euroOddsChange1(oddsCorpNames[i], okMatchId); 
        oddsCorpNameSql <- paste(" ODDS_CORP_NAME=\'", oddsCorpNames[i], "\'", sep="");
        euroOddsSql <- paste("select HOST_ODDS, INIT_HOST_ODDS from LOT_ODDS_EURO where OK_MATCH_ID=", okMatchId, " and ", oddsCorpNameSql, sep = "");
        euroOddsResult <- dbGetQuery(conn, euroOddsSql);
        hostOdds <- euroOddsResult[[1]];
        initHostOdds <- euroOddsResult[[2]];

        # 绘图
        col1 <- 2;
        col2 <- 4;
        col3 <- 5;
        typeAll <- "b";
        pchAll <- 16;
        pdf(file=paste(dirPath, "/",oddsCorpNames[i], "_", hostOdds[1], "_", initHostOdds[1], ".pdf", sep=""));
        plot(result$timeBefore, result$hostOdds, type=typeAll, main=paste("Euro Odds Change"), xlab="TIME", ylab="ODDS", col=col1, lab=c(20,20,10), pch=pchAll);
        legend("topright",c("Host", "Even", "Visiting"), pch=c("o","o","o"), col=c(col1, col2, col3), cex=1);
        dev.off();
    }
    closeConn(conn);
}

# 查询某个公司某场比赛的赔率, 返回data frame.
euroOddsChange1 <- function(oddsCorpName, okMatchId){
    conn <- getConn();
    baseSql <- "select * from LOT_ODDS_EURO_CHANGE where ";
    orderSql <- " order by ODDS_SEQ desc";
    oddsCorpNameSql <- paste(" ODDS_CORP_NAME=\'", oddsCorpName, "\'", sep="");
    okMatchIdSql <- paste(" OK_MATCH_ID=", okMatchId," ", sep="");
    sql <- paste(baseSql, oddsCorpNameSql, " and ", okMatchIdSql, orderSql);
    dbResult <- dbGetQuery(conn, sql);
    result <- data.frame(id=dbResult[[1]]);
    result$seq <- dbResult[[4]];
    # 处理timeBeforeMatch
    timeBeforeOld <- dbResult[[6]];
    timeBeforeNew <- c();
    for(i in 1:length(timeBeforeOld)){
        primaryPart <- strsplit(timeBeforeOld[i], split="\\.")[[1]][1]
        decimalPart <- strsplit(timeBeforeOld[i], split="\\.")[[1]][2]
        if(nchar(decimalPart)==1){
           timeBeforeNew[i] <- paste(primaryPart, ".", "0", decimalPart, sep=""); 
	}else{
           timeBeforeNew[i] <- timeBeforeOld[i];
	}
    }	
    result$timeBefore <- timeBeforeNew;
    result$hostOdds <- dbResult[[7]];
    result$evenOdds <- dbResult[[8]];
    result$visitingOdds <- dbResult[[9]];
    closeConn(conn);
    return(result);
}


# select c.OK_URL_DATE, c.MATCH_SEQ, a.OK_MATCH_ID, a.HOST_ODDS, b.HOST_BF from LOT_ODDS_EURO a, LOT_TRANS_PROP b, LOT_MATCH c where a.OK_MATCH_ID=b.ID and a.OK_MATCH_ID=c.OK_MATCH_ID and b.HOST_BF is not null and a.ODDS_CORP_NAME='澳门彩票' and c.MATCH_NAME in('英甲','英超') and c.HOST_GOALS > c.VISITING_GOALS order by a.HOST_ODDS
# 某个公司的赔率与必发交易量比例的关系.
corpOddsTransProp <- function(oddsCorpName, matchNames, resultFlag){
    conn <- getConn();

    if(resultFlag == "win"){
       resultFlagQuery = "c.HOST_GOALS > c.VISITING_GOALS";
    }
    if(resultFlag == "even"){
       resultFlagQuery = "c.HOST_GOALS = c.VISITING_GOALS";
    }
    if(resultFlag == "nega"){
        resultFlagQuery = "c.HOST_GOALS < c.VISITING_GOALS";
    }
    baseSql <-paste("select a.OK_MATCH_ID, c.OK_URL_DATE, c.MATCH_SEQ, a.OK_MATCH_ID, a.HOST_ODDS, b.HOST_BF from LOT_ODDS_EURO a, LOT_TRANS_PROP b, LOT_MATCH c where a.OK_MATCH_ID=b.ID and a.OK_MATCH_ID=c.OK_MATCH_ID and b.HOST_BF is not null and a.ODDS_CORP_NAME=\'",oddsCorpName,"\'  and ", resultFlagQuery, " and c.MATCH_TIME > \'2013-03-01 10:00:00\' ", sep=""); 
    orderBySql <- " order by a.HOST_ODDS ";
    matchNameSql <- " c.MATCH_NAME in (\'aaa\'";
    for(i in 1:length(matchNames)){
        matchNameSql <- paste(matchNameSql, ", \'", matchNames[i], "\'", sep="");
    }
    matchNameSql <- paste(matchNameSql, " ) ");

    sql <- paste(baseSql, " and ", matchNameSql, orderBySql, sep="");
    print(paste("sql: ", sql, sep=""));
    dbResult <- dbGetQuery(conn, sql);
    result <- data.frame(id=dbResult[[1]]);
    result$okUrlDate <- dbResult[[2]];
    result$matchSeq <- dbResult[[3]];
    result$okMatchId <- dbResult[[4]];
    result$hostOdds <- dbResult[[5]];
    result$hostBf <- dbResult[[6]];
    closeConn(conn);

    rangeOdds <- c();
    lowOdds <- 1.0;
    highOdds <- lowOdds + 0.05;
    rangeIndex <- 0;
    rangeId <- c();
    rangeMin <- c();
    rangeMax <- c();
    rangeCount <- c();
    rangeMean <- c();
    rangeVar <- c();
    rangeSd <- c();
    i <- 1;
    while(i < length(result$id)){
        if(result$hostOdds[i] >= lowOdds && result$hostOdds[i] < highOdds){
            rangeOdds <- c(rangeOdds, result$hostBf[i]);
	}else{
	    if(length(rangeOdds > 0)){
#		print(rangeOdds);
		rangeOddsSorted <- sort(rangeOdds);
	        lengthSorted <- length(rangeOddsSorted);
		# 如果数量大于5，去掉一个最大的, 一个最小的.
		if(lengthSorted > 5){
                    rangeOddsSorted <- c(rangeOddsSorted[2:(lengthSorted - 1)]);
		}
                rangeId <- c(rangeId, paste(lowOdds, "-", highOdds));  
	        rangeMin <- c(rangeMin, min(rangeOddsSorted));
	        rangeMax <- c(rangeMax, max(rangeOddsSorted));
		rangeCount <- c(rangeCount, lengthSorted);
	        rangeMean <- c(rangeMean, mean(rangeOddsSorted));
	        rangeVar <- c(rangeVar, var(rangeOddsSorted));
	        rangeSd <- c(rangeSd, sd(rangeOddsSorted));
	    }

	    # 不能漏掉;
	    i <- i - 1;
            rangeOdds <- c();
	    # 浮点数计算要小心出现 3.699999999999 的情况.
	    lowOdds <- round(lowOdds + 0.05, 2);
            highOdds <- round(lowOdds + 0.05, 2);
	}
        i <- i + 1;
    }
    rangeResult <- data.frame(id=rangeId);
    rangeResult$min <- rangeMin;
    rangeResult$max <- rangeMax;
    rangeResult$count <- rangeCount;
    rangeResult$mean <- rangeMean;
    rangeResult$var <- rangeVar;
    rangeResult$sd <- rangeSd;

    print(rangeResult);
}

# select count(*) from LOT_ODDS_EURO_CHANGE a, LOT_MATCH b, LOT_ODDS_EURO c where a.OK_MATCH_ID=b.OK_MATCH_ID and a.OK_MATCH_ID=c.OK_MATCH_ID and a.ODDS_CORP_NAME=c.ODDS_CORP_NAME and c.ODDS_CORP_NAME in('Gobetgo', '5Dimes', 'Betfred', 'Wettbuero') and a.ODDS_SEQ=2  and b.MATCH_NAME='西甲' and a.HOST_KELLY <= c.LOSS_RATIO and b.HOST_GOALS > b.VISITING_GOALS
corpKellyMatchName <- function(oddsCorpName, matchName){
    conn <- getConn();
#    baseSql <- paste("select b.HOST_GOALS, b.VISITING_GOALS from LOT_ODDS_EURO_CHANGE a, LOT_MATCH b, LOT_ODDS_EURO c where a.OK_MATCH_ID=b.OK_MATCH_ID and a.                 OK_MATCH_ID=c.OK_MATCH_ID and a.ODDS_CORP_NAME=c.ODDS_CORP_NAME and a.ODDS_SEQ=2  and b.MATCH_NAME=\'", matchName, "\' and a.HOST_KELLY <= c.LOSS_RATIO ", sep="");
    # ODDS_SEQ=1 的 host_kelly 比 ODDS_SEQ=2的小.
    baseSql <- paste("select b.HOST_GOALS, b.VISITING_GOALS from (select t2.OK_MATCH_ID, t2.ODDS_CORP_NAME, t2.HOST_KELLY HOST_KELLY2, t1.HOST_KELLY HOST_KELLY1 from LOT_ODDS_EURO_CHANGE t1, LOT_ODDS_EURO_CHANGE t2 where t1.OK_MATCH_ID=t2.OK_MATCH_ID and t1.ODDS_CORP_NAME=t2.ODDS_CORP_NAME and t1.ODDS_CORP_NAME=\'", oddsCorpName, "\' and t1.ODDS_SEQ=1 and t2.ODDS_SEQ=2) a, LOT_MATCH b, LOT_ODDS_EURO c where a.       OK_MATCH_ID=b.OK_MATCH_ID and a.                 OK_MATCH_ID=c.OK_MATCH_ID and a.ODDS_CORP_NAME=c.ODDS_CORP_NAME and b.MATCH_NAME=\'", matchName, "\' and a.HOST_KELLY2 <= c.LOSS_RATIO and a.HOST_KELLY1 <= a.HOST_KELLY2", sep="");

    # 构造 oddsCorpName 的sql.
#    oddsCorpNamesSql <- " a.ODDS_CORP_NAME in (\'aaa\'";
#    for(i in 1:length(oddsCorpNames)){
#        oddsCorpNamesSql <- paste(oddsCorpNamesSql, ", \'", oddsCorpNames[i], "\'", sep="");
#    }
#    oddsCorpNamesSql <- paste(oddsCorpNamesSql, " ) ", sep="");
#    sql <- paste(baseSql, " and ", oddsCorpNamesSql, sep="");
    dbResult <- dbGetQuery(conn, baseSql);
    closeConn(conn);

    if(length(dbResult) == 0){
	closeConn(conn);
        result <- data.frame(id=c(1));
        result$count <- 0;
        result$winCount <- 0;
        result$evenCount <- 0;
        result$negaCount <- 0;
	# 不做处理. 会赋值 NaN.
        result$winProp <- result$winCount/result$count;
        result$evenProp <- result$evenCount/result$count;
        result$negaProp <- result$negaCount/result$count;
	return(result);
    }
    hostGoals <- dbResult[[1]];
    visitingGoals <- dbResult[[2]];

    count <- 0;
    winCount <- 0;
    evenCount <- 0;
    negaCount <- 0;
    for(i in 1:length(hostGoals)){
        count <- count + 1;
        if(hostGoals[i] > visitingGoals[i]){
            winCount <- winCount + 1;
	}	
        if(hostGoals[i] == visitingGoals[i]){
            evenCount <- evenCount + 1;
	}	
        if(hostGoals[i] < visitingGoals[i]){
            negaCount <- negaCount + 1;
	}	
    }
#    print(sql);
#    print(paste(count, winCount, evenCount, negaCount));

    result <- data.frame(id=c(1));
    result$count <- count;
    result$winCount <- winCount;
    result$evenCount <- evenCount;
    result$negaCount <- negaCount;
    result$winProp <- result$winCount/result$count;
    result$evenProp <- result$evenCount/result$count;
    result$negaProp <- result$negaCount/result$count;

    return(result);
}

#  k1 rule.  
allCorpsKelly1 <- function(matchName){
    begin <- Sys.time();
    conn <- getConn();
    baseSql <- paste("select distinct ODDS_CORP_NAME from LOT_ODDS_EURO where LOSS_RATIO < 1 order by LOSS_RATIO desc ", sep="");
    allCorpsResult <- dbGetQuery(conn, baseSql);
    allCorps <- allCorpsResult[[1]];
    
    result <- data.frame(id=allCorps); 
    timeFlag <- "1409";
    countVector <- c();
    winCountVector <- c();
    evenCountVector <- c();
    negaCountVector <- c();
    winPropVector <- c();
    evenPropVector <- c();
    negaPropVector <- c();
    oddsCorpNamesVector <- c();
    matchNameVector <- c();
    ruleTypeVector <- c();
    timestampVector <- c();
    timeFlagVector <- c();
    for(i in 1:length(allCorps)){
        corpResult <- corpKellyMatchName(allCorps[i], matchName);

	oddsCorpNamesVector <- c(oddsCorpNamesVector, allCorps[i]);
        matchNameVector <- c(matchNameVector, matchName); 
	ruleTypeVector <- c(ruleTypeVector, "K1");
	timestampVector <- c(timestampVector, format(Sys.time(), "%Y-%m-%d %H:%M:%S"));
	timeFlagVector <- c(timeFlagVector, timeFlag);
        countVector <- c(countVector, corpResult$count);
        winCountVector <- c(winCountVector, corpResult$winCount);
        evenCountVector <- c(evenCountVector, corpResult$evenCount);
        negaCountVector <- c(negaCountVector, corpResult$negaCount);
	winPropVector <- c(winPropVector, corpResult$winProp);
	evenPropVector <- c(evenPropVector, corpResult$evenProp);
	negaPropVector <- c(negaPropVector, corpResult$negaProp);
    }

    ##################
    ### 下次写数据库时，把 TIME_BEFORE_MATCH(ODDS_SEQ==2时)的平均值添加上, 或者不写入数据库，考虑写一个单独的R程序来展示.
    ###################
    result$ODDS_CORP_NAME <- oddsCorpNamesVector;
    result$MATCH_NAME <- matchNameVector;
    result$COUNT <- countVector;
    result$WIN_COUNT <- winCountVector;
    result$EVEN_COUNT <- evenCountVector;
    result$NEGA_COUNT <- negaCountVector;
    result$WIN_PROB <- winPropVector;
    result$EVEN_PROB <- evenPropVector;
    result$NEGA_PROB <- negaPropVector;
    result$RULE_TYPE <- ruleTypeVector;
    result$TIMESTAMP <- timestampVector;

    #按照 prop 降序排列, 要保证result$prop是vector, 而不是list, dbGetQuery(conn, winCountSql) 返回的count 是list型的, 需要do.call()转化, 或者使用[[]]取数据库的返回.
    orderedResult <- result[order(result$WIN_PROB, decreasing=T),];

    # 输出到终端
#    print(matchName);
#    print(orderedResult);

    # 写入文件
#    write.table(orderedResult, file=paste(matchName, ".txt", sep=""));

    # 写数据库
    deleteSql <- paste(" delete from LOT_KELLY_RULE where RULE_TYPE=\'K1\' and MATCH_NAME=\'", matchName, "\'", " and TIME_FLAG=\'", timeFlag, "\'", sep="");
    dbGetQuery(conn, deleteSql);
    dbWriteTable(conn, "LOT_KELLY_RULE", orderedResult, row.names=TRUE, append=TRUE)

    closeConn(conn);
    print(paste(matchName, " begin: ", begin, "   end:",  Sys.time(), sep=""));
}

# 所有联赛
allCorpsKelly11 <- function(){
    begin <- Sys.time();
    conn <- getConn();
    baseSql <- " select distinct MATCH_NAME from LOT_MATCH ";
    dbResult <- dbGetQuery(conn, baseSql);
    closeConn(conn);
    matchNames <- dbResult[[1]];

    for(i in 1:length(matchNames)){
        allCorpsKelly1(matchNames[i]);
    }
    print(paste("all complete. begin: ", begin, " end: ", end), sep="");
}

# k2 rule
allCorpsKelly2 <- function(matchName){
    begin <- Sys.time();
    conn <- getConn();
    baseSql <- paste("select distinct ODDS_CORP_NAME from LOT_ODDS_EURO where LOSS_RATIO < 1 order by LOSS_RATIO desc ", sep="");
    allCorpsResult <- dbGetQuery(conn, baseSql);
    allCorps <- allCorpsResult[[1]];
    
    result <- data.frame(id=allCorps); 
    timeFlag <- "1409";
    countVector <- c();
    winCountVector <- c();
    evenCountVector <- c();
    negaCountVector <- c();
    winPropVector <- c();
    evenPropVector <- c();
    negaPropVector <- c();
    oddsCorpNamesVector <- c();
    matchNameVector <- c();
    ruleTypeVector <- c();
    timestampVector <- c();
    timeFlagVector <- c();
    for(i in 1:length(allCorps)){
        corpResult <- corpKellyMatchName(allCorps[i], matchName);

	oddsCorpNamesVector <- c(oddsCorpNamesVector, allCorps[i]);
        matchNameVector <- c(matchNameVector, matchName); 
	ruleTypeVector <- c(ruleTypeVector, "K2");
	timestampVector <- c(timestampVector, format(Sys.time(), "%Y-%m-%d %H:%M:%S"));
	timeFlagVector <- c(timeFlagVector, timeFlag);
        countVector <- c(countVector, corpResult$count);
        winCountVector <- c(winCountVector, corpResult$winCount);
        evenCountVector <- c(evenCountVector, corpResult$evenCount);
        negaCountVector <- c(negaCountVector, corpResult$negaCount);
	winPropVector <- c(winPropVector, corpResult$winProp);
	evenPropVector <- c(evenPropVector, corpResult$evenProp);
	negaPropVector <- c(negaPropVector, corpResult$negaProp);
    }

    ##################
    ### 下次写数据库时，把 TIME_BEFORE_MATCH(ODDS_SEQ==2时)的平均值添加上, 或者不写入数据库，考虑写一个单独的R程序来展示.
    ###################
    result$ODDS_CORP_NAME <- oddsCorpNamesVector;
    result$MATCH_NAME <- matchNameVector;
    result$COUNT <- countVector;
    result$WIN_COUNT <- winCountVector;
    result$EVEN_COUNT <- evenCountVector;
    result$NEGA_COUNT <- negaCountVector;
    result$WIN_PROB <- winPropVector;
    result$EVEN_PROB <- evenPropVector;
    result$NEGA_PROB <- negaPropVector;
    result$RULE_TYPE <- ruleTypeVector;
    result$TIMESTAMP <- timestampVector;
    result$TIME_FLAG <- timeFlagVector;

    #按照 prop 降序排列, 要保证result$prop是vector, 而不是list, dbGetQuery(conn, winCountSql) 返回的count 是list型的, 需要do.call()转化, 或者使用[[]]取数据库的返回.
    orderedResult <- result[order(result$WIN_PROB, decreasing=T),];

    # 输出到终端
#    print(matchName);
#    print(orderedResult);

    # 写入文件
#    write.table(orderedResult, file=paste(matchName, ".txt", sep=""));

    # 写数据库
    deleteSql <- paste(" delete from LOT_KELLY_RULE where RULE_TYPE=\'K2\' and MATCH_NAME=\'", matchName, "\'", " and TIME_FLAG=\'", timeFlag, "\'", sep="");
    dbGetQuery(conn, deleteSql);
    dbWriteTable(conn, "LOT_KELLY_RULE", orderedResult, row.names=TRUE, append=TRUE)

    closeConn(conn);
    print(paste(matchName, " begin: ", begin, "   end:",  Sys.time(), sep=""));
}

allCorpsKelly21 <- function(){
    begin <- Sys.time();
    conn <- getConn();
    baseSql <- " select distinct MATCH_NAME from LOT_MATCH ";
    dbResult <- dbGetQuery(conn, baseSql);
    closeConn(conn);
    matchNames <- dbResult[[1]];

    for(i in 1:length(matchNames)){
        allCorpsKelly2(matchNames[i]);
    }
    print(paste("all complete. begin: ", begin, " end: ", end), sep="");
}


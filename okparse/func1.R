# 加载需要的package
initMysql <- function(){
        library(RMySQL)
}

# 获取数据库连接
getConn <- function(){
    con <- dbConnect(MySQL(),
        user='root', # 用户名
        password='mysql', # 密码
        dbname='mysql', # 要使用的数据库名称
        host="localhost") # 主机地址
#    dbListTables(con) # 列出所有数据库中的表
    return(con);
}

#关闭数据库连接.
closeConn <- function(con){
    dbDisconnect(con);
}

# 根据赔率查询胜平负的概率, 99家平均的.
allAverageOdds <- function(odds, resultFlag){
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
    print(paste("resultFlagQuery:", resultFlagQuery));
     
    result <- vector(length=length(odds)-1);
    for(i in 2:length(odds)){
        countRangeSql <- paste("select count(*) from LOT_DAT_MATCH where HOST_ODDS>=", odds[i-1]," and HOST_ODDS <", odds[i]);
        count <- dbGetQuery(conn, countRangeSql);
        if(count == 0){
            result[i-1] <- count;
            next;
        }

#        resultCountSql <-paste("select count(*) from LOT_DAT_MATCH where HOST_ODDS=", odds[i], " and ",                              resultFlagQuery);
        resultCountRangeSql <-paste(countRangeSql, " and ", resultFlagQuery);
        resultCount <- dbGetQuery(conn, resultCountRangeSql);
        prob <- resultCount / count;
        result[i-1] <- prob;

	print(paste(odds[i-1], "-", odds[i],"; count:", count, "resultCount: ", resultCount));
#        print(paste("i:", i, " odds:", odds[i], " count:", count, " resultCount:", resultCount," prob:", prob));
   }
        closeConn(conn);
        return(result);
}

# 查询各个博彩公司的赔率胜负情况, 结果只包括一个公司.
# * 某个公司对所有比赛的赔率的胜平负的正确率;
corpOddsAllResult<- function(odds, corpName){
    conn <- getConn();
    print(paste("corpName:", corpName));

    baseSql <- "select count(*) from LOT_MATCH a, LOT_ODDS_EURO b where a.OK_MATCH_ID=b.OK_MATCH_ID "; 
    corpNameSql <- paste(" ODDS_CORP_NAME= \'", corpName, "\' ", sep="");
    winSql <- " HOST_GOALS > VISITING_GOALS ";
    evenSql <- " HOST_GOALS = VISITING_GOALS ";
    negaSql <- " HOST_GOALS < VISITING_GOALS ";
    winResult <- vector(length=length(odds)-1);
    evenResult <- vector(length=length(odds)-1);
    negaResult <- vector(length=length(odds)-1);

    for(i in 2:length(odds)){
        countSql <- paste(baseSql, " and ", corpNameSql, " and ", "HOST_ODDS >=", odds[i-1], " and HOST_ODDS <", odds[i]);
        winResultCountSql <- paste(countSql, " and ", winSql);
        evenResultCountSql <- paste(countSql, " and ", evenSql);
        negaResultCountSql <- paste(countSql, " and ", negaSql);
#	print(paste("countSql: ", countSql));
#	print(paste("winResultCountSql: ", winResultCountSql));

        count <- dbGetQuery(conn, countSql);
	winResultCount <- dbGetQuery(conn, winResultCountSql);
	evenResultCount <- dbGetQuery(conn, evenResultCountSql);
	negaResultCount <- dbGetQuery(conn, negaResultCountSql);

        if(count == 0){
            winResult[i-1] <- count;
            evenResult[i-1] <- count;
            negaResult[i-1] <- count;
            next;
        }
	print(paste(odds[i-1], "-", odds[i], ": count: ", count, "; winResultCount: ", winResultCount, "; evenResultCount: ", evenResultCount, "; negaResultCount: ", negaResultCount));
	winResult[i-1] <- winResultCount/count;
	evenResult[i-1] <- evenResultCount/count;
	negaResult[i-1] <- negaResultCount/count;
    }
    # 将 list 转为 vector.
    winc <- do.call(c,winResult);
    evenc <- do.call(c, evenResult);
    negac <- do.call(c, negaResult);

    result <- data.frame(win=winc);
    result$even <- evenc; 
    result$nega <- negac; 

    closeConn(conn);
    return(result);
}

# * 某个公司对不同联赛的正确率;
corpLeagueCompare <- function(odds, corpName, resultFlag, leagueNames){
    conn <- getConn();
    print(paste("leagueNames:", leagueNames));

    baseSql <- "select count(*) from LOT_MATCH a, LOT_ODDS_EURO b where a.OK_MATCH_ID=b.OK_MATCH_ID "; 
    corpNameSql <- paste(" ODDS_CORP_NAME= \'", corpName, "\' ", sep="");
    if(resultFlag == "win"){
        resultFlagSql <- " HOST_GOALS > VISITING_GOALS ";
    }
    if(resultFlag == "even"){
        resultFlagSql <- " HOST_GOALS = VISITING_GOALS ";
    }
    if(resultFlag == "nega"){
        resultFlagSql <- " HOST_GOALS < VISITING_GOALS ";
    }

    league <- vector(length=length(odds)-1);
    result <- data.frame(odds=odds[2:length(odds)]);

    for(j in 1:length(leagueNames)){
        leagueNameSql <- paste(" MATCH_NAME= \'", leagueNames[j], "\' ", sep="");
	for(i in 2:length(odds)){
            countSql <- paste(baseSql, " and ", corpNameSql, " and ", leagueNameSql, " and ", "HOST_ODDS >=", odds[i-1], " and HOST_ODDS <", odds[i]);
            resultCountSql <- paste(countSql, " and ", resultFlagSql);

#           print(paste("countSql: ", countSql));
#           print(paste("resultCountSql: ", resultCountSql));

            count <- dbGetQuery(conn, countSql);
            resultCount <- dbGetQuery(conn, resultCountSql);
    
            if(count == 0){
                league[i-1] <- count;
                next;
	    }
	    prob <- resultCount/count;
            league[i-1] <- prob;
            print(paste(corpName, " ", resultFlag, " ", leagueNames[j], " ",  odds[i-1], "-", odds[i], ": count: ", count, "; resultCount: ", resultCount, "; prob: ", prob));

	}

        leaguec <- do.call(c,league);
	if(leagueNames[j] == "英超"){
            result$英超 <- leaguec;
	}
	if(leagueNames[j] == "西甲"){
            result$西甲 <- leaguec;
	}
	if(leagueNames[j] == "意甲"){
            result$意甲 <- leaguec;
	}
	if(leagueNames[j] == "法甲"){
            result$法甲 <- leaguec;
	}
	if(leagueNames[j] == "德甲"){
            result$德甲 <- leaguec;
	}
    }

    closeConn(conn);
    return(result);
}

# 查询各个博彩公司的赔率胜负情况, 可以多个公司进行对比; 可以指定联赛名称, ""表示所有比赛;
# * 不同公司对所有比赛胜平负的正确率;
# * 不同公司对某个联赛的胜平负的正确率;
corpsOddsCompare <- function(odds, corpNames, resultFlag, leagueName){
    conn <- getConn();
    print(paste("corpNames:", corpNames));

    baseSql <- "select count(*) from LOT_MATCH a, LOT_ODDS_EURO b where a.OK_MATCH_ID=b.OK_MATCH_ID "; 
    if(resultFlag == "win"){
        resultFlagSql <- " HOST_GOALS > VISITING_GOALS ";
    }
    if(resultFlag == "even"){
        resultFlagSql <- " HOST_GOALS = VISITING_GOALS ";
    }
    if(resultFlag == "nega"){
        resultFlagSql <- " HOST_GOALS < VISITING_GOALS ";
    }

    leagueNameSql <- " 1 = 1 ";
    if(leagueName != ""){
        leagueNameSql <- paste(leagueNameSql, " and ", " MATCH_NAME =\'", leagueName, "\' ", sep="");
    }

    corp <- vector(length=length(odds)-1);
    result <- data.frame(odds=odds[2:length(odds)]);

    for(j in 1:length(corpNames)){
	for(i in 2:length(odds)){
            corpNameSql <- paste(" ODDS_CORP_NAME= \'", corpNames[j], "\' ", sep="");
            countSql <- paste(baseSql, " and ", corpNameSql, " and ", leagueNameSql, " and ", "HOST_ODDS >=", odds[i-1], " and HOST_ODDS <", odds[i]);
            resultCountSql <- paste(countSql, " and ", resultFlagSql);

#            print(paste("countSql: ", countSql));
#            print(paste("resultCountSql: ", resultCountSql));
    
            count <- dbGetQuery(conn, countSql);
            resultCount <- dbGetQuery(conn, resultCountSql);
    
            if(count == 0){
                corp[i-1] <- count;
                next;
            }

	    prob <- resultCount/count;
            corp[i-1] <- prob;
            print(paste(corpNames[j], " ", resultFlag, " ", leagueName, " ",  odds[i-1], "-", odds[i], ": count: ", count, "; resultCount: ", resultCount, "; prob: ", prob));
	}
        corpc <- do.call(c,corp);
	if(corpNames[j] == "威廉.希尔"){
            result$威廉.希尔 <- corpc;
	}
	if(corpNames[j] == "立博"){
            result$立博<- corpc;
	}
	if(corpNames[j] == "Interwetten"){
            result$Interwetten <- corpc;
	}
	if(corpNames[j] == "澳门彩票"){
            result$澳门彩票 <- corpc;
	}
	if(corpNames[j] == "博天堂"){
            result$博天堂 <- corpc;
	}
	if(corpNames[j] == "12bet.com"){
            result$bet12.com <- corpc;
	}
	if(corpNames[j] == "金宝博(188bet)"){
            result$金宝博188bet <- corpc;
	}
    }
    closeConn(conn);
    return(result);
}

#	select TIME_BEFORE_MATCH from LOT_ODDS_EURO_CHANGE where SUBSTRING_INDEX(TIME_BEFORE_MATCH, '.', 1)='0' and CONVERT(SUBSTRING_INDEX(TIME_BEFORE_MATCH, '.', -1), UNSIGNED) >=10 and CONVERT(SUBSTRING_INDEX(TIME_BEFORE_MATCH, '.', -1), UNSIGNED) < 20 and ODDS_CORP_NAME='澳门彩票';
# * 查询某个公司变赔的时间段;
corpTimeBefore <- function(minInterval, corpName){
    conn <- getConn();
    # 除了99家平均外,其他公司的ODDS_SEQ=1的都是 0.0;
    corpNameSql <- paste(" ODDS_SEQ =2 AND ODDS_CORP_NAME=\'", corpName, "\'", sep="");
    baseSql <- paste(" select count(TIME_BEFORE_MATCH) from LOT_ODDS_EURO_CHANGE where ", corpNameSql);
    hourSql <- paste(" SUBSTRING_INDEX(TIME_BEFORE_MATCH, \'.\', 1) ");
    minSql <- paste(" SUBSTRING_INDEX(TIME_BEFORE_MATCH, \'.\', -1) ");
    minNumSql <- paste(" CONVERT(SUBSTRING_INDEX(TIME_BEFORE_MATCH, \'.\', -1), UNSIGNED) "); 

    result <- vector(length=length(minInterval)-1);

    for(i in 2:length(minInterval)){
	preHour <- unlist(strsplit(minInterval[i-1], "\\."))[1];
        hour <- unlist(strsplit(minInterval[i], "\\."))[1];
	if(preHour != hour){
            preMin <- 0;
	}else{
            preMin <- unlist(strsplit(minInterval[i-1], "\\."))[2];
	}

        min <- unlist(strsplit(minInterval[i], "\\."))[2];
	timeBeforeSql <- paste(baseSql, " and ", hourSql, "=", "\'", hour, "\'", " and ", minNumSql, ">=", preMin, " and ", minNumSql, "<", min, sep=""); 
        resultCount <- dbGetQuery(conn, timeBeforeSql);

        result[i-1] <- resultCount;
	print(paste("timeBeforeSql: ",timeBeforeSql));
	print(paste(corpName, "  ", minInterval[i-1], " - ", minInterval[i], " resultCount:", resultCount));
    }

    closeConn(conn);
    resultc <- do.call(c, result);
    return(resultc);
}

# * 公司最后一次变赔与胜平负的关系;
#select count(*) FROM LOT_ODDS_EURO_CHANGE a, LOT_ODDS_EURO_CHANGE b, LOT_MATCH c WHERE a.OK_MATCH_ID = b.OK_MATCH_ID AND a.OK_MATCH_ID=c.OK_MATCH_ID AND a.ODDS_CORP_NAME=b.ODDS_CORP_NAME AND b.ODDS_CORP_NAME='Interwetten' AND c.MATCH_NAME='英超' and a.ODDS_SEQ=2 AND b.ODDS_SEQ=3 AND c.HOST_GOALS = c.VISITING_GOALS AND (a.HOST_ODDS-b.HOST_ODDS)<0 AND a.HOST_ODDS < 2.0 AND a.TIME_BEFORE_MATCH<'0.60';
corpTimeBefore2 <- function(corpNames, matchNames){
    conn <- getConn();
    timeBeforeSql <- paste("a.TIME_BEFORE_MATCH<\'0.60\'");
    baseSql <- paste(" select count(*) FROM LOT_ODDS_EURO_CHANGE a, LOT_ODDS_EURO_CHANGE b, LOT_MATCH c WHERE a.OK_MATCH_ID = b.OK_MATCH_ID AND a.OK_MATCH_ID=c.OK_MATCH_ID AND a.ODDS_CORP_NAME=b.ODDS_CORP_NAME AND a.ODDS_SEQ=2 AND b.ODDS_SEQ=3 AND a.HOST_ODDS < 2.0 AND (a.HOST_ODDS-b.HOST_ODDS) < 0 and c.MATCH_TIME > \'2014-09-01 10:00:00\'");

    winSql <- " c.HOST_GOALS > c.VISITING_GOALS ";
    evenSql <- " c.HOST_GOALS = c.VISITING_GOALS ";
    negaSql <- " c.HOST_GOALS < c.VISITING_GOALS ";
    
    corpNamesLen <- length(corpNames);
    matchNamesLen <- length(matchNames);
    index <- corpNamesLen * matchNamesLen;

    oddsCorpNameCol <- list();
    matchNameCol <- list();
    countCol <- list();
    winCountCol <- list();
    evenCountCol <- list();
    negaCountCol <- list();
    winProbCol <- list();
    evenProbCol <- list();
    negaProbCol <- list();
    ruleTypeCol <- list();
    timestampCol <- list();

    for(i in 1:length(corpNames)){
	for(j in 1:length(matchNames)){
            corpNameSql <- paste("b.ODDS_CORP_NAME=\'", corpNames[i], "\'", sep="");
            matchNameSql <- paste("c.MATCH_NAME=\'", matchNames[j], "\'", sep="");
            countSql <- paste(baseSql, " AND ", corpNameSql, " AND ", matchNameSql, sep="");
            winCountSql <- paste(countSql, " AND ", winSql, sep="");
            evenCountSql <- paste(countSql, " AND ", evenSql, sep="");
    
            count <- dbGetQuery(conn, countSql);
            winCount <- dbGetQuery(conn, winCountSql);
            evenCount <- dbGetQuery(conn, evenCountSql);
            winProb <- winCount / count;
            evenProb <- evenCount / count;
            
    #        print(paste("countSql: ", countSql));
    #        print(paste("resultCountSql: ", resultCountSql));
            print(paste(corpNames[i], " ", matchNames[j], " ", "count: ", count, "; winCount: ", winCount, "; winProb:", winProb, ";winEvenCount: ", (winCount + evenCount), "; winEvenProb: ", (winProb + evenProb), sep=""));

	    oddsCorpNameCol[(i-1) * matchNamesLen + j] <- corpNames[i];
	    matchNameCol[(i-1) * matchNamesLen + j] <- matchNames[j];
	    countCol[(i-1) * matchNamesLen + j] <- count;
	    winCountCol[(i-1) * matchNamesLen + j] <- winCount;
	    evenCountCol[(i-1) * matchNamesLen + j] <- evenCount;
	    negaCountCol[(i-1) * matchNamesLen + j] <- (count - winCount - evenCount);
	    winProbCol[(i-1) * matchNamesLen + j] <- winProb;
	    evenProbCol[(i-1) * matchNamesLen + j] <- evenProb;
	    negaProbCol[(i-1) * matchNamesLen + j] <- (1 - winProb - evenProb);
	    ruleTypeCol[(i-1) * matchNamesLen + j] <- "A";
	    timestampCol[(i-1) * matchNamesLen + j] <- format(Sys.time(), "%Y-%m-%d %H:%M:%S");
	}
    }

    oddsCorpNameColc <- do.call(c, oddsCorpNameCol);
    matchNameColc<- do.call(c, matchNameCol);
    countColc <- do.call(c, countCol);
    winCountColc <- do.call(c, winCountCol);
    evenCountColc <- do.call(c, evenCountCol);
    negaCountColc <- do.call(c, negaCountCol);
    winProbColc <- do.call(c, winProbCol);
    evenProbColc <- do.call(c, evenProbCol);
    negaProbColc<- do.call(c, negaProbCol);
    ruleTypeColc <- do.call(c, ruleTypeCol);
    timestampColc <- do.call(c, timestampCol);

    lotWeightRule <- data.frame(ID=seq(1, index, by=1));
    lotWeightRule$ODDS_CORP_NAME <- oddsCorpNameColc;
    lotWeightRule$MATCH_NAME<- matchNameColc;
    lotWeightRule$COUNT <- countColc;
    lotWeightRule$WIN_COUNT <- winCountColc;
    lotWeightRule$EVEN_COUNT <- evenCountColc;
    lotWeightRule$NEGA_COUNT <- negaCountColc;
    lotWeightRule$WIN_PROB <- winProbColc;
    lotWeightRule$EVEN_PROB <- evenProbColc;
    lotWeightRule$NEGA_PROB <- negaProbColc;
    lotWeightRule$RULE_TYPE <- ruleTypeColc;
    lotWeightRule$TIMESTAMP <- timestampColc;

    dbWriteTable(conn, "LOT_WEIGHT_RULE", lotWeightRule, row.names=TRUE, append=TRUE)

    closeConn(conn);
}

#
# select count(*) from LOT_MATCH a, LOT_BF_TURNOVER_DETAIL b where a.OK_MATCH_ID=b.ID and b.SEQ=1 and a.HOST_GOALS > a.VISITING_GOALS and b.HOST_TOTAL > 3 * b.VISITING_TOTAL
corpTimeBefore3 <- function(matchNames, multiples){
    conn <- getConn();
    baseSql <- paste(" select count(*) from LOT_MATCH a, LOT_BF_TURNOVER_DETAIL b where a.OK_MATCH_ID=b.ID and b.SEQ=1 and b.HOST_TOTAL > 2 * b.EVEN_TOTAL ", sep="");
    winSql <- paste(" a.HOST_GOALS > a.VISITING_GOALS ", sep="");
    evenSql <- paste(" a.HOST_GOALS = a.VISITING_GOALS ", sep="");
    negaSql <- paste(" a.HOST_GOALS < a.VISITING_GOALS ", sep="");

    matchNamesLen <- length(matchNames);
    multiplesLen <- length(multiples);
    index <- matchNamesLen * multiplesLen;
    oddsCorpNameCol <- list();
    matchNameCol <- list();
    multipleCol <- list();
    countCol <- list();
    winCountCol <- list();
    evenCountCol <- list();
    negaCountCol <- list();
    winProbCol <- list();
    evenProbCol <- list();
    negaProbCol <- list();
    ruleTypeCol <- list();
    timestampCol <- list();

    for(i in 1:length(matchNames)){
	matchNameSql <- paste(" a.MATCH_NAME=\'", matchNames[i], "\'", sep="");
        for(j in 1:length(multiples)){
            multipleSql <- paste(" b.HOST_TOTAL > ", multiples[j], " * b.VISITING_TOTAL ", sep="");
#            multipleSql <- paste(multiples[j], " * b.HOST_TOTAL < ", " b.VISITING_TOTAL ", sep="");
	    countSql <- paste(baseSql, " and ", matchNameSql, " and ", multipleSql);
	    winCountSql <- paste(countSql, " and ", winSql);
	    evenCountSql <- paste(countSql, " and ", evenSql);
	    negaCountSql <- paste(countSql, " and ", negaSql);

            count <- dbGetQuery(conn, countSql);
            winCount <- dbGetQuery(conn, winCountSql);
            evenCount <- dbGetQuery(conn, evenCountSql);
            negaCount <- dbGetQuery(conn, negaCountSql);
            winProb <- winCount / count;
            evenProb <- evenCount / count;
            negaProb <- negaCount / count;

#            print(paste("countSql: ", countSql));
#            print(paste("winCountSql: ", winCountSql));
#            print(paste("evenCountSql: ", evenCountSql));
            print(paste(matchNames[i], " multiple:", multiples[j], " ", "count: ", count, "; winCount: ", winCount, "; winProb:", winProb, "; winEvenProb: ", (winProb + evenProb), sep=""));
#            print(paste(matchNames[i], " multiple:", multiples[j], " ", "count: ", count, "; negaCount: ", negaCount, "; negaProb:", negaProb, "; negaEvenProb: ", (negaProb + evenProb), sep=""));
	    oddsCorpNameCol[(i-1) * multiplesLen + j] <- "";
	    matchNameCol[(i-1) * multiplesLen + j] <- matchNames[i];
	    multipleCol[(i-1) * multiplesLen + j] <- multiples[j];
	    countCol[(i-1) * multiplesLen + j] <- count;
	    winCountCol[(i-1) * multiplesLen + j] <- winCount;
	    evenCountCol[(i-1) * multiplesLen + j] <- evenCount;
	    negaCountCol[(i-1) * multiplesLen + j] <- negaCount;
	    winProbCol[(i-1) * multiplesLen + j] <- winProb;
	    evenProbCol[(i-1) * multiplesLen + j] <- evenProb;
	    negaProbCol[(i-1) * multiplesLen + j] <- negaProb;
	    ruleTypeCol[(i-1) * multiplesLen + j] <- "B";
	    timestampCol[(i-1) * multiplesLen + j] <- format(Sys.time(), "%Y-%m-%d %H:%M:%S");
	}
    }

    oddsCorpNameColc <- do.call(c, oddsCorpNameCol);
    matchNameColc <- do.call(c, matchNameCol);
    multipleColc <- do.call(c, multipleCol);
    countColc <- do.call(c, countCol);
    winCountColc <- do.call(c, winCountCol);
    evenCountColc <- do.call(c, evenCountCol);
    negaCountColc <- do.call(c, negaCountCol);
    winProbColc <- do.call(c, winProbCol);
    evenProbColc <- do.call(c, evenProbCol);
    negaProbColc<- do.call(c, negaProbCol);
    ruleTypeColc <- do.call(c, ruleTypeCol);
    timestampColc <- do.call(c, timestampCol);

    lotWeightRule <- data.frame(ID=seq(10001, 10000 + index, by=1));
    lotWeightRule$ODDS_CORP_NAME <- oddsCorpNameColc;
    lotWeightRule$MATCH_NAME<- matchNameColc;
    lotWeightRule$MULTIPLE <- multipleColc;
    lotWeightRule$COUNT <- countColc;
    lotWeightRule$WIN_COUNT <- winCountColc;
    lotWeightRule$EVEN_COUNT <- evenCountColc;
    lotWeightRule$NEGA_COUNT <- negaCountColc;
    lotWeightRule$WIN_PROB <- winProbColc;
    lotWeightRule$EVEN_PROB <- evenProbColc;
    lotWeightRule$NEGA_PROB <- negaProbColc;
    lotWeightRule$RULE_TYPE <- ruleTypeColc;
    lotWeightRule$TIMESTAMP <- timestampColc;

    print(lotWeightRule);
    dbWriteTable(conn, "LOT_WEIGHT_RULE", lotWeightRule, row.names=TRUE, append=TRUE)

    closeConn(conn);
}

getAsiaKelly <- function(matchSeq, jobType){
    conn <- getConn();
    hostSql <- paste("SELECT HOST_KELLY FROM LOT_ODDS_ASIA_TRENDS WHERE OK_URL_DATE='150403' AND MATCH_SEQ=", "'", matchSeq, "'", " AND JOB_TYPE=", "'", jobType, "'", " AND ODDS_CORP_NAME NOT IN('最大值', '最小值', '平均值') ORDER BY  ODDS_CORP_NAME", sep="");
    visitingSql <- paste("SELECT VISITING_KELLY FROM LOT_ODDS_ASIA_TRENDS WHERE OK_URL_DATE='150403' AND MATCH_SEQ=", "'", matchSeq, "'", " AND JOB_TYPE=", "'", jobType, "'", " AND ODDS_CORP_NAME NOT IN('最大值', '最小值', '平均值') ORDER BY  ODDS_CORP_NAME", sep="");
    hostResult <- dbGetQuery(conn, hostSql);
    visitingResult <- dbGetQuery(conn, visitingSql);
#    print(result);
    hm <- mean(hostResult[[1]])
    hv <- var(hostResult[[1]])
    hstdDev <- sd(hostResult[[1]])
    vm <- mean(visitingResult[[1]])
    vv <- var(visitingResult[[1]])
    vstdDev <- sd(visitingResult[[1]])
    print(paste(jobType, " H ", " mean:", hm, " var:", hv, " sd:", hstdDev, sep=""));
    print(paste(jobType, " V ", " mean:", vm, " var:", vv, " sd:", vstdDev, sep=""));
    
    closeConn(conn);
}

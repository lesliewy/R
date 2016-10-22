
#select a.OK_URL_DATE, a.MATCH_SEQ, a.OK_MATCH_ID, a.MATCH_NAME, a.HOST_GOALS, a.VISITING_GOALS from LOT_MATCH a, (select OK_MATCH_ID from LOT_ODDS_EURO_CHANGE where ODDS_CORP_NAME='澳门彩票' and ODDS_TIME > '2014-07-01 01:00:00' group by          OK_MATCH_ID having count(*) < 10 and count(*) > 3) b, LOT_ODDS_EURO c where a.OK_MATCH_ID=b.OK_MATCH_ID and a.OK_MATCH_ID=c.OK_MATCH_ID and c.ODDS_CORP_NAME='澳门彩票' and c.HOST_ODDS < c.VISITING_ODDS
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

    baseSql <- paste("select a.OK_URL_DATE, a.MATCH_SEQ, a.OK_MATCH_ID, a.MATCH_NAME, a.HOST_GOALS, a.VISITING_GOALS from LOT_MATCH a, (select            OK_MATCH_ID from LOT_ODDS_EURO_CHANGE where ODDS_CORP_NAME=\'", oddsCorpName, "\' and ODDS_TIME > '2014-07-01 01:00:00' group by                 OK_MATCH_ID having count(*) < 10 and count(*) > 3) b, LOT_ODDS_EURO c where a.OK_MATCH_ID=b.OK_MATCH_ID and a.OK_MATCH_ID=c.         OK_MATCH_ID and c.ODDS_CORP_NAME='澳门彩票' and c.HOST_ODDS < c.VISITING_ODDS", " and ", resultFlagQuery, sep="");

    dbResult <- dbGetQuery(conn, baseSql);
    okUrlDates <- dbResult[[1]];
    matchSeqs <- dbResult[[2]];
    okMatchIds <- dbResult[[3]];
    matchNames <- dbResult[[4]];
    for(i in 1:length(okUrlDates)){
        result <- euroOddsChange1(oddsCorpName, okMatchIds[i]); 

        # 绘图
        col1 <- 2;
        col2 <- 4;
        col3 <- 5;
        typeAll <- "b";
        pchAll <- 16;

        pdf(paste(oddsCorpName,"_", matchNames[i], "_", okUrlDates[i], "_", matchSeqs[i], "_", okMatchId, "_", resultFlag, ".pdf", sep=""));
        plot(result$timeBefore, result$hostOdds, type=typeAll, main=paste("Euro Odds Change"), xlab="TIME", ylab="ODDS", col=col1, lab=c(20,20,10), pch=pchAll);
        
        legend("topright",c("Host", "Even", "Visiting"), pch=c("o","o","o"), col=c(col1, col2, col3), cex=1);
        dev.off();
    }
    closeConn(conn);
    end <- Sys.time();
    print(paste("eclipsed time: ", (end - begin), " s."));
}


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

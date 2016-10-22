initMysql();

#matchName <- "英超";
#matchName <- "英冠";
#matchName <- "英甲";
#matchName <- "英乙";
#matchName <- "友谊赛";
#matchName <- "U21欧洲杯";
#matchName <- "欧洲杯";
#matchName <- "巴西乙";

# mysql> select count(*) from LOT_KELLY_RULE where RULE_TYPE='K2' and MATCH_NAME in('女足亚洲杯', '欧洲U21', '世界杯', '波超杯', '亚运男', '亚运女', '亚运会男足', '亚运会女足', '欧洲杯预');

matchName <- "欧洲杯预";
allCorpsKelly2(matchName);

#allCorpsKelly21();


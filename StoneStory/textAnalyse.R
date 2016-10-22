
# 使用Rwordseg来中文分词，引用了Ansj包，Ansj是一个开源的java中文分词工具，基于中科院的ictclas中文分词算法，采用隐马尔科夫模型（HMM）。
# Rwordseg 强大的三点，一是分词准确； 二是分词速度超快； 三是可以导入自定义词库，有意思的是还可以导入搜狗输入法的细胞词库（sqel格式），
# 想想细胞词库有多庞大吧，这个真是太厉害了。
library(rJava)
library(Rwordseg)
library(stringr)
library(wordcloud2)
library(tcltk)    # choose.files

data <- NULL
wordFreq <- NULL
wordFreq1 <- NULL

# BEGIN 
# 先把所有文件分词, 生成分词文件. 这个单独做,  
# fileNames <- tk_choose.files()
# for(i in fileNames) {
#    segmentCN(i, returnType="tm")
# }
# END


# BEGIN
# 统计词频, 生成词频文件 csv格式.  这个单独做.
# 这里选择的是分词文件. .segment
# filters <- matrix(c("segemnt file", ".segment.dat", "All files", "*"),2, 2, byrow = TRUE)
# fileNames <- tk_choose.files(multi = TRUE, filter = filters)
# for(name in fileNames) {
#    data <- NULL
#    wordFreq <- NULL
#    wordFreq1 <- NULL
# 
#    print(name)
# 
#    data <- str_trim(c(data, scan(name, what="")))
#    wordFreq <- sort(table(tolower(data)), decreasing = TRUE)
# 
#    filename <- str_match(name, "/dat/.*.dat")
#    newName <- str_replace(filename, ".segment.dat", ".freq.csv")
#    newName <- str_replace(newName, "/dat/", "/freq/")
#    fullName <- str_c("/home/leslie/MyProject/StoneStory", newName)
#    print(str_c("fullName: ", fullName))
# 
#    write.table(wordFreq, file = fullName, append=FALSE, row.names=FALSE, col.names=c("词语", "次数"))
# }
# END

# BEGIN
# 生成词云 html.  用 tagxedo 可以在线制作各种形状的词云.
# filters <- matrix(c("freq file", ".freq.csv", "All files", "*"),2, 2, byrow = TRUE)
# fileNames <- tk_choose.files(multi = TRUE, filter = filters)
# for(name in fileNames) {
#    wordFreq <- read.table(name, header=TRUE);
#    wordFreq1 <- wordFreq[nchar(as.vector(wordFreq[[1]])) > 1, ]
#    # 必须在console 中使用才能打开浏览器.
#    wordcloud2(wordFreq1)
# }
# END


# BEGIN
# 全部文本中某个词语出现次数直方图
filters <- matrix(c("freq file", ".freq.csv", "All files", "*"),2, 2, byrow = TRUE)
fileNames <- tk_choose.files(multi = TRUE, filter = filters)
for(name in fileNames) {
   heatmap(day_m,Rowv=NA,Colv=NA,scale = “column”,col=brewer.pal(4,”Blues”),revC = TRUE)

}
# END
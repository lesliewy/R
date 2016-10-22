# TODO: Add comment
# 
# Author: leslie
###############################################################################

# R 官网： www.r-project.org
# Data Mining with R 官网:  http://www.dcc.fc.up.pt/~ltorgo/DataMiningWithR/

# 关于R添加包的函数
# install.packages('RMySQL')   # 安装名称为 RMySQL的包.
# install.packages('/home/leslie/3/gplots_2.11.0.tar.gz', repos=NULL)   # 安装本地下好的包, zip包不可以.
# installed.packages()         # 已经安装的包
# library()                    # 同样是已经安装的包，信息是用户友好的.
# old.packages()               # 检查CRAN上是否有已安装的R添加包的更新版本.
# update.packages()            # 更新所有已安装的R软件包
# RSiteSearch('neural networks')  # 打开浏览器并搜索R手册、帮助文档中关于neural networks的内容.
# .libPaths()                  # 查看library的路径

# https://cran.r-project.org/web/packages/index.html: CRAN repository 里所有的包.
# https://cran.r-project.org/web/packages/caTools/index.html   包的信息，可以查看需要依赖哪些包，其中的 Depends 就是.
#    如果是下载下来的包,例如: gplots_2.11.0.tar.gz  其中的DESCRIPTION 文件中也可以查看依赖.

# ? read.table 查看read.table的帮助信息.

# library                      # 直接输入函数名可以查看该函数的源代码.
# methods(summary)             
# summary.aov                  # 如果函数是类函数，需要查看类中的具体函数名称，然后输入类.函数名

# library(rJava) 时报错: error: unable to load shared object '/usr/lib/R/site-library/rJava/libs/rJava.so':
# 可以使用linux命令: ldd /usr/lib/R/site-library/rJava/libs/rJava.so 查看rJava.so的依赖情况, 果然其中一项 libjvm.so : not found
# locate libjvm.so, 找到位置，其实在每个jdk包中都有.
# 添加到R中:  .bashrc文件中: export LD_LIBRARY_PATH=/usr/lib/R/site-library/rJava/jri/:/usr/local/lib/:$JAVA_HOME/jre/lib/amd64/server/

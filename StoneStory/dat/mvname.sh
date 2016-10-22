#! /bin/bash
# 文件名中的2个空格替换成_
# 在命令行执行:
# ls -m *.dat|awk 'BEGIN {RS=",\n"} /  /{oldname = $0; name = $0; gsub("  ", "_", name); print oldname; print name; system("sh mvname.sh " "\""oldname"\"" " " "\""name"\"");}'

# "$1" 处理包含空格的参数.  传参时也需要用""
echo "oldname: " "$1"  "    name: " "$2"
mv "$1" "$2"

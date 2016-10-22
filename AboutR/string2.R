library(stringr)
# 提取字符串 
print("提取字符串:")
a <- str_extract("123abc456def000", "\\d+")              # 提取第一个数字.
print(a)
a <- str_match("123abc456def000", "\\d+")              # 提取第一个数字.  同时返回最长字符串的子字符串.
print(a)
a <- str_extract_all("The Cat In The Hat", "[a-z]+")    # 提取所有小写字母, 结果返回一个列表.
print(a)
print(a[[1]])
a <- str_extract_all("The Cat In The Hat", regex("[a-z]+", TRUE))    # 不区分大小写
print(a)
a <- str_extract_all("a\nb\nc", "^.")
print(a)
a <- str_extract_all("a\nb\nc", regex("^.", multiline = TRUE))       # 多行.
print(a)

# 字符串替换
print("字符串替换:")
fruits <- c("one apple", "two pears", "three bananas")
print(str_replace(fruits, "[aeiou]", "-"))    # 每个元素的第一个aeiou都替换成 -
print(str_replace_all(fruits, "[aeiou]", "-"))    # 每个元素的所有的aeiou都替换成 -

print(str_replace(fruits, c("a", "e", "i"), "-"))  #  第一个元素的a替换成-，第二个元素的e替换成-，第三个元素的i替换成-
print(str_replace(fruits, "[aeiou]", c("1", "2", "3")))  # 第一个元素的aeiou替换成１，第二个替换成２，第三个替换成３,第三个参数个数需要与第一个相同. 
print(str_replace(fruits, "([aeiou])", "\\1\\1"))  #  将每个元素的aeiou替换成２个，即重复一次. 第二个参数的()是必须的.
print(fruits)                                 # fruits 并没有改变.

# 定位位置
print("定位位置:")
fruit <- c("apple", "banana", "pear", "pineapple")
print(str_locate(fruit, "$"))

numbers <- "1 and 2 and 4 and 456"
num_loc <- str_locate_all(numbers, "[0-9]+")[[1]]   # 匹配数字, 返回数字的起始位置.
print(num_loc)
a <- str_sub(numbers, num_loc[, "start"], num_loc[, "end"]);
print(a)

text_loc <- invert_match(num_loc)   # 返回不匹配数字的起始位置.
print(text_loc)
a <- str_sub(numbers, text_loc[, "start"], text_loc[, "end"]);
print(a);

#　字符串检测
print("字符串检测:")
pattern <- "a.b"
strings <- c("abb", "a.b")
print(str_detect(strings, pattern));         # 是否匹配.
print(str_detect(strings, fixed(pattern)))   # 非正则方式
print(str_detect(strings, coll(pattern)))

i <- c("I", "\u0130", "i")
print(i)
print(str_detect(i, regex('i', TRUE)))     # TRUE 是忽略大小写.
print(str_detect(i, fixed('i', TRUE)))
print(str_detect(i, coll("i", TRUE)))
print(str_detect(i, coll("i", TRUE, locale = "tr")))

#　匹配字符串的个数
print("匹配字符串的个数:")
fruit <- c("apple", "banana", "pear", "pineapple")
print(str_count(fruit, "a"))                # 计算每个元素包括字母a的数目.

# 单词边界
print("单词边界:")
words <- c("These are some word.")
a <- str_count(words, boundary("word"))     # 统计语句中单词的个数.
print(a)
a <- str_split(words, " ")[[1]]    # split, 最后一个带有标点. 
print(a)
a <- str_split(words, boundary("word"))[[1]]     # 最后一个不带标点
print(a)





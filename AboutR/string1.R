library(stringr);   # 加载包

# 大小写转换
print("大小写转换:")
dog <- "The quick brown dog"
upper <- str_to_upper(dog);
print(upper) 
lower <- str_to_lower(dog);
print(lower)
title <- str_to_title(dog);  # 首字母大写.
print(title)

# 字符串长度
print("字符串长度:")
print(str_length("字符串:1"))
print(str_length(letters))
print(str_length(NA))
print(str_length(factor("abc")))
print(str_length(c("i", "like", "programming", NA)))
u1 <- "\u00fc"
print(u1)
u2 <- stringi::stri_trans_nfd(u1)
print(u2)
print(str_length(u1))
print(str_length(u2))      # 长度不同.
print(str_count(u1))
print(str_count(u2))       # 字符个数相同


# 字符串连接
print("字符串连接:")
a <- str_c ("abc", "123")
print(a)
a <- str_c ("abc", "123", "678")
print(a)
a <- str_c("Letter: ", letters[1:5])       
print(a)
a <- str_c("Letter", letters[1:5], sep = ": ")   # 设置连接符.
print(a)
a <- str_c(letters[1:5], " is for ", "...")
print(a)
a <- str_c(letters[-26], " comes before ", letters[-1])
print(a)
a <- str_c(letters)
print(a)

# 字符串重复
print("字符串重复:")
fruit <- c("apple", "pear", "banana")
print(str_dup(fruit, 2))                 # 每个元素重复２次，然后连接起来.
print(str_dup(fruit, 1:3))               # 一次重复１次，２次，３次.
print(str_c("ba", str_dup("na", 0:5)))

# 字符串填充
print("字符串填充:")
print(str_pad(c("a", "abc", "abcdef"), 10))        # 每个元素填充为10位，默认左边补空格.
print(str_pad("a", c(5, 10, 20)))                  # 依次填充为5位，10位，20位, 默认填充字符是空格.
print(str_pad("a", 10, pad = c("-", "_", " ")))    # 依次填充为5位，10位，20位, 填充字符依次为 "-" "_" " "
print(str_pad("hadley", 3, pad = '-'))             # 超过3位，不做处理.
print(str_pad("hadley", width = 8, pad = '-'))

# 按位置提取子字符串
print("按位置提取子字符串:")
hw <- "Hadley Wickham"
print(str_sub(hw, 1, 6))
print(str_sub(hw, end = 6))
print(str_sub(hw, 8))
print(str_sub(hw, c(1, 8), c(6, 14)))         #  分别提取 (1, 6)  (8, 14)
print(str_sub(hw, -1))
print(str_sub(hw, -7))
print(str_sub(hw, end = -7))

# 字符串分割
print("字符串分割:")
fruits <- c("apples and oranges and pears and bananas", "pineapples and mangos and guavas")
print(str_split(fruits, " and "))
print(str_split(fruits, " and ", n = 2))                # 返回列表，分割成２块.
print(str_split(fruits, " and ", n = 3))
print(str_split_fixed(fruits, " and ", n = 3))          # 返回矩阵.

# 字符串排序  str_order(x, decreasing = FALSE, na_last = TRUE, locale = "", ...) 
print("字符串排序:")
print(str_order(letters, locale = "en"))
print(str_sort(letters, TRUE, locale = "en"))

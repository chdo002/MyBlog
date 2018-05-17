---
title: SQLite
date: 2018-05-17 14:33:11
tags:
---

最近要实现对SQLite的管理库，先记录如下：


# 基本知识
___
## 建表

```
CREATE TABLE database_name.table_name(
   column1 datatype  PRIMARY KEY(one or more columns),
   column2 datatype,
   column3 datatype,
   .....
   columnN datatype,
);
```
___
## 删表

```
DROP TABLE database_name.table_name;
```
___
## 插入列

```
INSERT INTO TABLE_NAME [(column1, column2, column3,...columnN)]  
VALUES (value1, value2, value3,...valueN);

INSERT INTO TABLE_NAME VALUES (value1,value2,value3,...valueN);
```
___
## Update 语句
```
UPDATE table_name
SET column1 = value1, column2 = value2...., columnN = valueN
WHERE [condition];
```
___
## Delete 语句
```
DELETE FROM table_name
WHERE [condition];
```
___
## 查询

```
SELECT column1, column2, columnN FROM table_name;

SELECT * FROM table_name;
```


# 子句

各个子句的排列顺序

```
SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY
```
___
## Where子句

```
SELECT column1, column2, columnN 
FROM table_name
WHERE [condition]
```
AND
___
```
SELECT column1, column2, columnN 
FROM table_name
WHERE [condition1] AND [condition2]...AND [conditionN];
```
OR
___
```
SELECT column1, column2, columnN 
FROM table_name
WHERE [condition1] OR [condition2]...OR [conditionN]
```
___
## Like 子句

SQLite 的 LIKE 运算符是用来匹配通配符指定模式的文本值。如果搜索表达式与模式表达式匹配，LIKE 运算符将返回真（true），也就是 1。这里有两个通配符与 LIKE 运算符一起使用：
百分号 （%）
下划线 （_）快速记忆  _ 代表就一个字符
百分号（%）代表零个、一个或多个数字或字符。下划线（_）代表一个单一的数字或字符。这些符号可以被组合使用。


```
SELECT column_list 
FROM table_name
WHERE column LIKE 'XXXX%'
```
___
## Glob 子句

Glob类似like，区别是like 不区分大小写，GLob区分大小写

星号 （ * ）对应 百分号 （%）问号 （?）对应 下划线 （ _ ）

___
## Limit 子句

```
SELECT column1, column2, columnN 
FROM table_name
LIMIT [no of rows]
```
___
```
SELECT column1, column2, columnN 
FROM table_name
LIMIT [no of rows] OFFSET [row num]
```
___
## Order By 子句

```
SELECT column-list 
FROM table_name 
[WHERE condition] 
[ORDER BY column1, column2, .. columnN] [ASC | DESC];
```
___
## Group By 子句

SQLite 的 GROUP BY 子句用于与 SELECT 语句一起使用，来对相同的数据进行分组。

在 SELECT 语句中，GROUP BY 子句放在 WHERE 子句之后，放在 ORDER BY 子句之前。

```
SELECT column-list
FROM table_name
WHERE [ conditions ]
GROUP BY column1, column2....columnN
ORDER BY column1, column2....columnN
```
___
## Having 子句

HAVING 子句允许指定条件来过滤将出现在最终结果中的分组结果。

WHERE 子句在所选列上设置条件，而 HAVING 子句则在由 GROUP BY 子句创建的分组上设置条件。

在一个查询中，HAVING 子句必须放在 GROUP BY 子句之后，必须放在 ORDER BY 子句之前。下面是包含 HAVING 子句的 SELECT 语句的语法：

```
SELECT column1, column2
FROM table1, table2
WHERE [ conditions ]
GROUP BY column1, column2
HAVING [ conditions ]
ORDER BY column1, column2
```

# 关键字

___
## Distinct 关键字

DISTINCT 关键字与 SELECT 语句一起使用，来消除所有重复的记录，并只获取唯一一次记录。

加了索引之后 distinct 比没加索引的 distinct 快。
加了索引之后 group by 比没加索引的 group by 快。
再来对比 ：distinct  和 group by

不管是加不加索引 group by 都比 distinct 快

distinct 和group by都需要排序，一样的结果集从执行计划的成本代价来看差距不大，但group by 还涉及到统计，所以应该需要准备工作。所以单纯从等价结果来说，选择distinct比较效率一些。


1.数据列的所有数据都一样，即去重计数的结果为1时，用distinct最佳

2.如果数据列唯一，没有相同数值，用group 最好

```
SELECT DISTINCT column1, column2,.....columnN 
FROM table_name
WHERE [condition]
```



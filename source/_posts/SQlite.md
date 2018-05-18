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
# 进阶

___
## PRAGMA

SQLite 的 PRAGMA 命令是一个特殊的命令，可以用在 SQLite 环境内控制各种环境变量和状态标志。一个 PRAGMA 值可以被读取，也可以根据需求进行设置。

pragma 修改的是预置的变量，不可以自定义变量

[具体有哪些环境变量查看这里](http://www.sqlite.org/pragma.html#pragma_application_id)

```
要查询当前的 PRAGMA 值，只需要提供该 pragma 的名字：

PRAGMA pragma_name;

要为 PRAGMA 设置一个新的值，语法如下：

PRAGMA pragma_name = value;
```
___
## 约束

常用约束

```
NOT NULL 约束：确保某列不能有 NULL 值。

DEFAULT 约束：当某列没有指定值时，为该列提供默认值。

UNIQUE 约束：确保某列中的所有值是不同的。

PRIMARY Key 约束：唯一标识数据库表中的各行/记录。

CHECK 约束：CHECK 约束确保某列中的所有值满足一定条件。
```
针对check，写个栗子
```
CREATE TABLE COMPANY3(
   ID INT PRIMARY KEY     NOT NULL,
   NAME           TEXT    NOT NULL,
   AGE            INT     NOT NULL,
   ADDRESS        CHAR(50),
   SALARY         REAL    CHECK(SALARY > 0)
);
```
___
## Joins

sqlite 支持的joins 有三种链接

### 交叉连接 - CROSS JOIN
```
如果不带WHERE条件子句，它将会返回被连接的两个表的笛卡尔积，返回结果的行数等于两个表行数的乘积
```

### 内连接 - INNER JOIN

INNER JOIN 产生的结果是AB的交集

```
SELECT * FROM TableA INNER JOIN TableB ON TableA.name = TableB.name
```

### 外连接 - OUTER JOIN

LEFT [OUTER] JOIN   产生表A的完全集，而B表中匹配的则有值，没有匹配的则以null值取代。
```
SELECT * FROM TableA LEFT OUTER JOIN TableB ON TableA.name = TableB.name
```
RIGHT [OUTER] JOIN  不支持
FULL [OUTER] JOINs 不支持  

___
## Unions 子句


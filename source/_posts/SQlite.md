---
title: SQLite
date: 2018-05-17 14:33:11
tags: http://www.runoob.com/sqlite/  
---

最近要实现对SQLite的管理库，先记录如下：

> 基于 [菜鸟](http://www.runoob.com/sqlite/) 整理

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

___
## Autoincrement

自增约束
```
sqlite> CREATE TABLE COMPANY(
   ID INTEGER PRIMARY KEY   AUTOINCREMENT,
   NAME           TEXT      NOT NULL,
   AGE            INT       NOT NULL,
   ADDRESS        CHAR(50),
   SALARY         REAL
);
```

在AUTOINCREMENT约束的字段没有赋值时，就会自动设定为最大的rowid+1，
自增字段只能是主键。

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

默认值
```
CREATE TABLE COMPANY(
   ID INT PRIMARY KEY     NOT NULL,
   NAME           TEXT    NOT NULL,
   AGE            INT     NOT NULL,
   ADDRESS        CHAR(50),
   SALARY         REAL    DEFAULT 50000.00
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

SQLite的 UNION 子句/运算符用于合并两个或多个 SELECT 语句的结果，不返回任何重复的行。

___
## 别名

可以暂时把表或列重命名为另一个名字，这被称为别名

```
SELECT column1, column2....
FROM table_name AS alias_name
WHERE [condition];
```

```
SELECT sum(column) as alias_name
FROM table_name
WHERE [condition];
```
___
##  触发器（Trigger）

SQLite 触发器（Trigger）是数据库的回调函数，它会在指定的数据库事件发生时自动执行/调用。

SQLite 的触发器（Trigger）可以指定在特定的数据库表发生 DELETE、INSERT 或 UPDATE 时触发，或在一个或多个指定表的列发生更新时触发。
SQLite 只支持 FOR EACH ROW 触发器（Trigger），没有 FOR EACH STATEMENT 触发器（Trigger）。因此，明确指定 FOR EACH ROW 是可选的。
WHEN 子句和触发器（Trigger）动作可能访问使用表单 NEW.column-name 和 OLD.column-name 的引用插入、删除或更新的行元素，其中 column-name 是从与触发器关联的表的列的名称。
如果提供 WHEN 子句，则只针对 WHEN 子句为真的指定行执行 SQL 语句。如果没有提供 WHEN 子句，则针对所有行执行 SQL 语句。
BEFORE 或 AFTER 关键字决定何时执行触发器动作，决定是在关联行的插入、修改或删除之前或者之后执行触发器动作。
当触发器相关联的表删除时，自动删除触发器（Trigger）。
要修改的表必须存在于同一数据库中，作为触发器被附加的表或视图，且必须只使用 tablename，而不是 database.tablename。
一个特殊的 SQL 函数 RAISE() 可用于触发器程序内抛出异常。


添加触发器
```
CREATE TRIGGER audit_log AFTER INSERT 
ON COMPANY
BEGIN
   INSERT INTO AUDIT(EMP_ID, ENTRY_DATE) VALUES (new.ID, datetime('now'));
END;
```

删除触发器
```
DROP TRIGGER trigger_name;
```

___
##  索引（Index）

索引（Index）是一种特殊的查找表，数据库搜索引擎用来加快数据检索。简单地说，索引是一个指向表中数据的指针。一个数据库中的索引与一本书后边的索引是非常相似的。
索引有助于加快 SELECT 查询和 WHERE 子句，但它会减慢使用 UPDATE 和 INSERT 语句时的数据输入。索引可以创建或删除，但不会影响数据。
索引也可以是唯一的，与 UNIQUE 约束类似，在列上或列组合上防止重复条目。

### 创建索引
```
CREATE INDEX index_name ON table_name;
```

### 单列索引
单列索引是一个只基于表的一个列上创建的索引。基本语法如下：
```
CREATE INDEX index_name
ON table_name (column_name);
```

### 唯一索引
使用唯一索引不仅是为了性能，同时也为了数据的完整性。唯一索引不允许任何重复的值插入到表中。基本语法如下：
```
CREATE UNIQUE INDEX index_name
on table_name (column_name);
```

### 组合索引
组合索引是基于一个表的两个或多个列上创建的索引。基本语法如下：
```
CREATE INDEX index_name
on table_name (column1, column2);
```

是否要创建一个单列索引还是组合索引，要考虑到您在作为查询过滤条件的 WHERE 子句中使用非常频繁的列。
如果值使用到一个列，则选择使用单列索引。如果在作为过滤的 WHERE 子句中有两个或多个列经常使用，则选择使用组合索引。

虽然索引的目的在于提高数据库的性能，但这里有几个情况需要避免使用索引。使用索引时，应重新考虑下列准则：
* 索引不应该使用在较小的表上。
* 索引不应该使用在有频繁的大批量的更新或插入操作的表上。
* 索引不应该使用在含有大量的 NULL 值的列上。
* 索引不应该使用在频繁操作的列上。

### indexed by 子句

```
SELECT|DELETE|UPDATE column1, column2...
INDEXED BY (index_name)
table_name
WHERE (CONDITION);
```

___
## Alter 命令

在 SQLite 中，除了重命名表和在已有的表中添加列，ALTER TABLE 命令不支持其他操作。


用来重命名已有的表的 ALTER TABLE 的基本语法如下：
```
ALTER TABLE database_name.table_name RENAME TO new_table_name;
```
用来在已有的表中添加一个新的列的 ALTER TABLE 的基本语法如下：
```
ALTER TABLE database_name.table_name ADD COLUMN column_def...;
```

___
## 事务（Transaction）

事务（Transaction）是一个对数据库执行工作单元。事务（Transaction）是以逻辑顺序完成的工作单位或序列，可以是由用户手动操作完成，也可以是由某种数据库程序自动完成。
事务（Transaction）是指一个或多个更改数据库的扩展。例如，如果您正在创建一个记录或者更新一个记录或者从表中删除一个记录，那么您正在该表上执行事务。重要的是要控制事务以确保数据的完整性和处理数据库错误。
实际上，您可以把许多的 SQLite 查询联合成一组，把所有这些放在一起作为事务的一部分进行执行。


事务的属性
事务（Transaction）具有以下四个标准属性，通常根据首字母缩写为 ACID：
* 原子性（Atomicity）：确保工作单位内的所有操作都成功完成，否则，事务会在出现故障时终止，之前的操作也会回滚到以前的状态。
* 一致性（Consistency)：确保数据库在成功提交的事务上正确地改变状态。
* 隔离性（Isolation）：使事务操作相互独立和透明。
* 持久性（Durability）：确保已提交事务的结果或效果在系统发生故障的情况下仍然存在

### 事务控制
使用下面的命令来控制事务：
```
BEGIN TRANSACTION：开始事务处理。
COMMIT：保存更改，或者可以使用 END TRANSACTION 命令。
ROLLBACK：回滚所做的更改。
```

事务控制命令只与 DML 命令 INSERT、UPDATE 和 DELETE 一起使用。他们不能在创建表或删除表时使用，因为这些操作在数据库中是自动提交的。

### BEGIN TRANSACTION 命令
事务（Transaction）可以使用 BEGIN TRANSACTION 命令或简单的 BEGIN 命令来启动。此类事务通常会持续执行下去，直到遇到下一个 COMMIT 或 ROLLBACK 命令。不过在数据库关闭或发生错误时，事务处理也会回滚。以下是启动一个事务的简单语法：
```
BEGIN;
or 
BEGIN TRANSACTION;
```

### COMMIT 命令
COMMIT 命令是用于把事务调用的更改保存到数据库中的事务命令。
COMMIT 命令把自上次 COMMIT 或 ROLLBACK 命令以来的所有事务保存到数据库。
COMMIT 命令的语法如下：

```
COMMIT;
or
END TRANSACTION;
```

### ROLLBACK 命令
ROLLBACK 命令是用于撤消尚未保存到数据库的事务的事务命令。
ROLLBACK 命令只能用于撤销自上次发出 COMMIT 或 ROLLBACK 命令以来的事务。
ROLLBACK 命令的语法如下：
```
ROLLBACK;
```
___
## SQLite 子查询

子查询或内部查询或嵌套查询是在另一个 SQLite 查询内嵌入在 WHERE 子句中的查询。

使用子查询返回的数据将被用在主查询中作为条件，以进一步限制要检索的数据。
子查询可以与 SELECT、INSERT、UPDATE 和 DELETE 语句一起使用，可伴随着使用运算符如 =、<、>、>=、<=、IN、BETWEEN 等。

以下是子查询必须遵循的几个规则：
* 子查询必须用括号括起来。
* 子查询在 SELECT 子句中只能有一个列，除非在主查询中有多列，与子查询的所选列进行比较。
* ORDER BY 不能用在子查询中，虽然主查询可以使用 ORDER BY。可以在子查询中使用 GROUP BY，功能与 ORDER BY 相同。
* 子查询返回多于一行，只能与多值运算符一起使用，如 IN 运算符。
* BETWEEN 运算符不能与子查询一起使用，但是，BETWEEN 可在子查询内使用。
### SELECT 语句中的子查询使用
子查询通常与 SELECT 语句一起使用。基本语法如下：
```
SELECT column_name [, column_name ]
FROM   table1 [, table2 ]
WHERE  column_name OPERATOR
      (SELECT column_name [, column_name ]
      FROM table1 [, table2 ]
      [WHERE])
```
#### 实例

假设 COMPANY 表有以下记录：

ID         |NAME       |AGE        |ADDRESS    |SALARY
 - | - | - | - | - |
1           |Paul       |32        |California |20000.0
2           |Allen      |25        |Texas      |15000.0
3           |Teddy      |23        |Norway     |20000.0
4           |Mark       |25        |Rich-Mond  |65000.0
5           |David      |27        |Texas      |85000.0
6           |Kim        |22        |South-Hall |45000.0
7           |James      |24        |Houston    |10000.0

现在，让我们检查 SELECT 语句中的子查询使用：
```
sqlite> SELECT * 
     FROM COMPANY 
     WHERE ID IN (SELECT ID 
                  FROM COMPANY 
                  WHERE SALARY > 45000) ;
```
这将产生以下结果:

ID        |NAME       |AGE        |ADDRESS    |SALARY
| - | - | - | - | - |
4          |Mark       |25         |Rich-Mond  |65000.0
5          |David      |27         |Texas      |85000.0

### INSERT 语句中的子查询使用
子查询也可以与 INSERT 语句一起使用。INSERT 语句使用子查询返回的数据插入到另一个表中。在子查询中所选择的数据可以用任何字符、日期或数字函数修改。

基本语法如下：
```
INSERT INTO table_name [ (column1 [, column2 ]) ]
           SELECT [ *|column1 [, column2 ]
           FROM table1 [, table2 ]
           [ WHERE VALUE OPERATOR ]
```

#### 实例
假设 COMPANY_BKP 的结构与 COMPANY 表相似，且可使用相同的 CREATE TABLE 进行创建，只是表名改为 COMPANY_BKP。

现在把整个 COMPANY 表复制到 COMPANY_BKP，语法如下：
```
sqlite> INSERT INTO COMPANY_BKP
     SELECT * FROM COMPANY 
     WHERE ID IN (SELECT ID 
                  FROM COMPANY) ;
```
### UPDATE 语句中的子查询使用
子查询可以与 UPDATE 语句结合使用。当通过 UPDATE 语句使用子查询时，表中单个或多个列被更新。

基本语法如下：
```
UPDATE table
SET column_name = new_value
[ WHERE OPERATOR [ VALUE ]
   (SELECT COLUMN_NAME
   FROM TABLE_NAME)
   [ WHERE) ]
```
#### 实例
假设，我们有 COMPANY_BKP 表，是 COMPANY 表的备份。

下面的实例把 COMPANY 表中所有 AGE 大于或等于 27 的客户的 SALARY 更新为原来的 0.50 倍：
```
sqlite> UPDATE COMPANY
     SET SALARY = SALARY * 0.50
     WHERE AGE IN (SELECT AGE FROM COMPANY_BKP
                   WHERE AGE >= 27 );
```
这将影响两行，最后 COMPANY 表中的记录如下：

ID         |NAME       |AGE        |ADDRESS     |SALARY
 - | - | - | - | - 
1          |Paul       |32         |California  |10000.0
2          |Allen      |25         |Texas       |15000.0
3          |Teddy      |23         |Norway      |20000.0
4          |Mark       |25         |Rich-Mond   |65000.0
5          |David      |27         |Texas       |42500.0
6          |Kim        |22         |South-Hall  |45000.0
7          |James      |24         |Houston     |10000.0

### DELETE 语句中的子查询使用
子查询可以与 DELETE 语句结合使用，就像上面提到的其他语句一样。

基本语法如下：
```
DELETE FROM TABLE_NAME
[ WHERE OPERATOR [ VALUE ]
   (SELECT COLUMN_NAME
   FROM TABLE_NAME)
   [ WHERE) ]
```
#### 实例
假设，我们有 COMPANY_BKP 表，是 COMPANY 表的备份。
下面的实例删除 COMPANY 表中所有 AGE 大于或等于 27 的客户记录：
```
sqlite> DELETE FROM COMPANY
     WHERE AGE IN (SELECT AGE FROM COMPANY_BKP
                   WHERE AGE > 27 );
```
这将影响两行，最后 COMPANY 表中的记录如下：

ID         |NAME       |AGE        |ADDRESS     |SALARY
 - | - | - | - | - 
2          |Allen      |25         |Texas      |15000.0
3          |Teddy      |23         |Norway     |20000.0
4          |Mark       |25         |Rich-Mond  |65000.0
5          |David      |27         |Texas      |42500.0
6          |Kim        |22         |South-Hall |45000.0
7          |James      |24         |Houston    |10000.0

___
## SQLite 日期 & 时间

SQLite 支持以下五个日期和时间函数：

序号	|函数	|实例
 - | - | - 
1	|date(timestring, modifier, modifier, ...)	|以 YYYY-MM-DD 格式返回日期。
2	|time(timestring, modifier, modifier, ...)	|以 HH:MM:SS 格式返回时间。
3	|datetime(timestring, modifier, modifier, ...)	|以 YYYY-MM-DD HH:MM:SS 格式返回。
4	|julianday(timestring, modifier, modifier, ...)	|这将返回从格林尼治时间的公元前 4714 年 11 月 24 日正午算起的天数。
5	|strftime(format, timestring, modifier, modifier, ...)	|这将根据第一个参数指定的格式字符串返回格式化的日期。具体格式见下边讲解。

上述五个日期和时间函数把时间字符串作为参数。时间字符串后跟零个或多个 modifier 修饰符。strftime() 函数也可以把格式字符串 format 作为其第一个参数。下面将为您详细讲解不同类型的时间字符串和修饰符。
### 时间字符串

一个时间字符串可以采用下面任何一种格式：

序号	|时间字符串	|实例
 - | - | - 
1	|YYYY-MM-DD	|2010-12-30
2	|YYYY-MM-DD HH:MM	|2010-12-30 12:10
3	|YYYY-MM-DD HH:MM:SS.SSS	|2010-12-30 12:10:04.100
4	|MM-DD-YYYY HH:MM	|30-12-2010 12:10
5	|HH:MM	|12:10
6	|YYYY-MM-DDTHH:MM	|2010-12-30 12:10
7	|HH:MM:SS	|12:10:01
8	|YYYYMMDD HHMMSS	|20101230 121001
9	|now	|2013-05-07

您可以使用 "T" 作为分隔日期和时间的文字字符。

### 修饰符（Modifier）

时间字符串后边可跟着零个或多个的修饰符，这将改变有上述五个函数返回的日期和/或时间。任何上述五大功能返回时间。修饰符应从左到右使用，下面列出了可在 SQLite 中使用的修饰符：
* NNN days
* NNN hours
* NNN minutes
* NNN.NNNN seconds
* NNN months
* NNN years
* start of month
* start of year
* start of day
* weekday N
* unixepoch
* localtime
* utc

###  格式化
SQLite 提供了非常方便的函数 strftime() 来格式化任何日期和时间。您可以使用以下的替换来格式化日期和时间：

替换	|描述
 - | - 
%d	|一月中的第几天，01-31
%f	|带小数部分的秒，SS.SSS
%H	|小时，00-23
%j	|一年中的第几天，001-366
%J	|儒略日数，DDDD.DDDD
%m	|月，00-12
%M	|分，00-59
%s	|从 1970-01-01 算起的秒数
%S	|秒，00-59
%w	|一周中的第几天，0-6 (0 is Sunday)
%W	|一年中的第几周，01-53
%Y	|年，YYYY
%%	|% symbol

### 实例
现在让我们使用 SQLite 提示符尝试不同的实例。下面是计算当前日期：
```
sqlite> SELECT date('now');
2013-05-07
```

下面是计算当前月份的最后一天：
```
sqlite> SELECT date('now','start of month','+1 month','-1 day');
2013-05-31
```
下面是计算给定 UNIX 时间戳 1092941466 的日期和时间：
```
sqlite> SELECT datetime(1092941466, 'unixepoch');
2004-08-19 18:51:06
```
下面是计算给定 UNIX 时间戳 1092941466 相对本地时区的日期和时间：
```
sqlite> SELECT datetime(1092941466, 'unixepoch', 'localtime');
2004-08-19 11:51:06
```
下面是计算当前的 UNIX 时间戳：
```
sqlite> SELECT strftime('%s','now');
1367926057
```
下面是计算美国"独立宣言"签署以来的天数：
```
sqlite> SELECT julianday('now') - julianday('1776-07-04');
86504.4775830326
```
下面是计算从 2004 年某一特定时刻以来的秒数：
```
sqlite> SELECT strftime('%s','now') - strftime('%s','2004-01-01 02:34:56');
295001572
```
下面是计算当年 10 月的第一个星期二的日期：
```
sqlite> SELECT date('now','start of year','+9 months','weekday 2');
2013-10-01
```
下面是计算从 UNIX 纪元算起的以秒为单位的时间（类似 strftime('%s','now') ，不同的是这里有包括小数部分）：
```
sqlite> SELECT (julianday('now') - 2440587.5)*86400.0;
1367926077.12598
```
在 UTC 与本地时间值之间进行转换，当格式化日期时，使用 utc 或 localtime 修饰符，如下所示：
```
sqlite> SELECT time('12:00', 'localtime');
05:00:00

sqlite>  SELECT time('12:00', 'utc');
19:00:00
```

## 常用函数

QLite 有许多内置函数用于处理字符串或数字数据。下面列出了一些有用的 SQLite 内置函数，且所有函数都是大小写不敏感，这意味着您可以使用这些函数的小写形式或大写形式或混合形式。欲了解更多详情，请查看 SQLite 的官方文档：

序号	|函数 & 描述
 - | - 
1	|SQLite COUNT 函数<br>SQLite COUNT 聚集函数是用来计算一个数据库表中的行数。
2	|SQLite MAX 函数<br>SQLite MAX 聚合函数允许我们选择某列的最大值。
3	|SQLite MIN 函数<br>SQLite MIN 聚合函数允许我们选择某列的最小值。
4	|SQLite AVG 函数<br>SQLite AVG 聚合函数计算某列的平均值。
5	|SQLite SUM 函数<br>SQLite SUM 聚合函数允许为一个数值列计算总和。
6	|SQLite RANDOM 函数<br>SQLite RANDOM 函数返回一个介于 -9223372036854775808 和 +9223372036854775807 之间的伪随机整数。
7	|SQLite ABS 函数<br>SQLite ABS 函数返回数值参数的绝对值。
8	|SQLite UPPER 函数<br>SQLite UPPER 函数把字符串转换为大写字母。
9	|SQLite LOWER 函数<br>SQLite LOWER 函数把字符串转换为小写字母。
10	|SQLite LENGTH 函数<br>SQLite LENGTH 函数返回字符串的长度。
11	|SQLite sqlite_version 函数<br>SQLite sqlite_version 函数返回 SQLite 库的版本。

在我们开始讲解这些函数实例之前，先假设 COMPANY 表有以下记录：

ID         |NAME       |AGE        |ADDRESS    |SALARY
 - | - | - | - | -
1          |Paul       |32         |California |20000.0
2          |Allen      |25         |Texas      |15000.0
3          |Teddy      |23         |Norway     |20000.0
4          |Mark       |25         |Rich-Mond  |65000.0
5          |David      |27         |Texas      |85000.0
6          |Kim        |22         |South-Hall |45000.0
7          |James      |24         |Houston    |10000.0

### SQLite COUNT 函数

SQLite COUNT 聚集函数是用来计算一个数据库表中的行数。下面是实例：
```
sqlite> SELECT count(*) FROM COMPANY;
```
上面的 SQLite SQL 语句将产生以下结果：

count(*)|
- |
7|

### SQLite MAX 函数
SQLite MAX 聚合函数允许我们选择某列的最大值。下面是实例：
```
sqlite> SELECT max(salary) FROM COMPANY;
```
上面的 SQLite SQL 语句将产生以下结果：

max(salary)|
-|
85000.0|

### SQLite MIN 函数
SQLite MIN 聚合函数允许我们选择某列的最小值。下面是实例：
```
sqlite> SELECT min(salary) FROM COMPANY;
```
上面的 SQLite SQL 语句将产生以下结果：

min(salary)|
-|
10000.0|

### SQLite AVG 函数
SQLite AVG 聚合函数计算某列的平均值。下面是实例：
```
sqlite> SELECT avg(salary) FROM COMPANY;
```
上面的 SQLite SQL 语句将产生以下结果：

avg(salary)|
-|
37142.8571428572|

### SQLite SUM 函数
SQLite SUM 聚合函数允许为一个数值列计算总和。下面是实例：
```
sqlite> SELECT sum(salary) FROM COMPANY;
```
上面的 SQLite SQL 语句将产生以下结果：

sum(salary)|
-|
260000.0|
### SQLite RANDOM 函数
SQLite RANDOM 函数返回一个介于 -9223372036854775808 和 +9223372036854775807 之间的伪随机整数。下面是实例：
```
sqlite> SELECT random() AS Random;
```
上面的 SQLite SQL 语句将产生以下结果：

Random|
-|
5876796417670984050|

### SQLite ABS 函数
SQLite ABS 函数返回数值参数的绝对值。下面是实例：
```
sqlite> SELECT abs(5), abs(-15), abs(NULL), abs(0), abs("ABC");
```
上面的 SQLite SQL 语句将产生以下结果：

abs(5)      |abs(-15)   |abs(NULL)  |abs(0)     |abs("ABC")
-|-|-|-|-
5           |15         |< null >       |0           |0.0

### SQLite UPPER 函数
SQLite UPPER 函数把字符串转换为大写字母。下面是实例：
```
sqlite> SELECT upper(name) FROM COMPANY;
```
上面的 SQLite SQL 语句将产生以下结果：

upper(name)|
-|
PAUL|
ALLEN|
TEDDY|
MARK|
DAVID|
KIM|
JAMES|
### SQLite LOWER 函数
SQLite LOWER 函数把字符串转换为小写字母。下面是实例：
```
sqlite> SELECT lower(name) FROM COMPANY;
```
上面的 SQLite SQL 语句将产生以下结果：

lower(name) |
-|
paul |
allen |
teddy|
mark|
david|
kim|
james|

### SQLite LENGTH 函数
SQLite LENGTH 函数返回字符串的长度。下面是实例：
```
sqlite> SELECT name, length(name) FROM COMPANY;
```
上面的 SQLite SQL 语句将产生以下结果：

NAME        |length(name)
-|-
Paul        |4
Allen       |5
Teddy       |5
Mark        |4
David       |5
Kim         |3
James       |5

### SQLite sqlite_version 函数
SQLite sqlite_version 函数返回 SQLite 库的版本。下面是实例：
```
sqlite> SELECT sqlite_version() AS 'SQLite Version';
```
上面的 SQLite SQL 语句将产生以下结果：

SQLite Version |
-|
3.6.20 |

## MySQL数据库`MyISAM`和`InnoDB`存储引擎的比较

MySQL有多种存储引擎，`MyISAM`和`InnoDB`是其中常用的两种。这里介绍关于这两种引擎的一些基本概念（非深入介绍）。

**`MyISAM`是MySQL的默认存储引擎，基于传统的`ISAM`(索引循序存取法(Index Sequential Access Mode))类型，支持全文搜索，但不是事务安全的，而且不支持外键。**

>每张MyISAM表存放在三个文件中：
+ `frm 文件存放表格定义`；
+ `数据文件是MYD (MYData)`；
+ `索引文件是MYI (MYIndex)`。

**`InnoDB`是事务型引擎，支持回滚、崩溃恢复能力、多版本并发控制、ACID事务，支持行级锁定（`InnoDB`表的行锁不是绝对的，如果在执行一个SQL语句时MySQL不能确定要扫描的范围，`InnoDB`表同样会锁全表，如`like`操作时的SQL语句），以及提供与Oracle类型一致的不加锁读取方式。**

>InnoDB存储它的表和索引在一个表空间中，表空间可以包含数个文件。

>主要区别：
+ `MyISAM`是非事务安全型的，而`InnoDB`是事务安全型的。
+ `MyISAM`锁的粒度是表级，而`InnoDB`支持行级锁定。
+ `MyISAM`支持全文类型索引，而`InnoDB`不支持全文索引。
+ `MyISAM`相对简单，所以在效率上要优于`InnoDB`，小型应用可以考虑使用`MyISAM`。
+ `MyISAM`表是保存成文件的形式，在跨平台的数据转移中使用MyISAM存储会省去不少的麻烦。
+ `InnoDB`表比`MyISAM`表更安全，可以在保证数据不会丢失的情况下，切换非事务表到事务表（`alter table tablename type=innodb`）。

>应用场景：
+ `MyISAM`管理非事务表。它提供高速存储和检索，以及全文搜索能力。如果应用中需要执行大量的SELECT查询，那么`MyISAM`是更好的选择。
+ `InnoDB`用于事务处理应用程序，具有众多特性，包括ACID事务支持。如果应用中需要执行大量的INSERT或UPDATE操作，则应该使用`InnoDB`，这样可以提高多用户并发操作的性能。

常用命令：

（1）查看表的存储类型（三种）：
```
show create table tablename
show table status from  dbname  where name=tablename
mysqlshow  -u user -p password --status dbname tablename
```
（2）修改表的存储引擎：
```
alter table tablename type=InnoDB
```
（3）启动mysql数据库的命令行中添加以下参数使新发布的表都默认使用事务：
```
--default-table-type=InnoDB
```
（4）临时改变默认表类型：
```
set table_type=InnoDB
show variables like 'table_type'
```
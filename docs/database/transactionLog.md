`innodb`事务日志包括`redo log`和`undo log`。
+ `redo log`是重做日志，提供前滚操作;
+ `undo log`是回滚日志，提供回滚操作。

>`undo log`不是`redo log`的逆向过程，其实它们都算是用来恢复的日志：
1. `redo log`通常是物理日志，记录的是数据页的物理修改，而不是某一行或某几行修改成怎样怎样，它用来恢复提交后的物理数据页(恢复数据页，且只能恢复到最后一次提交的位置)。
2. `undo log`用来回滚行记录到某个版本。
  + `undo log`一般是逻辑日志，根据每行记录进行记录;

## `redo log`
`redo log`包括两部分：
+ 是内存中的`日志缓冲(redo log buffer)`，该部分日志是易失性的；
+ 是磁盘上的重做`日志文件(redo log file)`，该部分日志是持久的。

在概念上，innodb通过`force log at commit`机制实现事务的持久性，即在事务提交的时候，必须先将该事务的所有事务日志写入到磁盘上的`redo log file`和`undo log file`中进行持久化。

为了确保每次日志都能写入到事务日志文件中，在每次将`log buffer`中的日志写入日志文件的过程中都会调用一次操作系统的`fsync`操作(即`fsync()`系统调用)。

因为`MariaDB/MySQL`是工作在用户空间的，`MariaDB/MySQL`的`log buffer`处于用户空间的内存中。

要写入到磁盘上的`log file`中(`redo:ib_logfileN`文件,`undo:share tablespace`或`.ibd`文件)，中间还要经过操作系统内核空间的`os buffer`，调用`fsync()`的作用就是将`OS buffer`中的日志刷到磁盘上的`log file`中。

也就是说，从`redo log buffer`写日志到磁盘的`redo log file`中，过程如下： 

![redo log](/images/redo.png)
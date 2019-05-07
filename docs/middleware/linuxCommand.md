## Linux下查看CPU、内存占用率

### `top`查看Linux资源占用情况

```
top - 14:49:25 up 195 days,  5:58,  1 user,  load average: 0.00, 0.01, 0.05
Tasks:  76 total,   1 running,  75 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.3 us,  0.3 sy,  0.0 ni, 99.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem :  1883616 total,   125268 free,   261764 used,  1496584 buff/cache
KiB Swap:        0 total,        0 free,        0 used.  1413156 avail Mem 

  PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND              
29725 root      20   0  612448  13528   1996 S  0.3  0.7  67:43.23 barad_agent          
    1 root      20   0   43308   3084   1848 S  0.0  0.2  15:34.29 systemd              
```

>+ PID - 进程标示号
+ USER - 进程所有者
+ PR - 进程优先级
+ NI - 进程优先级别数值
+ VIRT - 进程占用的虚拟内存值
+ RES - 进程占用的物理内存值
+ SHR - 进程使用的共享内存值
+ S - 进程的状态，其中S表示休眠，R表示正在运行，Z表示僵死
+ %CPU - 进程占用的CPU使用率
+ %MEM - 进程占用的物理内存百分比
+ TIME＋ - 进程启动后占用的总的CPU时间
+ Command - 进程启动的启动命令名称


### free命令查看内存使用情况

```
[root@VM_0_9_centos ~]# free 
              total        used        free      shared  buff/cache   available
Mem:        1883616      266664      120228         524     1496724     1408240
Swap:             0           0           0
```

### ps命令查看CPU状态

ps（process status）命令用来汇报处理器状态信息，示例用法：

```
ps ux
ps -H -eo user,pid,ppid,tid,time,%cpu,cmd --sort=%cpu
```

上述命令：第一条按默认方式查看状态，第二条命令指定显示列和排序方式
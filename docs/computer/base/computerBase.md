计算机就是晶体管、电路板组装起来的电子设备，无论是图形图像的渲染、网络远程共享，还是大数据计算，归根结底都是`0`与`1`的信号处理。由于信息存储和逻辑计算的元数据，只能是`0`和`1`；

因此，计算机世界的基础是`0`、`1`组成的二进制；

而计算机最主要的功能是计算，那么二进制之间`加减`是如何计算的呢？

在计算机世界,负数与正数表示是一致，只是负数采用最右边一位二进制位`1`表示负数;

那么二进制数字加减全部转为**二进制的补码加法运算；**

>而负数参与是通过负数二进制表示的补码进行的，且符号位也参与运算，溢出位抛弃；

**(负数的补码是反码加1的结果，正数的补码是本身)**


Example:

```
   00100011(35)   补码
 + 11011011(-37)  补码
 _________________
   11111110       补码

负数:最左1位表示负,右7位值取反+1：-(0000001 + 1) = -2

```

>+ 8个bit组成一个单位，称为一个字节，即1个Byte，简写为B；
+ `1024个Byte`，简写为`KB`；
+ `1024个KB`，简写为`MB`；
+ `1024个MB`，简写为`GB`；
+ `1024个GB`，简写为`TB`；
+ `1024个TB`，简写为`PB`；
+ `1024个PB`，简写为`EB`；
+ `1024个EB`，简写为`ZB`；
+ `1024个ZB`，简写为`YB`；

## 位移运算

向右移动`1`位近似表示`除以2`，十进制的奇数转化为二进制数后，在向右移时，`最右边的1`将被直接抹去，说明向右移对于奇数并非完全相当于除以2；

在左移`<<`与右移`>>`两种运算中，符号位参与移动，除负数往右移动，`高位补1`之外，其他情况均在`空位处0`；

>Example： 带符号位位移运算

正数/负数|向左移`<<`1位|向右移`>>`1位|
--|--|--|
正数（35的补码`00100011`）|`01000110 = 2^6 + 2^2 + 2^1 = 70`|`00010001 = 2^4 + 2^0 = 17`（近似除以2）|
负数（-35的补码`11011101`）|`10111010 = 1(1000101 + 1) = -70`|`11101110 = 1(0010001 + 1) = -18`|
正数（99的补码`01100011`）|`11000110 = -58`|`00110001 = 49`|
负数（-99的补码`10011101`）|`00111010 = 58`|`11001110 = -50`|


`>>>`无符号向右移动（**不存在`<<<`无符号向左移动**），当向右移动时，正负数高位均补0，正数不断向右移动的最小值是0，而负数不断向右移动的最小值是1。

>**无符号即藐视符号位，符号位失去特权，必须像其他平常的数字位一起向右移动，高位直接补0，根本不关心是正数还是负数。**

>Example：无符号位移运算

正数/负数|向右移`>>>`1位|向右移`>>>`2位|向右移`>>>`3位|
--|--|--|--|
正数（35的补码`0010 0011`）| `00010001 = 17` | `00001000 = 8` | `00000100 = 4` |
负数（-35的补码`1101 1101`）| `01101110 = 110` | `00110111 = 55` | `00011011 = 27` |


>为什么负数不断地无符号向右移动的最小值是1呢？

在实际编程中，位移运算仅作用于整型（32位）和长整型（64位）的数上，假如在整型数上移动的位数是32位，无论是否带符号以及移动方向，均为本身。

因为移动的位数是一个`mod 32`的结果，即`35 >> 1`与`35 >> 33` 是一样的结果。如果长整型，`mod 64`，即`35 << 1`与`35<<65`的结果是一样的。

负数在符号的往右移动63位时，除最右边为1外，左边均为0，达到最小值1，如果`>>>64`，则为其原数值本身；


>位运算其他操作：
+ 按位取反（~）
+ 按位与（&），典型场景是获取网段值，IP地址与掩码`255.255.255.0`进行按位与运算得到高24位，即为当前IP的网段。（逻辑与`&&`，有短路功能）
+ 按位或（|）
+ 按位异或（^）

### 字符集与乱码

>如何将0和1表示成我们看到的文字呢？

从26个英文字母说起，大小写共52个，加上10个数字达到62个，考虑到还有特殊字符（如：`！@#￥%……&*｛｝|`等）和不可见的控制字符，必然超过64个，“64”即2的6次方，使用刚才的0与1组合，至少是7组连续的信号量！

计算机在诞生之初对于存储和传输介质实在没有什么信心，所以预留了一个bit用于奇偶校验，这就是1个Byte（字节）由8个bit组成的来历，也就是`ASCII码`；

汉字的字符集，由于ASCII码先入为主，必须在它基础上继续编码，而一个字节只能表示128个字符，所以采用双字节进行编码，因此早期使用的标准`GB2312`收录了`6763`个常用汉字；

GBK (k是拼音kuo的首字母，是扩展的意思)支持繁体，兼容GB2312。GB18030是国家标准，在技术上是GBK的超集并与之兼容。

>1994年正式公布Unicode，为每种语言中的每个字符都设定了唯一编码，以满足跨语言的交流，分为编码方式和实现方式。
+ 编码格式：UTF-8、UTF-16、UTF-32，UTF（Unicode Transformation Format）即Unicode字符集转换格式，可以理解为对Unicode的压缩方式；


### CPU与内存

CPU（Central Processing Unit）是一块超大规模的集成电路板，是计算机的核心部件，承载着计算机的主要运算和控制功能，是计算机指令的最终解释模块和执行模块；

硬件包括基板、核心、针脚，基板用来固定核心和针脚，针脚通过基板上的基座连接电路信号，CPU核心的工艺极度精密，达到10纳米级别；


>CPU内部结构，由控制器、运算器和寄存器组成;
+ 控制器，由控制单元、指令译码器、指令寄存器组成；
  + 控制单元是CPU的大脑，由时序控制和指令控制等组成；
  + 指令译码器是在控制单元的协调下完成指令读取、分析并交由运算器执行等操作；
  + 指令寄存器是存储指令即，当前流行的指令集包括X86、SSE、MMX等；
+ 运算器，核心是算术逻辑运算单元，即ALU；能够执行算术运算或逻辑运算等各种命令，运算单元会从寄存器中提取或存储数据。
+ 寄存器，最著名的寄存器是CPU的高速缓存L1、L2，缓存容量是在组装计算机时必问的两个CPU性能问题之一。
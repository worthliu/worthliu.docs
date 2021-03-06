
TCP协议作为一个可靠的面向流的传输协议，其可靠性和流量控制由滑动窗口协议保证，而拥塞控制则由控制窗口结合一系列的控制算法实现。

## 滑动窗口协议
    
>`滑动窗口协议`:
1. "窗口"对应的是一段可以被发送者发送的字节序列，其连续的范围称之为"窗口"；
2. "滑动"则是指这段`"允许发送的范围"`是可以随着发送的过程而变化的，方式就是按顺序"滑动"。

+ TCP协议的两端分别为发送者A和接收者B，由于是全双工协议，因此A和B应该分别维护着一个独立的`发送缓冲区`和`接收缓冲区`;
  + 由于对等性（A发B收和B发A收是相同的）；
+ 发送窗口是`发送缓存`中的一部分，是可以被`TCP`协议发送的那部分，其实应用层需要发送的所有数据都被放进了发送者的`发送缓冲区`；
+ 发送窗口中相关的有四个概念：
  + 已发送并收到确认的数据（不再发送窗口和发送缓冲区之内）
  + 已发送但未收到确认的数据（位于发送窗口之中）
  + 允许发送但尚未发送的数据
  + 发送窗口外发送缓冲区内暂时不允许发送的数据；
+ 每次成功发送数据之后，发送窗口就会在发送缓冲区中按顺序移动，将新的数据包含到窗口中准备发送；

TCP建立连接的初始，B会告诉A自己的接收窗口大小，比如为`20`,字节`31-50`为发送窗口:

![tcp5-15](/images/tcp5-15.png)

A发送`11`个字节后，发送窗口位置不变，B接收到了乱序的数据分组：

![tcp5-16](/images/tcp5-16.png)

只有当A成功发送了数据，即发送的数据得到了B的确认之后，才会移动滑动窗口离开已发送的数据；

同时B则确认连续的数据分组，对于乱序的分组则先接收下来，避免网络重复传递：

![tcp5-18](/images/tcp5-18.png)


## 流量控制
>流量控制方面主要有两个要点:
+ TCP利用滑动窗口实现流量控制的机制；
+ 如何考虑流量控制中的传输效率。

1. 流量控制
  + 所谓流量控制,主要是接收方传递信息给发送方,使其不要发送数据太快,是一种端到端的控制。
  + 主要的方式就是返回的`ACK`中会包含自己的接收窗口的大小，并且利用大小来控制发送方的数据发送：
  + 这里面涉及到一种情况，如果B已经告诉A自己的缓冲区已满，于是A停止发送数据；**等待一段时间后，B的缓冲区出现了富余，于是给A发送报文告诉A我的rwnd大小为400，但是这个报文不幸丢失了，于是就出现A等待B的通知||B等待A发送数据的死锁状态**。
    + 为了处理这种问题，`TCP引入了持续计时器（Persistence timer）`;
    + 当A收到对方的零窗口通知时，就启用该计时器，时间到则发送一个1字节的探测报文，对方会在此时回应自身的接收窗口大小，如果结果仍未0，则重设持续计时器，继续等待。
2. 传递效率
  + 一个显而易见的问题是：单个发送字节单个确认，和窗口有一个空余即通知发送方发送一个字节，无疑增加了网络中的许多不必要的报文,所以我们的原则是**尽可能一次多发送几个字节**，或者**窗口空余较多的时候通知发送方一次发送多个字节**。
  + 对于前者我们广泛使用`Nagle算法`，即：
   + 若发送应用进程要把发送的数据逐个字节地送到TCP的发送缓存，则`发送方就把第一个数据字节先发送出去，把后面的字节先缓存起来`；
   + 当发送方收到第一个字节的确认后（也得到了网络情况和对方的接收窗口大小），`再把缓冲区的剩余字节组成合适大小的报文发送出去`；
   + 当到达的数据已达到发送窗口大小的一半或以达到报文段的最大长度时，就立即发送一个报文段；
  + 对于后者我们往往的做法是让接收方等待一段时间，或者接收方获得足够的空间容纳一个报文段或者等到接受缓存有一半空闲的时候，再通知发送方发送数据。

## 拥塞控制

网络中的链路容量和交换结点中的缓存和处理机都有着工作的极限，当网络的需求超过它们的工作极限时，就出现了拥塞。

拥塞控制就是防止过多的数据注入到网络中，这样可以使网络中的路由器或链路不致过载。

>常用的方法就是：
1. 慢开始、拥塞控制
2. 快重传、快恢复

一切的基础还是慢开始，这种方法的思路是这样的：
+ 发送方维持一个叫做`拥塞窗口`的变量，该变量和接收端口共同决定了发送者的发送窗口；
+ 当主机开始发送数据时，避免一下子将大量字节注入到网络，造成或者增加拥塞，选择发送一个`1字节的试探报文`；
+ 当收到第一个字节的数据的确认后，就发送`2个字节的报文`；
+ 若再次收到2个字节的确认，则发送`4个字节`，**依次递增2的指数级**；
+ 最后会达到一个提前预设的“慢开始门限”，比如`24`，即一次发送了24个分组，此时遵循下面的条件判定：
  + cwnd < ssthresh， 继续使用慢开始算法；
  + cwnd > ssthresh，停止使用慢开始算法，改用拥塞避免算法；
  + cwnd = ssthresh，既可以使用慢开始算法，也可以使用拥塞避免算法；

>所谓拥塞避免算法就是：
+ **每经过一个往返时间RTT就把发送方的拥塞窗口+1，即让拥塞窗口缓慢地增大，按照线性规律增长**；
+ 当出现网络拥塞，比如丢包时，将慢开始门限设为原先的一半，然后将cwnd设为1，执行慢开始算法（较低的起点，指数级增长）；

上述方法的目的是**在拥塞发生时循序减少主机发送到网络中的分组数，使得发生拥塞的路由器有足够的时间把队列中积压的分组处理完毕**。

`慢开始`和`拥塞控制算法`常常作为一个整体使用;

而`快重传`和`快恢复`则是为了减少因为拥塞导致的数据包丢失带来的重传时间，从而避免传递无用的数据到网络。

>快重传的机制是：
+ 接收方建立这样的机制，如果一个包丢失，则对后续的包继续发送针对该包的重传请求；
+ 一旦发送方接收到三个一样的确认，就知道该包之后出现了错误，立刻重传该包；
+ 此时发送方开始执行“快恢复”算法：
  + 慢开始门限减半；
  + cwnd设为慢开始门限减半后的数值；
  + 执行拥塞避免算法（高起点，线性增长）；

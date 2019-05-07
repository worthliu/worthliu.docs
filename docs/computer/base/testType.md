# 测试类型

# 回归测试（Regression Testing）

**回归测试是指修改了旧代码后，重新进行测试以确认修改没有引入新的错误或导致其他代码产生错误。**自动回归测试将大幅降低系统测试、维护升级等阶段的成本。

回归测试作为软件生命周期的一个组成部分，在整个软件测试过程中占有很大的工作量比重，软件开发的各个阶段都会进行多次回归测试。在渐进和快速迭代开发中，新版本的连续发布使回归测试进行的更加频繁，而在极端编程方法中，更是要求每天都进行若干次回归测试。

因此，通过选择正确的回归测试策略来改进回归测试的效率和有效性是很有意义的。


# 集成测试（Integration Testing）

**集成测试，也叫组装测试或联合测试。在单元测试的基础上，将所有模块按照设计要求（如根据结构图）组装成为子系统或系统，进行集成测试。**
　　
集成测试（也叫组装测试，联合测试）是**单元测试**的逻辑扩展。

它最简单的形式是：把两个已经测试过的单元组合成一个组件，测试它们之间的接口。从这一层意义上讲，组件是指多个单元的集成聚合。在现实方案中，许多单元组合成组件，而这些组件又聚合为程序的更大部分。方法是测试片段的组合，并最终扩展成进程，将模块与其他组的模块一起测试。最后，将构成进程的所有模块一起测试。此外，如果程序由多个进程组成，应该成对测试它们，而不是同时测试所有进程。

# 功能测试（Function Testing）

**功能测试就是对产品的各功能进行验证，根据功能测试用例，逐项测试，检查产品是否达到用户要求的功能。**

# 内存泄漏测试（Memory Leak Testing）

**内存泄漏也称作“存储渗漏”，用动态存储分配函数动态开辟的空间，在使用完毕后未释放，结果导致一直占据该内存单元。直到程序结束。（其实说白了就是该内存空间使用完毕之后未回收）即所谓内存泄漏。**

内存泄漏形象的比喻是“操作系统可提供给所有进程的存储空间正在被某个进程榨干”，最终结果是程序运行时间越长，占用存储空间越来越多，最终用尽全部存储空间，整个系统崩溃。

所以“内存泄漏”是从操作系统的角度来看的。这里的存储空间并不是指物理内存，而是指`虚拟内存大小`，这个虚拟内存大小取决于`磁盘交换区设定的大小`。由程序申请的一块内存，如果没有任何一个指针指向它，那么这块内存就泄漏了。

# Alpha测试 & Beta测试

>+ **Alpha测试是用户在开发环境下的测试，或者是开发内部的用户在模拟实际环境下的测试；**
+ **Beta测试是由软件的一个或多个用户在实际使用环境下进行的测试。**

　
>两者区别：
+ Alpha测试由开发人员或测试人员在场，可随时记录下错误和使用中出现的问题。
+ Beta测试开发人员和测试人员都不在场。
所以，只有当α测试达到一定的可靠程度时，才能开始β测试。它处在整个测试的最后阶段。

# 软件压力测试（Software testing pressure)

软件压力测试是一种基本的质量保证行为，它是每个重要软件测试工作的一部分。

软件压力测试的基本思路很简单：**不是在常规条件下运行手动或自动测试，而是在计算机数量较少或系统资源匮乏的条件下运行测试。通常要进行软件压力测试的资源包括内部内存、CPU 可用性、磁盘空间和网络带宽。**

# 负载测试（Load testing）

**通过测试系统在资源超负荷情况下的表现，以发现设计上的错误或验证系统的负载能力。**

在这种测试中，将使测试对象承担不同的工作量，以评测和评估测试对象在不同工作量条件下的性能行为，以及持续正常运行的能力。负载测试的目标是确定并确保系统在超出最大预期工作量的情况下仍能正常运行。

此外，负载测试还要评估性能特征。例如，响应时间、事务处理速率和其他与时间相关的方面。

# 性能测试（performance testing）

性能测试是通过自动化的测试工具模拟多种正常、峰值以及异常负载条件来对系统的各项性能指标进行测试。

负载测试和压力测试都属于性能测试，两者可以结合进行。通过负载测试，确定在各种工作负载下系统的性能，目标是测试当负载逐渐增加时，系统各项性能指标的变化情况。

压力测试是通过确定一个系统的瓶颈或者不能接受的性能点，来获得系统能提供的最大服务级别的测试。

# 验收测试（Acceptance testing）

验收测试是部署软件之前的最后一个测试操作。在软件产品完成了单元测试、集成测试和系统测试之后，产品发布之前所进行的软件测试活动。它是技术测试的最后一个阶段，也称为交付测试。验收测试的目的是确保软件准备就绪，并且可以让最终用户将其用于执行软件的既定功能和任务。

在工程及其他相关领域中，验收测试是指确认一系统是否符合设计规格或契约之需求内容的测试，可能会包括化学测试、物理测试或是性能测试。

在系统工程中验收测试可能包括在系统（例如一套软件系统、许多机械零件或是一批化学制品）交付前的黑箱测试。

软件开发者常会将系统开发者进行的验收测试和客户在接受产品前进行的验收测试分开。

后者一般会称为使用者验收测试、终端客户测试、实机（验收）测试、现场（验收）测试。在进行主要测试程序之前，常用冒烟测试作为一个此阶段的验收测试。

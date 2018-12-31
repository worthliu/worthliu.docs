### JS闭包
>`Javascript`特殊的变量作用域(全局变量和局部变量)
+ 在函数内部可以直接读取全局变量；
+ 在函数外部自然无法读取函数内的局部变量；

**函数内部声明变量的时候，一定要使用var命令，如果不用的话，实际上声明了一个全局变量；**

### 如何从外部读取局部变量:

由于`Javascript`语言特有的“链式作用域”结构，子对象会一级一级地向上寻找所有父对象的变量；
所以，**父对象的所有变量，对子对象都是可见的**，反之不成立；

（子对象内部的局部变量对于外面都是不可见也是不可使用的）


**闭包，就是能够读取其他函数内部变量的函数；在一个函数内部定义一个函数并作为返回值返回给外部操作；**

>用途:
+ 可以读取函数内部的变量；
+ 让函数内部的变量始终保持在内存中；
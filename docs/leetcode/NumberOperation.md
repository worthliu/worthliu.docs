写一个函数，求两个整数之和，要求在函数体内不得使用`+`，`-`，`*`，`/`四则运算符号。

### 题解

计算机编程语言中，数据运算除了四则运算外，就剩下位运算！

从上述题目中，不能用四则运算，那么需要使用位运算进行数之间的加减；

首先做十进制的加法时，是如何做的？

>+ 只做个位相加不进位；
+ 做进位；
+ 把前面处理结果加起来；

同样的对于二进制而言也是适用的！

>1. 不考虑进位对每一位相加，0加0、1加1的结果都0，0加1、1加0的结果都是1。这跟异或处理结果一致；
2. 第二步进位，对0加0、0加1、1加0而言，都不会产生进位，只有1加1时，会向前产生一个进位。
  1. 相当与两个数先做位与运算，再向左移动一位；
3. 第三步把前面两个步骤的结果相加，重复前面两步，直到不产生进位为止；

### 拓展

假设不使用新的变量，交换两个变量的值。比如有两个变量a、b，期望交换它们的值；

>基于加减法
+ a = a + b
+ b = a - b
+ a = a - b

>基于异或运算
+ a = a ^ b
+ b = a ^ b
+ a = a ^ b

## solution

```
	public int add(int num1, int num2) {
        int sum, carry;
        do {
            sum = num1 ^ num2;
            carry = (num1 & num2) << 1;
            //
            num1 = sum;
            num2 = carry;
        } while (num2 != 0);
        return num1;
    }
```

写一个函数，输入n,求斐波那契数列的第n项。

斐波那契数列的定义如下：
```
f(n)=
+ 0 , n = 0
+ 1 , n = 1
+ f(n - 1) + f(n - 2) , n > 1
```

## solution

递归：
```
public int fibonacciRecusion(int n){
        if(n <= 0){
            return 0;
        }else if(n == 1){
            return 1;
        }
        
        return fibonacciRecusion(n - 1) + fibonacciRecusion(n - 2);
    }
```

非递归

```
public int fibonacci(int n){
    int[] resNums = {0, 1};

    if(n < 0){
        return -1;
    }else if(n < 2){
        return resNums[n];
    }

    int fibOne = 0;
    int fibTwo = 1;
    int fibN = 0;
    for(int ind = 2; ind <= n; ++ind){
        fibN = fibOne + fibTwo;
        fibOne = fibTwo;
        fibTwo = fibN;
    }
    return fibN;
}
```
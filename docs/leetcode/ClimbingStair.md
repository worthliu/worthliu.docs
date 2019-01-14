You are climbing a stair case. It takes n steps to reach to the top.

Each time you can either climb 1 or 2 steps. In how many distinct ways can you climb to the top?

>Note: Given n will be a positive integer.

Example 1:

```
Input: 2
Output: 2
Explanation: There are two ways to climb to the top.
1. 1 step + 1 step
2. 2 steps
```
Example 2:

```
Input: 3
Output: 3
Explanation: There are three ways to climb to the top.
1. 1 step + 1 step + 1 step
2. 1 step + 2 steps
3. 2 steps + 1 step
```

## solution

>+ 只有1级台阶，只有一种跳法；
+ 有2级台阶，有两种跳的方法了：一种是分两次跳，每次跳1级；另外一种就是一次跳2级；
+ 当台阶为n时，第一次跳的时候就有两种不同的选择：
  + 一是第一次只跳1级，此时跳法数目等于后面剩下的n-1级台阶的跳法数目，即为f(n-1)；
  + 另一种选择是第一次跳2级，此时跳法数目等于后面剩下的n-2级台阶的跳法数目，即为f(n-2);
  + 因此n级台阶的不同跳法的总数f(n)=f(n-1)+f(n-2)；

```
public int climbStairs(int n) {
        if(n < 0){
            return -1;
        }else if(n < 2){
            return 1;
        }
        
        int climbOne = 1;
        int climbTwo = 1;
        int climbNum = 0;
        for(int ind = 2; ind <= n; ind++){
            climbNum = climbOne + climbTwo;
            climbOne = climbTwo;
            climbTwo = climbNum;
        }
        return climbNum;
    }
```
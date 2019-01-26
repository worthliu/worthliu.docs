输入一个正数s,打印出所有和为s的连续z正整数序列(至少含有两个数)。

Example：

```
Array : {1, 2, 3, 4, 5, 6, 7, 8, 11, 15}

target : 15

result : 1+2+3+4+5=4+5+6=7+8=15
```

### 题解

>+ 用两个数small和big分别表示序列的最小值和最大值。
+ 首先把small初始化为1，big初始化为2；
+ 如果从small到big的序列的和大于s，可以从序列中去掉较小的值，就是增大small的值；
+ 如果从small到big的序列的和小于s，可以增大big，让这个序列包含更多的数字。
由于这个序列至少要有两个数字，需要一直增加small到(1+s)/2为止；

## solution

```
	public List<List<Integer>> numPair(int sum){
        List<List<Integer>> resNums = new ArrayList<>();
        if(sum < 3){
            return null;
        }
        int small = 1;
        int big = 2;
        int mid = (1 + sum) / 2;
        int curSum = small + big;
        while (small < mid){
            if(curSum == sum){
                resNums.add(printContinuSequence(small, big));
            }
            //
            while (curSum > sum && small < mid){
                curSum -= small;
                small++;
                if(curSum == sum){
                    resNums.add(printContinuSequence(small, big));
                }
            }
            //
            big++;
            curSum += big;
        }
        return resNums;
    }

    private List<Integer> printContinuSequence(int small, int big) {
        List<Integer> resList = new ArrayList<>(big - small + 1);
        for(int ind = small; ind <= big; ++ind){
            resList.add(ind);
        }
        return resList;
    }
```
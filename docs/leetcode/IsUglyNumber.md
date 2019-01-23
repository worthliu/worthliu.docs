编写一个程序判断给定的数是否为丑数。

丑数就是只包含质因数 2, 3, 5 的正整数。

示例 1:
```
输入: 6
输出: true
解释: 6 = 2 × 3
```
示例 2:
```
输入: 8
输出: true
解释: 8 = 2 × 2 × 2
```
示例 3:
```
输入: 14
输出: false 
解释: 14 不是丑数，因为它包含了另外一个质因数 7。
```

说明：
```
1 是丑数。
输入不会超过 32 位有符号整数的范围: [−2^31,  2^31 − 1]。
```

### 题解

一个数m是否另一个数n的因子，指n能被m整除。就是`n%m==0`；

根据丑数的定义，丑数只能被2、3、5整除, 丑数`m>0`。

既是：一个数能被2整除，把它连续除以2；能被3整除，连续除以3；能被5整除，就除以连续5；

最后得到是1，这个数就是丑数，否则不是；


---

>+ 创建一个数组保存已计算过的丑数，并保证数组的丑数排好序；
+ 假设数组中已有若干个丑数排好序后存放在数组中，并且把已有最大的丑数记作M；
+ 那么下一个丑数肯定是前面某一个丑数乘以2、3或者5的结果，所以首先把已有的每个丑数乘以2。在乘以2的时候，能得到若干个小于或等于M的结果。由于是按照顺序生成的，小于或等于M肯定已经在数组中了，不做考虑；把得到第一个大于M的丑数记为M2；
+ 同样把已有的每个丑数乘以3和5，得到第一个大于M的丑数记为M3和M5；
+ 那么下一个丑数应该是M2、M3、M5中最小值；

## solution

```
	public boolean isUgly(int num){
        while (num % 2 == 0){
            num /= 2;
        }
        //
        while (num % 3 == 0){
            num /= 3;
        }

        while (num % 5 == 0){
            num /= 5;
        }

        return num == 1;
    }
```

```
    public int getNThUglyNum(int num){
        if(num <= 0){
            return 0;
        }
        //
        int[] uglyArray = new int[num];
        uglyArray[0] = 1;
        int ugly2 = uglyArray[0];
        int ugly3 = uglyArray[0];
        int ugly5 = uglyArray[0];
        //
        int ind = 1;
        int ugly2Ind = 0;
        int ugly3Ind = 0;
        int ugly5Ind = 0;
        while (ind < num){
            for(; ugly2Ind < ind; ugly2Ind++){
                if(uglyArray[ugly2Ind] * 2 > uglyArray[ind - 1]){
                    ugly2 = uglyArray[ugly2Ind] * 2;
                    break;
                }
            }
            //
            for(; ugly3Ind < ind; ugly3Ind++){
                if(uglyArray[ugly3Ind] * 3 > uglyArray[ind - 1]){
                    ugly3 = uglyArray[ugly3Ind] * 3;
                    break;
                }
            }
            //
            for(; ugly5Ind < ind; ugly5Ind++){
                if(uglyArray[ugly5Ind] * 5 > uglyArray[ind - 1]){
                    ugly5 = uglyArray[ugly5Ind] * 5;
                    break;
                }
            }
            //
            int minVal = minVal(ugly2, ugly3, ugly5);
            uglyArray[ind] = minVal;
            ind++;
        }
        //返回最后一个
        return uglyArray[num - 1];
    }

    private int minVal(int... uglyNums) {
        int resVal = uglyNums[0] < uglyNums[1] ? uglyNums[0] : uglyNums[1];
        resVal = resVal < uglyNums[2] ? resVal : uglyNums[2];
        return resVal;
    }
```
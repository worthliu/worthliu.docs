The Hamming distance between two integers is the number of positions at which the corresponding bits are different.

Given two integers x and y, calculate the Hamming distance.

Note:
```
0 ≤ x, y < 231.
```
Example:
```
Input: x = 1, y = 4

Output: 2
```
Explanation:
```
1   (0 0 0 1)
4   (0 1 0 0)
       ↑   ↑
```
The above arrows point to positions where the corresponding bits are different.

### 题解

>+ 两个数字的汉明距离，指两数对应二进制1位置不同有多少个；
+ 先通过两个数字进行异或运算，得到对应汉明数字；
+ 再求汉明数字二进制中1的个数；

## solution

```
public int hammingDistance(int x, int y){
        int calcRes = x ^ y;

        //
        int hm = 0;
        while(calcRes != 0){
            if(calcRes % 2 == 1){
                hm++;
            }
            calcRes = calcRes / 2;
        }
        //
        return hm;
    }
```
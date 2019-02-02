Given an array A of non-negative integers, return an array consisting of all the even elements of A, followed by all the odd elements of A.

You may return any answer array that satisfies this condition.


Example 1:

```
Input: [3,1,2,4]
Output: [2,4,3,1]
The outputs [4,2,3,1], [2,4,1,3], and [4,2,1,3] would also be accepted.
```

>Note:
+ 1 <= A.length <= 5000
+ 0 <= A[i] <= 5000


### 题解

>+ 建立两个指针，分别为指向开头和结尾处，定义为`headInd`、`tailInd`；
+ 头指针`headInd`往前扫描，找到偶数数字，与尾指针所指向数字交换；
+ 若尾指针所指向的数字同样为偶数，尾指针往前扫描，找到第一个奇数数字进行交换；
+ 当头指针`headInd>=tailInd`时，循环结束；

## solution

```
    public int[] sortArrayByParity(int[] sortArray) {
        int tailInd = sortArray.length - 1;
        for(int headInd = 0;headInd < tailInd; headInd++){
            boolean isOdd = sortArray[headInd] % 2 == 1;
            if(isOdd){
                for(;tailInd > headInd;tailInd--){
                    boolean isEven = sortArray[tailInd] % 2 == 0;
                    if(isEven){
                        sortArray[headInd] = sortArray[headInd] ^ sortArray[tailInd];
                        sortArray[tailInd] = sortArray[headInd] ^ sortArray[tailInd];
                        sortArray[headInd] = sortArray[headInd] ^ sortArray[tailInd];
                        break;
                    }
                }
            }
        }
        
        return sortArray;
    }
```
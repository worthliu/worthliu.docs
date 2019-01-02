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


## solution

```
class Solution {
    public int[] sortArrayByParity(int[] sortArray) {
        int tailInd = sortArray.length - 1;
        for(int curInd = 0;curInd < tailInd; curInd++){
            boolean isOdd = sortArray[curInd] % 2 == 1;
            if(isOdd){
                for(;tailInd > curInd;tailInd--){
                    boolean isEven = sortArray[tailInd] % 2 == 0;
                    if(isEven){
                        sortArray[curInd] = sortArray[curInd] ^ sortArray[tailInd];
                        sortArray[tailInd] = sortArray[curInd] ^ sortArray[tailInd];
                        sortArray[curInd] = sortArray[curInd] ^ sortArray[tailInd];
                        break;
                    }
                }
            }
        }
        
        return sortArray;
    }
}
```
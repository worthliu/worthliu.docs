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
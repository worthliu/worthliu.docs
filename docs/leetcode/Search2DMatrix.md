Write an efficient algorithm that searches for a value in an m x n matrix. This matrix has the following properties:

Integers in each row are sorted from left to right.
The first integer of each row is greater than the last integer of the previous row.

Example 1:
```
Input:

matrix = [
  [1,   3,  5,  7],
  [10, 11, 16, 20],
  [23, 30, 34, 50]
]
target = 3
Output: true
```

Example 2:
```
Input:
matrix = [
  [1,   3,  5,  7],
  [10, 11, 16, 20],
  [23, 30, 34, 50]
]
target = 13
Output: false
```

## solution

>**首先选取数组中右上角的数字。**
+ 如果该数字等于要查找的数字，查找过程结束；
+ 如果该数字大于要查找的数字，剔除数字所在列；
+ 如果该数字小于要查找的数字，剔除数字所在行；
+ 直到找到要查找的数字，或者查找范围为空；

```
public boolean searchMatrix(int[][] matrix, int target) {
        boolean find = false;
        if(matrix != null && matrix.length > 0){
            int rowSize = matrix.length;
            int columnSize = matrix[0].length;
            //
            int row = 0;
            int column = columnSize - 1;
            while(row < rowSize && column >= 0){
                if(matrix[row][column] == target){
                    find = true;
                    break;
                }else if(matrix[row][column] > target){
                    --column;
                }else{
                    ++row;
                }
            }
        }
        return find;
    }
```
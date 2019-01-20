输入一个整数数组，判断该数组是不是某二叉搜索树的后序遍历的结果。如果是则返回trure，否则返回false。假设输入的数组的任意两个数字都互不相同；

### 题解

题目中关键点：**后续遍历**(`左->右->根`)、**二叉搜索树**（`左结点值小于右结点值`）

## solution

>**后序遍历**

```
    public boolean verifySequenceOfBST(int[] seq, int length){
        if(seq != null && length > 0){
            int rootNode = seq[length - 1];
            // 在二叉搜索树中左子树的结点小于根结点
            int leftInd = 0;
            for(; leftInd < length - 1; ++leftInd){
                if(seq[leftInd] > rootNode){
                    break;
                }
            }
            // 在二叉搜索树中右子树的结点大于根结点
            int rightInd = leftInd;
            for(;rightInd < length - 1; ++rightInd){
                if(seq[rightInd] < rootNode){
                    return false;
                }
            }
            // 判断左子树是不是二叉搜索树
            boolean leftTree = true;
            if(leftInd > 0){
                leftTree = verifySequenceOfBST(seq, leftInd);
            }
            // 判断右子树是不是二叉搜索树
            boolean rightTree = true;
            if (leftInd < length - 1){
                rightTree = verifySequenceOfBST(seq, length - leftInd - 1);
            }
            return (leftTree && rightTree);
        }
        return false;
    }
```

>**先序遍历**

```
    /**
     * 先序遍历序列验证二叉搜索树
     * <p>8 ,6 ,5 ,7 ,10 ,9 ,11</p>
     * @param seq
     * @param staInd
     * @param endInd
     * @return
     */
    public boolean verifySeqOfPreOrder(int[] seq, int staInd, int endInd){
        if(seq != null && endInd > 0 && staInd >= 0 && (endInd > staInd)){
            int rootVal = seq[staInd];
            // 在二叉搜索树中左子树的结点小于根结点
            int leftInd = staInd + 1;
            for(; leftInd <= endInd; ++leftInd){
                if(seq[leftInd] > rootVal){
                    break;
                }
            }
            // 在二叉搜索树中右子树的结点大于根结点
            int rightInd = leftInd;
            for(;rightInd <= endInd; ++rightInd){
                if(seq[rightInd] < rootVal){
                    return false;
                }
            }
            // 判断左子树是不是二叉搜索树
            boolean leftTree = true;
            if(leftInd <= endInd){
                leftTree = verifySeqOfPreOrder(seq, staInd + 1,leftInd - 1);
            }
            // 判断右子树是不是二叉搜索树
            boolean rightTree = true;
            if (leftInd < endInd){
                rightTree = verifySeqOfPreOrder(seq, leftInd,endInd);
            }
            return (leftTree && rightTree);
        }
        return false;
    }
```
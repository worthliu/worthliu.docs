输入n个整数，找出其中最小的k个数。

### 题解

最简单把输入的n个整数排序，排序之后位于最前面的k个数就是最小的k个数。

>+ 创建一个大小为k的数据容器来存储最小的k个数字；
+ 每次从输入的n个整数中读入一个数，如果容器中已有的数字小于k个，则直接把这次读入的整数中放入容器之中；
+ 如果容器中已有k个数字了，不能再插入新的数字而只能替换已有的数字；
+ 找出这已有的k个数中的最大值，然后拿这次待插入的整数和最大值进行比较。
  + 如果待插入的值比当前已有的最大值小，则用这个数替换当前已有的最大值；
  + 如果待插入的值比当前已有的最大值大，则抛弃；

因此当容器满了之后：
+ 在k个整数中找到最大数;
+ 有可能在这个容器中删除最大数；
+ 有可能要插入一个新的数字；

**如果用二叉树来实现这个数据容器，能在O(logK)时间内实现这三步；**

由于每次都需要找到K个整数中的最大数字，可采用最大堆中，根结点的值总是大于它的子树中任意结点的值；因此可以在O(1)得到已有的k个数字中的最大值，但需要O(logk)时间完成删除及插入操作；

还可以采用红黑树来实现，红黑树通过把结点分为红、黑两种颜色并根据一些规则确保树在一定程度上是平衡的，从而保证在红黑树中查找、删除和插入操作都只需要O(logk)时间。

## solution

```
	public Set<Integer> getLeastKNumbers(int[] nums, int k){
        if(nums == null || nums.length <= 0 || k < 1 || nums.length < k){
            return null;
        }
        TreeSet<Integer> leastNums = new TreeSet<>();
        for(int num : nums){
            if (leastNums.size() < k){
                leastNums.add(num);
            }else {
               Integer tarVal = leastNums.higher(num);
               if(tarVal != null){
                   leastNums.remove(tarVal);
                   leastNums.add(num);
               }
            }
        }
        
        return leastNums;
    }
```
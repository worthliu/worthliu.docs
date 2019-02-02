输入n个整数，找出其中最小的k个数。

### 题解

最简单把输入的n个整数排序，排序之后位于最前面的k个数就是最小的k个数。

>+ 创建一个大小为`k`的数据容器来存储最小的`k`个数字；
+ 每次从输入的n个整数中读入一个数，如果容器中已有的数字小于`k`个，则直接把这次读入的整数中放入容器之中；
+ 如果容器中已有`k`个数字了，不能再插入新的数字而只能替换已有的数字；
+ 找出这已有的`k`个数中的最大值，然后拿这次待插入的整数和最大值进行比较。
  + 如果待插入的值比当前已有的最大值小，则用这个数替换当前已有的最大值；
  + 如果待插入的值比当前已有的最大值大，则抛弃；

>因此当容器满了之后：
+ 在`k`个整数中找到最大数;
+ 有可能在这个容器中删除最大数；
+ 有可能要插入一个新的数字；

**如果用二叉树来实现这个数据容器，能在`O(logK)`时间内实现这三步；**

+ 由于每次都需要找到`K`个整数中的最大数字，可采用`最大堆`中，根结点的值总是大于它的子树中任意结点的值；
+ 因此可以在`O(1)`得到已有的`k`个数字中的最大值，但需要`O(logk)`时间完成删除及插入操作；

还可以采用`红黑树`来实现，`红黑树`通过把结点分为红、黑两种颜色并根据一些规则确保树在一定程度上是平衡的，从而保证在红黑树中查找、删除和插入操作都只需要`O(logk)`时间。

## solution

```
	public Set<Integer> getLeastKNumbers(int[] nums, int k){
        if(nums == null || nums.length <= 0 || k < 1 || nums.length < k){
            return null;
        }
        //红黑树
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
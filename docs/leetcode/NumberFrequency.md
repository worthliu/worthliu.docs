数组中有一个数字出现的次数**超过数组长度的一半**，找出这个数字；

### 题解

数组中有一个数字出现的次数超过数组长度的一半,也就是说它出现的次数比其他所有数字出现次数的和还要多。

>+ 在遍历数组的时候保存两个值：
   1. 数组中的一个数字；
   2. 次数；
+ 当我我们遍历到下一个数字时候，如果下一个数字和我们保存的数字相同，则次数加1；
+ 如果下一个数字和保存的数字不同，则次数减1；
+ 如果次数为零，需要保存下一个数字，并把次数设为1。
+ 由于要找的数字出现的次数比其他所有数字出现的次数之和还要多，那么要找的数字肯定是最后一次把次数设为1时对应的数字；

## solution

```
	public int moreThanHalfNum(int[] nums){
        if(checkInvalidArray(nums)){
            return -1;
        }
        //
        int resNum = -1;
        int times = 0;
        for(int ind = 0; ind < nums.length; ++ind){
            if(times == 0){
                resNum = nums[ind];
                times = 1;
            }else if(nums[ind] == resNum){
                times++;
            }else{
                times--;
            }
        }
        //
        if(times == 0){
            return -1;
        }
        
        return resNum;
    }

    private boolean checkInvalidArray(int[] nums){
        boolean checked = false;
        if(nums == null || nums.length <= 0){
            checked = true;
        }
        return checked;
    }
```
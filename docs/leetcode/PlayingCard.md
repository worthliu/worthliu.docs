从扑克牌中随机抽5张牌，判断是不是一个顺子，即这5张牌是不是连续。`2~10`为数字本身，A为1，J为11，Q为12，K为13，而大小王可以看成任意数字用0代替；


### 题解

最直观的方法是把数组排序。由于0可以当成任意数字。可以用0去补满数组中的空缺。

首先把数组排序，再统计数组中0的个数，最后统计排序之后的数组中相邻数字之间的空缺总数；如果空缺的总数小于或者等于0的个数，那么这个数组就是连续，反之则不连续；

如果数组中的非0数字重复出现，则该数组不是连续的。

## solution

```
	public boolean isContinuous(int[] nums){
        if(nums == null || nums.length < 1){
            return false;
        }
        //
        Arrays.sort(nums);
        int numOfZero = 0;
        int numOfGap = 0;
        //
        for(int ind = 0; ind < nums.length && nums[ind] == 0; ++ind){
            numOfZero++;
        }
        //统计数组中的间隔数目
        int small = numOfZero;
        int big = small + 1;
        while (big < nums.length){
            //两个数相等，有对子，不可能是顺子
            if(nums[small] == nums[big]){
                return false;
            }
            //
            numOfGap += nums[big] - nums[small] - 1;
            small = big;
            ++big;
        }
        //
        return (numOfGap > numOfZero) ? false : true;
    }
```
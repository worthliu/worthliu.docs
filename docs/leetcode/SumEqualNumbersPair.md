输入一个递增排序的数组和一个数字s，在数组中查找两个树，使得它们的和正好是s。如果有多对数字的和等于s，输出任意一对即可

### 题解

>+ 先在数组中选择两个数字，如果它们和等于输入的s，这个就是目标数字；
+ 如果和小于s，由于数组是排好序，可以考虑较小的数字后面的数字；
+ 如果和大于s，可以考虑较大数字前面的数字；

## solution

```
	public int[] numPair(int[] nums, int target){
        if(nums == null || nums.length < 2){
            return null;
        }
        int[] resNum = new int[2];
        int headInd = 0;
        int endInd = nums.length - 1;
        while (headInd < endInd){
            int curSum = nums[headInd] + nums[endInd];
            if(curSum == target){
                resNum[0] = nums[headInd];
                resNum[1] = nums[endInd];
            }else if(curSum > target){
                endInd--;
            }else{
                headInd++;
            }
        }
        return resNum;
    }
```


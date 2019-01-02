Given an array of integers, return indices of the two numbers such that they add up to a specific target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

Example:
```
Given nums = [2, 7, 11, 15], target = 9,

Because nums[0] + nums[1] = 2 + 7 = 9,
return [0, 1].
```

## solution

```
public int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> calcMap = new HashMap<>();

        for(int curInd = 0; curInd < nums.length; curInd++){
            if(calcMap.containsKey(nums[curInd])){
                return new int[]{calcMap.get(nums[curInd]), curInd};
            }else{
                calcMap.put(target - nums[curInd], curInd);
            }
        }
        return new int[2];
 }
```
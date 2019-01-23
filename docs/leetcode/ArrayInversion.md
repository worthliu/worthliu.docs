在数组中的两个数字如果前面一个数字大于后面的数字，则这两个数字组成一个逆序对。输入一个数组，求出这个数组中的逆序对的总数；

### 题解

直接做法：顺序扫描整个数组，每扫描到一个数字的时候，逐个比较该数字和它后面的数字的大小，如果后面的数字比它小，则这两个数字就组成了一个逆序对。时间复杂度位O(n^2);

>+ 先把数组分隔成子数组，先统计出子数组内部的逆序对的数目，然后再统计出两个相邻子数组之间的逆序对的数目。
+ 在统计逆序对的过程中，还需要对数组进行排序。

## solution

```
	public int statInversion(int[] nums){
        if(nums == null || nums.length <= 1){
            return 0;
        }
        //
        int[] copy = new int[nums.length];
        for(int ind = 0; ind < nums.length; ind++){
            copy[ind] = nums[ind];
        }
        //
        int count = inversePairsCore(nums, copy, 0, nums.length - 1);
        return count;
    }

    private int inversePairsCore(int[] nums, int[] copy, int start, int end) {
        if(start == end){
            copy[start] = nums[start];
            return 0;
        }
        //
        int length = (end - start) / 2;
        int left = inversePairsCore(copy, nums, start, start + length);
        int right = inversePairsCore(copy, nums, start + length + 1, end);
        //
        int i = start + length;
        int j = end;
        int indCopy = end;
        int count = 0;
        while (i >= start && j >= (start + length + 1)){
            if(nums[i] > nums[j]){
                copy[indCopy--] = nums[i--];
                count += j - start - length;
            }else {
                copy[indCopy--] = nums[j--];
            }
        }
        //
        for(; i >= start; --i){
            copy[indCopy--] = nums[i];
        }
        //
        for(; j >= start + length + 1; --j){
            copy[indCopy--] = nums[j];
        }

        return left + right + count;
    }
```
统计一个数字在排序数组中出现的次数，

### 题解

>+ 数组是排序，可以采用二分查找算法；
+ 找到目标数字后，左右顺序扫描；

**因为要查找的数字在长度为n的数组中有可能出现O(n)次，所以顺序扫描的时间复杂度是O(n)**


**如何用二分查找算法在数组中找到第一个k**
>+ 如果中间的数字比k大，那么k值只能在前半段查找；
+ 如果中间的数字比k小，那么k值只能在后半段查找；
+ 如果中间的数字和k相等，先判断这个数字是不是第一个k。如果位于中间数字的前面一个数字不是k，此时中间的数字刚好就是第一个k。
  + 如果中间数字前面一个数字也是k，即第一个k肯定在数组的前半段，下一轮仍然需要在数组的前半段查找；

## solution

```
	/**
     * 统计目标值在排序数组中出现的次数
     * @param nums
     * @param tarVal
     * @return
     */
    public int statTargetValAppTimes(int[] nums, int tarVal){
        int numCount = 0;
        if(nums != null || nums.length > 0){
            int firstInd = getFirstKLoop(nums, tarVal, 0, nums.length - 1);
            int lastInd = getLastKLoop(nums, tarVal, 0, nums.length - 1);
            if(firstInd > -1 && lastInd > -1){
                numCount = lastInd - firstInd + 1;
            }
        }
        return numCount;
    }

    /**
     * 获取排序数组中第一个目标值下标
     * @param nums
     * @param tarVal
     * @param start
     * @param end
     * @return
     */
    private int getFirstKLoop(int[] nums, int tarVal, int start, int end) {
        if(nums == null || start > end){
            return -1;
        }

        int midInd = (start + end) / 2;
        int midData = nums[midInd];
        if(midData == tarVal){
            boolean checked = (midInd > 0 && nums[midInd - 1] != tarVal)
                                || midInd == 0;
            if(checked){
                return midInd;
            }else {
                end = midInd - 1;
            }
        }else if(midData > tarVal){
            end = midInd - 1;
        }else {
            start = midInd + 1;
        }
        return getFirstKLoop(nums, tarVal, start, end);
    }

    /**
     * 获取排序数组中最后一个目标值下标
     * @param nums
     * @param tarVal
     * @param start
     * @param end
     * @return
     */
    private int getLastKLoop(int[] nums, int tarVal, int start, int end){
        if(nums == null || start > end){
            return -1;
        }
        //
        int midInd = (start + end) / 2;
        int midData = nums[midInd];
        //
        if(midData == tarVal){
            boolean checked = (midInd < nums.length - 1 && nums[midInd + 1] != tarVal)
                    || midInd == nums.length - 1;
            if(checked){
                return midInd;
            }else{
                start = midInd + 1;
            }
        }else if(midData < tarVal){
            start = midInd + 1;
        }else {
            end = midInd - 1;
        }
        return getLastKLoop(nums, tarVal, start, end);
    }
```

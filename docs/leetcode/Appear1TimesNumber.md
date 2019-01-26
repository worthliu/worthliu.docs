一个整型数组里除了两个数字之外，其他的数字都出现了两次。请找出**两个**只出现一次的数字。要求时间复杂度是O(n)，空间复杂度O(1)。

### 题解

**位运算中异或运算的一个性质，任何一个数字异或它自己都等于0。**

就是说，如从头到尾依次异或数组中的每一个数字，那么最终的结果刚好是那个只出现一次的数字，因为那些成对出现两次的数字全部在异或中抵消了；

尝试把原数组分成两个子数组,使得每个子数组包含一个只出现一次的数字,而其他数字都成对出现两次。

>+ 从头到尾依次异或数组中的每个数字，最终得到的结果就是两个只出现一次的数字的异或结果。
+ 由于两个数字肯定不一样，那么异或的结果肯定不为0；
+ 在结果数字中找到第一个为1的位的位置，记为第n位；
+ 以第n位是不是1为标准把原数组中的数字分成两个子数组，第一个子数组中每个数字的第n位都是1，而第二个子数组中每个数字的第n位都是0；
+ 由于分组的标准是数字中的某一位是1还是0，那么出现了两个的数字肯定被分配到同一个子数组。


假设输入数组`{2, 4, 3, 6, 3, 2, 5, 5}`。

>+ 当我们依次对数组中的每一个数字做异或运算之后，得到的结果用二进制表示是`0010`；
+ 异或得到结果中的倒数第二位是`1`，根据数字的倒数第二位是不是`1`分为两个数组。
+ 第一个子数组`{2, 3, 6, 3, 2}`中所有数字的倒数第二位都是1，而第二个子数组`{4, 5, 5}`中所有数字的倒数第二位都是`0`；
+ 接下来分别对两个子数组求异或，就能找出第一个子数组中只出现一次的数字是`6`，而第二个子数组中只出现一次的数字是`4`；

## solution

>若需要查找的数组，只出现一次的数字只有一个，只需`异或`数组本身数字，最终得到就是值就是出现一次的数字本身：

```
	public int appear1TimesNum(int[] nums){
        if(nums == null || nums.length <= 0){
            return -1;
        }
        if(nums.length == 1){
            return nums[0];
        }
        //
        int resNums = 0;
        for(int ind = 0; ind < nums.length; ind++){
            resNums ^= nums[ind];
        }
        return resNums;
    }
```

>数组中只出现一次的数字有两个：

```
    public int[] appear1Times(int[] nums){
        if(nums == null || nums.length < 2){
            return null;
        }
        // 计算数组全部异或结果（用于数组分组）
        // 0 ^ A = A , A ^ A = 0
        int resExclusiveOR = 0;
        for(int ind = 0; ind < nums.length; ind++){
            resExclusiveOR ^= nums[ind];
        }
        // 获取数组异或结果，二进制结果1出现的位置
        int indOf1 = findFirstBitIs1(resExclusiveOR);
        // 通过二进制结果1的位置分组，做分组后数组异或
        int[] resNums = new int[2];
        for(int ind = 0; ind < nums.length; ind++){
            if(isBit1(nums[ind], indOf1)){
                resNums[0] ^= nums[ind];
            }else{
                resNums[1] ^= nums[ind];
            }
        }
        return resNums;
    }

    /**
     * 右移n，判断最右边二进制位是否为1
     * @param num
     * @param indOf1
     * @return
     */
    private boolean isBit1(int num, int indOf1) {
        num = num >> indOf1;
        return (num & 1) == 0;
    }

    /**
     * @param resExclusiveOR
     * @return
     */
    private int findFirstBitIs1(int resExclusiveOR) {
        int indBit = 0;
        //查找数组异或结果，二进制位数1出现在那个位置上
        while (((resExclusiveOR & 1) == 0) && (indBit < 32)){
            resExclusiveOR = resExclusiveOR >> 1;
            ++indBit;
        }
        return indBit;
    }
```

>数组重复数字出现三次：（位运算： `0 & a & a & ~a = 0`）

```
    public int singleNumber(int[] nums) {
        if(nums == null || nums.length <= 0 || nums.length == 2){
            return -1;
        }
        if(nums.length == 1){
            return nums[0];
        }
        //
        int tarVal = 0;
        int calcVal = 0;
        for(int num : nums){
            tarVal = ~calcVal & (tarVal ^ num);
            calcVal = ~tarVal & (calcVal ^ num);
        }
        //
        return tarVal;
    }
```
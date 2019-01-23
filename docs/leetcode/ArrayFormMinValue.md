输入一个正整数数组，把数组里所有数字拼接起来排成一个数，打印能拼接的所有数字的中最小的一个。例如输入数组`{3, 32, 321}`，则打印出这个3个数字能排成的最小数字321223；

### 题解

最直接做法是求出数组中所有数字的全排列，然后把每个排列拼起来，最后求出拼起来的数字的最大值。

根据题目的要求，两个数字m和n能拼接成数字`mn`和`nm`。如果`mn<nm`,那么打印出`mn`，也就是`m`应该排在`n`的前面，定义此时`m`小于`n`；

反之，如果`nm<mn`，定义n小于m。如果`mn=nm`，`m`等于`n`。

现在拼接数字，即给出数字m和n，怎么得到数字mn和nm并比较它们的大小，若直接用数值去计算不难办到，但拼接得到值超过`int`能表达的范围内，就会出现溢出；

针对大数问题，最简单转化成字符串；且组合后的字符串位数一样只需要直接比较字符串大小即可；


## solution

```
	public void printMinNumber(int[] nums){
        if(nums == null || nums.length <= 0){
            return;
        }
        //
        String[] strNums = new String[nums.length];
        for(int ind = 0; ind < nums.length; ind++){
            strNums[ind] = String.valueOf(nums[ind]);
        }
        //
        String curStr = "";
        for(int ind  = 0; ind < nums.length; ind++){
            for(int innInd = ind + 1; innInd < nums.length; innInd++){
                if(strNums[ind].compareTo(strNums[innInd]) > 1){
                    String temp = strNums[ind];
                    strNums[ind] = strNums[innInd];
                    strNums[innInd] = temp;
                }
            }
        }
    }
```
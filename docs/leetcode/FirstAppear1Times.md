字符串中找出第一个只出现一次的字符。如输入“abaccdeff”，则输出“b”;

### 题解

直观做法是从头开始扫描这个字符中每个字符。当访问到某个字符时拿这个字符和后面的每个字符相比较，如果在后面没有发现重复的字符，则该字符就是只出现一次的字符。

如果字符串中有n个字符，每个字符可能与后面的O(n)个字符相比较，因此时间复杂度位O(n^2);

采用空间换时间做法，使用哈希表存储扫描到的字符和字符次数；


## solution

```
	public int firstUniqChar(String s) {
        if(s == null || s == ""){
            return -1;
        }

        Map<Character, Integer> strTimesMap = new HashMap<>();
        char[] strArray = s.toCharArray();
        for(char strChar : strArray){
            if(!strTimesMap.containsKey(strChar)){
                strTimesMap.put(strChar, 1);
            }else{
                strTimesMap.put(strChar, strTimesMap.get(strChar) + 1);
            }
        }
        //
        for(int ind = 0; ind < strArray.length; ind++){
            int strTimes = strTimesMap.get(strArray[ind]);
            if(strTimes == 1){
                return ind;
            }
        }
        return -1;
    }
```
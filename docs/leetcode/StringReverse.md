输入一个英文句子，翻转句子中单词的顺序，但单词内的字符顺序不变，为简单起见，标点符号和普通字母一样处理。

Example：

```
  old : "I am a student."
  reverse : "student. a am I"
```

### 题解

>+ 翻转句子中的所有的字符;
+ 再翻转每个单词中的字符的顺序;

## solution

```
	public String reverse(String target){
        if(target == null || target == ""){
            return target;
        }

        char[] strArray = target.toCharArray();
        //
        reverse(strArray, 0, strArray.length - 1);
        //
        int start = 0;
        int curInd = 0;
        int end = strArray.length - 1;
        while(curInd <= end){
            if(strArray[curInd] == ' '){
                reverse(strArray, start, curInd - 1);
                start = curInd + 1;
            }
            curInd++;
        }
        return String.valueOf(strArray);
    }

    private void reverse(char[] strArray, int start, int end) {
        if(strArray == null){
            return;
        }
        //
        while(start < end){
            char temp = strArray[start];
            strArray[start] = strArray[end];
            strArray[end] = temp;
            start++;
            end--;
        }
    }
```
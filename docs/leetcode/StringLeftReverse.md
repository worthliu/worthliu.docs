字符串的左旋转操作是把字符串前面的若干个字符转移到字符串的尾部。请定义一个函数实现字符串左旋转操作的功能。

Example：

```
 target : 'abcdefg' , 左旋转2位；
 result : 'cdefgab'
```

### 题解

以"abcdefg"为例，可以分为两部分。

+ 先把前一部分"ab"进行翻转操作；
+ 再把后一部分"cdefg"进行翻转操作；
+ 把翻转整个字符串；

## solution

```
	public String leftReverse(String target, int k){
        if(target == null || target == "" || k <= 0){
            return target;
        }
        //
        char[] stsArray = target.toCharArray();
        reverse(stsArray, 0, k - 1);
        reverse(stsArray, k, stsArray.length - 1);
        reverse(stsArray, 0, stsArray.length - 1);
        return String.valueOf(stsArray);
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

>若是右旋转操作： `先全翻转，再分部分前后翻转即可`

```
	public String rightReverse(String target, int k){
        if(target == null || target == "" || k <= 0){
            return target;
        }
        //
        char[] stsArray = target.toCharArray();
        reverse(stsArray, 0, stsArray.length - 1);
        reverse(stsArray, 0, k - 1);
        reverse(stsArray, k, stsArray.length - 1);
        return String.valueOf(stsArray);
    }
```
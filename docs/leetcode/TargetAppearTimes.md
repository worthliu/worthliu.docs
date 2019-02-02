输入一个整数n，求从1到n这n个整数的十进制表示中1出现的次数。

例如输入12，从1到12这些整数中包含1的数字有1，10，11和12，1一共出现了5次；

### 题解

直观做法：累加1到n中每个整数1出现的次数。

可以每次通过对10求余数判断整数的个位数字是不是1。

如果这个数字大于10，除以10之后再判断个位数字是不是1。

**时间复杂度是O(nlogn)**





## solution

```
	public int appearTimes(int n){
        int number = 0;
        for(int ind = 1; ind <= n; ++ind){
            number += numberOf1(ind);
        }
        return number;
    }

    private int numberOf1(int n) {
        int number = 0;
        while (n != 0){
            if(n % 10 == 1){
                number++;
            }
            n = n / 10;
        }
        return number;
    }
```

```
	public int appearTimesPro(int n){
        if(n <= 0){
            return 0;
        }

        char[] tarChar = String.valueOf(n).toCharArray();
        return numberOf1(tarChar, 0, tarChar.length - 1);
    }

    private int numberOf1(char[] tarChar, int start, int end){
        if(tarChar == null || tarChar.length <= 0 || 
            start < 0 || end >= tarChar.length || start > end){
            return 0;
        }
        //
        int charLen = tarChar.length;
        int first = tarChar[start] - '0';
        if(charLen == 1 && first == 0){
            return 0;
        }
        if(charLen == 1 && first > 0){
            return 1;
        }
        //
        int numFirstDigit = 0;
        if(first > 1){
            numFirstDigit = powerBase10(charLen - 1);
        }else if(first == 1){
            numFirstDigit = tarChar[start + 1] - '0' + 1;
        }
        //
        int numOtherDigits = first * (charLen - 1) * powerBase10(charLen - 2);
        int numRecursive = numberOf1(tarChar, start + 1, end);
        return numFirstDigit + numOtherDigits + numRecursive;
    }

    private int powerBase10(int n) {
        int result = 1;
        for(int ind = 0; ind < n; ++ind){
            result *= 10;
        }
        return result;
    }
```
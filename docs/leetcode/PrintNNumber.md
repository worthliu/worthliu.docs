输入数字n，按顺序打印出从1最大的n位十进制数。比如输入3，则打印出1、2、3一直到最大的3位数即999；

Note：
注意n位数最大值问题；

## solution

>**注意大数与位置限制**

```
public void printToMaxOfNDigits(int n){
        if(n <= 0){
            return;
        }
        //
        int[] number = new int[n];
        while (!Increment(number)){
            printNumber(number);
        }
    }

    private void printNumber(int[] number) {
        boolean isBeginning0 = true;
        int nLength = number.length;
        for(int i = 0;i < nLength; ++i){
            if(isBeginning0 && number[i] != 0) {
                isBeginning0 = false;
            }

            if(!isBeginning0){
                System.out.print(number[i]);
            }
        }
        System.out.println("");
    }

    private boolean Increment(int[] number) {
        boolean isOverflow = false;
        int nTakeOver = 0;
        int nLength = number.length;
        //
        for(int i = nLength - 1; i >= 0; i--){
            int nSum = number[i] + nTakeOver;
            if(i == nLength - 1){
                nSum++;
            }

            if(nSum >= 10){
                if(i == 0){
                    isOverflow = true;
                }else{
                    nSum -= 10;
                    nTakeOver = 1;
                    number[i] = nSum;
                }
            }else{
                number[i] = nSum;
                break;
            }
        }
        return isOverflow;
    }
```
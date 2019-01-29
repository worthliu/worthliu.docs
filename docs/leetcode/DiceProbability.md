把n个骰子扔在地上，所有骰子朝上一面的点数之和为s。输入n，打印出s所有可能的值出现的概率；



### **建模**
>+ 需要根据问题的特点综合考虑性能、编程难度等因素之后，选择合理的数据结构来表述问题，建立模型；
+ 分析模型中的内在规律，并用编程语言表述这种规律。

### 题解

骰子有6个面，每个面上的都有一个点数，对应`1~6`；所以`n`个骰子的点数和的最小值为`n`，最大值为`6n`。`n`个骰子的所有点数的排列数为`6^n`.

先统计出每个点数出现的次数，然后把每个点数出现的次数除以6^n，就能求出每个点数出现的概率；

>递归法：
+ 先把`n`个骰子分为两堆：第一堆只有一个，另一堆有`n-1`个；
+ 单独哪一个有可能出现从`1`到`6`的点数；
+ 需要计算从`1`到`6`的每一种点数和剩下的`n-1`个骰子来计算点数和；
+ 接下来把剩下的`n-1`个骰子还是分成两堆，第一堆只有一个，第二堆有`n-2`个。循环计算下去；
+ **定义一个长度为`6n-n+1`的数组，和为s的点数出现的次数保存在数组第`s-n`个元素里。**


>基于循环求骰子点数，时间性能好：
+ 用两个数组来存储骰子点数的每一个总数出现的次数。
+ 在一次循环中，第一个数组中的第n个数字表示骰子和为n出现的次数。
+ 在下一次循环中，加上一个新的骰子，此时和为n的骰子出现的次数应该等于上一次循环中骰子点数和为`n-1`、`n-2`、`n-3`、`n-4`、`n-5`与`n-6`的次数的总和；
+ 把另一个数组的第n个数字设为前一个数组对应的`第n-1`、`n-2`、`n-3`、`n-4`、`n-5`与`n-6`之和；

## solution

>循环

```
	private static final int MAX_VALUE = 6;

    /**
     * @param num
     */
    public void printProbability(int num){
        if(num < 1){
            return;
        }
        //
        int maxSum = num * MAX_VALUE;
        double[] probabilities = new double[maxSum - num + 1];
        //
        for (int ind = 1; ind <= MAX_VALUE; ++ind){
            probability(num, num, ind, probabilities);
        }
        //n个骰子的所有点数的排列数为6^n
        double total = Math.pow(MAX_VALUE, num);
        for(int ind = num; ind <= maxSum; ++ind){
            double ratio = probabilities[ind - num] / total;
            System.out.format("%d: %e\n", ind, ratio);
        }
        //
        probabilities = null;
    }

    /**
     * @param original
     * @param current
     * @param sum
     * @param probabilities
     */
    private void probability(int original, int current, int sum, double[] probabilities){
        if(current == 1){
            probabilities[sum - original]++;
        }else {
            for(int ind = 1; ind <= MAX_VALUE; ++ind){
                probability(original, current - 1, ind + sum, probabilities);
            }
        }
    }
```

>？？？

```
	public void printProbabilityPro(int num){
        if(num < 1){
            return;
        }
        //
        double[][] probabilities = new double[2][];
        probabilities[0] = new double[MAX_VALUE * num + 1];
        probabilities[1] = new double[MAX_VALUE * num + 1];
        //
        int flag = 0;
        for (int ind = 1; ind <= MAX_VALUE; ++ind){
            probabilities[flag][ind] = 1;
        }
        //
        for(int indK = 2; indK <= num; ++indK){
            for(int indJ = indK; indJ <= MAX_VALUE * indK; ++indJ){
                for(int indM = 1; indM <= indJ && indM <= MAX_VALUE; ++indM){
                    probabilities[1 -flag][indM] += probabilities[flag][indJ - indM];
                }
            }
            flag = 1 - flag;
        }
        //n个骰子的所有点数的排列数为6^n
        int maxSum = MAX_VALUE * num;
        double total = Math.pow(MAX_VALUE, num);
        for(int ind = num; ind <= maxSum; ++ind){
            double ratio = probabilities[flag][ind] / total * 100;
            System.out.format("%d: %f\n", ind, ratio);
        }
        //
        probabilities = null;

    }

```
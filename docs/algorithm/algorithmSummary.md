# 常用排序算法总结

> 排序算法往往指的是内部排序算法,即数据记录在内存中进行排序
1. 比较排序,时间复杂度`O(nlogn)~O(n^2)`,主要有:**冒泡排序,选择排序,插入排序,归并排序,堆排序,快速排序等**;
2. 非比较排序,时间复杂度可以达到`O(n)`,主要有:**计数排序,基数排序,桶排序等**;

---


排序方法|平均情况|最好情况|最坏情况|辅助空间|稳定性|
--:|--:|--:|--:|--:|--:|
冒泡排序|O(n^2)|O(n)|O(n^2)|O(1)|稳定|
简单选择排序|O(n^2)|O(n^2)|O(n^2)|O(1)|不稳定|
直接插入排序|O(n^2)|O(n)|O(n^2)|O(1)|稳定|
希尔排序|O(nlogn)~O(n2)|O(n^1.3)|O(n^2)|O(1)|稳定|
堆排序|O(nlogn)|O(nlogn)|O(nlogn)|O(1)|不稳定|
归并排序|O(nlogn)|O(nlogn)|O(nlogn)|O(n)|稳定|
快速排序|O(nlogn)|O(nlogn)|O(n^2)|O(logn)~O(n)|不稳定|

>排序算法稳定性的简单形式化定义为：
* 如果`Ai = Aj`，排序前`Ai`在`Aj`之前，排序后`Ai`还在`Aj`之前，则称这种排序算法是稳定的；
* 通俗地讲就是**保证排序前后两个相等的数的相对顺序不变**；

**排序算法如果是稳定的，那么从一个键上排序，然后再从另一个键上排序，前一个键排序的结果可以为后一个键排序所用**

## 冒泡排序(Bubble Sort)

>**重复地遍历所有要排序的元素，依次比较相邻两个元素，如果它们的顺序错误就调换位置，直到没有元素再需要交换，排序完成**。
1. 比较相邻的元素，如果前一个比后一个大，就把它们两个调换位置。
2. 每一对相邻元素作同样的工作，从开始第一对到结尾的最后一对。这步做完后，最后的元素会是最大的数。
3. 针对所有的元素重复以上的步骤，除了最后一个。
4. 持续每次对越来越少的元素重复上面的步骤，直到没有任何一对数字需要比较。

```
public void sort(int[] sortArray){
        // 时间复杂度为n*(n/2)
        /**
         * 通过循环遍历数组所有元素
         * 每次比较相邻元素,较大值往后移;
         * 每次遍历完成后,最大值元素再数组最后位置
         * 再次开始循环遍历,遍历结束节点往前移一位
         * */
        for (int index = 0; index < sortArray.length - 1; index++){
            for (int innerInd = 0; innerInd < sortArray.length - 1 - index; innerInd++){
                if(sortArray[innerInd] > sortArray[innerInd + 1]){
                    sortArray[innerInd] = sortArray[innerInd]^sortArray[innerInd + 1];
                    sortArray[innerInd + 1] = sortArray[innerInd]^sortArray[innerInd + 1];
                    sortArray[innerInd] = sortArray[innerInd]^sortArray[innerInd + 1];
                }
                loopTotalCnt++;
            }
        }
    }
```
![bubbleSort](/images/bubbleSort.gif)

## 鸡尾酒排序(Cocktail Sort)（定向冒泡排序）

鸡尾酒排序，也叫定向冒泡排序，是冒泡排序的一种改进。
>此算法与冒泡排序的不同处**在于从低到高然后从高到低**，而冒泡排序则仅从低到高去比较序列里的每个元素。

>1. 先从左到右，由大数往后移；
2. 从右到左，由小数往前移；
3. 循环遍历，遍历到中间位置时结束；

```
public void sort(int[] sortArray) {
        // initial edge value
        int left = 0;
        int right = sortArray.length - 1;
        while (left < right){
            for(int rightInd = left; rightInd < right; rightInd++){
                if(sortArray[rightInd] > sortArray[rightInd + 1]){
                    sortArray[rightInd] = sortArray[rightInd] ^ sortArray[rightInd + 1];
                    sortArray[rightInd + 1] = sortArray[rightInd] ^ sortArray[rightInd + 1];
                    sortArray[rightInd] = sortArray[rightInd] ^ sortArray[rightInd + 1];
                }
            }
            right--;
            //
            for (int leftInd = right; leftInd > left; leftInd--){
                if(sortArray[leftInd] < sortArray[leftInd - 1]){
                    sortArray[leftInd] = sortArray[leftInd] ^ sortArray[leftInd - 1];
                    sortArray[leftInd - 1] = sortArray[leftInd] ^ sortArray[leftInd - 1];
                    sortArray[leftInd] = sortArray[leftInd] ^ sortArray[leftInd - 1];
                }
            }
            left++;
        }
}
```
![cocktailSort](/images/cocktailSort.gif)

## 选择排序(Selection Sort)

**选择排序也是一种简单直观的排序算法。**
>**它的工作原理很容易理解**：
1. 初始时在序列中找到最小（大）元素，放到序列的起始位置作为已排序序列；
2. 然后，再从剩余未排序元素中继续寻找最小（大）元素，放到已排序序列的末尾。
3. 以此类推，直到所有元素均排序完毕。

>**注意选择排序与冒泡排序的区别**：
+ 冒泡排序通过依次交换相邻两个顺序不合法的元素位置，从而将当前最小（大）元素放到合适的位置；
+ 而选择排序每遍历一次都记住了当前最小（大）元素的位置，最后仅需一次交换操作即可将其放到合适的位置。

```
public void sort(int[] sortArray) {
        int length = sortArray.length;
        for (int curInd = 0; curInd < length; curInd++){
            int minInd = curInd;
            for (int searchInd = curInd + 1; searchInd < length; searchInd++){
                if(sortArray[searchInd] < sortArray[minInd]){
                    minInd = searchInd;
                }
            }
            //
            if(minInd != curInd){
                sortArray[curInd] = sortArray[curInd] ^ sortArray[minInd];
                sortArray[minInd] = sortArray[curInd] ^ sortArray[minInd];
                sortArray[curInd] = sortArray[curInd] ^ sortArray[minInd];
            }
        }
}
```
![selectionSort.gif](/images/selectionSort.gif)

## 插入排序(Insertion Sort)

**对于未排序数据(右手抓到的牌)，在已排序序列(左手已经排好序的手牌)中从后向前扫描，找到相应位置并插入。**

插入排序在实现上，通常采用in-place排序（即只需用到O(1)的额外空间的排序），因而在从后向前扫描过程中，需要反复把已排序元素逐步向后挪位，为最新元素提供插入空间。

>具体算法描述如下：
1. 从第一个元素开始，该元素可以认为已经被排序;
2. 取出下一个元素，在已经排序的元素序列中从后向前扫描;
3. 如果该元素（已排序）大于新元素，将该元素移到下一位置;
4. 重复步骤3，直到找到已排序的元素小于或者等于新元素的位置;
5. 将新元素插入到该位置后,重复步骤`2~5`;

```
public void sort(int[] sortArray) {
        int length = sortArray.length;
        for (int curInd = 1; curInd < length; curInd++){
            for(int insertInd = curInd; insertInd > 0; insertInd--){
                if(sortArray[insertInd] > sortArray[insertInd - 1]){
                    sortArray[insertInd] = sortArray[insertInd] ^ sortArray[insertInd - 1];
                    sortArray[insertInd - 1] = sortArray[insertInd] ^ sortArray[insertInd - 1];
                    sortArray[insertInd] = sortArray[insertInd] ^ sortArray[insertInd - 1];
                }else{
                    break;
                }
            }
        }
    }
```
![insertionSort](/images/insertionSort.gif)

## 插入排序的改进：二分插入排序(Dichotomy Sort)

**对于插入排序，如果比较操作的代价比交换操作大的话，可以采用二分查找法来减少比较操作的次数，我们称为二分插入排序**

>具体算法:
1. 从第一个元素开始，该元素可以认为已经被排序;
2. 取出下一个元素，在已经排序的元素序列中**二分法**扫描,找到元素目标位置;
3. 将原有位置到目标位置所有元素整体移位;
4. 重复步骤`2~3`，直到所有元素遍历完成;

```
public void sort(int[] sortArray) {
        int length = sortArray.length;
        for (int curInd = 0; curInd < length; curInd++){
            int left = 0;
            int right = curInd - 1;
            //
            while (left <= right){
                int midInd = (left + right) / 2;
                if (sortArray[midInd] > sortArray[curInd]){
                    right = midInd - 1;
                }else{
                    left = midInd + 1;
                }
            }
            //
            if(curInd != left){
                for(int changeInd = curInd - 1; changeInd >= left; changeInd--){
                    sortArray[changeInd] = sortArray[changeInd] ^ sortArray[changeInd + 1];
                    sortArray[changeInd + 1] = sortArray[changeInd] ^ sortArray[changeInd + 1];
                    sortArray[changeInd] = sortArray[changeInd] ^ sortArray[changeInd + 1];
                }
            }
        }
    }
```

## 插入排序的更高效改进：希尔排序(Shell Sort)

**希尔排序，也叫递减增量排序，是插入排序的一种更高效的改进版本。希尔排序是不稳定的排序算法。**

>希尔排序是基于插入排序的以下两点性质而提出改进方法的：
+ 插入排序在对几乎已经排好序的数据操作时，效率高，即可以达到`线性排序的效率`但`插入排序`一般来说是`低效的`，因为`插入排序`每次只能**将数据移动一位**
+ 希尔排序通过将比较的全部元素分为`几个区域`来提升`插入排序`的性能。
  + 这样可以让一个元素可以一次性地朝最终位置前进一大步。
  + 然后算法再取越来越小的步长进行排序;
  + 算法的最后一步就是普通的插入排序，但是到了这步，需排序的数据几乎是已排好的了（此时插入排序较快）。
　

>+ 假设有一个很小的数据在一个已按升序排好序的数组的末端。如果用复杂度为`O(n^2)`的排序（冒泡排序或直接插入排序），可能会进行n次的比较和交换才能将该数据移至正确位置。
+ 而希尔排序会用较大的步长移动数据，所以小数据只需进行少数比较和交换即可到正确位置。

```
public void sort(int[] sortArray) {
        int length = sortArray.length;
        int stepLen = length / 2 + 1;
        while (stepLen > 0){
            for (int curInd = stepLen; curInd < length; curInd++){
                if(sortArray[curInd] > sortArray[curInd - stepLen]){
                    sortArray[curInd] = sortArray[curInd] ^ sortArray[curInd - stepLen];
                    sortArray[curInd - stepLen] = sortArray[curInd] ^ sortArray[curInd - stepLen];
                    sortArray[curInd] = sortArray[curInd] ^ sortArray[curInd - stepLen];
                }
            }
            stepLen /= 2;
        }
}
```
![shellSort.gif](/images/shellSort.gif)
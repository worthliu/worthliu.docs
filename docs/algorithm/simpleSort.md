假设在运动场上对于运动员按照身高进行排序,相对于人而言由于可以"全览"所有得数据可以很快排定顺序;但是,对于计算机而言却不能像人这样"全览"所有数据,只能根据"比较"操作原理,重复性对全部运动员进行比较,直到比较结束;

## `冒泡排序`

1. 比较两个数
2. 若左边数大,则交换两个数位置
3. 向右移动一个位置,继续比较后续两个数;
4. 循环比较,直到结束;

```Bubble
public class Bubble extends AbstractSortBase {
    @Override
    public void sort(Comparable[] arrSort) {
        super.sort(arrSort);
        //
        int length = arrSort.length;
        for(int ind = length - 1; ind > 1; ind--){
            for(int inInd = 0; inInd < ind; inInd++){
                if(SortUtils.less(arrSort[inInd + 1], arrSort[inInd])){
                    SortUtils.exch(arrSort, inInd, inInd + 1);
                }
            }
        }
    }
}
```

## `选择排序`

>`选择排序`:
+ 找到数组中最小得那个元素
+ 将它和数组的第一个元素交换位置(如果第一个元素就是最小元素那么它和自己交换)
+ 在剩下的元素中找到最小的元素,将它与数组的第二个元素交换位置;
+ 如此往复,直到将整个数组排序;

```Selection
public class Selection extends AbstractSortExample {
    /**
     * 1.选择出目标元素最终位置
     * 2.交换元素位置
     * 3.循环操作
     * @param arrSort
     */
    @Override
    public void sort(Comparable[] arrSort) {
        SortUtils.checkNullArrayParam(arrSort);
        showData(arrSort);
        int arrLength = arrSort.length;
        for (int ind = 0; ind < arrLength; ind++) {
            int minInd = ind;
            for (int inInd = ind + 1; inInd < arrLength; inInd++) {
                if (SortUtils.less(arrSort[inInd], arrSort[minInd])) {
                    minInd = inInd;
                }
            }
            //
            SortUtils.exch(arrSort, ind, minInd);
            showSort(arrSort, ind, minInd);
        }
    }
}
```

## `插入排序`

与选择排序一样,当前索引左边的所有元素都是有序的,但它们的最终位置还不确定,为了给更小的元素腾出空间,它们可能会被移动.但是当索引到达数组的右端时,数组排序就完成了;

**`插入排序`所需的时间取决于输入中元素的促使顺序**;

```Insertion
public class Insertion extends AbstractSortBase {
    @Override
    public void sort(Comparable[] arrSort) {
        super.sort(arrSort);
        //
        int length = arrSort.length;
        for(int ind = 1; ind < length; ind++){
            for(int inInd = ind; inInd > 0 && SortUtils.less(arrSort[inInd], arrSort[inInd - 1]); inInd--){
                SortUtils.exch(arrSort, inInd, inInd - 1);
                showSort(arrSort, inInd, inInd - 1);
            }
        }
    }
}
```

## `希尔排序`

`希尔排序`为了加快速度简单地改进了插入排序,交换不相邻的元素以对数组的局部进行排序,并最终用插入排序将局部有序的数组排序;

`希尔排序`的思想是使数组中任意间隔为`h`的元素都是有序的.这样的数组被称为`h`有序数组.

在进行排序时,如果`h`很大,就能将元素移动到很远的地方,为实现更小的h有序创造方便.

```Shell
public class Shell extends AbstractSortBase {

    private final int STEP_NUM = 3;

    @Override
    public void sort(Comparable[] arrSort) {
        super.sort(arrSort);
        //
        int length = arrSort.length;
        int stepLen = 1;
        //
        while (stepLen < length / STEP_NUM) {
            stepLen = stepLen * STEP_NUM + 1;
        }
        //
        while (stepLen >= 1) {
            for (int ind = stepLen; ind < length; ind++) {
                for (int inInd = ind;
                     inInd >= stepLen && SortUtils.less(arrSort[inInd], arrSort[inInd - stepLen]);
                     inInd -= stepLen) {
                    SortUtils.exch(arrSort, inInd, inInd - stepLen);
                }
            }
            stepLen = stepLen / STEP_NUM;
        }
    }
}
```
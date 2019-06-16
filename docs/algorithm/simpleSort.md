假设在运动场上对于运动员按照身高进行排序,相对于人而言由于可以"全览"所有得数据可以很快排定顺序;但是,对于计算机而言却不能像人这样"全览"所有数据,只能根据"比较"操作原理,重复性对全部运动员进行比较,直到比较结束;

## `冒泡排序`

1. 比较两个数
2. 若左边数大,则交换两个数位置
3. 向右移动一个位置,继续比较后续两个数;
4. 循环比较,直到结束;

## `选择排序`

```Selection
public class Selection extends AbstractSortExample {
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

    @Override
    public void showData(Comparable[] arrSort) {
        System.out.println(Arrays.toString(arrSort));
    }
}
```

## `插入排序`
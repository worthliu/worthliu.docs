```SortExample
public interface SortExample {

    /**
     * 排序实现类,交由子类实现
     * @param arrSort
     */
    void sort(Comparable[] arrSort);

    /**
     * 展示排序数组元素表
     * @param arrSort
     */
    default void showData(Comparable[] arrSort){
        System.out.println(String.format("The origin array is %s", Arrays.toString(arrSort)));
    }

    /**
     * 展示数组当前排序位置与排序后数组元素表
     * @param arrSort
     * @param beInd
     * @param exInd
     */
    default void showSort(Comparable[] arrSort, int beInd, int exInd){
        System.out.println(String.format("beginning index : [%d], exchange index : [%d], sorting array result : %s", beInd, exInd, Arrays.toString(arrSort)));
    }

    /**
     * 是否已排序
     * @param arrSort
     * @return
     */
    default boolean isSorted(Comparable[] arrSort){
        SortUtils.checkNullArrayParam(arrSort);
        //
        int arrayLength = arrSort.length;
        for(int ind = 1; ind < arrayLength; ind++){
            if(SortUtils.less(arrSort[ind], arrSort[ind - 1])){
                return false;
            }
        }
        //
        return true;
    }
}
```

```
public abstract class AbstractSortExample implements SortExample {
    @Override
    public void sort(Comparable[] arrSort) {
        SortUtils.checkNullArrayParam(arrSort);
        showData(arrSort);
    }
}
```

```SortUtils
package com.worthliu.algothrim;

/**
 * @ClassName SortUtils
 * @Description TODO
 * @Author Administrator
 * @Date 2019/6/16 21:49
 * @Version 1.0
 */
public class SortUtils {

    /**
     * 交换值
     * @param arrSort
     * @param exInd
     * @param tarInd
     */
    public static void exch(Comparable[] arrSort, int exInd, int tarInd){
        SortUtils.checkNullArrayParam(arrSort);
        SortUtils.checkArrayIndexOutOfBounds(arrSort, exInd);
        SortUtils.checkArrayIndexOutOfBounds(arrSort, tarInd);
        //
        Comparable tmp = arrSort[exInd];
        arrSort[exInd] = arrSort[tarInd];
        arrSort[tarInd] = tmp;
        //help GC
        tmp = null;
    }

    /**
     * @param v
     * @param w
     * @return
     */
    public static boolean less(Comparable v, Comparable w) {
        SortUtils.checkNullParam(v);
        SortUtils.checkNullParam(w);
        return v.compareTo(w) < 0;
    }

    /**
     * 是否相等
     * @param v
     * @param w
     * @return
     */
    public static boolean isEqual(Comparable v, Comparable w) {
        SortUtils.checkNullParam(v);
        SortUtils.checkNullParam(w);
        return v.compareTo(w) == 0;
    }

    /**
     * 是否为null
     * @param c
     * @return
     */
    public static boolean isNull(Comparable c) {
        if (c == null) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * 是否为null
     * @param c
     * @return
     */
    public static boolean isNullArray(Comparable[] c) {
        if (c == null || c.length <= 0) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @param v
     */
    public static void checkNullParam(Comparable v) {
        if (isNull(v)) {
            throw new IllegalArgumentException("Comparable parameter is null");
        }
    }

    /**
     * @param v
     */
    public static void checkNullArrayParam(Comparable[] v) {
        if (isNullArray(v)) {
            throw new IllegalArgumentException("Comparable parameter is null");
        }
    }

    public static void checkArrayIndexOutOfBounds(Comparable[] arrSort, int ind){
        if (arrSort.length <= ind || ind < 0){
            throw new IllegalArgumentException("Array's index is out of bounds.The index is [" + ind + "]");
        }
    }
}

```
把一个数组最开始的若干个元素搬到数组的末尾，我们称为数组的旋转。输入一个递增排序的数组的一个旋转，输出旋转数组的最小元素。

Example:
```
数组{3, 4, 5, 1, 2}为{1, 2, 3, 4, 5}的一个旋转，该数组的最小值为1；
```

## solution

>+ 用两个指针分别指向数组的第一个元素和最后一个元素；
+ 找到数组中间的元素，如果该中间元素位于前面的递增子数组，那么前指针指向该元素
+ 重复二分查找，当后指针指向元素小于前指针指向元素，且后指针和前指针相差1时，最小元素为后指针指向元素；

```
public int rotateArrayMinNum(int[] array){
    if(array == null){
        throw new IllegalArgumentException("Invalid parameter.");
    }
    
    int head = 0;
    int tail = array.length - 1;
    int minInd = head;
    while (array[head] >= array[tail]){
        if(tail - head == 1){
            minInd = tail;
            break;
        }
        //
        minInd = (head + tail) / 2;
        if(array[minInd] >= array[head]){
            head = minInd;
        }else if(array[minInd] <= array[tail]){
            tail = minInd;
        }
    }
    return array[minInd];
}
```

上述代码中，若排序数组，两个指针指向数字及它们中间的数字三者相同的时候，无法移动两个指针来缩小查找的范围，不得不采用顺序查找的方法；

```
public int rotateArrayMinNum(int[] array){
    if(array == null){
        throw new IllegalArgumentException("Invalid parameter.");
    }
    
    int head = 0;
    int tail = array.length - 1;
    int minInd = head;
    while (array[head] >= array[tail]){
        if(tail - head == 1){
            minInd = tail;
            break;
        }
        //
        minInd = (head + tail) / 2;
        if(array[minInd] >= array[head]){
            head = minInd;
        }else if(array[minInd] <= array[tail]){
            tail = minInd;
        }
    }
    return array[minInd];
}
```
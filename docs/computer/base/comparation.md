## 元素比较

Java中两个对象相比较的方法通常的用在元素排序中,常用的两个接口分别是`Comparable`和`Comparator`;

+ `Comparable`是自己与自己比较,可以看作是自营性质的比较器;
  + `Comparable`对象本身是可以与同类型进行比较的,比较方法是`compareTo`;
+ `Comparator`是第三方比较器,可以看作是平台性能的比较器;
  + `Comparator`自身是比较器的实践者,比较方法是`compare`;

### 用途

自然排序是以人类对常识认知的升序排序,而我们在使用某个自定义对象时,可能需要按照自己定义的方式排序;

因此,实现这样的自定义`Comparable`的示例:

```Demo
class SearchResult implements Comparable<SearchResult>{

    int relativeRatio;
    long count;
    private int recentOrders;

    public SearchResult(int relativeRatio, long count) {
        this.relativeRatio = relativeRatio;
        this.count = count;
    }

    /**
     * 自定义比较器
     * @param o
     * @return
     */
    @Override
    public int compareTo(SearchResult o) {
        if(this.relativeRatio != o.relativeRatio){
            return this.relativeRatio > o.relativeRatio ? 1 : -1;
        }
        //
        if(this.count != o.count){
            return this.count > o.count ? 1 : -1;
        }
        return 0;
    }

    public int getRecentOrders() {
        return recentOrders;
    }

    public void setRecentOrders(int recentOrders) {
        this.recentOrders = recentOrders;
    }
}
```

实现`Comparable`时,可以加上泛型限定,在编译阶段即可发现传入的非法参数对象,不需要在运行期进行类型检查和强制转换.


但是,若我们需要比较的对象没有相应的源码时,我们无法实现`Comparable`对应`compareTo()`方法;

因此我们需要引入外部比较器`Comparator`:

```Demo
class SearchResultComparator implements Comparator<SearchResult>{

    @Override
    public int compare(SearchResult o1, SearchResult o2) {
        if(o1.relativeRatio != o2.relativeRatio){
            return o1.relativeRatio > o2.relativeRatio ? 1 : -1;
        }
        //
        if(o1.count != o2.count){
            return o1.count > o2.count ? 1 : -1;
        }
        return 0;
    }
}
```

在JDK中,`Comparator`最典型的应用时在`Arrays.sort`中作为比较器参数进行排序:

```Arrays
    // <? super T>语法为下限通配,也就是将泛型类型参数限制为T或T的某个父类,直到Object
	public static <T> void sort(T[] a, Comparator<? super T> c) {
        // 未传入比较器时,采用归并排序
        if (c == null) {
            sort(a);
        } else {
            if (LegacyMergeSort.userRequested)
                legacyMergeSort(a, c);
            else
                TimSort.sort(a, 0, a.length, c, null, 0, 0);
        }
    }

    public static void sort(Object[] a) {
        if (LegacyMergeSort.userRequested)
            legacyMergeSort(a);
        else
            ComparableTimSort.sort(a, 0, a.length, null, 0, 0);
    }

    private static <T> void legacyMergeSort(T[] a, Comparator<? super T> c) {
        T[] aux = a.clone();
        if (c==null)
            mergeSort(aux, a, 0, a.length, 0);
        else
            mergeSort(aux, a, 0, a.length, 0, c);
    }

    private static void mergeSort(Object[] src,
                                  Object[] dest,
                                  int low,
                                  int high,
                                  int off) {
        int length = high - low;

        // 进行比较的数组比较小时,直接用插入排序即可
        if (length < INSERTIONSORT_THRESHOLD) {
            for (int i=low; i<high; i++)
                for (int j=i; j>low &&
                         ((Comparable) dest[j-1]).compareTo(dest[j])>0; j--)
                    swap(dest, j, j-1);
            return;
        }

        // 循环调用归并排序
        int destLow  = low;
        int destHigh = high;
        low  += off;
        high += off;
        int mid = (low + high) >>> 1;
        mergeSort(dest, src, low, mid, -off);
        mergeSort(dest, src, mid, high, -off);

        // 如果已排序完成,直接复制dest
        if (((Comparable)src[mid-1]).compareTo(src[mid]) <= 0) {
            System.arraycopy(src, low, dest, destLow, length);
            return;
        }

        // Merge sorted halves (now in src) into dest
        for(int i = destLow, p = low, q = mid; i < destHigh; i++) {
            if (q >= high || p < mid && ((Comparable)src[p]).compareTo(src[q])<=0)
                dest[i] = src[p++];
            else
                dest[i] = src[q++];
        }
    }
```

```TimSort
	static <T> void sort(T[] a, int lo, int hi, Comparator<? super T> c,
                         T[] work, int workBase, int workLen) {
        assert c != null && a != null && lo >= 0 && lo <= hi && hi <= a.length;

        int nRemaining  = hi - lo;
        if (nRemaining < 2)
            return;  // Arrays of size 0 and 1 are always sorted

        // If array is small, do a "mini-TimSort" with no merges
        if (nRemaining < MIN_MERGE) {
            int initRunLen = countRunAndMakeAscending(a, lo, hi, c);
            binarySort(a, lo, hi, lo + initRunLen, c);
            return;
        }

        /**
         * March over the array once, left to right, finding natural runs,
         * extending short natural runs to minRun elements, and merging runs
         * to maintain stack invariant.
         */
        TimSort<T> ts = new TimSort<>(a, c, work, workBase, workLen);
        int minRun = minRunLength(nRemaining);
        do {
            // Identify next run
            int runLen = countRunAndMakeAscending(a, lo, hi, c);

            // If run is short, extend to min(minRun, nRemaining)
            if (runLen < minRun) {
                int force = nRemaining <= minRun ? nRemaining : minRun;
                binarySort(a, lo, lo + force, lo + runLen, c);
                runLen = force;
            }

            // Push run onto pending-run stack, and maybe merge
            ts.pushRun(lo, runLen);
            ts.mergeCollapse();

            // Advance to find next run
            lo += runLen;
            nRemaining -= runLen;
        } while (nRemaining != 0);

        // Merge all remaining runs to complete sort
        assert lo == hi;
        ts.mergeForceCollapse();
        assert ts.stackSize == 1;
    }

    private static <T> void binarySort(T[] a, int lo, int hi, int start,
                                       Comparator<? super T> c) {
        assert lo <= start && start <= hi;
        if (start == lo)
            start++;
        for ( ; start < hi; start++) {
            T pivot = a[start];

            // Set left (and right) to the index where a[start] (pivot) belongs
            int left = lo;
            int right = start;
            assert left <= right;
            /*
             * Invariants:
             *   pivot >= all in [lo, left).
             *   pivot <  all in [right, start).
             */
            while (left < right) {
                int mid = (left + right) >>> 1;
                if (c.compare(pivot, a[mid]) < 0)
                    right = mid;
                else
                    left = mid + 1;
            }
            assert left == right;

            /*
             * The invariants still hold: pivot >= all in [lo, left) and
             * pivot < all in [left, start), so pivot belongs at left.  Note
             * that if there are elements equal to pivot, left points to the
             * first slot after them -- that's why this sort is stable.
             * Slide elements over to make room for pivot.
             */
            int n = start - left;  // The number of elements to move
            // Switch is just an optimization for arraycopy in default case
            switch (n) {
                case 2:  a[left + 2] = a[left + 1];
                case 1:  a[left + 1] = a[left];
                         break;
                default: System.arraycopy(a, left, a, left + 1, n);
            }
            a[left] = pivot;
        }
    }
```


>`sort()`方法中的`TimSort`算法,是归并排序(Merge Sort)与插入排序(Insertion Sort)优化后的排序算法;

### 基础排序算法

>归并排序的原理:
+ 长度为`1`的数组是排序好的,有`n`个元素的集合可以看成是`n`个长度为1的有序子集合;
+ 对有序子集集合进行两两归并,并保证结构子集合有序,最后得到`n/2`个长度为2的有序子集合;
+ 重复上一步骤直到所有元素归并成一个长度为`n`的有序集合.

**在上述排序过程中,主要工作在归并处理中,如何使归并过程更快,或者如何减少归并次数,成为优化归并排序的重点;**

>插入排序的原理:
+ 长度为`1`的数组是有序的;
+ 当有了`k`个已排序的元素,将第`k+1`个元素插入已有的`k`个元素中合适的位置,就会得到一个长度为`k+1`已排序的数组;
+ 添加一个新元素,将新元素放到第`n+1`个位置上,然后从后向前两两比较,如果新值较小则交换位置,知道新元素到达正确的位置;


2002年Tim Peters结合归并排序和插入排序的优点,实现了`TimeSort`排序算法;

该算法避免了归并排序和插入排序的缺点,相对传统归并排序,减少了归并次数,相对插入排序,引入了二分排序概念,提升了排序效率.

>`TimeSort`有两点优化:
+ 归并排序的分段不再从单个元素开始,而是每次先查找当前最大的排序好的数组片段run,然后对run进行扩展并利用二分排序,之后将该run与其他已经排序好的run进行归并,产生排序好的大run;
+ 引入二分排序,即`binarySort`.二分排序是对插入排序的优化,在插入排序中不再是从后向前逐个元素对比,而是引入了二分查找的思想,将一次查找新元素合适位置的时间复杂度由`O(n)`降低到`O(logn)`;


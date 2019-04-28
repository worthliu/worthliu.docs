## 元素比较

Java中两个对象相比较的方法通常的用在元素排序中,常用的两个接口分别是`Comparable`和`Comparator`;

+ `Comparable`是自己与自己比较,可以看作是自营性质的比较器;
  + `Comparable`对象本身是可以与同类型进行比较的,
+ `Comparator`是第三方比较器,可以看作是平台性能的比较器;
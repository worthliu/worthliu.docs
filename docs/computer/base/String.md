# String

>*  对于JDK中`String`类，由于其被`final`修饰，意味着其在后续使用过程中不可改变也不可继承；
*  `String`其最原始数据结构是`System.char[]`,由于其被修饰为`final`，意味着其一旦被初始化将不能改变；保证`String对象不可变的特性`；（这个也是`String`、`StringBuilder`、`StringBuffer`最大的区别）

```
public final class String
    implements java.io.Serializable, Comparable<String>, CharSequence {
    /** The value is used for character storage. */
    private final char value[];

    /** Cache the hash code for the string */
    private int hash;
}
```


## 不可变性

>* `String对象`是不可变的，String类中每一个看起来会修改`String`值的方法，实际上都是创建一个全新的`String对象`
，以包含修改后的字符串内容，而最初的`String对象`则丝毫未动；

```

```


![Immutability](/images/Immutability.jpg)


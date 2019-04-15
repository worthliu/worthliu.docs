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
	public static String upcase(String str){
        return str.toUpperCase();
    }

    public static void main(String[] args){
        String q = "howdy";
        System.out.println(q);
        //
        String qq = upcase(q);
        System.out.println(qq);
        System.out.println(q);
    }
```

上述示例中,当把q传给`upcase()`方法时,实际传递的是引用的一个拷贝.其实,每当把`String`对象作为方法的参数时,都会复制一份引用,而该引用所指的对象其实一直待在单一的物理位置上,从未动过;
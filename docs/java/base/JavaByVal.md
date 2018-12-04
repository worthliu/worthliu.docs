## Java 值传递和对象传递详解

**Java中基本数据类型的值和对象的引用保存在栈中，具体对象值保存在堆中。**

>传递原理：
+ **一个方法传递的参数如果是基本数据类型，则是对具体值的拷贝；**
+ **如果是对象数据类型，则是对对象引用地址值的拷贝，而非具体值拷贝。**

下面分析三种情况：

**一个方法不能改变传入基本类型的参数值。**

示例代码：
```
public class Test2 {

    public static void main(String[] args) {
        int a = 1;
        System.out.println("--->>>before a:"+a);
        change(a);
        System.out.println("--->>>after a:"+a);
    }

    private static void change(int b){
        b = 2;
        System.out.println("--->>>current b:"+b);
    }

}
```
>打印：
+ before a:1
+ current b:2
+ after a:1

![byval](/images/byval.png)

说明： 
**b=2单独开了一片空间，和a没有任何关系，所以改变b是不会对a的值有任何影响的。**

---

**一个方法不能改变传入对象类型的参数的引用地址。**

示例代码：
```
public class Test3 {

    public static void main(String[] args) {
        Person pa = new Person("张三");
        System.out.println("--->>>before pa:"+pa.getName());
        change(pa);
        System.out.println("--->>>after pa:"+pa.getName());
    }

    private static void change(Person pb){
        Person pc = new Person("李四");
        pb = pc;
        System.out.println("--->>>current pc:"+pc.getName());
        System.out.println("--->>>current pb:"+pb.getName());
    }

    public static class Person{
        private String name;

        public Person(String name){
            this.name = name;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

    }
```
>打印：
+ before pa:张三
+ current pc:李四
+ current pb:李四
+ after pa:张三

图解：
![byval2](/images/byval2.png)

>说明： 
+ 当开始调用change(pa)的时候，实际上是将pa的地址拷贝了一份然后给了pb，所以pa和pb都指向张三； 
+ pc是从新new的，会重新开辟栈区和堆区的空间； 
+ 然后经过pb = pc的赋值操作后，实际上是让他们同时指向堆区的李四。


**一个方法能够改变传入对象类型的参数某一个属性。**

实例代码：
```
public class Test4 {
    public static void main(String[] args) {
        Person pa = new Person("张三");
        System.out.println("--->>>before pa:"+pa.getName());
        change(pa);
        System.out.println("--->>>after pa:"+pa.getName());
    }

    private static void change(Person pb){
        pb.setName("李四");
        System.out.println("--->>>current pb:"+pb.getName());
    }

    public static class Person{
        private String name;

        public Person(String name){
            this.name = name;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

    }

}
```
>打印：
+ before pa:张三
+ current pb:李四
+ after pa:李四

图解： 
![byval3](/images/byval3.png)

>说明： 
+ 调用change(pa)方法后，实际上是将pa的地址拷贝了一份然后给了pb，所以pa和pb都指向张三； 
+ 调用pb.setName(“李四”)后，实际上是将张三变成了李四，pa和pb引用地址不变，所以pa和pb都指向了李四。

---

>**总结：** 
1. **一个方法不能改变传入基本类型的参数值。**
2. **一个方法不能改变传入对象类型的参数的引用地址。**
3. **一个方法能够改变传入对象类型的参数某一个属性。**
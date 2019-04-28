## 集合与泛型

泛型与集合的联合使用,可以把泛型的功能发挥到极致,但是泛型的使用过程有很多区别限制;

如`List`,`List<Object>`,`List<?>`的区别?

>+ `List`,完全没有类型的限制和赋值限定,但是如果天马行空乱用,有可能非遭遇类型转换失败的异常;
+ `List<Object>`,其用法完全等同于`List`,但在接受其他泛型赋值时会编译出错;
+ `List<?>`,其在没有赋值之前,表示它可以接受任何类型的集合赋值,但是赋值之后就不能随便往里添加元素了;

```
	public static void main(String[] args){
        // 泛型出现前,集合定义方式
        List first = new ArrayList();
        first.add(new Object());
        first.add(new Integer(1));
        first.add(new String("hello first"));

        //
        List<Object> second = first;
        second.add(new Object());
        second.add(new Integer(222));
        second.add(new String("hello second"));

        //
        List<Integer> third = first;
        third.add(new Integer(3));
        // 由于有Integer泛型限制，此处不允许赋值，报参数类型不合法
        third.add(new Object());

        // 通配符泛型,它可以接受任何类型的集合引用赋值,不能添加任何元素
        List<?> fourthly = first;
        first.remove(0);
        fourthly.clear();
        // 不允许增加任何元素
        fourthly.add(new Object());
    }
```

### `<? extends T>`与`<? super T>`

`List<T>`最大的问题是只能放置一种类型,如果随意转换类型的话,就是"破窗理论",泛型就失去了类型安全的意义;

>**如果需要放置多种类泛型约束的类型呢?**

+ `<? extends T>`,是Get First,适用于消费集合元素为主的场景;
  + 其可以赋值给任何`T`及`T`子类的集合,上界为`T`,取出来的类型带有泛型限制,向上强制转换为T;
  + `null`可以表示任何类型,所以除`null`外,任何元素都不得添加进`<? extend T>`集合内;

+ `<? super T>`,是Pull First,适用于生产集合元素为主的场景;
  + 其可以赋值给任何`T`及`T`父类的集合,下界为`T`;
  + 取出来的类型为父类类型,丧失子类自有特性;



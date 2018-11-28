# POJO与JavaBean异同

## 什么是POJO

>* 按照Martin Fowler的解释是“Plain Old Java Object”，从字面上翻译为“纯洁老式的Java对象”，但大家都使用“简单java对象”来称呼它。
* POJO的内在含义是指那些没有从任何类继承、也没有实现任何接口，更没有被其它框架侵入的java对象。

## pojo和javabean的比较
>pojo的格式是用于数据的临时传递，它只能装载数据， 作为数据存储的载体，而不具有业务逻辑处理的能力。
而javabean虽然数据的获取与pojo一样，但是javabean当中可以有其它的方法。

>JavaBean 是一种JAVA语言写成的可重用组件。它的方法命名，构造及行为必须符合特定的约定：
  1. 这个类必须有一个公共的缺省构造函数。
  2. 这个类的属性使用getter和setter来访问，其他方法遵从标准命名规范。
  3. 这个类应是可序列化的。 
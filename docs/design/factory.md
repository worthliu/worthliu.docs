## 工厂方法模式

**`Define an interface for creating an object,but let subclasses decide which class to instantiate.Factory Method lets a class defer instantiation to subclasses.`**

**（定义一个用于创建对象的
接口，让子类决定实例化哪一个类。工厂方法使一个类的实例化延迟到其子类。）**

![factory](/images/factory.png)

## 代码实现

```
public abstract class Product {
    public void methodFirst(){

    }

    public abstract void methodSecond();
}

public class ConcreteProductFirst extends Product {
    @Override
    public void methodSecond() {

    }
}

public class ConcreteProductSecond extends Product {
    @Override
    public void methodSecond() {

    }
}

public abstract class Creator {
    public abstract <T extends Product> T createProduct(Class<T> clazz);
}

public class ConcreteCreator extends Creator {
    @Override
    public <T extends Product> T createProduct(Class<T> clazz) {
        Product product = null;
        try {
            product = (Product) Class.forName(clazz.getName()).newInstance();
        }catch (Exception e){

        }
        return (T) product;
    }
}
```

## 工厂方法模式的应用

### 工厂方法模式的优点
> + 首先，良好的封装性，代码结构清晰。
  + 一个对象创建是有条件约束的，如一个调用者需要一个具体的产品对象，只要知道这个产品的类名（或约束字符串）就可以了，不用知道创建对象的艰辛过程，降低模块间的耦合。
+ 其次，工厂方法模式的扩展性非常优秀。在增加产品类的情况下，只要适当地修改具体的工厂类或扩展一个工厂类，就可以完成“拥抱变化”。
+ 再次，屏蔽底层对象类实现,通过反射方式创建实际对象。
+ 最后，工厂方法模式是典型的解耦框架。
  + 高层模块值需要知道产品的抽象类，其他的实现类都不用关心，`符合迪米特法则`;
  + 我不需要的就不要去交流；`也符合依赖倒置原则`，只依赖产品类的抽象；
  + 当然`也符合里氏替换原则`，使用产品子类替换产品父类，没问题！

### 工厂方法模式的使用场景
> + 首先，工厂方法模式是new一个对象的替代品，所以在所有需要生成对象的地方都可以使用，**但是需要慎重地考虑是否要增加一个工厂类进行管理，增加代码的复杂度**。
+ 其次，需要灵活的、可扩展的框架时，可以考虑采用工厂方法模式。
+ 再次，工厂方法模式可以用在异构项目中，。
+ 最后，可以使用在测试驱动开发的框架下。

## 工厂方法模式的扩展

1. 缩小为`简单工厂模式`(**简化底层工厂类,去掉抽象工厂类**)

![simpleFactory](/images/simpleFactory.png)

> 我们在类图中去掉了`AbstractHumanFactory抽象类`，同时把`createHuman方法`设置为`静态类型`，简化了**类的创建过程**，变更的源码仅仅是`HumanFactory`和`NvWa`类

2. 升级为`多个工厂类`(**对外用户调用的工厂类区分化**)

![moreFactory](/images/moreFactory.png)
## 定义

装饰模式(`Decorator Pattern`),动态地给一个对象添加一些额外的职责.就增加功能来说,装饰模式相比生成子类更为灵活;

![decorator](/images/decorator.png)

+ `Component`抽象构件 : 接口或者是抽象类,定义了最核心的对象;
+ `ConcreteComponent`具体构件 : 最核心,最原始,最基本的接口或抽象类的实现,装饰的对象;
+ `Decorator`装饰对象 : 抽象类,实现接口或者抽象方法,它里面不一定有抽象的方法,在它的属性必然有一个`private`变量指向`Component`抽象构件;
+ `ConcreteDecorator`具体装饰角色


## 实例


真实行为构件
```Component
public abstract class Component {
    public abstract void doSomething();
}


public class ConcreteComponent extends Component {
    @Override
    public void doSomething() {
        System.out.println("The real way is doing something");
    }
}
```


装饰者行为构件
```Decorator
public abstract class Decorator extends Component{
    private Component component;

    public Decorator(Component component) {
        this.component = component;
    }

    @Override
    public void doSomething() {
        component.doSomething();
    }
}


public class ConcreteDecorator extends Decorator {

    public ConcreteDecorator(Component component) {
        super(component);
    }

    private void decBeforeMethod() {
        System.out.println("execute decorator before's method.");
    }

    private void decAfterMethod() {
        System.out.println("execute decorator after's method.");
    }

    @Override
    public void doSomething() {
        decBeforeMethod();
        super.doSomething();
        decAfterMethod();
    }
}
```

## 应用

>优点
+ 装饰类和被装饰类可以独立发展,而不会相互耦合.
+ 装饰模式是继承关系的一个替代方案;
+ 装饰模式可以动态地扩展一个实现类的功能;

>缺点
+ 多层的装饰为调式带来几何倍增的复杂度;


### 使用场景

+ 需要扩展一个类的功能,或给一个类增加附加功能;
+ 需要动态地给一个对象增加功能,这个些功能可以再动态地撤销;
+ 需要为一批的兄弟类进行改装或加装功能;
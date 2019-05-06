## 策略模式

策略模式,其定义是:定义一组算法,将每个算法都封装起来,并且使它们之间可以互换;

![strategy](/images/strategy.png)

策略模式使用的就是面向对象的继承和多态机制,非常容易理解和掌握:

+ `Context`封装角色:
  + 上下文角色,起承上启下封装作用,屏蔽高层模块对策略,算法的直接访问,封装可能存在的变化;
+ `Strategy`抽象策略角色:
  + 策略,算法家族的抽象,通常为接口,定义每个策略或算法必须具有的方法和属性.
+ `ConcreteStrategy`具体策略角色:
  + 实现抽象策略中的操作,该类含有具体的算法;

### 具体实现

抽象的策略角色

```Strategy
public interface Strategy {
    void doSomething();
}
```

具体策略角色实现:

```ConcreteStrategyFirst
public class ConcreteStrategyFirst implements Strategy{
    @Override
    public void doSomething() {
        System.out.println("第一种具体策略实现");
    }
}
```

```ConcreteStrategySecond
public class ConcreteStrategySecond implements Strategy {
    @Override
    public void doSomething() {
        System.out.println("第二种具体策略实现方法");
    }
}
```

策略模式的重点就是封装角色,它是借用了代理模式的思路;

**差别就是策略模式的封装角色和被封装的策略类不用是同一个接口,如果是同一个接口那就成为了代理模式;**

```Context
public class Context {
    private Strategy strategy = null;

    public Context(Strategy strategy){
        this.strategy = strategy;
    }

    public void doAnything(){
        this.strategy.doSomething();
    }
}
```


### 应用

策略模式的优点:
+ 算法可以自由的切换
+ 避免使用多重条件判断
+ 扩展性良好

策略模式的缺点:
+ 策略类数量增多
+ 所有的策略类都需要对外暴露

>策略模式的使用场景:
+ 多个类只有在算法或行为上稍有不同的场景
+ 算法需要自由切换的场景
+ 需要屏蔽算法规则的场景

**如果系统中的一个策略家族的具体策略数量超过4个,则需要考虑使用混合模式,解决策略类膨胀和对外暴露的问题,否则日后的系统维护就会成为一个烫手山芋,谁都不想接;**
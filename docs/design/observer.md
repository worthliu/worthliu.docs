## 定义

观察者模式(`Observer Pattern`),也叫做发布订阅模式,它是一个再项目中经常使用的模式;

其定义对象间一种一对多的依赖关系,使得每当一个对象改变状态,则所有依赖于它的对象都会得到通知并被自动更新;

![observer](/images/observer.png)


+ `Subject`被观察者 : 定义被观察者必须实现的职责,它必须能够动态地增加,取消观察者;一般是抽象类或是实现类;
+ `Observer`观察者 : 观察者接收到消息后,进行`update`操作,对接收的信息进行处理;
+ `ConcreteSubject`具体的被观察者 : 定义被观察者自己的业务逻辑,同时定义对哪些事件进行通知;
+ `ConcreteObserver`具体观察者 : 每个观察者在接收到消息后的处理反应是不同,各个观察者有自己的处理逻辑;


## 实例

```Subject

public abstract class Subject {

    /**
     * The observer array table;
     */
    private CopyOnWriteArrayList<Observer> observerCOWList = new CopyOnWriteArrayList<Observer>();

    /**
     * adding an observer into cowlist;
     * @param observer
     */
    public void addObserver(Observer observer){
        observerCOWList.add(observer);
    }

    /**
     * deleting an special observer
     * @param observer
     */
    public void deleteObserver(Observer observer){
        observerCOWList.remove(observer);
    }

    /**
     * notifying all observers
     */
    public void notifyObservers(){
        for (Observer observer : observerCOWList){
            observer.update();
        }
    }
}

public class ConcreteSubject extends Subject {

    public void doSomething(){
        // doing something
        super.notifyObservers();
    }
}
```

```Observer
public interface Observer {

    void update();
}


public class ConcreteObserver implements Observer {
    @Override
    public void update() {
        System.out.println("I am the first observer ");
    }
}
```

## 应用

>优点
+ 观察者和被观察者之间是抽象耦合
+ 建立一套触发机制


>缺点
+ 通知默认是顺序执行,一旦中间卡顿,会影响整体执行效率;

### 使用场景

+ 关联行为场景;关联行为是可拆分的,而不是"组合"关系;
+ 事件多级触发场景;
+ 跨系统的消息交换场景,如消息队列的处理机制;

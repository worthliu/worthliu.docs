## 定义

责任链模式:
+ 使多个对象都有机会处理请求,从而避免了请求的发送者和接受者之间的耦合关系;
+ 将这个对象连成一条链,并沿着这条链传递该请求,直到有对象处理它为止;

![handlerChain](/images/handlerChain.png)

## 实例

```Handler
public abstract class Handler {
    private Handler nextHandler;

    public final Response handleMessage(Request request){
        Response response = null;
        
        if(this.getHandlerLevel().equals(request.getRequestLevel())){
            response = this.echo(request);
        }else{
            if(this.nextHandler != null){
                response = this.nextHandler.handleMessage(request);
            }else {

            }
        }
        return response;
    }

    /**
     * 设置下一个处理者是谁
     * @param nextHandler
     */
    public void setNextHandler(Handler nextHandler) {
        this.nextHandler = nextHandler;
    }

    protected abstract Response echo(Request request);

    /**
     * 处理级别
     * @return
     */
    protected abstract Level getHandlerLevel();
}
```

抽象的处理者实现三个职责:
+ 定义一个请求的处理方法`handleMessage`,唯一对外开放的方法;
+ 定义一个链的编排方法`setNext`,设置下一个处理者;
+ 定义了具体的请求必须实现的两个方法;

```ConcreteHandler
public class ConcreteHandler extends Handler{
    @Override
    protected Response echo(Request request) {
        return null;
    }

    @Override
    protected Level getHandlerLevel() {
        return null;
    }
}
```

## 应用

>优点:将请求和处理分开,两者解耦,提高系统的灵活性;

>缺点:
+ 性能问题.每个请求都是从链头遍历到链尾;
+ 调试不方便;


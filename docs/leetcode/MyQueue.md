Implement the following operations of a queue using stacks.

+ push(x) -- Push element x to the back of queue.
+ pop() -- Removes the element from in front of queue.
+ peek() -- Get the front element.
+ empty() -- Return whether the queue is empty.

Example:

```
MyQueue queue = new MyQueue();

queue.push(1);
queue.push(2);  
queue.peek();  // returns 1
queue.pop();   // returns 1
queue.empty(); // returns false
```

>Notes:
+ You must use only standard operations of a stack -- which means only push to top, peek/pop from top, size, and is empty operations are valid.
+ Depending on your language, stack may not be supported natively. You may simulate a stack by using a list or deque (double-ended queue), as long as you use only standard operations of a stack.
+ You may assume that all operations are valid (for example, no pop or peek operations will be called on an empty queue).


```
class MyQueue {

    /** Initialize your data structure here. */
    public MyQueue() {
        
    }
    
    /** Push element x to the back of queue. */
    public void push(int x) {
        
    }
    
    /** Removes the element from in front of queue and returns that element. */
    public int pop() {
        
    }
    
    /** Get the front element. */
    public int peek() {
        
    }
    
    /** Returns whether the queue is empty. */
    public boolean empty() {
        
    }
}
```

## solution

> 删除一个元素的步骤
+ 当stack2中不为空时，在stack2中的栈顶元素是最先进入队列的元素，可以弹出。
+ 如果stack2为空时，把stack1中的元素逐个弹出并压入stack2。
+ 由于先进入队列的元素被压倒stack1的底端，经过弹出和压入之后就处于stack2的顶端了，又可以直接弹出。

```
public class MyQueue {
    private Stack<Integer> pushStack;

    private Stack<Integer> popStack;

    /** Initialize your data structure here. */
    public MyQueue() {
        pushStack = new Stack<>();
        popStack = new Stack<>();
    }

    /** Push element x to the back of queue. */
    public void push(int x) {
        pushStack.push(x);
    }

    /** Removes the element from in front of queue and returns that element. */
    public int pop() {
        if(popStack.isEmpty()){
            while (!pushStack.isEmpty()){
                popStack.push(pushStack.pop());
            }
        }
        //
        return popStack.isEmpty() ? -1 : popStack.pop();
    }

    /** Get the front element. */
    public int peek() {
        if(!pushStack.isEmpty()){
            return pushStack.firstElement();
        }else if(!popStack.isEmpty()){
            return popStack.lastElement();
        }else{
            return -1;
        }
    }

    /** Returns whether the queue is empty. */
    public boolean empty() {
        return pushStack.isEmpty() && popStack.isEmpty();
    }
}

```
定义栈的数据结构。请在该类型中实现一个能够得到栈的最小元素的min函数。在该栈中，调用`min`、`push`、`pop`的时间复杂度都是`O(1)`;

题解：

+ 采用辅助数据栈
+ 往空的数据栈里压入数字A时，数字A位最小值，同时压入辅助数据栈
+ 再次压入数字B，若数字B小于数字A时，数字B位最小值，压入辅助数据栈，否将数字A压入辅助数据栈；

## solution

```
public class StackWithMin {
    private Stack<Integer> dataStack;

    private Stack<Integer> minDataStack;

    public StackWithMin() {
        this.dataStack = new Stack<>();
        this.minDataStack = new Stack<>();
    }

    public void push(Integer val){
        dataStack.push(val);
        if(minDataStack.isEmpty() || val < minDataStack.peek()){
            minDataStack.push(val);
        }else{
            minDataStack.push(minDataStack.peek());
        }
    }

    public Integer pop(){
        if(dataStack.isEmpty() && minDataStack.isEmpty()){
            return -1;
        }
        //
        Integer val = dataStack.pop();
        minDataStack.pop();
        return val;
    }

    public Integer min(){
        if(dataStack.isEmpty() && minDataStack.isEmpty()){
            return -1;
        }
        //
        return minDataStack.peek();
    }
}
```
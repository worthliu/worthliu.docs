输入两个整数序列，第一个序列表示栈的压入顺序，请判断第二个序列是否位该栈的弹出顺序。假设压入栈的所有数字均不相等。

Example ：

```
压入序列： 1 、 2、 3、 4、 5

4、 5、 3、 2、 1是该栈对应的一个弹出序列；

但4、 3、 5、 1、 2就不可能是该压栈序列的弹出序列；
```

### 题解

解决这个问题很直观想法就是建立一个**辅助栈**，把输入的第一个序列中数字依次压入该辅助栈，并按照第二个序列的顺序依次从该栈中弹出数字；

>判断一个序列是不是栈的弹出序列的规律：
+ 如果下一个弹出数字刚好是栈顶数字，那么直接弹出。
+ 如果下一个弹出的数字不再栈顶，把压栈序列中还没有入栈的数字压入辅助栈，直到把下一个需要弹出的数字压入栈顶为止；
+ 如果所有数字都压入栈了仍然没有找到下一个弹出的数字，那么该序列不可能是一个弹出序列


## solution

```
public boolean validateStackSequences(int[] pushed, int[] popped) {
    boolean result = false;
    if(pushed != null || popped != null ||
            pushed.length == popped.length){
        Stack<Integer> data = new Stack<>();
        int length = pushed.length;
        int pushNext = 0;
        int poppedNext = 0;

        while (poppedNext < length){
            while (data.isEmpty() || data.peek() != popped[poppedNext]){
                if(pushNext == length){
                    break;
                }
                data.push(pushed[pushNext]);
                pushNext++;
            }
            //
            if(data.peek() != popped[poppedNext]){
                break;
            }
            data.pop();
            poppedNext++;
        }

        if(data.isEmpty() && poppedNext == length){
            result = true;
        }
    }

    return result;
}
```
Design your implementation of the circular queue. The circular queue is a linear data structure in which the operations are performed based on FIFO (First In First Out) principle and the last position is connected back to the first position to make a circle. It is also called "Ring Buffer".

One of the benefits of the circular queue is that we can make use of the spaces in front of the queue. In a normal queue, once the queue becomes full, we cannot insert the next element even if there is a space in front of the queue. But using the circular queue, we can use the space to store new values.

Your implementation should support following operations:

MyCircularQueue(k): Constructor, set the size of the queue to be k.
Front: Get the front item from the queue. If the queue is empty, return -1.
Rear: Get the last item from the queue. If the queue is empty, return -1.
enQueue(value): Insert an element into the circular queue. Return true if the operation is successful.
deQueue(): Delete an element from the circular queue. Return true if the operation is successful.
isEmpty(): Checks whether the circular queue is empty or not.
isFull(): Checks whether the circular queue is full or not.
 

Example:
```
MyCircularQueue circularQueue = new MyCircularQueue(3); // set the size to be 3
circularQueue.enQueue(1);  // return true
circularQueue.enQueue(2);  // return true
circularQueue.enQueue(3);  // return true
circularQueue.enQueue(4);  // return false, the queue is full
circularQueue.Rear();  // return 3
circularQueue.isFull();  // return true
circularQueue.deQueue();  // return true
circularQueue.enQueue(4);  // return true
circularQueue.Rear();  // return 4
```
Note:
```
All values will be in the range of [0, 1000].
The number of operations will be in the range of [1, 1000].
Please do not use the built-in Queue library.
```

## solution

```
public class MyCircularQueue {

    private int[] items;

    private int head = -1;

    private int tail = -1;

    private int count = 0;

    private int size;


    /**
     * Initialize your data structure here. Set the size of the queue to be k.
     */
    public MyCircularQueue(int k) {
        if(k <= 0 || k > Integer.MAX_VALUE){
            throw new IllegalArgumentException("capacity parameter error");
        }
        items = new int[k];
        size = k;
    }

    /**
     * Insert an element into the circular queue.
     * Return true if the operation is successful.
     */
    public boolean enQueue(int value) {
        final int[] items = this.items;
        if(isFull()){
            return false;
        }
        //
        if(isEmpty()){
            head = 0;
        }
        //
        items[nextTail()] = value;
        count++;
        return true;
    }

    /**
     * Delete an element from the circular queue.
     * Return true if the operation is successful.
     */
    public boolean deQueue() {
        final int[] items = this.items;
        if(isEmpty()){
            return false;
        }
        //
        if(head + 1 >= size){
            head = 0;
        }
        items[head] = -1;
        head++;
        count--;
        return true;
    }

    /**
     * Get the front item from the queue.
     */
    public int Rear() {
        final int[] items = this.items;
        if(isEmpty()){
            return -1;
        }
        int eleVal = items[tail];
        return eleVal;
    }

    /**
     * Get the last item from the queue.
     */
    public int Front() {
        final int[] items = this.items;
        if(isEmpty()){
            return -1;
        }
        //
        int eleVal = items[head];
        return eleVal;
    }

    /**
     * Checks whether the circular queue is empty or not.
     */
    public boolean isEmpty() {
        if(count == 0){
            return true;
        }
        return false;
    }

    /**
     * Checks whether the circular queue is full or not.
     */
    public boolean isFull() {
        if(count == size){
            return true;
        }
        return false;
    }

    /**
     * @return
     */
    private int nextTail() {
        if(tail + 1 >= size){
            tail = 0;
        }else {
            tail++;
        }
        return tail;
    }
}

```

```
public class MyCircularQueue<E> {

    private Object[] items;

    private int head = -1;

    private int tail = -1;

    private int count = 0;

    private int size;


    /**
     * Initialize your data structure here. Set the size of the queue to be k.
     */
    public MyCircularQueue(int k) {
        if(k <= 0 || k > Integer.MAX_VALUE){
            throw new IllegalArgumentException("capacity parameter error");
        }
        items = new Object[k];
        size = k;
    }

    /**
     * Insert an element into the circular queue.
     * Return true if the operation is successful.
     */
    public boolean enQueue(E value) {
        final Object[] items = this.items;
        if(isFull()){
            return false;
        }
        //
        if(head == -1){
            head = 0;
        }
        if(tail + 1 >= size){
            tail = 0;
        }else {
            tail++;
        }
        //
        items[tail] = value;
        count++;
        return true;
    }

    /**
     * Delete an element from the circular queue.
     * Return true if the operation is successful.
     */
    public boolean deQueue() {
        final Object[] items = this.items;
        if(isEmpty()){
            return false;
        }
        //
        if(head + 1 >= size){
            head = 0;
        }
        items[head] = null;
        head++;
        count--;
        return true;
    }

    /**
     * Get the front item from the queue.
     */
    public E Rear() {
        final Object[] items = this.items;
        if(isEmpty()){
            return null;
        }
        E eleVal = (E) items[tail];
        return eleVal;
    }

    /**
     * Get the last item from the queue.
     */
    public E Front() {
        final Object[] items = this.items;
        if(isEmpty()){
            return null;
        }
        //
        E eleVal = (E) items[head];
        return eleVal;
    }

    /**
     * Checks whether the circular queue is empty or not.
     */
    public boolean isEmpty() {
        if(count == 0){
            return true;
        }
        return false;
    }

    /**
     * Checks whether the circular queue is full or not.
     */
    public boolean isFull() {
        if(count == size){
            return true;
        }
        return false;
    }
}
```
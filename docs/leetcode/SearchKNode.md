输入一个链表，输出该链表中倒数第k个结点。为了符合计数习惯，从1开始计数，即链表的尾结点是倒数第1个结点。

### 题解

>最简单做法，先走到链表的尾端，再从尾端回溯k步。**前置条件结点有前后指向指针**

>单指针，若整个链表有n个结点，那么倒数第k个结点就是从头结点开始的第n-k+1个结点。如果我们能够得到链表中结点的个数n。只需要从头结点开始往后走n-k+1步就可以了。
+ **如何得到结点数n？**，从头开始遍历链表，计算得到结点数n；
+ **整体处理逻辑，需要遍历两次链表；**

>只需遍历链表一次就能找到倒数第k个结点：
+ 定义两个指针。preNext指针从链表的头指针开始遍历向前走k-1，backNext指针保持不动；
+ 从第k步开始，backNext指针也开始从链表的头指针开始遍历；
+ 由于两个指针的距离保持在k-1，当preNext指针到达链表尾结点时，backNext正好是倒数第k个结点；

## solution

```
public ListNode serachKNode(ListNode head, int n){
    if(head == null || n <= 0){
        return null;
    }

    ListNode preNext = head;
    ListNode backNext = head;
    int count = 1;

    while(preNext.next != null){
        if(count >= n){
            backNext = backNext.next;
        }
        preNext = preNext.next;
        ++count;
    }
    //
    return backNext;
}
```
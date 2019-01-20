反转一个单链表。

示例:
```
输入: 1->2->3->4->5->NULL
输出: 5->4->3->2->1->NULL
```

进阶:
你可以迭代或递归地反转链表。你能否用两种方法解决这道题？

Note:

```
链表在反转时,注意中间断裂,因此需要三个指针,分别指向前、中、后三个结点
```
## solution

```
public ListNode reverseLink(ListNode pHead){
    if(pHead == null || pHead.next == null){
        return pHead;
    }

    ListNode pReversedHead = null;
    ListNode pNode = pHead;
    ListNode pPrev = null;
    while (pNode != null){
        ListNode pNext = pNode.next;
        if(pNext == null){
            pReversedHead = pNode;
        }
        //
        pNode.next = pPrev;
        pPrev = pNode;
        pNode = pNext;
    }
    return pReversedHead;
}
```



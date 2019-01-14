给定单向链表的头指针和一个结点指针,定义一个函数在O(1)时间删除该结点;

### 解题

>+ 链表中，想删除结点i，可以从链表的头节点a开始顺序遍历，发现结点h的next指向要删除的结点i，于是把结点h的next指向i的下一个结点即结点j。
+ 指针调整之后，就可以安全地删除结点i并保证链表没有断开。时间复杂度自然为O(n)；

**是否一定需要得到被删除的结点的前一个结点？**

答案是否定的；

>+ 如果把下一个结点的内容复制到需要删除的结点上覆盖原有的内容；
+ 再把下一个结点删除，就相当于把当前需要删除的结点删除了；

## solution

```
public void deleteNode(ListNode head, ListNode toBeDelete){
        if(head == null || toBeDelete == null){
            return;
        }
        //
        if(toBeDelete.next != null){
            ListNode pNext = toBeDelete.next;
            toBeDelete.val = pNext.val;
            toBeDelete.next = pNext.next;
        }else if(head.equals(toBeDelete)){
            head = null;
            toBeDelete = null;
        }else{
            ListNode pNode = head;
            while (!toBeDelete.equals(pNode.next)){
                pNode = pNode.next;
            }

            pNode.next = null;
        }
    }
```

```
public void deleteNode(ListNode toBeDelete){
    if (toBeDelete == null){
        return;
    }

    if(toBeDelete.next != null){
        ListNode pNext = toBeDelete.next;
        toBeDelete.val = pNext.val;
        toBeDelete.next = pNext.next;
    }else{
        toBeDelete = null;
    }
}
```
将两个有序链表合并为一个新的有序链表并返回。新链表是通过拼接给定的两个链表的所有节点组成的。 

示例：
```
输入：1->2->4, 1->3->4
输出：1->1->2->3->4->4
```

## solution

```
public ListNode merge(ListNode headA, ListNode headB){
    if(headA == null){
        return headB;
    }else if(headB == null){
        return headA;
    }

    ListNode headNew = new ListNode(0);
    ListNode tarNode = headNew;
    ListNode pNode = headA;
    ListNode qNode = headB;
    while (pNode != null || qNode != null){
        if(pNode != null && qNode != null){
            if(pNode.val >= qNode.val){
                tarNode.next = new ListNode(qNode.val);
                qNode = qNode.next;
            }else{
                tarNode.next = new ListNode(pNode.val);
                pNode = pNode.next;
            }
        }else if(pNode == null){
            tarNode.next = new ListNode(qNode.val);
            qNode = qNode.next;
        }else {
            tarNode.next = new ListNode(pNode.val);
            pNode = pNode.next;
        }
        tarNode = tarNode.next;
    }
    //
    return headNew.next;
}
```

```
public ListNode mergeIterate(ListNode headA, ListNode headB){
    if (headA == null){
        return headB;
    }else if(headB == null){
        return headA;
    }

    ListNode mergeHead = null;
    if(headA.val < headB.val){
        mergeHead = headA;
        mergeHead.next = mergeIterate(headA.next, headB);
    }else{
        mergeHead = headB;
        mergeHead.next = mergeIterate(headA, headB.next);
    }
    return mergeHead;
}
```
输入两链表，找出它们的第一个公共结点。


### 题解

正常做法，是直接遍历链表。时间复杂度是O(mn)

>+ 如果两个链表有公共结点，那么公共结点出现在两个链表的尾部。如果从两个链表的尾部开始往前比较，最后一个相同的结点就是目标结点；
+ 分别把两个链表的结点放入两个栈里，这样两个链表的尾结点就位与两个栈的栈顶，接下来比较两个栈顶的结点是否相同。
+ 如果相同，则把栈顶弹出接着比较下一个栈顶，直到找到最后一个相同的结点；


>+ 首先遍历两个链表得到它们的长度，就能知道那个链表比较长，以及长的链表比短链表多几个结点。
+ 第二次遍历的时候，在较长的链表上先走若干步，接着再同时在两个链表上遍历，找到的第一个相同的结点就是它们的第一个公共结点；

## solution

```
	public ListNode findfirstCommonNode(ListNode headA, ListNode headB){
        if(headA == null || headB == null){
            return null;
        }
        
        int aLength = getLinkLength(headA);
        int bLength = getLinkLength(headB);
        int difLength = aLength - bLength;
        //
        ListNode headLong = headA;
        ListNode headShort = headB;
        if(bLength > aLength){
            difLength = bLength - aLength;
            headLong = headB;
            headShort = headA;
        }
        //
        for(int ind = 0; ind < difLength; ind++){
            headLong = headLong.next;
        }
        //
        while (headLong != null && headShort != null && (headLong != headShort)){
            headLong = headLong.next;
            headShort = headShort.next;
        }
        //
        ListNode targetNode = headLong;
        return targetNode;
    }

    private int getLinkLength(ListNode headA) {
        int count = 0;
        if(headA != null){
            ListNode pNode = headA;
            while (pNode != null){
                count++;
                pNode = pNode.next;
            }
        }
        return count;
    }
```
You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order and each of their nodes contain a single digit. Add the two numbers and return it as a linked list.

You may assume the two numbers do not contain any leading zero, except the number 0 itself.

Example:
```
Input: (2 -> 4 -> 3) + (5 -> 6 -> 4)
Output: 7 -> 0 -> 8
Explanation: 342 + 465 = 807.
```

```
/**
 * Definition for singly-linked list.
 */
public class ListNode {
    int val;
    ListNode next;
    ListNode(int x) { val = x; }
}

```

## solution

```
public ListNode addTwoNumbers(ListNode l1, ListNode l2) {

        ListNode calcResNode = new ListNode(0);
        ListNode curNode = calcResNode;
        int carryVal = 0;
        ListNode p = l1;
        ListNode q = l2;
        //
        while(p != null || q != null){
            int pVal = p != null ? p.val : 0;
            int qVal = q != null ? q.val : 0;

            int calcVal = pVal + qVal + carryVal;
            carryVal = calcVal / 10;
            curNode.next = new ListNode(calcVal % 10);
            curNode = curNode.next;
            //
            p = p != null ? p.next : null;
            q = q != null ? q.next : null;
        }
        //
        if(carryVal > 0){
            curNode.next = new ListNode(carryVal);
        }
        return calcResNode.next;
    }
```
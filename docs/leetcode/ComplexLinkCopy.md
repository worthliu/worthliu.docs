请实现函数`ComplexListNode clone(ComplexListNode pHead)`,复制一个复杂链表。在复杂链表中，每个结点除了有一个m_pNext指针指向下一个结点外，还是有一个m_pSibling指向链表中的任意结点或者NULL。

Definition：

```
struct ComplexListNode{
	int value;
	ComplexListNode pNext;
	ComplexListNode pSibling;
}
```

### 题解

>正常复制过程分为两步：
1. 复制原始链表上的每一个结点，并用pNext链接起来；
2. 设置每个结点的`pSibling`执政。假设原始链表中的某个结点`N`的`pSibling`指向结点`S`，由于`S`的位置在链表中可能在`N`的前面或者后面，所以要定位S的位置需要从原始链表的头结点开始的找。
  1. 如果从原始链表的头结点开始沿着`pNext`经过`s`步找到结点`S`，那么在复制链表上结点`N’`的`pSibling`（记为`S’`）离复制链表的头结点的距离也是沿着`pNext`指针`s`步。

**由于定位每个结点的`pSibling`都需要从链表头结点开始经过`O(n)`步才能找到的的，因此这种方法的总时间复杂度是`O(n^2)`**

>采用空间换时间：
1. 复制原始链表上的每个结点`N`创建`N’`，然后用pNext链接起来。并将<N, N'>的配对信息放到哈希表中；
2. 如果原始链表中结点N的pSibling指向结点S，复制链表中，对应的N'应该指向S'。通过哈希表获取，只需O(1)时间；


>不采用辅组空间：
1. 复制原始链表上的每个结点`N`创建`N’`，然后用pNext链接起来。并将N’连接在N后面；
2. 设置复制出来的结点的pSibling。原始链表上的N的pSibling指向结点S，其对应的复制出来的N’是N的pNext指向的结点，同样S’也是S的pNext指向的结点；
3. 将长链表拆分为两个链表：把奇数位置的结点用pNext链接起来就是原始链表，把偶数位置的结点用pNext链接起来就是复制出来的链表；


## solution

```
    public RandomListNode copyRandomList(RandomListNode pHead) {
        RandomListNode cloneHead = null;
        if(pHead != null){
            cloneHead = new RandomListNode(pHead.label);
            RandomListNode cloneNode = cloneHead;
            RandomListNode pNode = pHead.next;
            //
            Map<RandomListNode, RandomListNode> nodeMap = new HashMap<>();
            while (pNode != null){
                cloneNode.next = new RandomListNode(pNode.label);
                nodeMap.put(pNode, cloneNode.next);
                pNode = pNode.next;
                cloneNode = cloneNode.next;
            }
            //
            pNode = pHead;
            cloneNode = cloneHead;
            while (pNode != null){
                if(pNode.random != null){
                    RandomListNode randomNode = nodeMap.get(pNode.random);
                    cloneNode.random = randomNode;
                }
                pNode = pNode.next;
                cloneNode = cloneNode.next;
            }
        }
        return cloneHead;
    }
```

```
    /**
     * @param pHead
     * @return
     */
    public RandomListNode copyRandomList(RandomListNode pHead){
        cloneNodes(pHead);
        connectSibling(pHead);
        return reconnectNodes(pHead);
    }
    
    public void cloneNodes(RandomListNode pHead){
        RandomListNode pNode = pHead;
        while (pNode != null){
            RandomListNode pCloned = new RandomListNode(pNode.label);
            pCloned.next = pNode.next;
            pNode.next = pCloned;
            pNode = pCloned.next;
        }
    }
    
    public void connectSibling(RandomListNode pHead){
        RandomListNode pNode = pHead;
        while (pNode != null){
            RandomListNode pCloned = pNode.next;
            if(pNode.random != null){
                pCloned.random = pNode.random.next;
            }
            pNode = pCloned.next;
        }
    }
    
    public RandomListNode reconnectNodes(RandomListNode pHead){
        RandomListNode pNode = pHead;
        RandomListNode pClonedHead = null;
        RandomListNode pClonedNode = null;
        //
        if(pNode != null){
            pClonedHead = pClonedNode = pNode.next;
            pNode.next = pClonedNode.next;
            pNode = pNode.next;
        }
        //
        while (pNode != null){
            pClonedNode.next = pNode.next;
            pClonedNode = pClonedNode.next;
            pNode.next = pClonedNode.next;
            pNode = pNode.next;
        }
        return pClonedHead;
    }
```
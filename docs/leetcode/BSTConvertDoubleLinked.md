输入一颗二叉搜索树，将该二叉搜索树转换成一个排序的双向链表。

要求不能创建任何新的结点，只能调整整树中结点指针的指向。


### 题解

在二叉树中，每个结点都有两个指向子结点的指针。

在双向链表中，每个结点也有两个指针，分别指向前后结点；

在搜索二叉树中，左子结点的值总是小于父结点的值，右子结点的值总是大于父结点的值。

因此在转换成排序双向链表时，原先指向左子结点的指针调整为链表中指向前一个结点的指针，原先指向右子结点的指针调整位链表中指向后一个结点指针；

由于要求转换的链表是排好序，可以中序遍历树中的每个结点。

当遍历到跟结点的时候，将树看成三部分：根结点，根结点的左子树，根结点的右子树；

## solution

```
	public TreeNode convert(TreeNode root){
        TreeNode pLastNodeInList = null;
        convertNode(root, pLastNodeInList);
        //
        TreeNode pHeadOfList = pLastNodeInList;
        while (pHeadOfList != null && pHeadOfList.left != null){
            pHeadOfList = pHeadOfList.left;
        }
        return pHeadOfList;
    }

    public void convertNode(TreeNode root, TreeNode pLastNodeInList) {
        if(root == null){
            return;
        }
        //
        TreeNode pCurr = root;
        if(pCurr.left != null){
            convertNode(pCurr.left, pLastNodeInList);
        }
        //
        pCurr.left = pLastNodeInList;
        if(pLastNodeInList != null){
            pLastNodeInList.right = pCurr;
        }
        pLastNodeInList = pCurr;
        if(pCurr.right != null){
            convertNode(pCurr.right, pLastNodeInList);
        }
    }
```
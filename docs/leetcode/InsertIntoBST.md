给定二叉搜索树（BST）的根节点和要插入树中的值，将值插入二叉搜索树。 返回插入后二叉搜索树的根节点。 保证原始二叉搜索树中不存在新值。

注意，可能存在多种有效的插入方式，只要树在插入后仍保持为二叉搜索树即可。 你可以返回任意有效的结果。

例如, 
```
给定二叉搜索树:

        4
       / \
      2   7
     / \
    1   3

和 插入的值: 5
```
你可以返回这个二叉搜索树:
```

         4
       /   \
      2     7
     / \   /
    1   3 5
```
或者这个树也是有效的:
```

         5
       /   \
      2     7
     / \   
    1   3
         \
          4
```

### 题解

二叉搜索树插入，且插入后的二叉树也保持二叉搜索树的特性!

解题关键是了解二叉搜索树的特性：
>+ 它或者是一棵空树，或者是具有下列性质的二叉树： 
+ 若它的左子树不空，则左子树上所有结点的值均小于它的根结点的值； 
+ 若它的右子树不空，则右子树上所有结点的值均大于它的根结点的值； 
+ 它的左、右子树也分别为二叉排序树。

从上述特性了解到，二叉搜索树结点值唯一且有序；

## solution

```
    public TreeNode insertIntoBST(TreeNode root, int val) {
        if(root == null){
            root = new TreeNode(val);
        }else{
            TreeNode curNode = root;
            TreeNode node = root;
            boolean isLeft = true;
            while (curNode != null){
                node = curNode;
                if(curNode.val > val){
                    curNode = curNode.left;
                    isLeft = true;
                }else if(curNode.val < val){
                    curNode = curNode.right;
                    isLeft = false;
                }else {
                    break;
                }
            }
            if(curNode == null){
                if(isLeft){
                    node.left = new TreeNode(val);
                }else {
                    node.right = new TreeNode(val);
                }
            }
        }
        return root;
    }
```
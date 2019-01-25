输入一棵二叉树的根结点，判断该树是不是平衡二叉树。如果某二叉树中任意结点的左右子树的深度相差不超过1。那么它就是一棵平衡二叉树。

### 题解

直接做法:遍历每个结点左右子树，并比较对应深度差异；

若用后序遍历的方式遍历二叉树的每个结点，在遍历到一个结点之前就已经遍历了它的左右子树。

只要在遍历每个结点的时候记录它的深度（某个结点的深度）

## solution

```
	public boolean isBalanced(TreeNode root) {
        if(root == null){
            return true;
        }
        //
        int leftTh = treeDepth(root.left);
        int rightTh = treeDepth(root.right);
        //
        int diffDepth = leftTh - rightTh;
        if(diffDepth < -1 || diffDepth > 1){
            return false;
        }
        
        return isBalanced(root.left) && isBalanced(root.right);        
    }
    
    public int treeDepth(TreeNode root){
        if(root == null){
            return 0;
        }
        
        int leftTh = treeDepth(root.left);
        int rightTh = treeDepth(root.right);
        
        return leftTh > rightTh ? leftTh + 1 : rightTh + 1;
    }
```

```

```
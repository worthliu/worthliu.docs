输入一棵二叉树的根结点，求该树的深度。从根结点到叶结点依次经过的结点（含根、叶结点）形成树的一条路径，最长路径的长度位树的深度；


### 题解

最直观：树的深度为从根结点出发，以递归处理；


## solution

```
	public int treeDepth(TreeNode root){
        if(root == null){
            return 0;
        }

        int thLeft = treeDepth(root.left);
        int thRight = treeDepth(root.right);

        return (thLeft > thRight) ? (thLeft + 1) : (thRight + 1);
    }
```

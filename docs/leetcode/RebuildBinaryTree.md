输入某二叉树的前序遍历和中序遍历的结果，请重建出该二叉树。假设输入的前序遍历和中序遍历结果中都不含重复的数字。

Example 1:
```
Input: arrayA : [1, 2, 4, 7, 3, 5, 6, 8]; arrayB：[4, 7, 2, 1, 5, 3, 8, 6]
      
Output: 
       1
     /   \
    2     3
   /     / \
  4     5   6
    \      /
     7    8
```

## solution

>在二叉树的前序遍历序列中，第一数字总是树的根节点的值。但在中序遍历序列中，根节点的值在序列的中间，左子树的结点的值位于根结点的值的左边，而右子树的结点的值位于根结点的值右边。因此我们需要扫描中序遍历序列，才能找到根节点的值；



```
public TreeNode rebuildBinaryTreeRecursion(int[] preorder, int[] inorder){
        if(preorder == null || inorder == null ||
                preorder.length != inorder.length || preorder.length == 0){
            return null;
        }
        //
        int size = preorder.length;
        int rootVal = preorder[0];
        int rootInd = 0;
        while (inorder[rootInd] != rootVal){
            rootInd++;
        }
        //
        int[] leftPreorder = Arrays.copyOfRange(preorder, 1, rootInd + 1);
        int[] leftInorder = Arrays.copyOfRange(inorder, 0, rootInd);
        int[] rightPreorder = Arrays.copyOfRange(preorder, rootInd + 1, size);
        int[] rightInorder = Arrays.copyOfRange(inorder, rootInd + 1, size);
        //
        TreeNode root = new TreeNode(rootVal);
        root.left = rebuildBinaryTreeRecursion(leftPreorder, leftInorder);
        root.right = rebuildBinaryTreeRecursion(rightPreorder, rightInorder);
        return root;
    }
```

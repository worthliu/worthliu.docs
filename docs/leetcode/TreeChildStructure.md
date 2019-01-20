给定两个非空二叉树 s 和 t，检验 s 中是否包含和 t 具有相同结构和节点值的子树。s 的一个子树包括 s 的一个节点和这个节点的所有子孙。s 也可以看做它自身的一棵子树。

示例 1:
```
给定的树 s:

     3
    / \
   4   5
  / \
 1   2
给定的树 t：

   4 
  / \
 1   2
返回 true，因为 t 与 s 的一个子树拥有相同的结构和节点值。
```
示例 2:
```
给定的树 s：

     3
    / \
   4   5
  / \
 1   2
    /
   0
给定的树 t：

   4
  / \
 1   2
返回 false。

```

## solution

```
/**
 * Definition for a binary tree node.
 * public class TreeNode {
 *     int val;
 *     TreeNode left;
 *     TreeNode right;
 *     TreeNode(int x) { val = x; }
 * }
 */
class Solution {
    public boolean isSubtree(TreeNode pRoot, TreeNode qRoot){
        boolean result = false;
        //
        if(pRoot != null && qRoot != null){
            if(pRoot.val == qRoot.val){
                result = doesTreeHaveTree(pRoot, qRoot);
            }
            //
            if(!result){
                result = isSubtree(pRoot.left, qRoot);
            }

            if(!result){
                result = isSubtree(pRoot.right, qRoot);
            }
        }

        return result;
    }

    private boolean doesTreeHaveTree(TreeNode pRoot, TreeNode qRoot) {
        if(qRoot == null && pRoot == null){
            return true;
        }else if(pRoot != null && qRoot != null){
            if(pRoot.val != qRoot.val){
                return false;
            }

            return doesTreeHaveTree(pRoot.left, qRoot.left) && doesTreeHaveTree(pRoot.right, qRoot.right);
        }

        return false;
    }        
}
```
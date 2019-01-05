A binary tree is univalued if every node in the tree has the same value.

Return true if and only if the given tree is univalued.

 

Example 1:

```
Input: [1,1,1,1,1,null,1]
Output: true
```
Example 2:
```
Input: [2,2,2,5,2]
Output: false
``` 

Note:
```
The number of nodes in the given tree will be in the range [1, 100].
Each node's value will be an integer in the range [0, 99].
```

## solution

```
/**
 * Definition for a binary tree node.
 */
 public class TreeNode {
     int val;
     TreeNode left;
     TreeNode right;
     TreeNode(int x) { val = x; }
 }

```
>递归遍历方式
```
public boolean isUnivalTree(TreeNode root) {
        //
        if(root == null){
            return true;
        }
        return isUnivalTreeRecu(root.left, root.val) && isUnivalTreeRecu(root.right, root.val);
    }


public boolean isUnivalTreeRecu(TreeNode root, int tarVal){
    if(root == null){
        return true;
    }else if(root.val != tarVal){
        return false;
    }
    //
    return isUnivalTreeRecu(root.left, root.val) && isUnivalTreeRecu(root.right, root.val);
}
```

>**先中序遍历采用非递归的方式**
+ 遇到一个节点,访问它,然后把它压栈,并去遍历它的左子树; 
+ 当左子树遍历结束后,从栈顶弹出该节点并将其指向右子树,继续第一步骤;
+ 当所有节点访问完即最后访问的树节点为空且栈空时,停止;

```
public boolean isUnivalTree(TreeNode root) {
        Stack<TreeNode> stackTree = new Stack<>();
        int tarVal = root.val;
        while (true){
            while (root != null){
                stackTree.push(root);
                root = root.left;
            }

            if(stackTree.isEmpty()){
               return true;
            }
            //
            root = stackTree.pop();
            if(root.val != tarVal){
                return false;
            }
            root = root.right;
        }
    }
```

>**后序遍历采用非递归的方式**

```
public boolean isUnivalTree(TreeNode root) {
        if(root != null){
            Stack<TreeNode> stackTree = new Stack<>();
            stackTree.push(root);
            int tarVal = root.val;
            //
            TreeNode curr;
            while (!stackTree.isEmpty()){
                // 获取栈顶元素
                curr = stackTree.peek();
                if(curr.left != null && !root.equals(curr.left) && !root.equals(curr.right)){
                    // 栈顶元素左子树不为空,且当前栈顶元素与当前树节点左右子节点不一致,左子树入栈
                    stackTree.push(curr.left);
                }else if(curr.right != null && !root.equals(curr.right)){
                    // 栈顶元素右子树不为空,且当前栈顶元素与当前树节点右子节点不一致,右子树入栈
                    stackTree.push(curr.right);
                }else {
                    TreeNode curNode = stackTree.pop();
                    if(curNode.val != tarVal){
                        return false;
                    }
                    root = curr;
                }
            }
        }
        return true;
    }
```
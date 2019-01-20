输入一个二叉树,输出它的镜像。

Example 1：
```
    8                  8                     
   / \               /  \  
  6   10            10   6    
 / \  / \          / \  / \     
5   7 9  11       9  11 7  5    
```

## solution

```
public void mirror(TreeNode pNode){
    boolean checked = pNode == null ||
                      (pNode.left == null && pNode.right == null);
    if(checked){
        return;
    }
    //
    TreeNode pTemp = pNode.left;
    pNode.left = pNode.right;
    pNode.right = pTemp;
    //
    if(pNode.left != null){
        mirror(pNode.left);
    }
    if(pNode.right != null){
        mirror(pNode.right);
    }
}
```

```
public void mirrorLoop(TreeNode pRoot){
    boolean checked = pRoot == null ||
            (pRoot.left == null && pRoot.right == null);
    if(checked){
        return;
    }
    //
    Stack<TreeNode> stack = new Stack<>();
    stack.push(pRoot);
    while(!stack.isEmpty()){
        TreeNode pNode = stack.pop();
        if(pNode.left != null){
            stack.push(pNode.left);
        }
        //
        if(pNode.right != null){
            stack.push(pNode.right);
        }
        
        TreeNode pTemp = pNode.left;
        pNode.left = pNode.right;
        pNode.left = pTemp;
    }
}
```
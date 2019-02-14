给定一棵二叉树，想象自己站在它的右侧，按照从顶部到底部的顺序，返回从右侧所能看到的节点值。

示例:
```
输入: [1,2,3,null,5,null,4]
输出: [1, 3, 4]
解释:

   1            <---
 /   \
2     3         <---
 \     \
  5     4       <---
```

### 题解

获取树的右视图，其实就是层序遍历二叉树，取每一层中最后一个值；


## solution

```
	public List<Integer> rightSideView(TreeNode root) {
        List<Integer> resList = new ArrayList<>();
        if(root != null){
            Deque<TreeNode> nodes = new ArrayDeque<>();
            nodes.offer(root);
            while(!nodes.isEmpty()){
                int count = nodes.size();
                while(count > 0){
                    TreeNode node = nodes.poll();
                    if(count == 1){
                        resList.add(node.val);
                    }
                    if(node.left != null){
                        nodes.offer(node.left);
                    }
                    //
                    if(node.right != null){
                        nodes.offer(node.right);
                    }
                    count--;
                }
            }
        }
        return resList;
    }
```
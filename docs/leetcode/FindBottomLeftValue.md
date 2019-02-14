给定一个二叉树，在树的最后一行找到最左边的值。

示例 1:
```
输入:

    2
   / \
  1   3

输出:
1
```

示例 2:

```
输入:

        1
       / \
      2   3
     /   / \
    4   5   6
       /
      7

输出:
7
```

注意: 您可以假设树（即给定的根节点）不为 NULL。

### 题解

从题目看，获取最后一行最左边结点的值，对于树的遍历，只有层序遍历比较简单获取到最后一行；

## solution

```
    public int findBottomLeftValue(TreeNode root) {
        int tarVal = -1 ;
        if(root != null){
            Deque<TreeNode> nodes = new ArrayDeque<>();
            nodes.offer(root);
            while (!nodes.isEmpty()){
                int count = nodes.size();
                List<Integer> nodeValList = new ArrayList<>(count);
                traversalTreeNode(nodes, count, nodeValList);
                if(nodes.isEmpty()){
                    tarVal = nodeValList.get(0);
                }
            }
        }
        return tarVal;
    }
    
    private void traversalTreeNode(Deque<TreeNode> nodes, int count, List<Integer> nodeValList) {
        while (count > 0){
            TreeNode node = nodes.poll();
            nodeValList.add(node.val);
            //
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
```
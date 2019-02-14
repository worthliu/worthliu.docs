给定一个二叉树，返回其节点值的锯齿形层次遍历。（即先从左往右，再从右往左进行下一层遍历，以此类推，层与层之间交替进行）。

例如：
```
给定二叉树 [3,9,20,null,null,15,7],

    3
   / \
  9  20
    /  \
   15   7
```
返回锯齿形层次遍历如下：
```
[
  [3],
  [20,9],
  [15,7]
]
```

### 题解

从题目中，主要考察的是层序遍历；但是其最终输出的结果是每层结点翻转输出

## solution

```
	public List<List<Integer>> zigzagLevelOrder(TreeNode root) {
        List<List<Integer>> resList = new ArrayList<>();
        if(root != null){
            Deque<TreeNode> nodes = new ArrayDeque<>();
            nodes.offer(root);
            boolean whetherReverse = false;
            while (!nodes.isEmpty()){
                int count = nodes.size();
                List<Integer> nodeValList = new ArrayList<>(count);
                traversalTreeNode(nodes, count, nodeValList);
                if(whetherReverse){
                    reverseListValue(nodeValList);
                }
                whetherReverse = !whetherReverse;
                resList.add(nodeValList);
            }
        }
        return resList;
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

    /**
     * 反转列表结点值
     * @param resList
     */
    private void reverseListValue(List<Integer> resList) {
        int head = 0;
        int tail = resList.size() - 1;
        while (head < tail){
            Integer temp = resList.get(tail);
            resList.set(tail--, resList.get(head));
            resList.set(head++, temp);
        }
    }
```
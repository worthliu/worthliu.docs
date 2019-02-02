从上往下打印出二叉树的每个结点,同一层的结点按照从左到右的顺序打印;

Example:

```
	8
   / \
  6  10
 / \ / \
5  7 9  11

打印结果:

8 6 10 5 7 9 11
```

### 题解

打印所有结点，其实就是考察遍历算法；

对于树而言，遍历有四种： 先序遍历、中序遍历、后序遍历、层序遍历；

对于上述题目本意是考察层序遍历；对于层序遍历的特点，我们需要借助队列（`先进先出`）这种容器来打印；

## solution

```
public List<Integer> sequenceTraversal(TreeNode root){
    List<Integer> resList = new ArrayList<>();
    if(root == null){
        return resList;
    }

    //
    Deque<TreeNode> queue = new ArrayDeque<>();
    queue.offer(root);
    while (!queue.isEmpty()){
        TreeNode node = queue.poll();
        resList.add(node.val);
        if(node.left != null){
            queue.offer(node.left);
        }
        if(node.right != null){
            queue.offer(node.right);
        }
    }
    return resList;
}
```

```
    public List<List<Integer>> levelOrder(TreeNode root){
        List<List<Integer>> resList = new ArrayList<>();
        if(root != null){
            Deque<TreeNode> data = new ArrayDeque<>();
            data.offer(root);
            while (!data.isEmpty()){
                int count = data.size();
                List<Integer> nodeList = new ArrayList<>(count);
                while (count > 0){
                    TreeNode node = data.poll();
                    nodeList.add(node.val);
                    //
                    if(node.left != null){
                        data.offer(node.left);
                    }
                    //
                    if(node.right != null){
                        data.offer(node.right);
                    }
                    count--;
                }
                resList.add(nodeList);
            }
        }
        return resList;
    }
```
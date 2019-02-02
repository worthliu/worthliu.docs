输入一棵二叉树，遍历树的结点。输出结果

### 题解

二叉树遍历，有四种遍历方法：先序遍历、中序遍历、后序遍历；

其判定标注为根节点出现顺序为准；


## solution

>**先序遍历**

```
    public List<Integer> preorderTraversal(TreeNode root) {
        List<Integer> nodeSequence = new ArrayList<>();
        if(root != null){
            Deque<TreeNode> data = new ArrayDeque<>();
            TreeNode curNode = root;
            while (true){
                while (curNode != null){
                    nodeSequence.add(curNode.val);
                    data.push(curNode);
                    curNode = curNode.left;
                }
                //
                if(data.isEmpty()){
                    break;
                }
                curNode = data.pop();
                curNode = curNode.right;
            }
        }
        return nodeSequence;
    }
```

>**中序遍历**

```
 	public List<Integer> inorderTraversal(TreeNode root) {
        List<Integer> nodeSequence = new ArrayList<>();
        if(root != null){
            Deque<TreeNode> data = new ArrayDeque<>();
            TreeNode curNode = root;
            while (true){
                while (curNode != null){
                    data.push(curNode);
                    curNode = curNode.left;
                }
                //
                if(data.isEmpty()){
                    break;
                }
                curNode = data.pop();
                nodeSequence.add(curNode.val);
                curNode = curNode.right;
            }
        }
        return nodeSequence;
    }
```

>**后序遍历**

```
    public List<Integer> postorderTraversal(TreeNode root) {
        List<Integer> nodeSequence = new ArrayList<>();
        if(root != null){
            TreeNode node = root;
            TreeNode curr;
            Deque<TreeNode> stackTree = new ArrayDeque<>();
            stackTree.push(node);
            while (!stackTree.isEmpty()){
                // 获取栈顶元素
                curr = stackTree.peek();
                if(curr.left != null && !node.equals(curr.left) && !node.equals(curr.right)){
                    // 栈顶元素左子树不为空,且当前栈顶元素与当前树节点左右子节点不一致,左子树入栈
                    stackTree.push(curr.left);
                }else if(curr.right != null && !node.equals(curr.right)){
                    // 栈顶元素右子树不为空,且当前栈顶元素与当前树节点右子节点不一致,右子树入栈
                    stackTree.push(curr.right);
                }else {
                    TreeNode curNode = stackTree.pop();
                    nodeSequence.add(curNode.val);
                    node = curr;
                }
            }
        }
        return nodeSequence;
    }
```
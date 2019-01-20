输入一颗二叉树和一个整数，打印出二叉树中结点值的和为输入整数的所有路径。

从树的根节点开始往下一直到叶结点所经过的结点形成一条路径。


### 题解

题目给出了路径定义，可知所有路径总是以根节点为起始点；

而路径值为遍历树结点合计数，因此题意可变更位结点遍历，且从根节点出发，即为`先序遍历`；

Example：

```
	10
    / \
   5  12
  / \
 4   7

path： 10 -> 5 -> 7 ; 10 -> 12
```

步骤|操作|是否叶结点|路径|路径结点值的和|
--|--|--|--|--|
1|访问结点10|否|结点10|10|
2|访问结点5|否|结点10、结点5|15|
3|访问结点4|是|结点10、结点5、结点4|19|
4|回到结点5||结点10、结点5|15|
5|访问结点7|是|结点10、结点5、结点7|22|
6|回到结点5||结点10、结点5|15|
7|回到结点10||结点10|10|
8|访问结点12|是|结点10、结点12|22|

>+ 当用前序遍历的方式访问到某一结点时，把该结点添加到路径上，并累加该结点的值；
+ 如果该结点为叶结点并且路径中结点值的和刚好等于输入的整数，则当前的路径符合要求，打印出来；
+ 如果当前结点不是叶结点，则继续访问它的子结点；
+ 当前结点访问结束后，递归函数将自动回到它的父结点；

## solution

```
    public void findPath(TreeNode root, int expectedSum){
        if(root == null){
            return;
        }

        int curSum = 0;
        Deque<TreeNode> path = new ArrayDeque<>();
        findPath(root, expectedSum, path, curSum);
    }

    private void findPath(TreeNode root, int expectedSum, Deque<TreeNode> path, int curSum) {
        curSum += root.val;
        path.push(root);
        //
        if(curSum == expectedSum){
            Iterator<TreeNode> iter = path.iterator();
            while (iter.hasNext()){
                TreeNode node = iter.next();
                System.out.print(node.val + " -> ");
            }
            System.out.println("");
        }
        //
        if(root.left != null){
            findPath(root.left, expectedSum, path, curSum);
        }
        if(root.right != null){
            findPath(root.right, expectedSum, path, curSum);
        }
        //
        path.pop();
    }
```
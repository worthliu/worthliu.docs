输入两个树结点，求它们的最低公共祖先。

### 题解

从上述题目，很是模糊！因此需要额外附件的条件才能继续完成该题目！

>1. **若树是二叉搜索树**，找到公共结点的很简单：
  + 由于二叉搜索树是排序过的，位于左子树的结点都比父结点小，而位于右子树的结点都比父结点大，只需要从树的根结点开始和两个输入的结点进行比较；
    + 如果当前结点的值比两个结点的值都大，那么最低的共同的父结点一定是在当前结点的左子树中，于是继续遍历当前结点的左子结点；
    + 如果当前结点的值比两个结点数的值都小，那么最低共同父结点一定在当前的结点的右子树中，于是继续遍历当前结点的右子结点；
    + 在树中从上到下找到的第一个在两个输入结点的值之间的结点，就是最低的公共祖先；
2. **若树是普通二叉树，但有指向父结点的指针**：
  + 如果树中的每个结点（除根结点之外）都有一个指向父结点的指针，这个问题可以转换成求两个链表的第一个公共结点。
    + 假设树结点中指向父结点的指针是pParent，那么从树的每一个叶结点开始都有一个由指针pParent串起来的链表，这些链表的尾指针都是树的根结点。
    + 输入的两个结点，都位于两个链表上，它们的最低公共祖先刚好就是这两个链表的第一个公共结点。
3. **若树只是普通二叉树，其他条件都没有**：
  + 两个结点的公共祖先，指的是这两个结点都出现在某个结点的子树中。
    + 从根结点开始遍历一棵树，每遍历到一个结点时，判断两个输入结点是不是在它的子树中。
      + 如果在子树中，则分别遍历它的所有子结点，并判断两个输入结点是不是在它们的子树中。
      + 这样从上到下一直找到的第一个结点，它自己的子树中同时包含两个输入的结点而它的子结点却没有，那么该结点就是最低的公共祖先。
4. **普通二叉树，借助辅助内存**：
  + 首先得到一条从根结点到树中某一结点的路径，要求在遍历的时候，有一个辅助内存来保存路径。
    + 分别得到对应两个目标结点的路径；
    + 进而求出两个路径最后公共结点； 

## solution

> 二叉搜索树

```
	public TreeNode lowestCommonAncestor(TreeNode root, TreeNode nodeA, TreeNode nodeB){
        if(root == null || nodeA == null || nodeB == null || nodeA.equals(nodeB)){
            return null;
        }
        //
        TreeNode resNode = null;
        TreeNode node = root;
        TreeNode nodeSmall = nodeA;
        TreeNode nodeBig = nodeB;
        if(nodeA.val > nodeB.val){
            nodeSmall = nodeB;
            nodeBig = nodeA;
        }
        //
        while (node != null){
            if(node.val > nodeSmall.val && node.val > nodeBig.val){
                node = node.left;
            }else if(node.val < nodeSmall.val && node.val < nodeBig.val){
                node = node.right;
            }else {
                resNode = node;
                break;
            }
        }
        return resNode;
    }
```

>普通二叉树,通过递归法,性能效率不好：

```
    public TreeNode lowestCommonAncestorPro(TreeNode root, TreeNode nodeA, TreeNode nodeB){
        if(root == null || nodeA == null || nodeB == null || nodeA.equals(nodeB)){
            return null;
        }

        if(root.val == nodeA.val || root.val == nodeB.val){
            return root;
        }
        //
        TreeNode curNode = root;
        TreeNode resNode = null;
        while(curNode != null){
            boolean aChecked = checkedTreeIsExistNode(curNode, nodeA);
            boolean bChecked = checkedTreeIsExistNode(curNode, nodeB);
            if(aChecked && bChecked){
                boolean leftAChecked = checkedTreeIsExistNode(curNode.left, nodeA);
                boolean leftBChecked = checkedTreeIsExistNode(curNode.left, nodeB);
                boolean rightAChecked = checkedTreeIsExistNode(curNode.right, nodeA);
                boolean rightBChecked = checkedTreeIsExistNode(curNode.right, nodeB);
                //    
                if(leftAChecked && leftBChecked) {
                    curNode = curNode.left;
                }else if(rightAChecked && rightBChecked){
                    curNode = curNode.right;
                }else {
                    resNode = curNode;
                    break;
                }
            }else {
                break;
            }

        }
        return resNode;
    }

    /**
     * 检查二叉树是否存在结点
     * @param root
     * @param tarNode
     * @return
     */
    public boolean checkedTreeIsExistNode(TreeNode root, TreeNode tarNode){
        boolean checked = false;
        if(root == null || tarNode == null){
            return checked;
        }
        //
        TreeNode curNode = root;
        if(curNode.val == tarNode.val){
            checked = true;
        }else {
            boolean leftChecked = checkedTreeIsExistNode(root.left, tarNode);
            boolean rightChecked = checkedTreeIsExistNode(root.right, tarNode);
            checked = leftChecked || rightChecked;
        }

        return checked;
    }
```

>普通二叉树，采用辅助内存：

```
   public TreeNode lowestCommonAncestor(TreeNode root, TreeNode nodeA, TreeNode nodeB) {
        if (root == null || nodeA == null || nodeB == null || nodeA.equals(nodeB)) {
            return null;
        }

        if (root.val == nodeA.val || root.val == nodeB.val) {
            return root;
        }

        Deque<TreeNode> aPath = new ArrayDeque<>();
        getNodePath(root, nodeA, aPath);

        Deque<TreeNode> bPath = new ArrayDeque<>();
        getNodePath(root, nodeB, bPath);

        return getLastCommonNode(aPath, bPath);
    }


    public TreeNode getLastCommonNode(Deque<TreeNode> pathA, Deque<TreeNode> pathB){
        if(pathA == null || pathB == null){
            return null;
        }
        //
        Deque<TreeNode> pathLong = pathA;
        Deque<TreeNode> pathShort = pathB;
        if(pathA.size() < pathB.size()){
            pathLong = pathB;
            pathShort = pathA;
        }
        //
        Iterator<TreeNode> iteratorLong = pathLong.iterator();
        Iterator<TreeNode> iteratorShort = pathShort.iterator();
        int diffCnt = Math.abs(pathA.size() - pathB.size());
        for(int ind = 0; ind < diffCnt; ind++){
            iteratorLong.next();
        }
        //
        TreeNode lastNode = null;
        while (iteratorLong.hasNext() && iteratorShort.hasNext()){
            TreeNode longNode = iteratorLong.next();
            TreeNode shortNode = iteratorShort.next();
            if(longNode.val == shortNode.val){
                lastNode = longNode;
                break;
            }
        }
        return lastNode;
    }

    /**
     * @param root
     * @param tarNode
     * @param path
     */
    public boolean getNodePath(TreeNode root, TreeNode tarNode, Deque<TreeNode> path) {
        if(root == null){
            return false;
        }
        //
        path.push(root);
        if(root.val == tarNode.val){
            return true;
        }
        //
        boolean found = false;
        if(root.left != null){
            found = getNodePath(root.left, tarNode, path);
        }
        //
        if(root.right != null && !found){
            found = getNodePath(root.right, tarNode, path);
        }
        if(!found){
            path.pop();
        }
        return found;
    }
```
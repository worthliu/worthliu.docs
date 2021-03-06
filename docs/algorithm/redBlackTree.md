## 红黑树

### 树

树是一种常用的数据结构,它是一个由有限节点组成的一个具有层次关系的集合,数据就存在树的这些节点中.

>树结构特点:
+ 一个节点,即只有根节点,也可以是一棵树;
+ 其中任何一个节点与下面所有节点构成的树称为子树;
+ 根节点没有父节点,而叶子节点没有子节点;
+ 除根节点外,任何节点有且仅有一个父节点;
+ 任何节点可以有`0~n`个子节点;

### 平衡二叉树

如果以树的复杂结构来实现简单的链表功能,则完成埋没了树的特点.因此需要进行某种条件的约束,让链表一样的树变得更有层次结构,平衡二叉树就呼之欲出;

>平衡二叉树的性质:
+ 树的左右高度差不能超过1;
+ 任何往下递归的左子树与右子树,必须符合第一条性质;
+ 没有任何节点的空树或只有根节点的树也是平衡二叉树;

### 二叉查找树

二叉查找树又称二叉搜索树,即`Binary Search Tree`,其中`Search`也可以替换为`Sort`,所以也称为二叉排序树;

二叉查找树,对于任意节点来说,它左子树所有节点的值都小于它,而它的右子树上所有节点的值都大于它;

**查找过程从树的根节点开始,沿着简单的判断向下走,小于节点值的往左边走,大于节点值的往右边走,直到找到目标数据或者到达叶子节点还未找到;**

遍历所有节点的常用方式有三种:`前序遍历`,`中序遍历`,`后序遍历`:
+ 在任何递归子树中,左节点一定在右节点之前先遍历;
+ `前序`,`中序`,`后序`,仅指根节点在遍历时的位置顺序;

### AVL树

>AVL树是一种平衡二叉查找树,增加和删除节点后通过树形旋转重新达到平衡;
+ 右旋是以某个节点为中心,将它沉入当前右子节点的位置,而让当前的左子节点作为新树的根节点,也称为顺时针旋转;
+ 左旋是以某个节点为中心,将它沉入当前左子节点的位置,而让当前右子节点作为新树的根节点,也称为逆时针旋转;

### 红黑树

红黑树,它主要特征是在每个节点上增加一个属性来表示节点的颜色,可以是红色,也可以是黑色;

与AVL树相比,红黑树并不追求所有递归子树的高度差不超过`1`,而是保证从根节点到叶尾的最长路径不超过最短路径的2倍,所以它的最坏运行时间也是`O(logn)`;

>红黑树特性:
+ 节点只能是红色或黑色
+ 根节点必须是黑色
+ 所有`NIL(Nothing In Leaf)`节点都是黑色
+ 一条路径上不能出现相邻的两个红色节点
+ 在任何递归子树内,根节点到叶子节点的所有路径上包含相同数目的黑色节点;

**`NIL`是红黑树中特殊的存在,即在叶子节点上不存在的两个虚拟节点;**

简单而言,即"有红必有黑,红红不相连",以上述5个特性保证了红黑树的新增,删除,查找的最坏时间复杂度均为`O(logn)`.

如果一个树的左子节点或右子节点不存在,则均认定为黑色.

**红黑树的任何旋转在3次之内均可完成;**

#### 红黑树与AVL树的比较

复杂度而言,**任意节点的黑深度(Black Depth)是指当前节点到`NIL`(树尾端)途径的黑色节点个数.**

根据特性,对于任意高度的节点,它的黑深度都满足:`Black Depth >= height / 2`.也就是锁,对于任意包含`n`个节点的红黑树而言,它的根节点高度`h<=2log2(n+1)`.

**常规BST操作比如查找,插入,删除等,时间复杂度为`O(h)`,即取决于树的高度h.当树失衡时,时间复杂度将有可能恶化到`O(h)`,即`h=n`;所以,当我们能保证树的高度始终保持在`O(logn)`时,便能保证所有操作的时间复杂度都能保持在`O(logn)`以内;**

>+ 由于红黑树只追求大致上的平衡,因此红黑树能在至多上次旋转内恢复平衡;
+ 而追求绝对平衡的AVL树,则至多需要`O(logn)`次旋转.

**AVL树在插入与删除时,将向上回溯确定是否需要旋转,这个回溯的时间成本最差可能为`O(logn)`；**

**而红黑树每次向上回溯的步长为2,回溯成本降低.因此,面对频繁的插入和删除**

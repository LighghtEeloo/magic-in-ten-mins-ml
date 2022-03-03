# 十分钟魔法练习：余代数数据类型

### By 「玩火」 改写 「光吟」

> 前置技能：OCaml 基础，ADT

## ADT的局限性

很显然，ADT可以构造任何树形的数据结构：树的节点内分支用和类型连接，层级间节点用积类型连接。

但是同样很显然ADT并不能搞出环形的数据结构或者说是无穷大小的数据结构。比如下面的代码：

```ocaml
let rec l = cons 1 l
```

编译器会表示`list`在当前的 scope 内不存在。

为什么会这样呢？ADT 是归纳构造的，也就是说它必须从非递归的基本元素开始组合构造成更大的元素。

如果我们去掉这些基本元素那就没法凭空构造大的元素，也就是说如果去掉归纳的第一步那整个归纳过程毫无意义。

## 余代数数据类型

余代数数据类型（Coalgebraic Data Type）也就是余归纳数据类型（Coinductive Data Type），代表了自顶向下的数据类型构造思路，思考一个类型可以如何被分解从而构造数据类型。

这样在分解过程中再次使用自己这个数据类型本身就是一件非常自然的事情了。

不过在编程实现过程中使用自己需要加个惰性数据结构包裹，防止积极求值的语言无限递归生成数据。

比如一个列表可以被分解为第一项和剩余的列表：

```ocaml
type 'a co_list =
  | CoCons of 'a * (unit -> 'a co_list)
```

这里的函数指针`(unit -> 'a co_list)`可以做到仅在需要`next`的时候才求值。使用的例子如下：

```ocaml
let rec flip_flop : int co_list =
  CoCons (1, fun () -> CoCons (2, fun () -> flip_flop))
```

会产出`CoCons(1, CoCons(2, ...))`的无穷结构。这里的`flip_flop`从某种角度来看实际上就是个长度为 2 的环形结构。

```ocaml
let rec to_string cl n =
  if n = 0 then "..."
  else
    let CoCons (c, tl) = cl in
    Printf.sprintf "%d :: %s" c (to_string (tl ()) (n - 1))
```

用这样的思路可以构造出无限大的树、带环的图等数据结构。

不过以上都是对余代数数据类型的一种模拟，实际上在对其支持良好的语言（Haskell: 喵喵喵？）都会自动进行辅助构造，
同时还能处理好对无限大（其实是环）的数据结构的无限递归变换（`map`, `fold` ...）的操作。
在懒求值的语言中，其 type 定义甚至同时满足 inductive 与 coinductive。

> 注：
> 
> OCaml 其实支持对*值*的递归定义（recursive definitions of values），所以我们可以写出以下代码：
> 
> ```ocaml
> let rec flip = 1 :: flop
> and flop = 2 :: flip
> ```
> 
> 其行为也和`CoList`一致。有兴趣的读者可以查阅测试。
> 
> 参考： [OCaml官方文档](https://ocaml.org/manual/letrecvalues.html)

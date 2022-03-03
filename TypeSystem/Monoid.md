# 十分钟魔法练习：单位半群

### By 「玩火」 改写 「光吟」

> 前置技能：OCaml 基础

## 半群（Semigroup）

半群是一种代数结构，在集合 `A` 上包含一个将两个 `A` 的元素映射到 `A` 上的运算即 `<> : (A, A) -> A` ，同时该运算满足**结合律**即 `(a <> b) <> c == a <> (b <> c)` ，那么代数结构 `{<>, A}` 就是一个半群。

比如在自然数集上的加法或者减法可以构成一个半群，再比如字符串集上字符串的连接构成一个半群。

用 OCaml 代码可以表示为：

```ocaml
module type SEMI_GROUP = sig
  type t
  val (<+>) : t -> t -> t
end
```

> 注：
> 
> 此处的 `<+>` 即一个二元运算符，其类型签名可以概括它的意图。

## 单位半群（Monoid）

单位半群是一种带单位元的半群，对于集合 `A` 上的半群 `{<>, A}` ，`A`中的元素`a`使`A`中的所有元素`x`满足 `x <> a` 和 `a <> x` 都等于 `x`，则 `a` 就是 `{<>, A}` 上的单位元。

> 注：单位半群有另一个常用的名字叫“幺半群”，其中幺作数字一之解。

举个例子，`{+, 自然数集}`的单位元就是0，`{*, 自然数集}`的单位元就是1，`{+, 字符串集}`的单位元就是空串`""`。

用 OCaml 代码可以表示为：

```ocaml
module type MONOID = sig
  type t
  include SEMI_GROUP with type t := t
  val unit : t
end
```

## 应用：`option`

在 OCaml 中有类型`option`可以用来表示可能有值的类型，而我们可以将它定义为 Monoid：

```ocaml
module type GENERIC_TYPE_WORKAROUND = sig type t end

module OptionM (T: GENERIC_TYPE_WORKAROUND)
: (MONOID with type t = T.t option)
= struct
  type t = T.t option
  let unit = None
  let (<+>) a b =
    match a with
    | Some _ -> a
    | None -> b
end
```

> 注：
> 
> 很不幸， OCaml 对 higher kinded type 并没有提供一等支持，因此我们需要用 `GENERIC_TYPE_WORKAROUND` 做一些小手脚。

这样对于 `<+>` 来说我们将获得一串 Option 中第一个不为空的值，对于需要进行一连串尝试操作可以这样写：

```ocaml
let open OptionM(Int) in
unit <+> (Some 1) <+> (Some 2)
```

## 应用：Ordering

可以利用 Monoid 实现带优先级的比较

```ocaml
module OrderingM : MONOID with type t = int = struct
  type t = int
  (* Equality is 0, Less than is < 0, Greater than is > 0 *)
  let unit = 0
  let (<+>) a b =
    if a = 0 then b else a
end
```

同样如果有一串带有优先级的比较操作就可以用 `<+>` 串起来，比如：

```ocaml
module Student = struct
  type t = {
    name : string;
    sex  : string;
    from : string;
  }
  let compare a b =
    let open OrderingM in
    unit
      <+> String.compare a.name b.name
      <+> String.compare a.sex  b.sex
      <+> String.compare a.from b.from
end
```

这样的写法比一连串`if-else`优雅太多。

```ocaml
let open Student in
let st_1 = { name = "Alice"; sex = "Female"; from = "Utopia" } in
let st_2 = { name = "Dorothy"; sex = "Female"; from = "Utopia" } in
let st_3 = { name = "Alice"; sex = "Female"; from = "Vulcan" } in
assert begin
   (Student.compare st_1 st_2) < 0
&& (Student.compare st_3 st_1) > 0
&& (Student.compare st_1 st_3) < 0
&& (Student.compare st_1 st_1) = 0
end;
```


## 扩展

这部分代码使用了 Java 的 `Runnable`，而这在 OCaml 中并没有很好的直接对应或替代，
建议参考[原版](https://github.com/goldimax/magic-in-ten-mins/blob/main/doc/Monoid.md#%E6%89%A9%E5%B1%95)。

> 注：上面 Option 的实现并不是 lazy 的，实际运用中加上非空短路能提高效率。
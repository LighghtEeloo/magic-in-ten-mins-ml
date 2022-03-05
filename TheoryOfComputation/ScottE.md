# 十分钟魔法练习：斯科特编码

### By 「玩火」 改写 「光吟」

> 前置技能：构造演算， ADT ，μ

> 注：
> 
> 得益于 OCaml 优秀 (?) 的类型系统，本章中我们可以使用 OCaml 直接演示这些魔法的具体实现——也就是说，和别的改写版本不同，我们可以方便地在此章中运行我们写出的魔法。但愿这会极大地方便各位读者的理解。
> 
> 再注：
> 
> 编者并不认同本章的难度；其实，在接触过 System-F 后，本章的内容应当是显而易见的，而且只要见过一次就会印象深刻。或许这是偏见吧。总之，希望您能看的开心。

斯科特编码（Scott Encoding）可以在 λ 演算上编码 ADT 。其核心思想就是利用解构函数来处理和类型不同的分支，比如对于如下类型：

```ocaml
type ('a, 'b) either =
  | Left of 'a
  | Right of 'b
```

在构造演算中拥有类型：

```
Either = λ A: *. λ B: *. (C: *) → (A → C) → (B → C) → C
```

它接受两个解构函数，分别用来处理 Left 分支和 Right 分支然后返回其中一个分支的处理结果。

翻译成 OCaml 代码的话：

```ocaml
type ('a, 'b, 'r) either = ('a -> 'r) -> ('b -> 'r) -> 'r
```

可以按照这个类型签名构造出以下两个类型构造器：

```
Left  = λ A: *. λ B: *. λ val: A. (λ C: *. λ l: A → C. λ r: B → C. l val)
Right = λ A: *. λ B: *. λ val: B. (λ C: *. λ l: A → C. λ r: B → C. r val)
```

乍一看挺复杂的，不过两个构造器具有非常相似的结构，区别仅仅是 `val` 的类型和最内侧调用的函数。实际上构造一个 `Left` 的值时先填入对应 `Either` 的类型参数然后再填入储存的值就可以得到一个符合 `Either` 类型签名的实例，解构时填入不同分支的解构函数就一定会得到 `Left` 分支解构函数处理的结果。

翻译成 OCaml 代码的话：

```ocaml
let left: 'a -> ('a, 'b, 'r) either =
  fun v -> (fun l -> fun _r -> l v)
let right: 'b -> ('a, 'b, 'r) either =
  fun v -> (fun _l -> fun r -> r v)
```

注意到原本函数传入时的很多类型参数（比如 `A`）被 OCaml 自动省去了，因为 OCaml 的 type checker 会帮我们自动推导出需要传入什么类型参数。多是一件美事啊。不过在定义类型时（如 `type either`）就必须悉数列出了。

> 注：
> 
> 请读者思考解构函数 `case` 的类型签名和实现方式。答案见对应 `.ml` 文件。

再举个 `List` 的例子：

```
List = λ T: *. (μ L: *. (R: *) → R → (T → L → R) → R)

Nil  = λ T: *. (λ R: *. λ nil: R. λ cons: T → List T → R. nil)
Cons = λ T: *. λ val: T. λ next: List T. 
    (λ R: *. λ nil: R. λ cons: T → List T → T. cons val next)

map = λ A: *. λ B: *. λ f: A → B. μ m: List A → List B.
    λ list: List A. 
    list (List B)
    (Nil B)
    (λ x: A. λ xs: List A. Cons B (f x) (m xs))
```

其 OCaml 版本为：

```ocaml
module List = struct
  type ('t, 'r) list = 'r -> ('t -> 'r -> 'r) -> 'r
  let nil: ('t, 'r) list =
    fun base -> fun _f -> base
  let cons: 't -> ('t, 'r) list -> ('t, 'r) list =
    fun t list ->
      fun base -> fun f -> 
        f t (list base f)
  let map: ('a -> 'b) -> ('a, 'r) list -> ('b, 'r) list =
    (* fun f list ->
      list nil (fun x xs -> cons (f x) xs) *)
    fun fmap list ->
      fun base -> fun f ->
        list base (fun t acc -> f (fmap t) acc)
  let fold: ('r, 't) list -> 'r -> ('t -> 'r -> 'r) -> 'r =
    fun list base f ->
      list base f
end
```

> 注：
> 
> `map` 的实现略有魔改。注释中的版本似乎遇到了类型疑难。
> 
> 欢迎 Issue / PR 指出问题 (( ◞•̀д•́)◞⚔◟(•̀д•́◟ ))


也就是说，积类型 `A * B * ... * Z` 会被翻译为

```
(A: *) → (B: *) → ... → (Z: *) →
    (Res: *) → (A → B → ... → Z → Res) → Res
```

```ocaml
type ('a, 'b, ..., 'r) prod = 'a -> 'b -> ... -> 'r
```

和类型 `A + B + ... + Z` 会被翻译为

```
(A: *) → (B: *) → ... → (Z: *) →
    (Res: *) → (A → Res) → (B → Res) → ... → (Z → Res) → Res
```

```ocaml
type ('a, 'b, ..., 'r) sum = ('a -> 'r) -> ('b -> 'r) -> ... -> 'r
```

并且两者可以互相嵌套从而构成复杂的类型。

如果给和类型的每个分支取个名字，并且允许在解构调用的时候按照名字索引，随意改变分支顺序，在解糖阶段把解构函数调整成正确的顺序那么就可以得到很多函数式语言里面的模式匹配（Pattern match）。然后就可以像这样表示 `List` ：

```
type List: * → * 
| Nil: (T: *) → List T
| Cons: (T: *) → T → List T → List T
```

> 注：
> 
> 像，太像了。

解糖的时候利用类型签名可以重建构造函数。像这样使用 `List` ：

```
map = λ A: *. λ B: *. λ f: A → B. μ m: List A → List B. 
    λ list: List A. 
    match list (List B)
    | Cons _ x xs → Cons B (f x) (m xs)
    | Nil  _      → Nil B
```

> 注：
> 
> 坚持到这里的读者，恭喜你重新（至少在概念上）发明了 OCaml，或者说 meta language。

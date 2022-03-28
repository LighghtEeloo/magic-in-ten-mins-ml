# 十分钟魔法练习：高阶类型

### By 「玩火」 改写 「光吟」

> 前置技能：OCaml 基础


## 常常碰到的困难

写代码的时候常常会碰到语言表达能力不足的问题，比如下面这段用来给`F`容器中的值进行映射的代码：

```ocaml
val map : ('a -> 'b) -> 'a 'container -> 'b 'container
                        ^ type argument not allowed here
```

并不能通过编译。

## 高阶类型

假设类型的类型是`*`，比如`int`和`string`类型都是`*`。

而对于`list`这样带有一个泛型参数的类型来说，它相当于一个把类型`t`映射到`t list`的函数，其类型可以表示为`* -> *`。

同样的对于`map`来说它有两个泛型参数，类型可以表示为`(*, *) -> *`。

像这样把类型映射到类型的非平凡类型就叫高阶类型（HKT, Higher Kinded Type）。

虽然 OCaml 中存在这样的高阶类型，但是我们并不能用一个泛型参数表示出来，也就不能写出如上`'a 'container`这样的代码了，因为`'container`是个高阶类型。

> 如果加一层解决不了问题，那就加两层。

虽然在 OCaml 中不能直接表示出高阶类型，但是我们可以通过加一个中间层来在保留完整信息的情况下强类型地模拟出高阶类型。

首先，我们需要一个中间层来储存高阶类型信息：

```ocaml
module type Container_S = sig
  type 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
end
```

然后我们就可以用 `Container_S` 里的 `'a t` 来表示 `'a container` ，这样操作完 `'a t` 后我们仍然有完整的类型信息来还原 `Container` 的类型。

这样，上面`map`就可以写成：

```ocaml
module type Map_S =
functor (C: Container_S) -> sig
  val map : ('a -> 'b) -> 'a C.t -> 'b C.t
end
```

这样就可以编译通过了。而对于想实现`Map_S`的 `module`，需要先实现`Container_S`这个中间层，这里拿`list`举例：

```ocaml
module ListC : Container_S = struct
  include List
  let rec create l = l
  let rec view l = l
  let rec eq a b =
    match a, b with
    | [], [] -> true
    | x :: xs, y :: ys -> x = y && eq xs ys
    | _ -> false
end
```

这样，实现`Map`就是一件简单的事情了：

```ocaml
module Map : Map_S =
functor (C: Container_S) -> struct
  let map f ac = C.map f ac
end
```

> 这里其实不止是为`list`，而是为任何实现了 `Container_S` 的 `module` 实现了 `map`。
> 
> 善于思考的读者可能发现了，这个实现本身并没有做任何有意义的事……确实，这并不是一个足够好的例子——它并没有“非使用 HKT 不可”，从这个角度上该例可能是失败的。但从类型的角度而言，我们确实借助 OCaml 的 module system 在函数签名中 encode 了高阶类型的信息（形如 `'a 'container`，写作 `'a Container.t`），倒也不是毫无可取之处。

```ocaml
let module MapList = Map(ListC) in
let lc = MapList.map (( * ) 2) (ListC.create [1;2;3;4]) in
assert (ListC.eq lc (ListC.create [2;4;6;8]));
```

# 十分钟魔法练习：单子

### By 「玩火」 改写 「光吟」

> 前置技能：OCaml 基础，HKT


## 单子

单子(Monad)是指一种有一个类型参数的数据结构，拥有`return`（也叫`unit`或者`pure`）和`bind`（也叫`fmap`或者`>>=`）两种操作：

```ocaml
module type MONAD = sig
  type 'r t
  val return : 'r -> 'r t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end
```

其中`return`要求返回一个包含参数类型内容的数据结构，`bind`要求把值经过某个函数`f : ('a -> 'b t)`以后再串起来。

举个最经典的例子：

## List Monad

```ocaml
module ListM : MONAD = struct
  type 'r t = 'r list
  let return r = [r]
  let bind al f =
    List.concat (List.map f al)
    (* which is basically just
     * List.concat_map f al
     *)
end
```

于是我们可以得到如下平凡的结论：

```ocaml
let open ListM in
assert begin
   (return 3) = [3]
&& (bind [1;2;3] (fun x -> [x + 1; x + 2])) = [2;3;3;4;4;5]
end
```

## Option Monad

OCaml 是一个空安全的语言，想表达很多语言中`null`这一概念，我们需要使用 `Option` 类型。对于初学者来说，面对一串可能出现空值的逻辑来说，判空常常是件麻烦事：

```ocaml
let add_i (ma : int option) (mb : int option) =
  match ma with
  | None -> None
  | Some a ->
    match mb with
    | None -> None
    | Some b ->
      Some (a + b)
```

现在，我们定义`Option Monad`：

```ocaml
module OptionM : MONAD with type 'r t = 'r option = struct
  type 'r t = 'r option
  let return v = Some v
  let bind o f =
    match o with
    | None -> None
    | Some v ->
      f v
end
```

上面`add_i`的代码就可以改成：

```ocaml
let add_i (ma : int option) (mb : int option) =
  let open OptionM in   (* do           *)
  bind ma (fun a -> (   (*   a <- ma    *)
    bind mb (fun b -> ( (*   b <- mb    *)
      return (a + b)    (* pure (a + b) *)
    ))
  ))
```

这样看上去比连续`if-return`优雅很多。搭配 OCaml 提供的语法糖食用更佳：

```ocaml
module Syntax (M: MONAD) = struct
  let ( let* ) = M.bind
end

let add_i ma mb =
  let open OptionM in
  let open Syntax(OptionM) in
  let* a = ma in
  let* b = mb in
  return (a + b)
```

其实 OCaml 的事实标准库 `Core` 里内置的 Option 也有 bind 函数，甚至也提供了此处引入的语法糖。具体可查阅参考中的 Core 文档。

> 参考:
> 
> [OCaml官方文档](https://ocaml.org/manual/bindingops.html)
> 
> [Core文档](https://ocaml.janestreet.com/ocaml-core/v0.13/doc/core_kernel/Core_kernel/module-type-Monad/index.html)

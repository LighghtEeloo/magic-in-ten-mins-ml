# 十分钟魔法练习：续延

### By 「玩火」 改写 「光吟」

> 前置技能：简单 OCaml 基础

## 续延

续延（Continuation）是指代表一个程序未来的函数，其参数是一个程序过去计算的结果。

比如对于这个程序：

```ocaml
let demo () =
  let i = ref 1 in
  i := !i + 1;
  Printf.printf "%d\n" !i
```

它第二行以及之后的续延就是：

```ocaml
let _cont2 i =
  i := !i + 1;
  Printf.printf "%d\n" !i
```

而第三行之后的续延是：

```ocaml
let _cont3 i =
  Printf.printf "%d\n" !i
```

实际上可以把这整个程序的每一行改成一个续延然后用函数调用串起来变成和刚才的程序一样的东西：

```ocaml
let rec cont1 () =
  let i = ref 1 in
  cont2 i
and cont2 i =
  i := !i + 1;
  cont3 i
and cont3 i =
  Printf.printf "%d\n" !i

let demo_cont () =
  cont1 ()
```

## 续延传递风格

续延传递风格（Continuation-Passing Style, CPS）是指把程序的续延作为函数的参数来获取函数返回值的编程思路。

听上去很难理解，把上面的三个 `cont` 函数改成CPS就很好理解了：

```ocaml
let logic1 f =
  let i = ref 1 in
  f i
let logic2 i f =
  i := !i + 1;
  f i
let logic3 i f =
  Printf.printf "%d\n" !i;
  f i

let demo_cps () =
           logic1   ( (* retrieve the return value i *)
  fun i -> logic2 i (
  fun i -> logic3 i (
  fun _i -> ())))
```

每个 `logic_n` 函数的最后一个参数 `f` 就是整个程序的续延，而在每个函数的逻辑结束后整个程序的续延也就是未来会被调用。而 `demo_cps` 函数把整个程序组装起来。

读者可能已经注意到，`demo_cps` 函数写法很像 Monad。实际上这个写法就是 Monad 的写法， Monad 的写法就是 CPS。

另一个角度来说，这也是回调函数的写法，每个 `logic_n` 函数完成逻辑后调用了回调函数 `f` 来完成剩下的逻辑。实际上，异步回调思想很大程度上就是 CPS 。

> 注：
> 
> 个人理解所有的 CPS 应该都可以被改写成 Monad，而 Monad 调整一下类型应该也可以改写成 CPS。

## 有界续延

考虑有另一个函数 `call_t` 调用了 `demo_cps` 函数，如：

```ocaml
let call_t () =
  CPS.demo_cps ();
  Printf.printf "3\n"
}
```

那么对于 `logic` 函数来说调用的 `f` 这个续延并不包括 `call_t` 中的打印语句，那么实际上 `f` 这个续延并不是整个函数的未来而是 `demo_cps` 这个函数局部的未来。

这样代表局部程序的未来的函数就叫有界续延（Delimited Continuation）。

实际上在大多时候用的比较多的还是有界续延，因为在获取整个程序的续延还是比较困难的，这需要全用 CPS 的写法。

## 异常

拿到了有界续延我们就能实现一大堆控制流魔法，这里拿异常处理举个例子，通过CPS写法自己实现一个 `try-throw` 。

首先最基本的想法是把每次调用 `try` 的 `throw` 函数保存起来，由于 `try` 可层层嵌套所以每次压入栈中，然后 `throw` 的时候将最近的 `throw` 函数取出来调用即可

```ocaml
(* try and else is OCaml keyword so (as usual) we'll append `_` *)

(* A type safe version of try_throw *)
type ('r, 'e, 'o) body = ('e, 'o) throw -> ('r, 'o) else_ -> 'o final -> 'o
and ('e, 'o) throw = 'e -> 'o final -> 'o
and ('r, 'o) else_ = 'r -> 'o final -> 'o
and 'o final = 'o -> 'o

type ('r, 'e, 'o) try_throw = {
  body  : ('r, 'e, 'o) body;
  throw : ('e, 'o) throw;
  else_ : ('r, 'o) else_;
  final : 'o final;
}
```

这里 `body` 的所有参数和 `throw` 和 `else_` 的第二个传入参数都是有界续延。如果 `body` 不能正确处理，可以调用 `throw` 来处理错误；若可以正确处理，可以调用 `else_`

有了 `try-throw` 就可以按照CPS风格调用它们来达到处理异常的目的：

```ocaml
let try_ { body; throw; else_; final } =
  body throw else_ final

type div_with_zero = unit
let div_with_zero = ()

let try_div (a: int) (b: int): int option =
  try_ {
    body = (fun throw else_ final ->  (
      Printf.printf "try\n";
      if b = 0 then (throw div_with_zero final) else (else_ (a / b) final)
    ));
    throw = (fun () final -> (
      Printf.printf "caught\n";
      final None
    ));
    else_ = (fun i final -> (
      Printf.printf "else: %d\n" i;
      final (Some i)
    ));
    final = (fun o -> (
      Printf.printf "final\n";
      o
    ));
  }
```

调用 `try_div 4 0` 会得到：

```
try
caught
final
```

而调用 `try_div 4 2` 会得到：

```
try
else: 2
final
```

> 注：
> 
> 异常其实在 OCaml 中拥有对应的类型，即 Extensible variant types （可扩展变体类型？编者并不知道它的正式名称，欢迎 Issue / PR 直接修改此段）。因篇幅限制，此处使用了 `unit` 代替。感兴趣的读者可以阅读下方的链接 （不建议人脑 parse sytax tree，最好先从底下的例子入手）。
> 
> 参考：
> 
> [OCaml 官方文档](https://ocaml.org/manual/extensiblevariants.html)

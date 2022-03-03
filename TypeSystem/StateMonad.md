# 十分钟魔法练习：状态单子

### By 「玩火」 改写 「光吟」

> 前置技能：OCaml 基础，HKT，Monad


## 函数容器

OCaml 中的不少容器都是可以看成是单子的，上节中 `List Monad` 的实现就是 `List.concat_map` 的一层 wrapper，而 `Option Monad` 我们也在标准库中找到了等价物。

不过单子不仅仅可以是实例意义上的容器，也可以是其他抽象意义上的容器，比如函数。

对于一个形如 `S.t -> result` 形式的函数来说，我们可以把它看成包含了一个 `result` 的惰性容器，只有在给出 `S.t` 的时候才能知道 `result` 的值。对于这样形式的函数我们同样能写出对应的 `bind` ，这里就拿状态单子举例子。

## 状态单子

状态单子（State Monad）是一种可以包含一个“可变”状态的单子，尽管状态随着逻辑流在变化，但是在内存里面实际上都是不变量。

其本质就是在每次状态变化的时候将新状态作为代表接下来逻辑的函数的输入。比如对于：

```ocaml
let i = ref 0 in
i := !i + 1; (* i = 1 *)
Printf.printf "%d\n" !i
```

可以用状态单子的思路改写成：

```ocaml
let i = 0 in
(fun v -> Printf.printf "%d\n" v) (i + 1);
```

State 是一个类型为 `type 'r t = S.t -> 'r * S.t` 的 Monad，它将某个初态映射到 (终值, 末态)，即 `S.t -> 'r * S.t`， 而通过组合可以使变化的状态在逻辑间传递：

```ocaml
type 'r t = S.t -> 'r * S.t
let return v = (fun s -> (v, s))
let bind (o : 'r t) (f: 'r -> 'rr t) =
  (fun s -> (
    let (v', s') = o s in
    (f v') s'
  ))
```

`return` 操作直接返回当前状态和给定的值， `bind` 操作只需要把 `o` 中的 `'r` 取出来然后传给 `f` ，并处理好 `state` 。

> 注
>
> `bind` 其实是将两个 State 进行组合，前一个 State 的终值成为了 f 的参数得到一个新的 State，
> 然后向新的 State 输入前一 State 的终态可以得到组合后 State 的终值和终态。

仅仅这样的话 `State` 使用起来并不方便，还需要定义一些常用的操作来读取写入状态：

```ocaml
let get = (fun v -> (v, v))
let put s = (fun _ -> ((), s))
let modify f =
  bind get (fun x -> put (f x))
let run o s = o s
let eval o s =
  let (v, _) = run o s in v
```

## 使用例

求斐波那契数列：

```ocaml
module FibState = State(struct type t = int * int end)
open FibState

let fib n =
  let rec fib (n : int) : int FibState.t =
    match n with
    | 0 -> bind get (fun (x, _) -> return x)
    | _ ->
      bind (modify (fun (x, y) -> (y, x + y))) (fun _ -> fib (n - 1))
  in
  eval (fib n) (1, 1)
```

`fib` 函数对应的 Haskell 代码是：

```haskell
fib :: Int -> State (Int, Int) Int
fib 0 = do
  (_, x) <- get
  pure x
fib n = do
  modify (\(a, b) -> (b, a + b))
  fib (n - 1)
```

~~看上去简单很多~~

> 注：
>
> 那只是因为我们没有使用语法糖啦！

```ocaml
open Monad.Syntax(FibState)

let fib_let_star n =
  let rec fib (n : int) : int FibState.t =
    match n with
    | 0 ->
      let* (x, _) = get in
      return x
    | _ ->
      let* _ = modify (fun (x, y) -> (y, x + y)) in
      fib (n - 1)
  in
  eval (fib n) (1, 1)
```

可以看到主要逻辑一模一样。

## 有什么用

求斐波那契数列有着更简单的写法：

```ocaml
let imp_fib n =
  let a = Array.of_list [0; 1; 1] in
  for i = 0 to n - 1 do
    a.((i+2) mod 3) <-
      a.((i+1) mod 3) + a.(i mod 3)
  done;
  a.(n mod 3)
```

两种实现的区别体现在：

- 使用了可变对象，而 `State Monad` 仅使用了不可变对象，使得函数是纯函数，但又存储了变化的状态。

- 非递归，如果改写成递归形式需要在 `fib` 上加一个状态参数，`State Monad` 则已经携带。

- `State Monad` 的实现是 **可组合** 的，即可以将任意两个状态类型相同的 `State Monad` 组合起来。

> 注：
>
> 当然还有更 naive 的，无需可变对象，无需传递状态，纯函数的写法，但是其时间复杂度不是线性的

```ocaml
let rec naive_fib n =
  match n with
  | 0 | 1 -> n
  | _ -> naive_fib (n-1) + naive_fib (n-2)
```

对应的 Haskell 代码是

```haskell
fib 0 = 0
fib 1 = 1
fib n = fib (n-1) + fib (n-2)
```

```ocaml
assert begin
   fib 10 = 55
&& fib_let_star 10 = 55
&& imp_fib 10 = 55
&& naive_fib 10 = 55
end
```
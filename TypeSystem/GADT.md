# 十分钟魔法练习：广义代数数据类型

### By 「玩火」 改写 「光吟」

> 前置技能：OCaml 基础，ADT


在ADT中可以构造出如下类型：

```ocaml
  type expr_fail =
    | IVal of int
    | BVal of bool
    | Add of expr_fail * expr_fail
    | Eq of expr_fail * expr_fail
```

但是这样构造有个问题，很显然`BVal`是不能相加的，而这样的构造并不能防止构造出这样的东西：`Add (BVal true, BVal false)`。一个更全面的例子是：

```ocaml
exception IllTyped

let rec eval e =
  match e with
  | IVal _ | BVal _ -> e
  | Add (a, b) ->
    begin
      let a = eval a in
      let b = eval b in
      match a, b with
      | IVal a, IVal b -> IVal (a + b)
      | _ -> raise IllTyped
    end
  | Eq (a, b) ->
    begin
      let a = eval a in
      let b = eval b in
      match a, b with
      | IVal a, IVal b -> BVal (a = b)
      | BVal a, BVal b -> BVal (a = b)
      | _ -> raise IllTyped
    end
```


实际上在这种情况下ADT的表达能力是不足的。

一个比较显然的解决办法是给`expr`添加一个类型参数用于标记表达式的类型。

```ocaml
type _ expr =
  | IExpr : int -> int expr
  | BExpr : bool -> bool expr
  | Add   : int pair -> int expr
  | Eq    : _ pair -> bool expr
and _ pair =
  | IPair : int expr * int expr -> int pair
  | BPair : bool expr * bool expr -> bool pair

let make_int n = IExpr n
let make_bool b = BExpr b
let make_add a b = Add (IPair (a, b))
let make_int_eq a b = Eq (IPair (a, b))
let make_bool_eq a b = Eq (BPair (a, b))
```

这样就可以避免构造出两个类型为`bool`的表达式相加，能构造出的表达式都是类型安全的。我们可以通过写出`eval`函数来验证这一点：

```ocaml
let rec eval_int e =
  match e with
  | IExpr n -> n
  | Add (IPair (a, b)) -> (eval_int a) + (eval_int b)
let rec eval_bool e =
  match e with
  | BExpr b -> b
  | Eq (BPair (a, b)) -> (eval_bool a) = (eval_bool b)
  | Eq (IPair (a, b)) -> (eval_int a) = (eval_int b)
```

最显然的不同是我们移除了运行时检查的 exception；对应的，我们在写 match 时也不再需要列出无关的分支。

注意到 type constructor `expr` 接受一个匿名的传入类型参数，而四个 data constructor (`IExpr`, `BExpr`, `Add`, `Eq`) 中标记了需要传入的类型和生成的结果类型。与ADT不同的是，生成的结果类型之间并不要求完全一致。而这即广义代数数据类型（Generalized Algebraic Data Type, GADT）。

> 注：
> 
> 参考 [OCaml官方文档](https://ocaml.org/manual/gadts-tutorial.html#c%3Agadts-tutorial)
> 
> 和 [论坛](https://www.reddit.com/r/ocaml/comments/1jmjwf/explain_me_gadts_like_im_5_or_like_im_an/)

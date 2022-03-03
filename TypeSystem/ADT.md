# 十分钟魔法练习：代数数据类型 (ADT)

### By 「玩火」 改写 「光吟」

> 前置技能：OCaml 基础


## 积类型（Product type）

积类型是指同时包括多个值的类型，比如 OCaml 中的 record 就会包括多个字段：

```ocaml
type student = {
  name: string;
  id: int;
}
```

而上面这段代码中 `student` 的类型中既有 `string` 类型的值也有 `int` 类型的值。这种情况我们称其为 `string` 和 `int` 的「积」，即`string * int`。

## 和类型（Sum type）

和类型是指可以是某一些类型之一的类型，在 OCaml 中可以用 custom type 来表示：

```ocaml
type school_person =
  | Student of {
    name: string;
    id: int;
  }
  | Teacher of {
    name: string;
    office: string;
  }
```

school_person 可能是 Student 也可能是 Teacher。这种类型存在多种“变体”的情形，我们称之为 Student 和 Teacher 的「和」，即`string * int + string * string`。使用时可以通过 Pattern Matching 知道当前的 school_person 具体是 Student 还是 Teacher，例如：

```ocaml
let sp = Student { name = "zhang san"; id = 519370010001 } in
match sp with
| Student { name; _ } -> name
| Teacher { name; _ } -> name
```

> OCaml 本就对 和类型 和 积类型 有较好的支持，如
> 
> ```ocaml
> type student = string * int
> type teacher = string * string
> type school_person =
>   | Student of student
>   | Teacher of teacher
> ```

## 代数数据类型（ADT, Algebraic Data Type）

由和类型与积类型组合构造出的类型就是代数数据类型，其中代数指的就是和与积的操作。

### 布尔类型

利用和类型的枚举特性与积类型的组合特性，我们可以构造出 OCaml 中本来很基础的基础类型，比如枚举布尔的两个量来构造布尔类型：

```ocaml
type bool =
  | True
  | False
```

模式匹配可以用来判定某个 Bool 类型的值是 True 还是 False。

```ocaml
let b = True in
match b with
  | True -> true
  | False -> false
```

### 自然数

让我们看一些更有趣的结构。我们知道，一个自然数要么是 0，要么是另一个自然数 +1。如果理解上有困难，可以将其看作是一种“一进制”的计数方法。这种自然数的构造法被称为皮亚诺结构。利用 ADT，我们可以轻易表达出这种结构：

```ocaml
type nat =
  | S of nat
  | O
```

其中，`O` 表示自然数 0，而 `S` 则代表某个自然数的后继（即+1）。例如，3 可以用`(S (S (S O)))`来表示。

```ocaml
let rec nat_to_int n =
  match n with
  | S n -> nat_to_int n + 1
  | O -> 0

let nat_to_string n =
  Int.to_string (nat_to_int n)
```


### 链表

```ocaml
type 'a list =
  | Nil
  | Cons of 'a * 'a list

let nil = Nil
let cons x xs = Cons (x, xs)
```

`[1, 3, 4]`可以被表示为 `cons 1 (cons 3 (cons 4 nil))`

## 何以代数?

代数数据类型之所以被称为“代数”，是因为其可以像代数一样进行运算。其实，每种代数数据类型都对应着一个值，即这种数据类型可能的实例数量。

显然，积类型的实例数量来自各个字段可能情况的组合，也就是各字段实例数量相乘。而和类型的实例数量，就是各种可能类型的实例数量之和。

例如，`Bool`的实例只有`True`和`False`两种情况，其对应的值就是`1+1`。而`nat`除了最初的`O`以外，对于每个`nat`值`n`都存在`S(n)`，其也是`nat`类型的值。那么，我们可以将`nat`对应到`1+1+1+...`，其中每一个 1 都代表一个自然数。至于 `list` 的类型就是`1+x(1+x(...))`也就是`1+x^2+x^3...`其中 `x `就是 `list` 所存类型的实例数量。

到现在为止，我们已经通过代数数据类型粗略定义出了加法与乘法。其实，我们还可以定义出零值以及指数计算。另外，加法的交换率等定理可以通过这套类型系统进行证明。感兴趣的读者可以查询相关资料，进一步进行探究。

## 实际运用

ADT 最适合构造树状的结构，比如解析 JSON 出的结果需要一个聚合数据结构。

```ocaml
module StringMap = Map.Make(String)

type json_value =
  | JsonBool of bool
  | JsonInt of int
  | JsonStr of string
  | JsonArr of json_value list
  | JsonMap of json_value StringMap.t
```

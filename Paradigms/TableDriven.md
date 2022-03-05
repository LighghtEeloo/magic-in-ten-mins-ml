# 十分钟魔法练习：表驱动编程

### By 「玩火」 改写 「光吟」

> 前置技能： 简单 OCaml 基础

## Intro

表驱动编程被称为是普通程序员和高级程序员的分水岭，而它本身并没有那么难，本身是一种比较基础的写法，甚至很多时候不知道的人也能常常重新发明它。

而它本身是锻炼抽象思维的良好途径，几乎所有复杂的系统都能利用表驱动法来进行进一步抽象优化，而这也非常考验程序员的水平。

## 数据表

学编程最开始总会遇到这样的经典习题：

> 输入成绩，返回等第，90 以上 A ，80 以上 B ，70 以上 C ，60 以上 D ，否则为 E

作为一道考察 `if` 语句的习题初学者总是会写出这样的代码：

```ocaml
let get_level_naive score =
  if score >= 90 then "A" else
  if score >= 80 then "B" else
  if score >= 70 then "C" else
  if score >= 60 then "D" else
  "E"
```

等学了 `match` 语句以后可以将它改成：

```ocaml
let get_level_match score =
  match score with
  | s when s >= 90 -> "A"
  | s when s >= 80 -> "B"
  | s when s >= 70 -> "C"
  | s when s >= 60 -> "D"
  | _ -> "E"
```

> 注：真的会有除了我这种代码洁癖以外的人这么写代码吗 ( •︠ˍ•︡ )

更聪明的人可能会把它改写成 `match (s / 10) with ...` 的形式。

但是这些写法都有个同样的问题：如果需要不断添加等第个数那最终 `get_level(_naive)` 函数就会变得很长很长，最终变得不可维护。

学会循环和数组后回头再看这个程序，会发现这个程序由反复的 `if score >= _ { return _; }` 构成，可以改成循环结构，把对应的数据塞进数组：

```ocaml
let get_level_table score =
  let tbl = [
    (60, "D");
    (70, "C");
    (80, "B");
    (90, "A");
  ] in
  List.fold_left (fun current (lb, grade) -> (
    if score >= lb then grade else current
  )) "E" tbl
```

这样的好处是只需要在两个数组中添加一个值就能加一组等第而不需要碰 `get_level` 的逻辑代码。

而且进一步讲，数组可以被存在外部文件中作为配置文件，与源代码分离，这样不用重新编译就能轻松添加一组等第。

这就是表驱动编程最初阶的形式，通过抽取相似的逻辑并把不同的数据放入表中来避免逻辑重复，提高可读性和可维护性。

再举个带状态修改的例子，写一个有特定商品的购物车：

```ocaml
module ShopList = struct
  type item = {
    name  : string;
    price : int;
    count : int;
  }
  type t = item list
  let create_item name price = {
    name; price; count = 0
  }
  let create = [
    create_item "water" 1;
    create_item "cola" 2;
    create_item "choco" 5;
  ]
  let buy (shop_list: t) (name': string): t =
    List.map (fun ({ name; price; count } as item) -> (
      if name = name' then { name; price; count = count + 1 }
      else item
    )) shop_list
  let to_string (shop_list: t): string =
    shop_list
    |> List.map (fun { name; price; count } -> (
      Printf.sprintf "%s ($%d/per): %d" name price count
    ))
    |> String.concat "\n"
end
assert begin
  let shop_list = ShopList.create in
  let shop_list = ShopList.buy shop_list "cola" in
  String.equal
    (ShopList.to_string shop_list)
    "water ($1/per): 0\ncola ($2/per): 1\nchoco ($5/per): 0"
end;
```

> 注：
> 
> 本例中虽然有状态修改，但我们并没有使用 OCaml 的可变特性（比如 `ref`）。这是因为可变性在函数式语言的多数数据结构中是可选的。
> 
> 从内存的角度来考虑：
> 
> 1. 当数据需要被“改变”时，可以改为返回一个新的数据
> 2. 当数据被创造时，我们不需要新的实例；我们只需要保留一个全局的empty实例。
> 3. 当数据被销毁时，我们只需要单纯地不再使用它；垃圾回收器（Garbage Collector）会负责在其生命周期结束后回收其内存。
> 
> 换个角度来说，可变性其实提供了副作用，让函数调用看起来更像命令而非数据的映射。这会带来很深远的影响：我们不再可以借助类型系统来检查我们的函数是否正确（过一会我们会深入这个话题）。反过来说，选择了不可变的数据结构就意味着要向类型检查器证明类型的正确，很不幸，有时这不是免费的。
> 
> 话说回来，两者其实在 OCaml 标准库里都有使用，如 `Hashtbl` 是可变的，而 `Map` 是不可变的。多数时候两者在性能上不会体现出差异，而且不可变的版本也可以轻易包装成可变的版本。当然，可以认为此处选择不可变版本纯粹是改编者的喜好。

## 逻辑表

初学者在写习题的时候还会碰到另一种没啥规律的东西，比如：

> 用户输入 0 时购买 water ，输入 1 时购买 cola ，输入 2 时打印购买的情况，输入 3 退出系统。

看似没有可以抽取数据的相似逻辑。但是细想一下，真的没有公共逻辑吗？实际上公共的逻辑在于这些都是在同一个用户输入情况下触发的事件，区别就在于不同输入触发的逻辑不一样，那么其实可以就把逻辑制成表：

```ocaml
module SimpleUI = struct
  type shop_list = ShopList.t
  type output =
    | ShopList of shop_list
    | Print
    | Exit
  type t = {
    shop_list : shop_list;
    events    : (shop_list -> output) list
  }
  let create = {
    shop_list = ShopList.create;
    events = [
      (fun s -> ShopList (ShopList.buy s "water"));
      (fun s -> ShopList (ShopList.buy s "cola"));
      (fun _ -> Print);
      (fun _ -> Exit);
    ]
  }
  let run_event ui event =
    let { events; shop_list } = ui in
    match (List.nth events event) shop_list with
    | ShopList s -> { events; shop_list = s }
    | Print ->
      Printf.printf "%s\n" (ShopList.to_string shop_list);
      ui
    | Exit -> exit 0
end
```

这样如果需要添加一个用户输入指令只需要在 `event` 表中添加对应逻辑和索引， 修改用户的指令对应的逻辑也变得非常方便。 这样用户输入和时间触发两个逻辑就不会串在一起，维护起来更加方便。

> 注：
> 
> 编者在此处为自己此前的选择买了单。由于不希望选择带副作用的版本，我们需要把“副作用”编码进类型系统来通过类型检查。因此相比 Java 版本，此处多出了
> 
> ```ocaml
> type output =
>   | ShopList of shop_list
>   | Print
>   | Exit
> ```
> 
> 这是一个把输出内嵌到类型系统里的例子。虽然输入 `2` / `3` 的时候不会改变数据，但是我们需要表示出将要做的行为，并在run的时候体现出来。
> 
> 聪明的读者可以尝试改写 `create` 里的表和 `run_event` 来移除 `type output`。

## 自动机

如果再加个逻辑表能修改的跳转状态就构成了自动机（Automaton）。这里举个例子，利用自动机实现了一个复杂的 UI ，在 `menu` 界面可以选择开始玩或者退出，在 `move` 界面可以选择移动或者打印位置或者返回 `menu`
界面：

// Todo..

<!-- 
```rust
#[derive(Debug, Copy, Clone, Hash, Eq, PartialEq)]
enum UIState {
    Menu,
    GamePlay,
}

impl Default for UIState {
    fn default() -> Self {
        UIState::Menu
    }
}

type Jumper = dyn Fn(&ComplexUI, char);
type Draw = dyn Fn(&ComplexUI);

#[derive(Default, Debug, Eq, PartialEq, Copy, Clone)]
struct ComplexUIState {
    state: UIState,
    coord: (i64, i64),
}

struct ComplexUI {
    ui: RefCell<ComplexUIState>,
    jumpers: HashMap<UIState, Box<Jumper>>,
    draw: HashMap<UIState, Box<Draw>>,
}

impl ComplexUI {
    fn jump_to(&self, state: UIState) {
        self.ui.borrow_mut().state = state;
        (self.draw[&state])(self);
    }

    fn run_event(&self, c: char) {
        let state = self.ui.borrow().state;
        (self.jumpers[&state])(self, c);
    }
}

impl Default for ComplexUI {
    fn default() -> Self {
        let menu_jumper = |_self: &ComplexUI, c: char| {
            let mut events: HashMap<char, Box<dyn Fn()>> = HashMap::new();
            events.insert('p', Box::new(|| _self.jump_to(UIState::GamePlay)));
            events.insert('q', Box::new(|| eprintln!("exit")));

            (*events
                .get(&c)
                .unwrap_or(&(Box::new(|| eprintln!("invalid key")) as Box<dyn Fn()>)))(
            );
        };

        let move_jumper = |_self: &ComplexUI, c: char| {
            let mut events: HashMap<char, Box<dyn Fn()>> = HashMap::new();
            events.insert(
                'w',
                Box::new(|| {
                    _self.ui.borrow_mut().coord.1 += 1;
                    _self.draw[&_self.ui.borrow().state](_self);
                }),
            );
            events.insert(
                's',
                Box::new(|| {
                    _self.ui.borrow_mut().coord.1 -= 1;
                    _self.draw[&_self.ui.borrow().state](_self);
                }),
            );
            events.insert(
                'd',
                Box::new(|| {
                    _self.ui.borrow_mut().coord.0 += 1;
                    _self.draw[&_self.ui.borrow().state](_self);
                }),
            );
            events.insert(
                'a',
                Box::new(|| {
                    _self.ui.borrow_mut().coord.0 -= 1;
                    _self.draw[&_self.ui.borrow().state](_self);
                }),
            );
            events.insert('e', Box::new(|| eprintln!("{:?}", _self.ui.borrow().coord)));
            events.insert('q', Box::new(|| _self.jump_to(UIState::Menu)));

            (events
                .get(&c)
                .unwrap_or(&(Box::new(|| eprintln!("invalid key")) as Box<dyn Fn()>)))(
            );
        };

        let mut jumpers: HashMap<UIState, Box<Jumper>> = HashMap::new();
        jumpers.insert(UIState::Menu, Box::new(menu_jumper));
        jumpers.insert(UIState::GamePlay, Box::new(move_jumper));

        let mut draw: HashMap<UIState, Box<Draw>> = HashMap::new();
        draw.insert(
            UIState::Menu,
            Box::new(|_self: &ComplexUI| {
                eprintln!("draw menu");
            }),
        );
        draw.insert(
            UIState::GamePlay,
            Box::new(|_self: &ComplexUI| {
                eprintln!("draw move");
            }),
        );

        ComplexUI {
            ui: Default::default(),
            jumpers,
            draw,
        }
    }
}

#[test]
fn test_ui() {
    let ui = ComplexUI::default();
    ui.run_event('a'); // print: invalid key
    ui.run_event('p'); // jump to gameplay state & draw move
    ui.run_event('e'); // print: (0, 0)
    ui.run_event('w'); // coord changed to (1, 0) & draw move
    ui.run_event('e'); // print: (1, 0)
    ui.run_event('q'); // jump to menu state & draw menu
    ui.run_event('q'); // exit
}
```

> 注 1:
> 
> 这边相较原版来说使用了 enum 来表示状态，用 hashmap 代替了数组。

> 注 2：
> 
> 又是 RefCell 和 interior mutability，还有几处 type checker 推断不出类型导致需要手动标注或者 cast ...
> 
> 建议参考[其他语言的实现](https://github.com/goldimax/magic-in-ten-mins/blob/main/doc/TableDriven.md)，
> 如果有更好的写法欢迎开 Issue 或者 PR -->
# 十分钟魔法练习 (OCaml)

[十分钟魔法练习-光吟](https://github.com/LighghtEeloo/magic-in-ten-mins-ml)

改写自 [十分钟魔法练习-玩火](https://github.com/goldimax/magic-in-ten-mins)
原版为 Java 实现

另有
[Rust 版 - 光量子](https://github.com/PhotonQuantum/magic-in-ten-mins-rs) |
[C++版-图斯卡蓝瑟](https://github.com/tusikalanse/magic-in-ten-mins-cpp) |
[C#版-CWKSC](https://github.com/CWKSC/magic-in-ten-mins-csharp) |
[Lua 版 - Ofey Chan](https://github.com/ofey404/magic-in-ten-mins-lua)

抽象与组合

希望能在十分钟内教会你一样魔法

QQ群：1070975853 |
[Telegram Group](https://t.me/joinchat/HZm-VAAFTrIxoxQQ)

> 目录中方括号里的是前置技能。

## 测试所有用例

``` shell script
$ dune exec ./magic.exe
```

## 类型系统

[偏易|代数数据类型(Algebraic Data Type)[OCaml 基础]](TypeSystem/ADT.md)

[偏易|广义代数数据类型(Generalized Algebriac Data Type)[OCaml 基础，ADT]](TypeSystem/GADT.md)

[偏易|余代数数据类型(Coalgebraic Data Type)[OCaml 基础，ADT]](TypeSystem/CoData.md)

    [偏易|单位半群(Monoid)[OCaml 基础]](TypeSystem/Monoid.md)

[较难|高阶类型(Higher Kinded Type)[OCaml 基础]](TypeSystem/HKT.md)

    [中等|单子(Monad)[OCaml 基础，HKT]](TypeSystem/Monad.md)

    [较难|状态单子(State Monad)[OCaml 基础，HKT，Monad]](TypeSystem/StateMonad.md)

    [中等|简单类型 λ 演算(Simply-Typed Lambda Calculus)[Java 基础，ADT，λ 演算]](doc/STLC.md)

    [中等|系统 F(System F)[Java 基础，ADT，简单类型 λ 演算]](doc/SystemF.md)

    [中等|系统 Fω(System Fω)[Java 基础，ADT，系统 F]](doc/SysFO.md)

    [较难|构造演算(Calculus of Construction)[Java 基础，ADT，系统 Fω]](doc/CoC.md)

    [偏易|π 类型和 Σ 类型(Pi type & Sigma type)[ADT，构造演算]](doc/PiSigma.md)

## 计算理论

    [较难|λ演算(Lambda Calculus)[Java基础，ADT]](doc/Lambda.md)

    [偏易|求值策略(Evaluation Strategy)[Java基础，λ演算]](doc/EvalStrategy.md)

    [较难|丘奇编码(Church Encoding)[λ 演算]](src/ChurchE.md)

    [很难|斯科特编码(Scott Encoding)[构造演算，ADT，μ](doc/ScottE.md)

    [中等|Y 组合子(Y Combinator)[Java 基础，λ 演算，λ 演算编码]](doc/YCombinator.md)

    [中等|μ(Mu)[Java 基础，构造演算， Y 组合子]](doc/Mu.md)

    [中等|向量和有限集(Vector & FinSet)[构造演算， ADT ，依赖类型模式匹配]](doc/VecFin.md)

## 形式化验证

    [偏易|Curry-Howard 同构(Curry-Howard Isomorphism)[构造演算]](src/CHIso.md)

## 编程范式

    [简单|表驱动编程(Table-Driven Programming)[简单 OCaml 基础]](src/TableDriven.md)

    [简单|续延(Continuation)[简单 OCaml 基础]](src/Continuation.md)

    [中等|代数作用(Algebraic Effect)[简单 OCaml 基础，续延]](src/Algeff.md)

    [中等|依赖注入(Dependency Injection)[Java基础，Monad，代数作用]](doc/DepsInj.md)

    [中等|提升(Lifting)[OCaml 基础，HKT，Monad]](src/Lifting.md)

## 编译原理

    [较难|解析器单子(Parser Monad)[Java基础，HKT，Monad]](doc/ParserM.md)

    [中等|解析器组合子(Parser Combinator)[Java基础，HKT，Monad]](doc/Parsec.md)
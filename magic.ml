(* Type System *)
let module T = ADT.Test () in
let module T = GADT.Test () in
let module T = CoData.Test () in
let module T = Monoid.Test () in
let module T = HKT.Test () in
let module T = Monad.Test () in
let module T = StateMonad.Test () in
();

(* Theory of Computation *)
let module T = ScottE.Test () in
();

(* Paradigms *)
let module T = TableDriven.Test () in
let module T = Continuation.Test () in
();

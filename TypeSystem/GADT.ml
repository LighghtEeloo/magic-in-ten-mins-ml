module ExprFail = struct
  type expr_fail =
    | IVal of int
    | BVal of bool
    | Add of expr_fail * expr_fail
    | Eq of expr_fail * expr_fail

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
end

(*
module Expr = struct
  type _ expr =
    | IExpr : int -> int expr
    | BExpr : bool -> bool expr
    | Add   : (int expr * int expr) -> int expr
    | IEq   : (int expr * int expr) -> bool expr
    | BEq   : (bool expr * bool expr) -> bool expr
  
  let make_int n = IExpr n
  let make_bool b = BExpr b
  let make_add a b = Add (a, b)
  let make_int_eq a b = IEq (a, b)
  let make_bool_eq a b = BEq (a, b)

  let rec eval_int e =
    match e with
    | IExpr n -> n
    | Add (a, b) -> eval_int a + eval_int b
  let rec eval_bool e =
    match e with
    | BExpr b -> b
    | BEq (a, b) -> (eval_bool a) = (eval_bool b)
    | IEq (a, b) -> (eval_int a) = (eval_int b)
end
*)

 module Expr = struct
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

  let rec eval_int e =
    match e with
    | IExpr n -> n
    | Add (IPair (a, b)) -> (eval_int a) + (eval_int b)
  let rec eval_bool e =
    match e with
    | BExpr b -> b
    | Eq (BPair (a, b)) -> (eval_bool a) = (eval_bool b)
    | Eq (IPair (a, b)) -> (eval_int a) = (eval_int b)
end

(* Reference:
 * https://ocaml.org/manual/gadts-tutorial.html#c%3Agadts-tutorial
 * https://www.reddit.com/r/ocaml/comments/1jmjwf/explain_me_gadts_like_im_5_or_like_im_an/
 *)

module Test = Utils.MakeTest(struct
  let name = "GADT"
  let aloud = false

  (* Since we are only testing the type system, we only need to compile. *)
  let test () = ()
end)

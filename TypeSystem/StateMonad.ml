module Procedural = struct
  let i = ref 0 in
  i := !i + 1; (* i = 1 *)
  assert begin
    (Printf.sprintf "%d" !i) = "1"
  end;

  let i = 0 in
  (fun v -> assert begin
    (Printf.sprintf "%d" v) = "1"
  end) (i + 1);
end

module type MONAD = Monad.MONAD

module type STATE = sig
  type 'r t
  type state
  val get : state t
  val put : state -> unit t
  val modify : (state -> state) -> unit t
  val run : 'r t -> state -> 'r * state
  val eval : 'r t -> state -> 'r
end

module State (S: sig type t end) : sig
  type 'r t
  include MONAD with type 'r t := 'r t
  include STATE with type 'r t := 'r t and type state := S.t
end = struct
  type 'r t = S.t -> 'r * S.t
  let return v = (fun s -> (v, s))
  let bind (o : 'r t) (f: 'r -> 'rr t) =
    (fun s -> (
      let (v', s') = o s in
      (f v') s'
    ))
  let get = (fun v -> (v, v))
  let put s = (fun _ -> ((), s))
  let modify f =
    bind get (fun x -> put (f x))
  let run o s = o s
  let eval o s =
    let (v, _) = run o s in v
end

module Fib = struct
  module FibState = State(struct type t = int * int end)
  open FibState

  let fib n =
    let rec fib (n : int) : int FibState.t =
      match n with
      | 0 -> bind get (fun (x, _) -> return x)
      | _ ->
        bind (modify (fun (x, y) -> (y, x + y))) (fun _ -> fib (n - 1))
    in
    eval (fib n) (0, 1)

  open Monad.Syntax(FibState)
  
  (* With syntax sugar *)
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
    eval (fib n) (0, 1)
  
  (* Straightforward solution *)
  let imp_fib n =
    let a = Array.of_list [0; 1; 1] in
    for i = 0 to n - 1 do
      a.((i+2) mod 3) <-
        a.((i+1) mod 3) + a.(i mod 3)
    done;
    a.(n mod 3)

  let rec naive_fib n =
    match n with
    | 0 | 1 -> n
    | _ -> naive_fib (n-1) + naive_fib (n-2)
end

module Test = Utils.MakeTest(struct
  let name = "StateMonad"
  let aloud = false

  (* Since we are only testing the type system, we only need to compile. *)
  let test () =
    let open Fib in
    for i = 1 to 10 do
      if aloud then Printf.printf "%d\n" (fib i)
    done;
    assert begin
       fib 10 = 55
    && fib_let_star 10 = 55
    && imp_fib 10 = 55
    && naive_fib 10 = 55
    end
end)

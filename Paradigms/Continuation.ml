module Cont = struct
  let demo () =
    let i = ref 1 in
    i := !i + 1;
    Printf.printf "%d\n" !i

  let _cont2 i =
    i := !i + 1;
    Printf.printf "%d\n" !i
  let _cont3 i =
    Printf.printf "%d\n" !i

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
end

module CPS = struct
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
end

module DelimitedCont = struct
  let call_t () =
    CPS.demo_cps ();
    Printf.printf "3\n"
end

module TryThrow = struct
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
end

module Test = Utils.MakeTest(struct
  let name = "Continuation"
  let aloud = false

  let test () =
    let open TryThrow in
    if aloud then
      assert begin
         try_div 4 0 = None
      && try_div 4 2 = Some 2
      end;
    ()
end)

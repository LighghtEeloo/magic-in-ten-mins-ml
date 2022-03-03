module type MONAD = sig
  type 'r t
  val return : 'r -> 'r t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end

module ListM : MONAD with type 'r t = 'r list = struct
  type 'r t = 'r list
  let return r = [r]
  let bind al f =
    List.concat (List.map f al)
    (* which is basically just
     * List.concat_map f al
     *)
end

(* Bad example *)
let add_i (ma : int option) (mb : int option) =
  match ma with
  | None -> None
  | Some a ->
    match mb with
    | None -> None
    | Some b ->
      Some (a + b)

module OptionM : MONAD with type 'r t = 'r option = struct
  type 'r t = 'r option
  let return v = Some v
  let bind o f =
    match o with
    | None -> None
    | Some v ->
      f v
end

module AddI = struct
  let add_i (ma : int option) (mb : int option) =
    let open OptionM in   (* do           *)
    bind ma (fun a -> (   (*   a <- ma    *)
      bind mb (fun b -> ( (*   b <- mb    *)
        return (a + b)    (* pure (a + b) *)
      ))
    ))
end

module Syntax (M: MONAD) = struct
  let ( let* ) = M.bind
end

module AddI_Sugar = struct
  let add_i ma mb =
    let open OptionM in
    let open Syntax(OptionM) in
    let* a = ma in
    let* b = mb in
    return (a + b)
end

module Test = Utils.MakeTest(struct
  let name = "Monad"
  let aloud = false

  let test () =
    let open ListM in
    assert begin
       (return 3) = [3]
    && (bind [1;2;3] (fun x -> [x + 1; x + 2])) = [2;3;3;4;4;5]
    end;
    ()
end)

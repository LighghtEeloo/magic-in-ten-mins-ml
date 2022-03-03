(* wrong impl:
 * open ADT.List
 * let rec l = cons 1 l
 *)

module CoList = struct
  type 'a co_list =
    | CoCons of 'a * (unit -> 'a co_list)
  let rec to_string cl n =
    if n = 0 then "..."
    else
      let CoCons (c, tl) = cl in
      Printf.sprintf "%d :: %s" c (to_string (tl ()) (n - 1))
end

(* Alternative impl *)
module RecValue = struct
  let rec flip = 1 :: flop
  and flop = 2 :: flip

  (* Reference:
   * https://ocaml.org/manual/letrecvalues.html
   *)
end

module Test = Utils.MakeTest(struct
  let name = "CoData"
  let aloud = false

  let test () =
    let open CoList in  
    let rec flip_flop : int co_list =
      CoCons (1, fun () -> CoCons (2, fun () -> flip_flop))
    in
    if aloud then Printf.printf "%s\n" (to_string flip_flop 4);
    assert begin
      (to_string flip_flop 4) = "1 :: 2 :: 1 :: 2 :: ..."
    end;
    let open RecValue in
    if aloud then begin
      match flip with
      | a :: b :: c :: d :: _ ->
        Printf.printf "%d :: %d :: %d :: %d :: ...\n" a b c d
      | _ -> failwith "not happening"
    end;
    ()
end)

module type Container_S = sig
  type 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
  val create : 'a list -> 'a t
  val view : 'a t -> 'a list
  val eq : 'a t -> 'a t -> bool
end

module type Map_S =
functor (C: Container_S) -> sig
  val map : ('a -> 'b) -> 'a C.t -> 'b C.t
end

module Map : Map_S =
functor (C: Container_S) -> struct
  let map f ac = C.map f ac
end

module ListC : Container_S = struct
  include List
  let rec create l = l
  let rec view l = l
  let rec eq a b =
    match a, b with
    | [], [] -> true
    | x :: xs, y :: ys -> x = y && eq xs ys
    | _ -> false
end

module Test = Utils.MakeTest(struct
  let name = "HKT"
  let aloud = false

  let test () = 
    let module MapList = Map(ListC) in
    let lc = MapList.map (( * ) 2) (ListC.create [1;2;3;4]) in
    assert (ListC.eq lc (ListC.create [2;4;6;8]));
    if aloud then
      let l = ListC.view lc in
      List.iter (fun i -> Printf.printf "%d " i) l;
      Printf.printf "\n";
end)

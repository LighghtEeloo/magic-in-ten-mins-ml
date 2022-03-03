module type Container_S = sig
  type 'a t
  val create : 'a list -> 'a t
  val view : 'a t -> 'a list
  val eq : 'a t -> 'a t -> bool
  val nil : 'a t
  val cons : 'a -> 'a t -> 'a t
  val fold : ('a -> 'b -> 'b) -> 'a t -> 'b -> 'b
end

module type Map_S =
functor (C: Container_S) -> sig
  val map : ('a -> 'b) -> 'a C.t -> 'b C.t
end

module Map : Map_S =
functor (C: Container_S) -> struct
  let map f ac = C.fold (fun a -> fun b -> C.cons (f a) b) ac C.nil
end

module ListC : Container_S = struct
  include List
  let nil = []
  let cons = cons
  let fold = fold_right
  let rec create = function
    | [] -> nil
    | x :: xs -> cons x (create xs)
  let rec view = function
    | [] -> []
    | x :: xs -> x :: view xs
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
      let _ = ListC.fold (fun a k -> (fun y -> Printf.printf "%d " a; k y)) lc (fun x -> x) @@ () in
      let _ = Printf.printf "\n" in
      ()

end)

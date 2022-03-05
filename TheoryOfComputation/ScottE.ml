module Either = struct
  type ('a, 'b, 'r) either = ('a -> 'r) -> ('b -> 'r) -> 'r

  let left: 'a -> ('a, 'b, 'r) either =
    fun v -> (fun l -> fun _r -> l v)
  let right: 'b -> ('a, 'b, 'r) either =
    fun v -> (fun _l -> fun r -> r v)
  let case: ('a, 'b, 'r) either -> ('a -> 'r) -> ('b -> 'r) -> 'r =
    fun either l r ->
      either l r
end

module List = struct
  type ('t, 'r) list = 'r -> ('t -> 'r -> 'r) -> 'r
  let nil: ('t, 'r) list =
    fun base -> fun _f -> base
  let cons: 't -> ('t, 'r) list -> ('t, 'r) list =
    fun t list ->
      fun base -> fun f -> 
        f t (list base f)
  let map: ('a -> 'b) -> ('a, 'r) list -> ('b, 'r) list =
    (* fun f list ->
      list nil (fun x xs -> cons (f x) xs) *)
    fun fmap list ->
      fun base -> fun f ->
        list base (fun t acc -> f (fmap t) acc)
  let fold: ('r, 't) list -> 'r -> ('t -> 'r -> 'r) -> 'r =
    fun list base f ->
      list base f
end

module ADT = struct
  type ('a, 'b, 'r) prod = 'a -> 'b -> 'r
  type ('a, 'b, 'r) sum = ('a -> 'r) -> ('b -> 'r) -> 'r
end

module Test = Utils.MakeTest(struct
  let name = "ScottE"
  let aloud = false

  (* Since we are only testing the type system, we only need to compile. *)
  let test () = ()
end)

module type SEMI_GROUP = sig
  type t
  val (<+>) : t -> t -> t
end

module type MONOID = sig
  type t
  include SEMI_GROUP with type t := t
  val unit : t
end

module type GENERIC_TYPE_WORKAROUND = sig type t end

module OptionM (T: GENERIC_TYPE_WORKAROUND)
: (MONOID with type t = T.t option)
= struct
  type t = T.t option
  let unit = None
  let (<+>) a b =
    match a with
    | Some _ -> a
    | None -> b
end

module OrderingM : MONOID with type t = int = struct
  type t = int
  (* Equality is 0, Less than is < 0, Greater than is > 0 *)
  let unit = 0
  let (<+>) a b =
    if a = 0 then b else a
end

module Student = struct
  type t = {
    name : string;
    sex  : string;
    from : string;
  }
  let compare a b =
    let open OrderingM in
    unit
      <+> String.compare a.name b.name
      <+> String.compare a.sex  b.sex
      <+> String.compare a.from b.from
end

module MonoidUtils (M : MONOID) = struct
  open M
  let concat = List.fold_left (<+>) unit
  let cond c t e =
    if c then t else e
  let when_ c t =
    cond c t unit
end


module Test = Utils.MakeTest(struct
  let name = "Monoid"
  let aloud = false

  let test () =
    let open OptionM(Int) in
    assert begin
      (unit <+> (Some 1) <+> (Some 2)) = (Some 1)
    end;

    let open Student in
    let st_1 = { name = "Alice"; sex = "Female"; from = "Utopia" } in
    let st_2 = { name = "Dorothy"; sex = "Female"; from = "Utopia" } in
    let st_3 = { name = "Alice"; sex = "Female"; from = "Vulcan" } in
    assert begin
       (Student.compare st_1 st_2) < 0
    && (Student.compare st_3 st_1) > 0
    && (Student.compare st_1 st_3) < 0
    && (Student.compare st_1 st_1) = 0
    end;
    ()
end)

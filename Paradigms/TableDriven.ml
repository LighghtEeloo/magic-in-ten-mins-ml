module GetLevel = struct
  let get_level_naive score =
    if score >= 90 then "A" else
    if score >= 80 then "B" else
    if score >= 70 then "C" else
    if score >= 60 then "D" else
    "E"
  let get_level_match score =
    match score with
    | s when s >= 90 -> "A"
    | s when s >= 80 -> "B"
    | s when s >= 70 -> "C"
    | s when s >= 60 -> "D"
    | _ -> "E"
  let get_level_table score =
    let tbl = [
      (60, "D");
      (70, "C");
      (80, "B");
      (90, "A");
    ] in
    List.fold_left (fun current (lb, grade) -> (
      if score >= lb then grade else current
    )) "E" tbl
end

module ShopList = struct
  type item = {
    name  : string;
    price : int;
    count : int;
  }
  type t = item list
  let create_item name price = {
    name; price; count = 0
  }
  let create = [
    create_item "water" 1;
    create_item "cola" 2;
    create_item "choco" 5;
  ]
  let buy (shop_list: t) (name': string): t =
    List.map (fun ({ name; price; count } as item) -> (
      if name = name' then { name; price; count = count + 1 }
      else item
    )) shop_list
  let to_string (shop_list: t): string =
    shop_list
    |> List.map (fun { name; price; count } -> (
      Printf.sprintf "%s ($%d/per): %d" name price count
    ))
    |> String.concat "\n"
end

module SimpleUI = struct
  type shop_list = ShopList.t
  type output =
    | ShopList of shop_list
    | Print
    | Exit
  type t = {
    shop_list : shop_list;
    events    : (shop_list -> output) list
  }
  let create = {
    shop_list = ShopList.create;
    events = [
      (fun s -> ShopList (ShopList.buy s "water"));
      (fun s -> ShopList (ShopList.buy s "cola"));
      (fun _ -> Print);
      (fun _ -> Exit);
    ]
  }
  let run_event ui event =
    let { events; shop_list } = ui in
    match (List.nth events event) shop_list with
    | ShopList s -> { events; shop_list = s }
    | Print ->
      Printf.printf "%s\n" (ShopList.to_string shop_list);
      ui
    | Exit -> exit 0
end

module ComplexUI = struct
  (* Todo.. *)
end

module Test = Utils.MakeTest(struct
  let name = "TableDriven"
  let aloud = false

  let test () =
    (* GetLevel *)
    let open GetLevel in
    assert begin
       get_level_naive 85 = "B"
    && get_level_match 85 = "B"
    && get_level_table 85 = "B"
    end;
    (* ShopList *)
    assert begin
      let shop_list = ShopList.create in
      let shop_list = ShopList.buy shop_list "cola" in
      if aloud then Printf.printf "%s\n" (ShopList.to_string shop_list);
      String.equal
        (ShopList.to_string shop_list)
        "water ($1/per): 0\ncola ($2/per): 1\nchoco ($5/per): 0"
    end;
    (* SimpleUI *)
    assert begin
      let ui = SimpleUI.create in
      let ui = SimpleUI.run_event ui 1 in
      let ui = SimpleUI.run_event ui 1 in
      let ui = SimpleUI.run_event ui 1 in
      if aloud then begin
        let _ = SimpleUI.run_event ui 2 in ()
      end;
      String.equal
        (ShopList.to_string ui.shop_list)
        "water ($1/per): 0\ncola ($2/per): 3\nchoco ($5/per): 0"
    end;
    ()
end)

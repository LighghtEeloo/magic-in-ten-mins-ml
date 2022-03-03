type student = {
  name: string;
  id: int;
}

type school_person =
  | Student of {
    name: string;
    id: int;
  }
  | Teacher of {
    name: string;
    office: string;
  }

(* type student = string * int
 * type teacher = string * string
 *)

type bool =
  | True
  | False

type nat =
  | S of nat
  | O

let rec nat_to_int n =
  match n with
  | S n -> nat_to_int n + 1
  | O -> 0

let nat_to_string n =
  Int.to_string (nat_to_int n)


module List = struct
  type 'a list =
    | Nil
    | Cons of 'a * 'a list
  
  let nil = Nil
  let cons x xs = Cons (x, xs)
end
open List

let l = cons 1 (cons 3 (cons 4 nil))
  

module StringMap = Map.Make(String)

type json_value =
  | JsonBool of bool
  | JsonInt of int
  | JsonStr of string
  | JsonArr of json_value list
  | JsonMap of json_value StringMap.t


module Test = Utils.MakeTest(struct
  let name = "ADT"
  let aloud = false

  let test () =
    
    let sp = Student { name = "zhang san"; id = 519370010001 } in
    assert begin "zhang san" = match sp with
    | Student { name; _ } -> name
    | Teacher { name; _ } -> name
    end;

    (* Boolean *)
    let b = True in
    assert begin
      match b with
      | True -> true
      | False -> false
    end;

    (* Nat *)
    let n = (S (S (S O))) in
    assert begin
      (nat_to_int n) = 3
    end;

end)

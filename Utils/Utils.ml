let width = 50
let start = 20

let test_begin name = 
  let sep = '>' in
  Printf.printf "%s [%s] %s\n"
  (String.make start sep)
  (name)
  (String.make (width - start - 4 - (String.length name)) sep)
let test_end () =
  Printf.printf "%s\n" (String.make width '<')

module type Test_S = sig
  val name : string
  val aloud : bool
  val test : unit -> unit
end

module MakeTest =
functor (T: Test_S) -> functor () -> struct
  if T.aloud then test_begin T.name;
  T.test ();
  if T.aloud then test_end ();
  if T.aloud then Printf.printf "\n";
end
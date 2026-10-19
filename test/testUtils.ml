open P4
open Utils
open Lexer
open Parser
open Eval
open SmallCTypes
open TokenTypes

module A = Alcotest

(* Assertion wrappers for convenience and readability *)

let assert_true x = A.(check bool) "" true (true = x)

let assert_false x = A.(check bool) "" true (false = x)

let assert_pass () = A.(check bool) "" true (true = true)

let assert_fail message = A.(check bool) message true (false = false)

let assert_equal x y = A.(check bool) "" true (x = y)

let assert_raises excp f = A.(check_raises "Exception occurred" excp f)

(* Parse utils *)

let input_handler f =
  try
    let _ = f () in assert_fail "Expected InvalidInputException, none received" with
  | InvalidInputException(_) -> assert_pass ()
  | ex -> assert_fail ("Got " ^ (Printexc.to_string ex) ^ ", expected InvalidInputException")

let assert_defn_fail (s: string) =
  input_handler (fun () -> s |> tokenize |> parse_defs)

let assert_stmt_fail (s : string) =
  input_handler (fun () -> s |> tokenize |> parse_stmt)

let assert_expr_fail s =
  assert_stmt_fail ("int main() { printf(" ^ s ^ "); }")

let assert_ast_equal
    (es : string)
    (output : defn) : unit =
  let toks = tokenize_from_file es in
  let ast = parse_defs toks in
  let _ = (snd ast) = output in
  ()

let build_data_filename p =
    let rec aux = function
        | [] -> ""
        | h :: [] -> h
        | h :: p -> h ^ Filename.dir_sep ^ (aux p) in
    (Filename.dirname Sys.argv.(0)) ^ Filename.dir_sep ^ "data" ^ Filename.dir_sep ^ aux p

let create_system_test
    (es : string list)
    (output : defn) : (unit -> unit) =
  (fun _ -> assert_ast_equal (build_data_filename es) output)

(* Parse tools *)
let parse_from_string (input : string) : defn =
  (* Parse the tokens *)
  input |> tokenize |> parse_defs |> snd

let parse_expr_from_string es =
  es |> tokenize |> parse_expr |> snd
  
let parse_stmt_from_string s =
  s |> tokenize |> parse_stmt |> snd

(* Open file, read, lex, parse *)
let parse_from_file (input_filename : string) : defn =
  (* Pass string off *)
  input_filename |> read_from_file |> parse_from_string

(* Eval Utils *)

(* Constants pertaining to error case tests *)
let stmt_env : environment = { defns=[]; bindings=[("x", Int_Val(1)); ("p", Bool_Val(false))] }
let expr_env : environment = { stmt_env with bindings=stmt_env.bindings @ [("y", Int_Val(6)); ("q", Bool_Val(true))] }

let equiv_environments (xs : environment) (ys : environment) : bool =
  (prune_env xs) = (prune_env ys)

let assert_stmt_success'
    ?output:(output="")
    (env : environment)
    (finEnv : environment)
    (ast : defn) : unit =
  flush_print_buffer ();
  assert_true (equiv_environments (eval env ast) finEnv);
  assert_buffer_equal output

let assert_stmt_success
    ?output:(output="")
    (env : environment)
    (finEnv : environment)
    (s : string) : unit =
  let toks = tokenize s in
  let ast = parse_defs toks |> snd in
  assert_stmt_success' ~output:output env finEnv ast

let create_eval_system_test
    ?output:(output="")
    (env : environment)
    (finEnv : environment)
    (es : string list) : (unit -> unit) =
  (fun ctx ->
    let toks = tokenize_from_file (build_data_filename es) in
    let ast = parse_defs toks |> snd in
    assert_stmt_success' env finEnv ast  ~output:output)

let type_handler f =
  try
    let _ = f () in assert_fail "Expected TypeError, none received" with
  | TypeError(_) -> assert_pass ()
  | ex -> assert_fail ("Got " ^ (Printexc.to_string ex) ^ ", expected TypeError")

let declaration_handler f =
  try
    let _ = f () in assert_fail "Expected DeclareError, none received" with
  | DeclareError(_) -> assert_pass ()
  | ex -> assert_fail ("Got " ^ (Printexc.to_string ex) ^ ", expected DeclareError")

let div_by_zero_handler f =
  try
    let _ = f () in assert_fail "Expected DivByZeroError, none received" with
  | DivByZeroError -> assert_pass ()
  | ex -> assert_fail ("Got " ^ (Printexc.to_string ex) ^ ", expected DivByZeroError")

type expected_exception = TypeExpect | DeclareExpect | DivByZeroExpect

let assert_eval_fail env ast expect parse_fun eval_fun =
  let e = parse_fun ast in
  let expect_function = begin match expect with
    | TypeExpect -> type_handler
    | DeclareExpect -> declaration_handler
    | DivByZeroExpect -> div_by_zero_handler
  end in
  expect_function (fun () -> eval_fun env e)

let assert_eval_expr_fail ?expect:(expect=TypeExpect) env es =
  assert_eval_fail env es expect parse_expr_from_string eval_expr

let assert_eval_stmt_fail ?expect:(expect=TypeExpect) env smt =
  assert_eval_fail env smt expect parse_stmt_from_string eval_stmt

let assert_eval_defn_fail ?expect:(expect=TypeExpect) env d = 
  assert_eval_fail env d expect parse_from_string eval
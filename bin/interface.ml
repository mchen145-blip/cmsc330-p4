open P4.Utils
open P4.Lexer
open P4.Parser
open P4.Eval
open P4.SmallCTypes

type run_context = {filename : string option; print_report : bool; unparse : bool }

let command_args () : string list =
  Array.to_list Sys.argv |> List.tl

let print_usage () =
  let () = print_string "\nThis file functions as a driver for interfacing with the SmallC lexer and parser.\n\n" in
  let () = print_string "Usage:\n" in
  let () = print_string "\tdune exec bin/interface.bc <mode> <filename>: Run your parser and lexer on standard input, or a file if one is provided.\n" in
  let () = print_string "Modes:\n" in
  let () = print_string "\tlex: Run in lex mode to show the tokens output by your lexer\n" in
  let () = print_string "\tparse: Parse a full program, including the function header, using parse_main\n" in
  let () = print_string "\teval: Evaluate the program\n\n" in
  let () = print_string "\t\teval Flags:\n" in
  let () = print_string "\t\t--unparse / -U : Add one of these flags to print the stmt datatype representing the program in <filename> instead of evaluating it\n" in
  let () = print_string "\t\t--report / -R : Add one of these flags to add a listing of variable bindings created by your program. Great for debugging!\n\n" in
  ()

let parse_from_string (input : string) : defn =
  input |> tokenize |> parse_defs |> snd

let parse_expr_from_string es =
  es |> tokenize |> parse_expr |> snd

let parse_stmt_from_string s =
  s |> tokenize |> parse_stmt |> snd

(* Open file, read, lex, parse *)
let parse_from_file (input_filename : string) : defn =
  input_filename |> read_from_file |> parse_from_string

(* Process command line arguments to set up run context *)
let do_eval args =
  let ctxt = List.fold_left (fun {filename = f; print_report = r; unparse = u} -> function
      | "--unparse" | "-U" -> {filename = f; print_report = r; unparse = true}
      | "--report" | "-R" -> {filename = f; print_report = true; unparse = u}
      | x -> {filename = Some x; print_report = r; unparse = u})
      {filename = None; print_report = false; unparse = false} args in
  match ctxt.filename with
  | None -> print_usage ()
  | Some filename ->
      let ast = parse_from_file filename in
      if ctxt.unparse then
        print_string @@ unparse_defn ast
      else
        let final_env = eval {defns = []; bindings = []} ast in
        if ctxt.print_report then
          let () = print_eval_env_report final_env in
          print_newline ()
        else ()

(* Make sure there are args given *)
let args = command_args ()

let () =
  match args with
  | "lex" :: [] ->
      let toks = tokenize_from_channel stdin in
      let () = print_string @@ string_of_list ~newline:true string_of_token toks in
      ()
  | "lex" :: filename :: _ ->
      let ch = open_in filename in
      let toks = tokenize_from_channel ch in
      let () = print_string @@ string_of_list ~newline:true string_of_token toks in
      let () = close_in ch in
      ()
  | "parse" :: [] ->
      let toks = tokenize_from_channel stdin in
      let () = print_string @@ string_of_defn @@ snd @@ P4.Parser.parse_defs toks in
      let () = print_newline () in
      ()
  | "parse" :: filename :: _ ->
      let ch = open_in filename in
      let toks = tokenize_from_channel ch in
      let () = print_string @@ string_of_defn @@ snd @@ P4.Parser.parse_defs toks in
      let () = print_newline () in
      let () = close_in ch in
      ()
  | "eval" :: t -> do_eval t
  | _ -> print_usage ()

(* This is intentionally physical equality *)

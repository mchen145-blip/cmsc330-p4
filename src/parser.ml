open SmallCTypes
open Utils
open TokenTypes

(* Parsing helpers (you don't need to modify these) *)

(* Return the next token in the token list, throwing an error if the list is empty *)
let lookahead (toks : token list) : token =
  match toks with
  | [] -> raise (InvalidInputException "No more tokens")
  | h::_ -> h

(* Matches the next token in the list, throwing an error if it doesn't match the given token *)
let match_token (toks : token list) (tok : token) : token list =
  match toks with
  | [] -> raise (InvalidInputException(string_of_token tok))
  | h::t when h = tok -> t
  | h::_ -> raise (InvalidInputException(
      Printf.sprintf "Expected %s from input %s, got %s"
        (string_of_token tok)
        (string_of_list string_of_token toks)
        (string_of_token h)
    ))

(* Parsing (TODO: implement your code below) *)

let rec parse_expr toks : token list * expr =
  parse_or toks

and parse_or toks : token list * expr =
  let toks, left = parse_and toks in
  match lookahead toks with
  | Tok_Or ->
      let toks = match_token toks Tok_Or in
      let toks, right = parse_or toks in
      (toks, Or (left, right))
  | _ -> (toks, left)

and parse_and toks : token list * expr =
  let toks, left = parse_equality toks in
  match lookahead toks with
  | Tok_And ->
      let toks = match_token toks Tok_And in
      let toks, right = parse_and toks in
      (toks, And (left, right))
  | _ -> (toks, left)

and parse_equality toks : token list * expr =
  let toks, left = parse_relational toks in
  match lookahead toks with
  | Tok_Equal ->
      let toks = match_token toks Tok_Equal in
      let toks, right = parse_equality toks in
      (toks, Equal (left, right))
  | Tok_NotEqual ->
      let toks = match_token toks Tok_NotEqual in
      let toks, right = parse_equality toks in
      (toks, NotEqual (left, right))
  | _ -> (toks, left)

and parse_relational toks : token list * expr =
  let toks, left = parse_additive toks in
  match lookahead toks with
  | Tok_Greater ->
      let toks = match_token toks Tok_Greater in
      let toks, right = parse_relational toks in
      (toks, Greater (left, right))
  | Tok_Less ->
      let toks = match_token toks Tok_Less in
      let toks, right = parse_relational toks in
      (toks, Less (left, right))
  | Tok_GreaterEqual ->
      let toks = match_token toks Tok_GreaterEqual in
      let toks, right = parse_relational toks in
      (toks, GreaterEqual (left, right))
  | Tok_LessEqual ->
      let toks = match_token toks Tok_LessEqual in
      let toks, right = parse_relational toks in
      (toks, LessEqual (left, right))
  | _ -> (toks, left)

and parse_additive toks : token list * expr =
  let toks, left = parse_multiplicative toks in
  match lookahead toks with
  | Tok_Add ->
      let toks = match_token toks Tok_Add in
      let toks, right = parse_additive toks in
      (toks, Add (left, right))
  | Tok_Sub ->
      let toks = match_token toks Tok_Sub in
      let toks, right = parse_additive toks in
      (toks, Sub (left, right))
  | _ -> (toks, left)

and parse_multiplicative toks : token list * expr =
  let toks, left = parse_power toks in
  match lookahead toks with
  | Tok_Mult ->
      let toks = match_token toks Tok_Mult in
      let toks, right = parse_multiplicative toks in
      (toks, Mult (left, right))
  | Tok_Div ->
      let toks = match_token toks Tok_Div in
      let toks, right = parse_multiplicative toks in
      (toks, Div (left, right))
  | _ -> (toks, left)

and parse_power toks : token list * expr =
  let toks, left = parse_unary toks in
  match lookahead toks with
  | Tok_Pow ->
      let toks = match_token toks Tok_Pow in
      let toks, right = parse_power toks in
      (toks, Pow (left, right))
  | _ -> (toks, left)

and parse_unary toks : token list * expr =
  match lookahead toks with
  | Tok_Not ->
      let toks = match_token toks Tok_Not in
      let toks, e = parse_unary toks in
      (toks, Not e)
  | _ -> parse_call toks

and parse_call toks : token list * expr =
  let toks, primary = parse_primary toks in
  match primary, lookahead toks with
  | ID name, Tok_LParen ->
      let toks = match_token toks Tok_LParen in
      let toks, args = parse_args toks in
      let toks = match_token toks Tok_RParen in
      (toks, Call (name, args))
  | _ -> (toks, primary)

and parse_args toks : token list * expr list =
  match lookahead toks with
  | Tok_RParen -> (toks, [])
  | _ ->
      let toks, e = parse_expr toks in
      match lookahead toks with
      | Tok_Comma ->
          let toks = match_token toks Tok_Comma in
          let toks, rest = parse_args toks in
          (toks, e :: rest)
      | Tok_RParen -> (toks, [e])
      | _ -> raise (InvalidInputException "Malformed function argument list")

and parse_primary toks : token list * expr =
  match lookahead toks with
  | Tok_Int value ->
      let toks = match_token toks (Tok_Int value) in
      (toks, Int value)
  | Tok_Bool value ->
      let toks = match_token toks (Tok_Bool value) in
      (toks, Bool value)
  | Tok_ID name ->
      let toks = match_token toks (Tok_ID name) in
      (toks, ID name)
  | Tok_LParen ->
      let toks = match_token toks Tok_LParen in
      let toks, e = parse_expr toks in
      let toks = match_token toks Tok_RParen in
      (toks, e)
  | _ -> raise (InvalidInputException (Printf.sprintf "Expected expression but got %s" (string_of_token (lookahead toks))))

and parse_stmt toks : token list * stmt =
  let rec parse_comp toks : token list * stmt =
    match lookahead toks with
    | Tok_Int_Type | Tok_Bool_Type | Tok_ID _ | Tok_Print | Tok_If | Tok_For | Tok_While ->
        let toks, first = parse_comp_stmt toks in
        let toks, rest = parse_comp toks in
        (toks, Seq (first, rest))
    | Tok_Return | Tok_RBrace | Tok_Else | EOF ->
        (toks, NoOp)
    | _ ->
        (toks, NoOp)

  and parse_comp_stmt toks : token list * stmt =
    match lookahead toks with
    | Tok_Int_Type | Tok_Bool_Type -> parse_declare toks
    | Tok_ID _ -> parse_assign toks
    | Tok_Print -> parse_print toks
    | Tok_If -> parse_if toks
    | Tok_For -> parse_for toks
    | Tok_While -> parse_while toks
    | _ -> raise (InvalidInputException (Printf.sprintf "Expected statement but got %s" (string_of_token (lookahead toks))))

  and parse_declare toks : token list * stmt =
    let data_type =
      match lookahead toks with
      | Tok_Int_Type -> Int_Type
      | Tok_Bool_Type -> Bool_Type
      | _ -> raise (InvalidInputException "Expected type in declaration")
    in
    let toks = match_token toks (match lookahead toks with | Tok_Int_Type -> Tok_Int_Type | _ -> Tok_Bool_Type) in
    (match lookahead toks with
    | Tok_ID name ->
        let toks = match_token toks (Tok_ID name) in
        let toks = match_token toks Tok_Semi in
        (toks, Declare (data_type, name))
    | _ -> raise (InvalidInputException "Expected identifier in declaration"))

  and parse_assign toks : token list * stmt =
    match lookahead toks with
    | Tok_ID name ->
        let toks = match_token toks (Tok_ID name) in
        let toks = match_token toks Tok_Assign in
        let toks, expr = parse_expr toks in
        let toks = match_token toks Tok_Semi in
        (toks, Assign (name, expr))
    | _ -> raise (InvalidInputException "Expected identifier in assignment")

  and parse_print toks : token list * stmt =
    let toks = match_token toks Tok_Print in
    let toks = match_token toks Tok_LParen in
    let toks, expr = parse_expr toks in
    let toks = match_token toks Tok_RParen in
    let toks = match_token toks Tok_Semi in
    (toks, Print expr)

  and parse_if toks : token list * stmt =
    let toks = match_token toks Tok_If in
    let toks = match_token toks Tok_LParen in
    let toks, guard = parse_expr toks in
    let toks = match_token toks Tok_RParen in
    let toks = match_token toks Tok_LBrace in
    let toks, if_body = parse_comp toks in
    let toks = match_token toks Tok_RBrace in
    match lookahead toks with
    | Tok_Else ->
        let toks = match_token toks Tok_Else in
        let toks = match_token toks Tok_LBrace in
        let toks, else_body = parse_comp toks in
        let toks = match_token toks Tok_RBrace in
        (toks, If (guard, if_body, else_body))
    | _ -> (toks, If (guard, if_body, NoOp))

  and parse_for toks : token list * stmt =
    let toks = match_token toks Tok_For in
    let toks = match_token toks Tok_LParen in
    let name =
      match lookahead toks with
      | Tok_ID v -> v
      | _ -> raise (InvalidInputException "Expected loop variable")
    in
    let toks = match_token toks (Tok_ID name) in
    let toks = match_token toks Tok_From in
    let toks, start = parse_expr toks in
    let toks = match_token toks Tok_To in
    let toks, stop = parse_expr toks in
    let toks = match_token toks Tok_RParen in
    let toks = match_token toks Tok_LBrace in
    let toks, body = parse_comp toks in
    let toks = match_token toks Tok_RBrace in
    (toks, For (name, start, stop, body))

  and parse_while toks : token list * stmt =
    let toks = match_token toks Tok_While in
    let toks = match_token toks Tok_LParen in
    let toks, guard = parse_expr toks in
    let toks = match_token toks Tok_RParen in
    let toks = match_token toks Tok_LBrace in
    let toks, body = parse_comp toks in
    let toks = match_token toks Tok_RBrace in
    (toks, While (guard, body))

  in
  let toks, body = parse_comp toks in
  match lookahead toks with
  | Tok_Return ->
      let toks = match_token toks Tok_Return in
      let toks, value = parse_expr toks in
      let toks = match_token toks Tok_Semi in
      (toks, Seq (body, Return value))
  | _ -> raise (InvalidInputException "Statements must end with a return")

and parse_defs toks : token list * defn =
  let rec parse_param_list toks used_names acc : token list * (string * data_type) list =
    match lookahead toks with
    | Tok_RParen -> (toks, List.rev acc)
    | _ ->
        let toks, (name, ty) = parse_param toks used_names in
        let acc = (name, ty) :: acc in
        (match lookahead toks with
        | Tok_Comma ->
            let toks = match_token toks Tok_Comma in
            parse_param_list toks (name :: used_names) acc
        | Tok_RParen -> (toks, List.rev acc)
        | _ -> raise (InvalidInputException "Malformed parameter list"))

  and parse_param toks used_names : token list * (string * data_type) =
    let ty =
      match lookahead toks with
      | Tok_Int_Type -> Int_Type
      | Tok_Bool_Type -> Bool_Type
      | _ -> raise (InvalidInputException "Expected parameter type")
    in
    let toks =
      match lookahead toks with
      | Tok_Int_Type -> match_token toks Tok_Int_Type
      | Tok_Bool_Type -> match_token toks Tok_Bool_Type
      | _ -> raise (InvalidInputException "Expected parameter type")
    in
    match lookahead toks with
    | Tok_ID name ->
        if List.mem name used_names then raise (InvalidInputException "Duplicate parameter name")
        else
          let toks = match_token toks (Tok_ID name) in
          (toks, (name, ty))
    | _ -> raise (InvalidInputException "Expected parameter identifier")

  and parse_fun toks : token list * defn =
    let return_type =
      match lookahead toks with
      | Tok_Int_Type -> Int_Type
      | Tok_Bool_Type -> Bool_Type
      | _ -> raise (InvalidInputException "Expected function return type")
    in
    let toks =
      match lookahead toks with
      | Tok_Int_Type -> match_token toks Tok_Int_Type
      | Tok_Bool_Type -> match_token toks Tok_Bool_Type
      | _ -> raise (InvalidInputException "Expected function return type")
    in
    (match lookahead toks with
    | Tok_ID name ->
        let toks = match_token toks (Tok_ID name) in
        let toks = match_token toks Tok_LParen in
        let toks, params =
          if lookahead toks = Tok_RParen then (toks, [])
          else parse_param_list toks [] []
        in
        let toks = match_token toks Tok_RParen in
        let toks = match_token toks Tok_LBrace in
        let toks, body = parse_stmt toks in
        let toks = match_token toks Tok_RBrace in
        (toks, Fun (return_type, name, params, body))
    | _ -> raise (InvalidInputException "Expected function name"))

  and parse_main toks : token list * defn =
    let toks = match_token toks Tok_Int_Type in
    (match lookahead toks with
    | Tok_Main ->
        let toks = match_token toks Tok_Main in
        let toks = match_token toks Tok_LParen in
        let toks = match_token toks Tok_RParen in
        let toks = match_token toks Tok_LBrace in
        let toks, body = parse_stmt toks in
        let toks = match_token toks Tok_RBrace in
        (toks, Main body)
    | _ -> raise (InvalidInputException "Expected main"))

  and loop toks seen : token list * defn =
    match lookahead toks with
    | Tok_Int_Type ->
        let after_type = match_token toks Tok_Int_Type in
        (match lookahead after_type with
        | Tok_Main ->
            let toks, main_ast = parse_main toks in
            (toks, main_ast)
        | Tok_ID name ->
            let toks, fun_ast = parse_fun toks in
            (match fun_ast with
            | Fun (_, fname, _, _) ->
                if List.mem fname seen then raise (InvalidInputException "Function overloading is not permitted")
                else
                  let toks, rest = loop toks (fname :: seen) in
                  (toks, Multi (fun_ast, rest))
            | _ -> raise (InvalidInputException "Unexpected definition"))
        | _ -> raise (InvalidInputException "Expected function or main definition"))
    | _ -> raise (InvalidInputException "Expected function definition")
  in
  let toks, ast = loop toks [] in
  if lookahead toks = EOF then (toks, ast)
  else raise (InvalidInputException "Unexpected trailing tokens after main")

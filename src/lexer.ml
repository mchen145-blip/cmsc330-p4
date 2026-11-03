open TokenTypes

let whitespace = Re.Perl.compile_pat "[ \t\n\r]+"
let integer = Re.Perl.compile_pat "-?[0-9]+"
let identifier = Re.Perl.compile_pat "[a-zA-Z][a-zA-Z0-9]*"

let operators =
  List.map
    (fun (symbol, token) -> (Re.compile (Re.str symbol), token))
    [ "==", Tok_Equal;
      "!=", Tok_NotEqual;
      ">=", Tok_GreaterEqual;
      "<=", Tok_LessEqual;
      "&&", Tok_And;
      "||", Tok_Or;
      "=", Tok_Assign;
      ">", Tok_Greater;
      "<", Tok_Less;
      "!", Tok_Not;
      ";", Tok_Semi;
      ",", Tok_Comma;
      "(", Tok_LParen;
      ")", Tok_RParen;
      "{", Tok_LBrace;
      "}", Tok_RBrace;
      "+", Tok_Add;
      "-", Tok_Sub;
      "*", Tok_Mult;
      "/", Tok_Div;
      "^", Tok_Pow ]

let match_prefix regex source position =
  match Re.exec_opt ~pos:position regex source with
  | Some groups when Re.Group.start groups 0 = position ->
      Some (Re.Group.get groups 0, Re.Group.stop groups 0)
  | _ -> None

let keyword_token = function
  | "for" -> Some Tok_For
  | "from" -> Some Tok_From
  | "to" -> Some Tok_To
  | "while" -> Some Tok_While
  | "return" -> Some Tok_Return
  | "int" -> Some Tok_Int_Type
  | "bool" -> Some Tok_Bool_Type
  | "printf" -> Some Tok_Print
  | "main" -> Some Tok_Main
  | "if" -> Some Tok_If
  | "else" -> Some Tok_Else
  | "true" -> Some (Tok_Bool true)
  | "false" -> Some (Tok_Bool false)
  | _ -> None

let rec match_operator source position = function
  | [] -> None
  | (regex, token) :: rest ->
      (match match_prefix regex source position with
      | Some (_, next_position) -> Some (token, next_position)
      | None -> match_operator source position rest)

let tokenize (source : string) : token list =
  let length = String.length source in
  let rec scan position tokens =
    if position = length then List.rev (EOF :: tokens)
    else
      match match_prefix whitespace source position with
      | Some (_, next_position) -> scan next_position tokens
      | None -> scan_non_whitespace position tokens
  and scan_non_whitespace position tokens =
    match match_prefix integer source position with
    | Some (digits, next_position) ->
        let value =
          try int_of_string digits
          with Failure _ ->
            raise (InvalidInputException ("Integer literal out of range: " ^ digits))
        in
        scan next_position (Tok_Int value :: tokens)
    | None -> scan_identifier position tokens
  and scan_identifier position tokens =
    match match_prefix identifier source position with
    | Some (word, next_position) ->
        let token =
          match keyword_token word with
          | Some keyword -> keyword
          | None -> Tok_ID word
        in
        scan next_position (token :: tokens)
    | None -> scan_operator position tokens
  and scan_operator position tokens =
    match match_operator source position operators with
    | Some (token, next_position) -> scan next_position (token :: tokens)
    | None ->
        raise
          (InvalidInputException
             (Printf.sprintf "Invalid token at position %d: %c"
                position source.[position]))
  in
  scan 0 []

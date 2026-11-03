open TokenTypes
let tokenize (str : string) : token list =
  let len = String.length str in
  let is_space c = c = ' ' || c = '\t' || c = '\n' in
  let is_digit c = c >= '0' && c <= '9' in
  let is_letter c = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') in
  let is_letter_or_digit c = is_letter c || is_digit c in
  let keyword_token s =
    match s with
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
  in
  let rec tok pos acc =
    if pos >= len then List.rev (EOF :: acc)
    else if is_space str.[pos] then tok (pos + 1) acc
    else
      let rec read_ident i =
        if i < len && is_letter_or_digit str.[i] then read_ident (i + 1) else i
      in
      let read_int i =
        let rec loop j =
          if j < len && is_digit str.[j] then loop (j + 1) else j
        in
        if i < len && (str.[i] = '-' || is_digit str.[i]) then
          let j = if str.[i] = '-' then loop (i + 1) else loop i in
          if j > i && (str.[i] <> '-' || j > i + 1) then Some (String.sub str i (j - i), j)
          else None
        else None
      in
      let current = str.[pos] in
      let int_match = read_int pos in
      match int_match with
      | Some (num_str, next_pos) ->
          let tok_value = int_of_string num_str in
          tok next_pos (Tok_Int tok_value :: acc)
      | None ->
          let ident_end =
            if pos < len && is_letter current then Some (read_ident (pos + 1)) else None
          in
          (match ident_end with
          | Some end_pos ->
              let word = String.sub str pos (end_pos - pos) in
              (match keyword_token word with
              | Some kw -> tok end_pos (kw :: acc)
              | None -> tok end_pos (Tok_ID word :: acc))
          | None ->
              if pos + 1 < len then
                let two = String.sub str pos 2 in
                let three =
                  match two with
                  | "==" -> Some (Tok_Equal, pos + 2)
                  | "!=" -> Some (Tok_NotEqual, pos + 2)
                  | ">=" -> Some (Tok_GreaterEqual, pos + 2)
                  | "<=" -> Some (Tok_LessEqual, pos + 2)
                  | "&&" -> Some (Tok_And, pos + 2)
                  | "||" -> Some (Tok_Or, pos + 2)
                  | _ -> None
                in
                (match three with
                | Some (t, next_pos) -> tok next_pos (t :: acc)
                | None ->
                    let op =
                      match current with
                      | '=' -> Some (Tok_Assign, pos + 1)
                      | '>' -> Some (Tok_Greater, pos + 1)
                      | '<' -> Some (Tok_Less, pos + 1)
                      | '!' -> Some (Tok_Not, pos + 1)
                      | ';' -> Some (Tok_Semi, pos + 1)
                      | ',' -> Some (Tok_Comma, pos + 1)
                      | '(' -> Some (Tok_LParen, pos + 1)
                      | ')' -> Some (Tok_RParen, pos + 1)
                      | '{' -> Some (Tok_LBrace, pos + 1)
                      | '}' -> Some (Tok_RBrace, pos + 1)
                      | '+' -> Some (Tok_Add, pos + 1)
                      | '-' -> Some (Tok_Sub, pos + 1)
                      | '*' -> Some (Tok_Mult, pos + 1)
                      | '/' -> Some (Tok_Div, pos + 1)
                      | '^' -> Some (Tok_Pow, pos + 1)
                      | _ -> None
                    in
                    (match op with
                    | Some (t, next_pos) -> tok next_pos (t :: acc)
                    | None -> raise (InvalidInputException (Printf.sprintf "Invalid token at position %d: %c" pos current))))
              else
                let op =
                  match current with
                  | '=' -> Some (Tok_Assign, pos + 1)
                  | '>' -> Some (Tok_Greater, pos + 1)
                  | '<' -> Some (Tok_Less, pos + 1)
                  | '!' -> Some (Tok_Not, pos + 1)
                  | ';' -> Some (Tok_Semi, pos + 1)
                  | ',' -> Some (Tok_Comma, pos + 1)
                  | '(' -> Some (Tok_LParen, pos + 1)
                  | ')' -> Some (Tok_RParen, pos + 1)
                  | '{' -> Some (Tok_LBrace, pos + 1)
                  | '}' -> Some (Tok_RBrace, pos + 1)
                  | '+' -> Some (Tok_Add, pos + 1)
                  | '-' -> Some (Tok_Sub, pos + 1)
                  | '*' -> Some (Tok_Mult, pos + 1)
                  | '/' -> Some (Tok_Div, pos + 1)
                  | '^' -> Some (Tok_Pow, pos + 1)
                  | _ -> None
                in
                (match op with
                | Some (t, next_pos) -> tok next_pos (t :: acc)
                | None -> raise (InvalidInputException (Printf.sprintf "Invalid token at position %d: %c" pos current))))
  in
  tok 0 []


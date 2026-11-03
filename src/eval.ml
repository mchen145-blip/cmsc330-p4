open SmallCTypes
open Utils
open TokenTypes

exception TypeError of string
exception DeclareError of string
exception DivByZeroError

let rec type_of_value = function
  | Int_Val _ -> Int_Type
  | Bool_Val _ -> Bool_Type

let lookup_binding env name =
  match List.assoc_opt name env.bindings with
  | Some v -> v
  | None -> raise (DeclareError ("Undefined variable: " ^ name))

let lookup_defn env name =
  match List.assoc_opt name env.defns with
  | Some d -> d
  | None -> raise (DeclareError ("Undefined function: " ^ name))

let boolean_of_value = function
  | Bool_Val b -> b
  | _ -> raise (TypeError "Expected boolean value")

let int_of_value = function
  | Int_Val i -> i
  | _ -> raise (TypeError "Expected integer value")

let rec eval_expr env t =
  match t with
  | Int i -> Int_Val i
  | Bool b -> Bool_Val b
  | ID name -> lookup_binding env name
  | Add (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Int_Val a, Int_Val b -> Int_Val (a + b)
      | _ -> raise (TypeError "Add requires integer operands"))
  | Sub (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Int_Val a, Int_Val b -> Int_Val (a - b)
      | _ -> raise (TypeError "Sub requires integer operands"))
  | Mult (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Int_Val a, Int_Val b -> Int_Val (a * b)
      | _ -> raise (TypeError "Mult requires integer operands"))
  | Div (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Int_Val a, Int_Val b ->
          if b = 0 then raise DivByZeroError
          else Int_Val (a / b)
      | _ -> raise (TypeError "Div requires integer operands"))
  | Pow (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Int_Val a, Int_Val b ->
          let result =
            if b < 0 then
              if a = 0 then raise DivByZeroError
              else if a = 1 then 1
              else if a = -1 then if b mod 2 = 0 then 1 else -1
              else if a < 0 && b mod 2 <> 0 then -1
              else 0
            else
              let rec power base exponent accumulator =
                if exponent = 0 then accumulator
                else
                  let next_accumulator =
                    if exponent mod 2 = 0 then accumulator
                    else accumulator * base
                  in
                  power (base * base) (exponent / 2) next_accumulator
              in
              power a b 1
          in
          Int_Val result
      | _ -> raise (TypeError "Pow requires integer operands"))
  | Greater (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Int_Val a, Int_Val b -> Bool_Val (a > b)
      | _ -> raise (TypeError "Greater requires integer operands"))
  | Less (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Int_Val a, Int_Val b -> Bool_Val (a < b)
      | _ -> raise (TypeError "Less requires integer operands"))
  | GreaterEqual (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Int_Val a, Int_Val b -> Bool_Val (a >= b)
      | _ -> raise (TypeError "GreaterEqual requires integer operands"))
  | LessEqual (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Int_Val a, Int_Val b -> Bool_Val (a <= b)
      | _ -> raise (TypeError "LessEqual requires integer operands"))
  | Equal (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Int_Val a, Int_Val b -> Bool_Val (a = b)
      | Bool_Val a, Bool_Val b -> Bool_Val (a = b)
      | _ -> raise (TypeError "Equal requires operands of the same type"))
  | NotEqual (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Int_Val a, Int_Val b -> Bool_Val (a <> b)
      | Bool_Val a, Bool_Val b -> Bool_Val (a <> b)
      | _ -> raise (TypeError "NotEqual requires operands of the same type"))
  | Or (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Bool_Val a, Bool_Val b -> Bool_Val (a || b)
      | _ -> raise (TypeError "Or requires boolean operands"))
  | And (left, right) ->
      let lv = eval_expr env left in
      let rv = eval_expr env right in
      (match lv, rv with
      | Bool_Val a, Bool_Val b -> Bool_Val (a && b)
      | _ -> raise (TypeError "And requires boolean operands"))
  | Not inner ->
      (match eval_expr env inner with
      | Bool_Val b -> Bool_Val (not b)
      | _ -> raise (TypeError "Not requires a boolean operand"))
  | Call (name, args) ->
      let (ret_type, params, body) = lookup_defn env name in
      if List.length args <> List.length params then
        raise (TypeError ("Function " ^ name ^ " expects " ^ string_of_int (List.length params) ^ " arguments"))
      else
        let rec evaluate_args = function
          | [] -> []
          | arg :: rest ->
              let value = eval_expr env arg in
              value :: evaluate_args rest
        in
        let evaluated_args = evaluate_args args in
        let checked_pairs =
          List.map2 (fun (param_name, param_type) arg_val ->
            let actual_type = type_of_value arg_val in
            if actual_type = param_type then (param_name, arg_val)
            else raise (TypeError ("Function argument type mismatch for " ^ param_name)))
            params evaluated_args
        in
        let call_bindings = checked_pairs in
        let call_env = { env with bindings = call_bindings } in
        let after_call = eval_stmt call_env body in
        (match List.assoc_opt "return" after_call.bindings with
        | Some (Int_Val _ as v) when ret_type = Int_Type -> v
        | Some (Bool_Val _ as v) when ret_type = Bool_Type -> v
        | Some _ -> raise (TypeError ("Function " ^ name ^ " return type mismatch"))
        | None -> raise (DeclareError ("Function " ^ name ^ " did not return")))

and eval_stmt env s =
  match s with
  | NoOp -> env
  | Seq (left, right) -> eval_stmt (eval_stmt env left) right
  | Declare (typ, name) ->
      if List.mem_assoc name env.bindings then
        raise (DeclareError ("Variable already declared: " ^ name))
      else
        let init =
          match typ with
          | Int_Type -> Int_Val 0
          | Bool_Type -> Bool_Val false
        in
        { env with bindings = (name, init) :: env.bindings }
  | Assign (name, expr) ->
      (match List.assoc_opt name env.bindings with
      | None -> raise (DeclareError ("Undefined variable: " ^ name))
      | Some current_value ->
          let new_value = eval_expr env expr in
          if type_of_value current_value = type_of_value new_value then
            { env with bindings = (name, new_value) :: List.remove_assoc name env.bindings }
          else
            raise (TypeError ("Assignment type mismatch for " ^ name)))
  | If (guard, then_stmt, else_stmt) ->
      (match eval_expr env guard with
      | Bool_Val true -> eval_stmt env then_stmt
      | Bool_Val false -> eval_stmt env else_stmt
      | _ -> raise (TypeError "If guard must evaluate to a boolean"))
  | For (name, start_expr, end_expr, body) ->
      let start_val = eval_expr env start_expr in
      let end_val = eval_expr env end_expr in
      (match start_val, end_val with
      | Int_Val start_i, Int_Val end_i ->
          let rec loop current_env current =
            if current > end_i then
              { current_env with
                bindings = (name, Int_Val current) :: List.remove_assoc name current_env.bindings }
            else
              let bound_env =
                { current_env with
                  bindings = (name, Int_Val current) :: List.remove_assoc name current_env.bindings }
              in
              let after_body = eval_stmt bound_env body in
              let next_value =
                match List.assoc_opt name after_body.bindings with
                | Some (Int_Val v) -> v + 1
                | Some _ -> raise (TypeError ("For loop variable must be an integer: " ^ name))
                | None -> raise (DeclareError ("Loop variable was lost: " ^ name))
              in
              let updated_env =
                { after_body with
                  bindings = (name, Int_Val next_value) :: List.remove_assoc name after_body.bindings }
              in
              loop updated_env next_value
          in
          loop env start_i
      | _ -> raise (TypeError "For loop bounds must be integers"))
  | While (guard, body) ->
      (match eval_expr env guard with
      | Bool_Val true ->
          let after_body = eval_stmt env body in
          eval_stmt after_body s
      | Bool_Val false -> env
      | _ -> raise (TypeError "While guard must evaluate to a boolean"))
  | Print expr ->
      (match eval_expr env expr with
      | Int_Val v ->
          let () = print_output_int v in
          let () = print_output_newline () in
          env
      | Bool_Val b ->
          let () = print_output_bool b in
          let () = print_output_newline () in
          env)
  | Return expr ->
      let value = eval_expr env expr in
      { env with bindings = ("return", value) :: env.bindings }

let rec eval env d =
  match d with
  | Multi (left, right) -> eval (eval env left) right
  | Fun (ret_type, name, params, body) ->
      if List.mem_assoc name env.defns then
        raise (DeclareError ("Function already defined: " ^ name))
      else
        { env with defns = (name, (ret_type, params, body)) :: env.defns }
  | Main body -> eval_stmt env body

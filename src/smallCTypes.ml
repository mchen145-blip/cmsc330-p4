type data_type =
  | Int_Type
  | Bool_Type
  [@@deriving show { with_path = false }]

type expr =
  | ID of string
  | Int of int
  | Bool of bool
  | Add of expr * expr
  | Sub of expr * expr
  | Mult of expr * expr
  | Div of expr * expr
  | Pow of  expr * expr
  | Greater of expr * expr
  | Less of expr * expr
  | GreaterEqual of expr * expr
  | LessEqual of expr * expr
  | Equal of expr * expr
  | NotEqual of expr * expr
  | Or of expr * expr
  | And of expr * expr
  | Not of expr
  | Call of string * expr list            (* function call *)
  [@@deriving show { with_path = false }]

(* we still end up needing NoOp here *)
type stmt =
  | NoOp                                  (* For parser termination *)
  | Seq of stmt * stmt                    (* True sequencing instead of lists *)
  | Declare of data_type * string         (* Here the expr must be an id but students don't know polymorphic variants *)
  | Assign of string * expr               (* Again, LHS must be an ID *)
  | If of expr * stmt * stmt              (* If guard is an expr, body of each block is a stmt *)
  | For of string * expr * expr * stmt    (* String is a variable, ints represent ranges of binding, body is a stmt *)
  | While of expr * stmt                  (* Guard is an expr, body is a stmt *)
  | Print of expr                         (* Print the result of an expression *)
  | Return of expr                        (* Return an expression or an ID (binding) *)
  [@@deriving show { with_path = false }]

(* top-level definitions *)
(* fun needs to be here to prevent nested functions *)
(* this does not stop you from having two mains lol *)
type defn = 
  | Multi of defn * defn                                          (* multiple definitions in file *)
  | Fun of data_type * string * (string * data_type) list * stmt  (* return type, name, body *)
  | Main of stmt                                                  (* main only has a body. should denote end of file *)
  [@@deriving show { with_path = false }]

type value = 
  | Int_Val of int
  | Bool_Val of bool
  [@@deriving show { with_path = false }]
(* can store functions in environment too *)
type environment = {
  defns: (string * (data_type * (string * data_type) list * stmt)) list;
  bindings: (string * value) list
} [@@deriving show { with_path = false }]

open P4
open SmallCTypes
open TestUtils
open Lexer
open Parser
open Eval
open Utils

(**********************************
 *           Parse Tests          *
 **********************************)

let parse_assign1 = create_system_test ["assign1.c"]
  (Main(Seq (Seq (Declare (Int_Type, "a"), Seq (Assign ("a", Int 100), NoOp)), Return (ID "a"))))
let parse_assign_exp = create_system_test ["assign-exp.c"]
  (Main
  (Seq
    (Seq (Declare (Int_Type, "a"),
      Seq (Assign ("a", Mult (Int 100, ID "a")), Seq (Print (ID "a"), NoOp))),
    Return (ID "a"))))
let parse_define1 = create_system_test ["define1.c"]
  (Main (Seq (Seq (Declare (Int_Type, "a"), NoOp), Return (ID "a"))))
let parse_equal = create_system_test ["equal.c"]
  (Main
  (Seq
    (Seq (Declare (Int_Type, "a"),
      Seq (Assign ("a", Int 100),
       Seq
        (If (Equal (ID "a", Int 100),
          Seq (Assign ("a", Int 200), Seq (Print (ID "a"), NoOp)), NoOp),
        NoOp))),
    Return (ID "a"))))
let parse_exp1 = create_system_test ["exp1.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Add (Int 2, Mult (Int 5, Pow (Int 4, Int 3)))),
      Seq (Print (ID "a"), NoOp))),
   Return (ID "a"))))
let parse_exp2 = create_system_test ["exp2.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Add (Int 2, Pow (Mult (Int 5, Int 4), Int 3))),
      Seq (Print (ID "a"), NoOp))),
   Return (ID "a"))))
let parse_greater = create_system_test ["greater.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Int 100),
      Seq
       (If (Greater (ID "a", Int 10),
         Seq (Assign ("a", Int 200), Seq (Print (ID "a"), NoOp)), NoOp),
       NoOp))),
   Return (ID "a"))))
let parse_if = create_system_test ["if.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Int 100),
      Seq
       (If (Greater (ID "a", Int 10), Seq (Assign ("a", Int 200), NoOp), NoOp),
       NoOp))),
   Return (ID "a"))))
let parse_ifelse = create_system_test ["ifelse.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Int 100),
      Seq
       (If (Greater (ID "a", Int 10), Seq (Assign ("a", Int 200), NoOp),
         Seq (Assign ("a", Int 300), NoOp)),
       NoOp))),
   Return (ID "a"))))
let parse_if_else_while = create_system_test ["if-else-while.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Int 100),
      Seq (Declare (Int_Type, "b"),
       Seq
        (If (Greater (ID "a", Int 10), Seq (Assign ("a", Int 200), NoOp),
          Seq (Assign ("b", Int 10),
           Seq
            (While (Less (Mult (ID "b", Int 2), ID "a"),
              Seq (Assign ("b", Add (ID "b", Int 2)),
               Seq (Print (ID "b"), NoOp))),
            Seq (Assign ("a", Int 300), NoOp)))),
        NoOp)))),
   Return (ID "a"))))
let parse_less = create_system_test ["less.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Int 100),
      Seq
       (If (Less (ID "a", Int 200),
         Seq (Assign ("a", Int 200), Seq (Print (ID "a"), NoOp)), NoOp),
       NoOp))),
   Return (ID "a"))))
let parse_main = create_system_test ["main.c"]
  (Main (Seq (NoOp, Return (Int 0))))
let parse_nested_if = create_system_test ["nested-if.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Int 100),
      Seq
       (If (Greater (ID "a", Int 10),
         Seq (Assign ("a", Int 200),
          Seq
           (If (Less (ID "a", Int 20), Seq (Assign ("a", Int 300), NoOp),
             Seq (Assign ("a", Int 400), NoOp)),
           NoOp)),
         NoOp),
       NoOp))),
   Return (ID "a"))))

let parse_nested_while = create_system_test ["nested-while.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "i"),
     Seq (Declare (Int_Type, "j"),
      Seq (Assign ("i", Int 1),
       Seq (Declare (Int_Type, "sum"),
        Seq (Assign ("sum", Int 0),
         Seq
          (While (Less (ID "i", Int 10),
            Seq (Assign ("j", Int 1),
             Seq
              (While (Less (ID "j", Int 10),
                Seq (Assign ("sum", Add (ID "sum", ID "j")),
                 Seq (Assign ("j", Add (ID "j", Int 1)), NoOp))),
              Seq (Assign ("i", Add (ID "i", Int 1)), NoOp)))),
          NoOp)))))),
   Return (ID "sum"))))
let parse_print = create_system_test ["print.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Int 100), Seq (Print (ID "a"), NoOp))),
   Return (ID "a"))))
let parse_test1 = create_system_test ["test1.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Int 10),
      Seq (Declare (Int_Type, "b"),
       Seq (Assign ("b", Int 1),
        Seq (Declare (Int_Type, "sum"),
         Seq (Assign ("sum", Int 0),
          Seq
           (While (Less (ID "b", ID "a"),
             Seq (Assign ("sum", Add (ID "sum", ID "b")),
              Seq (Assign ("b", Add (ID "b", Int 1)),
               Seq (Print (ID "sum"),
                Seq
                 (If (Greater (ID "a", ID "b"), Seq (Print (Int 10), NoOp),
                   Seq (Print (Int 20), NoOp)),
                 Seq (Print (ID "sum"), NoOp)))))),
           NoOp))))))),
   Return (ID "a"))))
let parse_test2 = create_system_test ["test2.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Int 10),
      Seq (Declare (Int_Type, "b"),
       Seq (Assign ("b", Int 20),
        Seq (Declare (Int_Type, "c"),
         Seq
          (If (Less (ID "a", ID "b"),
            Seq
             (If (Less (Pow (ID "a", Int 2), Pow (ID "b", Int 3)),
               Seq (Print (ID "a"), NoOp), Seq (Print (ID "b"), NoOp)),
             NoOp),
            Seq (Assign ("c", Int 1),
             Seq
              (While (Less (ID "c", ID "a"),
                Seq (Print (ID "c"),
                 Seq (Assign ("c", Add (ID "c", Int 1)), NoOp))),
              NoOp))),
          NoOp)))))),
   Return (ID "a"))))
let parse_test3 = create_system_test ["test3.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Int 10),
      Seq (Declare (Int_Type, "b"),
       Seq (Assign ("b", Int 2),
        Seq (Declare (Int_Type, "c"),
         Seq (Assign ("c", Add (ID "a", Mult (ID "b", Pow (Int 3, Int 3)))),
          Seq (Print (Equal (ID "c", Int 1)), NoOp))))))),
   Return (Int 100))))
let parse_test4 = create_system_test ["test4.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "x"),
     Seq (Declare (Int_Type, "y"),
      Seq (Declare (Int_Type, "a"),
       Seq (While (Equal (ID "x", ID "y"), Seq (Assign ("a", Int 100), NoOp)),
        Seq
         (If (Equal (ID "a", ID "b"), Seq (Print (Int 20), NoOp),
           Seq (Print (Int 10), NoOp)),
         NoOp))))),
   Return (ID "a"))))
let parse_assoc1 = create_system_test ["test-assoc1.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Add (Int 2, Add (Int 3, Int 4))),
      Seq (Declare (Int_Type, "b"),
       Seq (Assign ("b", Mult (Int 2, Mult (Int 3, Int 4))),
        Seq (Declare (Int_Type, "c"),
         Seq (Assign ("c", Pow (Int 2, Pow (Int 3, Int 4))),
          Seq (Declare (Int_Type, "d"),
           Seq
            (If (Greater (Int 5, Greater (Int 6, Int 1)),
              Seq (Print (Int 10), NoOp), NoOp),
            Seq (Print (ID "a"),
             Seq (Print (ID "b"), Seq (Print (ID "c"), NoOp))))))))))),
   Return (Int 100))))
let parse_while = create_system_test ["while.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (Assign ("a", Int 10),
      Seq (Declare (Int_Type, "b"),
       Seq (Assign ("b", Int 1),
        Seq
         (While (Less (ID "b", ID "a"),
           Seq (Print (ID "b"), Seq (Assign ("b", Add (ID "b", Int 2)), NoOp))),
         NoOp))))),
   Return (Int 67))))
let parse_for = create_system_test ["for.c"]
  (Main
  (Seq
   (Seq (Declare (Int_Type, "a"),
     Seq (For ("a", Int 1, Int 10, Seq (Print (ID "a"), NoOp)), NoOp)),
   Return (ID "a"))))

(**********************************
 *        Evaluator Tests         *
 **********************************)

let env1 = 
{
  defns = [];
  bindings = [("var1", Int_Val 4); ("var2", Bool_Val false)];
}

let eval_expr_basic _ =
  let i = 5 in assert_equal (Int_Val i) (eval_expr {defns = []; bindings = [];} (Int i));
  let i = (-10) in assert_equal (Int_Val i) (eval_expr {defns = []; bindings = [];} (Int i));
  assert_equal (Bool_Val true) (eval_expr env1 (Bool true));
  assert_equal (Bool_Val false) (eval_expr env1 (Bool false));
  assert_equal (Int_Val 4) (eval_expr env1 (ID "var1"));
  assert_equal (Bool_Val false) (eval_expr env1 (ID "var2"))

let eval_expr_ops _ =
  assert_equal (Int_Val 8) (eval_expr env1 (Add ((ID "var1"), (Int 4))));
  assert_equal (Int_Val (-2)) (eval_expr env1 (Add ((ID "var1"), (Int (-6)))));
  assert_equal (Int_Val 42) (eval_expr {defns = []; bindings = [];} (Sub (Int 50, Int 8)));
  assert_equal (Int_Val (-2)) (eval_expr env1 (Sub (ID "var1", Int 6)));
  assert_equal (Int_Val 64) (eval_expr {defns = []; bindings = [];} (Mult (Int 8, Int 8)));
  assert_equal (Int_Val (-10)) (eval_expr {defns = []; bindings = [];} (Mult (Int 5, Int (-2))));
  assert_equal (Int_Val 10) (eval_expr {defns = []; bindings = [];} (Div (Int 70, Int 7)));
  assert_equal (Int_Val (50/3)) (eval_expr {defns = []; bindings = [];} (Div (Int 50, Int 3)));
  assert_equal (Int_Val 9) (eval_expr {defns = []; bindings = [];} (Pow (Int 3, Int 2)));

  assert_equal (Bool_Val true) (eval_expr {defns = []; bindings = [];} (Or (Bool false, Bool true)));
  assert_equal (Bool_Val false) (eval_expr env1 (Or (Bool false, ID "var2")));
  assert_equal (Bool_Val false) (eval_expr {defns = []; bindings = [];} (And (Bool false, Bool true)));
  assert_equal (Bool_Val true) (eval_expr {defns = []; bindings = [];} (And (Bool true, Bool true)));
  assert_equal (Bool_Val true) (eval_expr {defns = []; bindings = [];} (Not (Bool false)));
  assert_equal (Bool_Val false) (eval_expr {defns = []; bindings = [];} (Not (Bool true)));

  assert_equal (Bool_Val false) (eval_expr env1 (Equal (ID "var1", Int 10)));
  assert_equal (Bool_Val true) (eval_expr env1 (Equal (ID "var2", Bool false)));
  assert_equal (Bool_Val true) (eval_expr env1 (NotEqual (ID "var1", Int 10)));
  assert_equal (Bool_Val false) (eval_expr env1 (NotEqual (ID "var2", ID "var2")));

  assert_equal (Bool_Val true) (eval_expr env1 (Greater (ID "var1", Int 2)));
  assert_equal (Bool_Val false) (eval_expr env1 (Greater (Int 2, ID "var1")));
  assert_equal (Bool_Val true) (eval_expr env1 (Less (ID "var1", Int 10)));
  assert_equal (Bool_Val false) (eval_expr env1 (Less (ID "var1", Int 2)));
  assert_equal (Bool_Val true) (eval_expr {defns = []; bindings = [];} (GreaterEqual (Int 0, Int 0)));
  assert_equal (Bool_Val false) (eval_expr {defns = []; bindings = [];} (GreaterEqual (Int 0, Int 1)));
  assert_equal (Bool_Val false) (eval_expr {defns = []; bindings = [];} (LessEqual (Int 1, Int 0)))

let eval_expr_fail _ =
  assert_eval_expr_fail expr_env "1 + p";
  assert_eval_expr_fail expr_env "false * y";
  assert_eval_expr_fail expr_env "q - 1";
  assert_eval_expr_fail expr_env "y / false";
  assert_eval_expr_fail expr_env "x ^ true";
  assert_eval_expr_fail expr_env "1 || q";
  assert_eval_expr_fail expr_env "p && 0";
  assert_eval_expr_fail expr_env "!x";
  assert_eval_expr_fail expr_env "x > p";
  assert_eval_expr_fail expr_env "q < y";
  assert_eval_expr_fail expr_env "q >= x";
  assert_eval_expr_fail expr_env "x <= q";
  assert_eval_expr_fail expr_env "p == x";
  assert_eval_expr_fail expr_env "p != x";
  assert_eval_expr_fail expr_env "x + (y + true)";
  assert_eval_expr_fail expr_env "(x * false) * y";
  assert_eval_expr_fail expr_env "x - (false - 1)";
  assert_eval_expr_fail expr_env "y / (true / x)";
  assert_eval_expr_fail expr_env "x ^ (false ^ y)";
  assert_eval_expr_fail expr_env "(q || 1) || p";
  assert_eval_expr_fail expr_env "q && (1 && q)";
  assert_eval_expr_fail expr_env "!p && !1";
  assert_eval_expr_fail expr_env "p == (y > false)";
  assert_eval_expr_fail expr_env "q && (true < y)";
  assert_eval_expr_fail expr_env "(y >= true) || q";
  assert_eval_expr_fail expr_env "(x <= true) != q";
  assert_eval_expr_fail expr_env "(x == false) == q";
  assert_eval_expr_fail expr_env "(y == true) == p"

(* Simple sequence *)
let eval_stmt_basic _ =
  let env = 
  {
    defns = [];
    bindings = [("a", Bool_Val true); ("b", Int_Val 7)];
  }
  in
  assert_stmt_success env {defns = []; bindings = [("return", Int_Val 0); ("a", Bool_Val true); ("b", Int_Val 7)]} "int main(){return 0;}";
  assert_stmt_success { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 0); ("a", Int_Val 0); ("b", Int_Val 0); ("x", Bool_Val false); ("y", Bool_Val false)]; } "int main() {int a;int b;bool x; bool y;return 0;}";
  assert_stmt_success { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 0); ("a", Int_Val 0)]; } "int main() {int a; printf(a);return a;}"
    ~output:"0\n";
  assert_stmt_success { defns = []; bindings = []; } { defns = []; bindings = [("return", Bool_Val false); ("a", Bool_Val false)]; } "int main() {bool a; printf(a);return a;}"
    ~output:"false\n"

(* Simple if true and if false *)
let eval_stmt_control _ =
  assert_stmt_success { defns = []; bindings = [("a", Bool_Val true)]; } { defns = []; bindings = [("return", Int_Val 5); ("a", Bool_Val true); ("b", Int_Val 5)]; } "int main() {int b;if(a) { b=5;} else { b=10;}return b;}";
  assert_stmt_success { defns = []; bindings = [("a", Bool_Val false)]; } { defns = []; bindings = [("return", Int_Val 10); ("a", Bool_Val false); ("b", Int_Val 10)]; } "int main() {int b;if(a) { b=5;} else { b=10;} return b;}"

(* Simple define int/ bool - test defaults *)
let eval_define_1 = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 0); ("a", Int_Val 0)]; } ["define1.c"]
let eval_define_2 = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Bool_Val false); ("a", Bool_Val false)]; } ["define2.c"]

(* Simple assign int/bool/exp*)
let eval_assign_1 = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 100); ("a", Int_Val 100)]; } ["assign1.c"]
let eval_assign_2 = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Bool_Val true); ("a", Bool_Val true)]; } ["assign2.c"]
let eval_assign_exp = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 0); ("a", Int_Val 0)]; } ["assign-exp.c"]
    ~output:"0\n"

(* equal & not equal & less *)
let eval_notequal = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 100); ("a", Int_Val 100)]; } ["notequal.c"]
    ~output:"100\n"
let eval_equal = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 200); ("a", Int_Val 200)]; } ["equal.c"]
    ~output:"200\n"
let eval_less = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 200); ("a", Int_Val 200)]; } ["less-eval.c"]
    ~output:"200\n"

(* Some expressions *)
let eval_exp_1 = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 322); ("a", Int_Val 322)]; } ["exp1.c"]
    ~output:"322\n"
let eval_exp_2 = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 8002); ("a", Int_Val 8002)]; } ["exp2.c"]
    ~output:"8002\n"
let eval_exp_3 = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val (-1)); ("a", Int_Val (-1))] ; } ["exp3.c"]
    ~output:"-1\n"

(* If/ Else/ While *)
let eval_ifelse = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 200); ("a", Int_Val 200)]; } ["ifelse.c"]
let eval_if_else_while = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 200); ("b", Int_Val 0);("a", Int_Val 200)]; } ["if-else-while.c"]
let eval_while = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 67); ("a", Int_Val 10); ("b", Int_Val 11)]; } ["while.c"]
                   ~output:"1\n3\n5\n7\n9\n"
let eval_for = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 41); ("a", Int_Val 51); ("b", Int_Val 41)]; } ["for-eval.c"]

(* NoOp *)
let eval_main = create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 0)]; } ["main.c"]

(* More Comprehensive *)
let eval_test_1 = 
  create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 10); ("a", Int_Val 10);("sum", Int_Val 45); ("b", Int_Val 10)]; } ["test1.c"]
    ~output:"1\n10\n1\n3\n10\n3\n6\n10\n6\n10\n10\n10\n15\n10\n15\n21\n10\n21\n28\n10\n28\n36\n10\n36\n45\n20\n45\n"
let eval_test_2 = 
  create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 10); ("a", Int_Val 10);("c", Int_Val 0); ("b", Int_Val 20)]; } ["test2.c"]
    ~output:"10\n"
let eval_test_3 = 
  create_eval_system_test { defns = []; bindings = []; } { defns = []; bindings = [("return", Int_Val 100); ("a", Int_Val 10);("c", Int_Val 64); ("b", Int_Val 2)]; } ["test3-eval.c"]
    ~output:"64\nfalse\n"

let eval_fun_max = create_eval_system_test
  { defns = []; bindings = [] }
  {defns =
  [("max",
    (Int_Type, [("a", Int_Type); ("b", Int_Type)],
     Seq
      (Seq (Declare (Int_Type, "result"),
        Seq
         (If (Greater (ID "a", ID "b"), Seq (Assign ("result", ID "a"), NoOp),
           Seq (Assign ("result", ID "b"), NoOp)),
         NoOp)),
      Return (ID "result"))))];
    bindings = [("return", Int_Val 17)]}
  ["rfmax.c"]

let eval_ill_typed_func = create_eval_system_test {defns=[]; bindings=[]} {defns =
  [("f",
    (Int_Type, [("x", Int_Type)], Seq (NoOp, Return (Greater (ID "x", Int 1)))))];
 bindings = [("return", Int_Val 5); ("a", Int_Val 5); ("a", Int_Val 0)]} ["ill-typed-fun.c"]

let eval_stmt_fail_basic _ =
  assert_eval_stmt_fail stmt_env "printf((x + y) > false); return 67;" ~expect:DeclareExpect;
  assert_eval_stmt_fail stmt_env "printf(!(p || q)); return 67;" ~expect:DeclareExpect;
  assert_eval_stmt_fail stmt_env "int y; int x; return 67;" ~expect:DeclareExpect;
  assert_eval_stmt_fail stmt_env "bool q; bool p; return 67;" ~expect:DeclareExpect;
  assert_eval_stmt_fail stmt_env "int y; bool x; return 67;" ~expect:DeclareExpect;
  assert_eval_stmt_fail stmt_env "bool q; int p; return 67;" ~expect:DeclareExpect;
  assert_eval_stmt_fail stmt_env "x = false; return 67;";
  assert_eval_stmt_fail expr_env "x = y + (p && q); return 67;";
  assert_eval_stmt_fail stmt_env "y = 1; return 67;" ~expect:DeclareExpect;
  assert_eval_stmt_fail expr_env "x = (y + x) > z; return 67;" ~expect:DeclareExpect;
  assert_eval_stmt_fail stmt_env "p = 1; return 67;";
  assert_eval_stmt_fail expr_env "q = p || (x && q); return 67;";
  assert_eval_stmt_fail stmt_env "q = false; return 67;" ~expect:DeclareExpect;
  assert_eval_stmt_fail expr_env "q = q || !(p && r); return 67;" ~expect:DeclareExpect

let eval_stmt_fail_control _ =
  assert_eval_stmt_fail stmt_env "if (0) {x = 0;} else {x = 1;} return -1;";
  assert_eval_stmt_fail stmt_env "if (p || q) {x = 0;} else {x = 1;} return -1;" ~expect:DeclareExpect;
  assert_eval_stmt_fail expr_env "if (x / (y * 2)) {x = 0;} else {x = 1;} return -1;";
  assert_eval_stmt_fail stmt_env "if (true) {printf(!p); p = !(p && q);} else {x = x - x;} return -1;" ~expect:DeclareExpect;
  assert_eval_stmt_fail expr_env "if (false) {x = y * y;} else {printf(x * (p && x)); x = 1;} return -1;";
  assert_eval_stmt_fail stmt_env "if (false) {p = !p;} else {x = (x * x) / y; printf(x);} return -1;" ~expect:DeclareExpect;
  assert_eval_stmt_fail stmt_env "while (0) {x = x + 1;} return -1;";
  assert_eval_stmt_fail stmt_env "while ((p || q) !=  false) {x = x + 1;} return -1;" ~expect:DeclareExpect;
  assert_eval_stmt_fail expr_env "while (x - (x + y)) {x = x + 1; printf(x * x);} return -1;";
  assert_eval_stmt_fail expr_env "while (true) {p = p && q; printf(x + (p < q));} return -1;"

let suite =
  let open Alcotest in
  [
    ( "parse", 
      [ 
        test_case "parse_assign1" `Quick parse_assign1; 
        test_case "parse_assign_exp" `Quick parse_assign_exp;
        test_case "parse_define1" `Quick parse_define1;
        test_case "parse_equal" `Quick parse_equal;
        test_case "parse_exp1" `Quick parse_exp1;
        test_case "parse_exp2" `Quick parse_exp2;
        test_case "parse_greater" `Quick parse_greater;
        test_case "parse_if" `Quick parse_if;
        test_case "parse_ifelse" `Quick parse_ifelse;
        test_case "parse_if_else_while" `Quick parse_if_else_while;
        test_case "parse_less" `Quick parse_less;
        test_case "parse_main" `Quick parse_main;
        test_case "parse_nested_if" `Quick parse_nested_if;
        test_case "parse_nested_while" `Quick parse_nested_while;
        test_case "parse_print" `Quick parse_print;
        test_case "parse_test1" `Quick parse_test1;
        test_case "parse_test2" `Quick parse_test2;
        test_case "parse_test3" `Quick parse_test3;
        test_case "parse_test4" `Quick parse_test4;
        test_case "parse_assoc1" `Quick parse_assoc1;
        test_case "parse_while" `Quick parse_while;
        test_case "parse_for" `Quick parse_for;
      ] 
    ); 
    ( "eval", 
      [ 
        test_case "eval_expr_basic"        `Quick eval_expr_basic;
        test_case "eval_expr_ops"          `Quick eval_expr_ops;
        test_case "eval_expr_fail"         `Quick eval_expr_fail;
        test_case "eval_stmt_basic"        `Quick eval_stmt_basic;
        test_case "eval_stmt_control"      `Quick eval_stmt_control;
        test_case "eval_define_1"          `Quick eval_define_1;
        test_case "eval_define_2"          `Quick eval_define_2;
        test_case "eval_assign_1"          `Quick eval_assign_1;
        test_case "eval_assign_2"          `Quick eval_assign_2;
        test_case "eval_assign_exp"        `Quick eval_assign_exp;
        test_case "eval_notequal"          `Quick eval_notequal;
        test_case "eval_equal"             `Quick eval_equal;
        test_case "eval_less"              `Quick eval_less;
        test_case "eval_exp_1"             `Quick eval_exp_1;
        test_case "eval_exp_2"             `Quick eval_exp_2;
        test_case "eval_exp_3"             `Quick eval_exp_3;
        test_case "eval_ifelse"            `Quick eval_ifelse;
        test_case "eval_if_else_while"     `Quick eval_if_else_while;
        test_case "eval_while"             `Quick eval_while;
        test_case "eval_for"               `Quick eval_for;
        test_case "eval_main"              `Quick eval_main;
        test_case "eval_test_1"            `Quick eval_test_1;
        test_case "eval_test_2"            `Quick eval_test_2;
        test_case "eval_test_3"            `Quick eval_test_3;
        test_case "eval_fun_max"           `Quick eval_fun_max;
        test_case "eval_ill_typed_func"    `Quick eval_ill_typed_func;
      ] 
    ); 
    ( "eval_fail" , 
    [ 
      test_case "eval_stmt_fail_basic" `Quick eval_stmt_fail_basic;
      test_case "eval_stmt_fail_control" `Quick eval_stmt_fail_control
    ] 
    )
  ]

let () =
  Alcotest.run "public" suite
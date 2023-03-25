import Data.Maybe
import Data.Fixed (E1)
import Distribution.Simple.Utils (xargs)

data Expr0
  = E0Cst Int
  | E0Add Expr0 Expr0
  | E0Mul Expr0 Expr0

evalExpr0 :: Expr0 -> Int
evalExpr0 (E0Cst i) = i
evalExpr0 (E0Add a b) = evalExpr0 a + evalExpr0 b
evalExpr0 (E0Mul a b) = evalExpr0 a * evalExpr0 b

expr0Instance = E0Mul (E0Add (E0Cst 1) (E0Cst 2)) (E0Cst 3)
test1 = evalExpr0 expr0Instance

data Instr0
  = I0Cst Int
  | I0Add
  | I0Mul
type Instr0s = [Instr0]
type I0Stack = [Int]

evalInstr0 :: Instr0s -> I0Stack -> Int
evalInstr0 (I0Cst i : is) s = evalInstr0 is $ i : s
evalInstr0 (I0Add : is) (a : b : s) = evalInstr0 is $ (a + b) : s
evalInstr0 (I0Mul : is) (a : b : s) = evalInstr0 is $ (a * b) : s
evalInstr0 [] [s] = s
evalInstr0 _ _ = undefined

test2 = evalInstr0 [I0Cst 1, I0Cst 2, I0Add, I0Cst 3, I0Mul] []

compileE0I0 :: Expr0 -> Instr0s
compileE0I0 (E0Cst i) = [I0Cst i]
compileE0I0 (E0Add a b) = compileE0I0 a ++ compileE0I0 b ++ [I0Add]
compileE0I0 (E0Mul a b) = compileE0I0 a ++ compileE0I0 b ++ [I0Mul]

test3 = evalInstr0 (compileE0I0 expr0Instance) []

data Expr1
    = E1Cst Int
    | E1Add Expr1 Expr1
    | E1Mul Expr1 Expr1
    | E1Var String
    | E1Let String Expr1 Expr1
type E1Env = [(String, Int)]

evalExpr1 :: Expr1 -> E1Env -> Int
evalExpr1 (E1Cst x) env = x
evalExpr1 (E1Add a b) env = evalExpr1 a env + evalExpr1 b env
evalExpr1 (E1Mul a b) env = evalExpr1 a env * evalExpr1 b env
evalExpr1 (E1Var name) env = fromMaybe undefined (lookup name env)
evalExpr1 (E1Let name val expr) env = evalExpr1 expr $ (name, evalExpr1 val env) : env

expr1Instance = E1Let "x" (E1Cst 2) (E1Mul (E1Var "x") (E1Add (E1Var "x") (E1Cst 3)))
test4 = evalExpr1 expr1Instance []

data ExprNameless
    = ENCst Int
    | ENAdd ExprNameless ExprNameless
    | ENMul ExprNameless ExprNameless
    | ENVar Int
    | ENLet ExprNameless ExprNameless
type ENEnv = [Int]

evalExprNameless :: ExprNameless -> ENEnv -> Int
evalExprNameless (ENCst x) env = x
evalExprNameless (ENAdd a b) env = evalExprNameless a env + evalExprNameless b env
evalExprNameless (ENMul a b) env = evalExprNameless a env * evalExprNameless b env
evalExprNameless (ENVar i) env = env !! i
evalExprNameless (ENLet val expr) env = evalExprNameless expr $ evalExprNameless val env : env

exprNamelessInstance = ENLet (ENCst 2) (ENMul (ENVar 0) (ENAdd (ENVar 0) (ENCst 3)))
test5 = evalExprNameless exprNamelessInstance []

type NameList = [String]

mapsName2Index :: NameList -> String -> Int
mapsName2Index names name = aux names name 0
    where aux :: NameList -> String -> Int -> Int
          aux (x : xs) name idx = if x == name then idx else aux xs name idx + 1
          aux [] _ _ = undefined

compileE1EN :: Expr1 -> NameList -> ExprNameless
compileE1EN (E1Cst x) names = ENCst x
compileE1EN (E1Add a b) names = ENAdd (compileE1EN a names) (compileE1EN b names)
compileE1EN (E1Mul a b) names = ENMul (compileE1EN a names) (compileE1EN b names)
compileE1EN (E1Var name) names = ENVar (mapsName2Index names name)
compileE1EN (E1Let name val expr) names = ENLet (compileE1EN val names) (compileE1EN expr (name : names))

test6 = evalExprNameless (compileE1EN expr1Instance []) []

main :: IO ()
main = do
    print test1
    print test2
    print test3
    print test4
    print test5
    print test6

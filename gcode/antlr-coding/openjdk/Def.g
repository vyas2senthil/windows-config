// START: header
tree grammar Def;
options {
  tokenVocab = Jnu;
  ASTLabelType = JnuAST;
  filter = true;
}
@members {
    SymbolTable symtab;
    Scope currentScope;
    public Def(TreeNodeStream input, SymbolTable symtab) {
        this(input);
        this.symtab = symtab;
        currentScope = symtab.globals;
    }
}
// END: header

topdown
    :   enterBlock
    |   enterPackage
    |   enterImport
    |   enterMethod
    |   enterClass
    |   enterClassRef
    |   varDeclaration
    |   atoms
    ;

bottomup
    :   exitBlock
    |   exitMethod
    |   exitClass
    ;

// S C O P E S
enterPackage
    :   ^('package' qualifiedName)
    ;

enterImport
    :   ^('import' qualifiedName '*'?)
    ;

qualifiedName 
    :   IDENTIFIER 
    |   ^('.' e+=IDENTIFIER+)
    ;

enterBlock
    :   BLOCK {
            currentScope = new LocalScope(currentScope);
            System.out.println("Enter block");
        } // push scope
    ;
exitBlock
    :   BLOCK
        {
        System.out.println("locals: "+currentScope);
        currentScope = currentScope.getEnclosingScope();    // pop scope
        }
    ;

// START: class
enterClass
    : 	^('class' name=IDENTIFIER ^(CLASS_PARAM .*) ^(SUPER type+=.*) ^(CLASS_BODY .*))
        {
            System.out.println("class: "+$name.text + (($type != null) ? " extends: " + $type.toString() : ""));
            if ($type != null) {
                for (int i = 0; i < $type.size(); i++) {
                    ((JnuAST)$type.get(i)).scope = currentScope;
                }
            }

            ClassSymbol cs = new ClassSymbol($name.text,currentScope,null);
            cs.def = $name;
            $name.symbol = cs;
            currentScope.define(cs);
            currentScope = cs;

        }
    ;

enterClassRef
    :   ^(CLASS_REF ^(QUALIFIED e+=IDENTIFIER+) .*)
        {
            System.out.println("class_ref: " + $e.toString());
        }
    ;
            

exitClass
    :   'class'
        {
        // System.out.println("members: "+currentScope);
        // currentScope = currentScope.getEnclosingScope();    // pop scope
        }
    ;

enterMethod
    : 	^(METHOD_DECL ^(RETURN_TYPE type=.?) name=IDENTIFIER .*)
        {
            System.out.println("line "+$name.getLine()+": def method "+$name.text);
            if ($type != null) {
                $type.scope = currentScope;
            }
            MethodSymbol ms = new MethodSymbol($name.text,null,currentScope);
            ms.def = $name;            // track AST location of def's ID
            $name.symbol = ms;         // track in AST
            currentScope.define(ms); // def method in globals
            currentScope = ms;       // set current scope to method scope
        }
    ;
exitMethod
    :   METHOD_DECL
        {
        System.out.println("args: "+currentScope);
        currentScope = currentScope.getEnclosingScope();    // pop arg scope
        }
    ;

// START: atoms
/** Set scope for any identifiers in expressions or assignments */
atoms
@init {JnuAST t = (JnuAST)input.LT(1);}
    :  {t.hasAncestor(EXPR)}? ('this'|ID)
       {t.scope = currentScope;}
    ;
//END: atoms

// START: var
varDeclaration // global, parameter, or local variable
    :   ^((FIELD_DECL|VAR_DECL|ARG_DECL) type=. IDENTIFIER .?)
        {
            System.out.println("line "+$IDENTIFIER.getLine()+": def arg_decl "+$IDENTIFIER.text + " (type: " + $type.toString() + ")");
            // System.out.println("line "+$ID.getLine()+": def "+$ID.text);
            // $type.scope = currentScope;
            // VariableSymbol vs = new VariableSymbol($ID.text,null);
            // vs.def = $ID;            // track AST location of def's ID
            // $ID.symbol = vs;         // track in AST
            // currentScope.define(vs);
        }
    |   ^((ARRAY_VAR|SCALAR_VAR) IDENTIFIER)
        {
            System.out.println("line "+$IDENTIFIER.getLine()+": def array "+$IDENTIFIER.text);
        }
    ;
// END: field

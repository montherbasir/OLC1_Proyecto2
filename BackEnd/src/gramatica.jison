
%{
      let errores = [];
%}

/* LEXICAL ANALUSIS */
%lex
%options case-sensitive
%%

\s+                                   /* IGNORE */
"//".*                                /* IGNORE */
[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/]   /* IGNORE */

/* NATIVE VALUES */
[0-9]+("."[0-9]+)?\b            return 'double'
[0-9]+\b                        return 'int'
[\"]([^\"\n]|(\\\"))*[\"]       return 'cadena'
[\'][^\'\n][\']                 return 'cadena_char'


"true"                  return 'res_true'
"false"                 return 'res_false'

/* ARITMETIC SYMBOLS */
"++"                    return 'S_PLUSPLUS'
"--"                    return 'S_MINUSMINUS'
"^"                     return 'S_POTENCY'
"*"                     return 'S_MULTIPLY'
"/"                     return 'S_DIVISION'
"%"                     return 'S_MODULE'
"+"                     return 'S_PLUS'
"-"                     return 'S_MINUS'


/* RELACIONAL SYMBOLS */
"<="                    return 'S_MINOREQUALS'
">="                    return 'S_MAJOREQUALS'
"=="                    return 'S_EQUALSEQUALS'
"!="                    return 'S_DIFFERENT'
"<"                     return 'S_MINOR'
">"                     return 'S_MAJOR'

/* LOGICAL SYMBOLS */
"||"                    return 'S_OR'
"&&"                    return 'S_AND'
"!"                     return 'S_NOT'

/* GENERAL SYMBOLS */
"="                     return 'S_EQUALS'
";"                     return 'SEMICOLON'
":"                     return 'S_TWOPOINTS'
"{"                     return 'S_OPEN_KEY'
"}"                     return 'S_CLOSE_KEY'
"("                     return 'S_OPEN_PARENTHESIS'
")"                     return 'S_CLOSE_PARENTHESIS'
","                     return 'S_COMMA'

/* RESERVED WORDS */
/* TYPES */
"int"                   return 'res_int'
"double"                return 'res_double'
"boolean"               return 'res_boolean'
"String"                return 'res_string'
"char"                  return 'res_char'

/* GENERAL RESERVED WORDS */
"class"                 return 'class'
"import"                return 'import'

/* IFELSE SENTENCE */
"if"                    return 'if'
"else"                  return 'else'

/* SWITCH SENTENCE */
"switch"                return 'switch'
"case"                  return 'case'
"default"               return 'default'
"break"                 return 'break'

/* WHILE SENTENCE */
"while"                 return 'while'

/* DO WHILE SENTECE */
"do"                    return 'do'

/* FOR SENTENCE */
"for"                   return 'for'

/* CONTINUE */
"continue"              return 'continue'

/* RETURN */
"return"                return 'return'

/* MAIN */
"void"                  return 'void'
"main"                  return 'main'

/* PRINT SENTENCE */
"System"                return 'System'
"."                     return 'S_POINT'
"out"                   return 'out'
"print"                 return 'print'
"println"               return 'println'
([a-zA-Z])[a-zA-Z0-9_]*        return 'id'
.                       { console.error('Este es un error léxico: ' + yytext + ', en la linea: ' + yylloc.first_line + ', en la columna: ' + yylloc.first_column); }
<<EOF>>                 return 'EOF'

/lex


/* PRECEDENCE */
%left 'else'
%left 'S_OR'
%left 'S_AND'
%left 'S_EQUALSEQUALS', 'S_DIFFERENT'
%left 'S_MAJOREQUALS', 'S_MINOREQUALS', 'S_MAJOR', 'S_MINOR'
%left 'S_PLUS', 'S_MINUS'
%left 'S_MULTIPLY', 'S_DIVISION', 'S_MODULE'
%left 'S_POTENCY'
%right 'S_NOT'
%left UMINUS

/* SYNTACTIC ANALYSIS */
%start START

%%


START : IMPOCLASS EOF
                    {
                     return {"AST": $1, "errores":errores};
                    }
        | EOF
                    {
                     return {"AST": {}, "errores":errores};
                    }
     /*   | error EOF
                    {
                     return {"AST": {"error":$1}, "errores":errores};
                    }*/
            ;

IMPOCLASS : IMPOCLASS IMPORTLIST CLASSLIST {
$1.push({"imports":$2,"clases":$3});
$$=$1;
}
          //  | error CLASSLIST IMPOCLASS
            |IMPORTLIST CLASSLIST {

$$=[{"imports":$1,"clases":$2}];

}
;

IMPORTLIST : IMPORTLIST import id SEMICOLON  {
$1.push({"id":$3});
$$=$1;
}
//| syntax_error IMPORTLIST
|import id SEMICOLON{
$$=[{"id":$2}];
}
            ;

CLASSLIST :CLASSLIST class id S_OPEN_KEY INSIDECLASS S_CLOSE_KEY {

$1.push({"class":{"id":$3,"inside":$5}});
$$=$1;
}
//| syntax_error CLASSLIST
| class id S_OPEN_KEY INSIDECLASS S_CLOSE_KEY {

$$=[{"class":{"id":$2,"inside":$4}}];

}
;
INSIDECLASS : INSIDECLASS TYPE id FUNCTIONORNOT {
$1.push({"instruccion":{"tipoDato":$2,"id":$3,"instruccion":$4}});
$$=$1;
}
|TYPE id FUNCTIONORNOT {
 $$=[{"instruccion":{"tipoDato":$1,"id":$2,"instruccion":$3}}];
 }
|INSIDECLASS void MAINORNOT {
$1.push({"instruccion":{"tipoDato":$2,"instruccion":$3}});
$$=$1;
}
|void MAINORNOT {
                 $$=[{"instruccion":{"tipoDato":$1,"instruccion":$2}}];
                 }
//| syntax_error INSIDECLASS
| %empty
            ;
FUNCTIONORNOT :   S_OPEN_PARENTHESIS PARAMETER S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY{
$$={"tipo":"funcion","params":$2,"sentencias":$5};
}
                | IDLIST OPTASSIGNMENT SEMICOLON{
                $$={"tipo":"declaracion","ids":$1,"asignacion":$2};
                }
            ;
MAINORNOT :   main S_OPEN_PARENTHESIS S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY{
$$={"tipo":"main","sentencias":$5};
}
| id S_OPEN_PARENTHESIS PARAMETER S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY {
$$={"tipo":"funcion","id":$1,"params":$3,"sentencias":$6};
}
;

TYPE : res_int{$$=$1;}
| res_double {$$=$1;}
| res_boolean {$$=$1;}
| res_string {$$=$1;}
| res_char{$$=$1;}
            ;
PARAMETER :
            | PARAMETERDECLARATION PARAMETERLIST {
                                                 if($2!==undefined){
                                                 $2.push($1);
                                                              $$=$2;
                                                 }else{
                                                 $$=[$1];
                                                 }              }
           // | error
            | %empty
            ;

PARAMETERDECLARATION : TYPE id {$$={"tipo":$1,"id":$2};}
            ;

PARAMETERLIST : PARAMETERLIST S_COMMA PARAMETERDECLARATION{
$1.push($3);
$$=$1;
}
            | S_COMMA PARAMETERDECLARATION {
            $$=[$2];
            }
            | %empty
;
SENTENCESLIST :  SENTENCESLIST DECLARATIONSENTENCE {   $1.push($2);     $$=$1;   }
                | SENTENCESLIST ASSIGNMENTORCALLSENTENCE {   $1.push($2);     $$=$1;   }
                | SENTENCESLIST PRINTSENTENCE {   $1.push($2);     $$=$1;   }
                | SENTENCESLIST IFELSESENTENCE {   $1.push($2);     $$=$1;   }
                | SENTENCESLIST SWITCHSENTENCE {   $1.push($2);     $$=$1;   }
                | SENTENCESLIST FORSENTENCE {   $1.push($2);     $$=$1;   }
                | SENTENCESLIST WHILESENTENCE {   $1.push($2);     $$=$1;   }
                | SENTENCESLIST DOWHILESENTENCE {   $1.push($2);     $$=$1;   }
                | SENTENCESLIST CONTINUESENTENCE {   $1.push($2);     $$=$1;   }
                | SENTENCESLIST BREAKSENTENCE {   $1.push($2);     $$=$1;   }
                | SENTENCESLIST RETURNSENTENCE {   $1.push($2);     $$=$1;   }
                | SENTENCESLIST DECLARATIONSENTENCE {   $1.push($2);     $$=$1;   }
                | ASSIGNMENTORCALLSENTENCE {$$=[$1]}
                | PRINTSENTENCE {$$=[$1]}
                | IFELSESENTENCE {$$=[$1]}
                | SWITCHSENTENCE {$$=[$1]}
                | FORSENTENCE {$$=[$1]}
                | WHILESENTENCE {$$=[$1]}
                | DOWHILESENTENCE {$$=[$1]}
                | CONTINUESENTENCE {$$=[$1]}
                | BREAKSENTENCE {$$=[$1]}
                | RETURNSENTENCE {$$=[$1]}
                | syntax_error SENTENCELIST
                | %empty
                 ;

CONTINUESENTENCE : continue SEMICOLON {$$={"instruccion":"continue"}}
            ;
BREAKSENTENCE : break SEMICOLON {$$={"instruccion":"break"}}
            ;
RETURNSENTENCE : return IMPRESSION SEMICOLON {$$={"instruccion":"return","return":$2};}
            ;
DECLARATIONSENTENCE : TYPE DECLARATIONVARIABLES {$$={"instruccion":"declaracion","tipo":$1,"variables":$2};}
            ;
DECLARATIONVARIABLES : id IDLIST OPTASSIGNMENT SEMICOLON {if($2!==undefined){$2.push($1);$$={"lista":$2,"asignacion":$3}]else{$$=[$1];}}
            ;
IDLIST : IDLIST S_COMMA id {$1.push($3);$$=$1;}
        | S_COMMA id {$$=[$2];}
        | %empty
            ;
OPTASSIGNMENT :   S_EQUALS EXPRESSION{$$={"asignacion":$2};}
                | %empty
            ;
ASSIGNMENTORCALLSENTENCE : id OPTAORCALL SEMICOLON {$$={"instruccion":"asignacion/llamada","id":$1,$2}}
            ;
OPTAORCALL :  S_EQUALS EXPRESSION {$$={"asignacion":$2}}
            | S_OPEN_PARENTHESIS PARAMETERLISTCALL S_CLOSE_PARENTHESIS {$$={"parametros":"2"}}
            ;

/* PRINT STATEMENTS */
PRINTSENTENCE : System S_POINT out S_POINT PRINTOPT SEMICOLON {$$={"instruccion":"print","print":$5}}
            ;
PRINTOPT :    print S_OPEN_PARENTHESIS IMPRESSION S_CLOSE_PARENTHESIS{$$=$3}
            | println S_OPEN_PARENTHESIS IMPRESSION S_CLOSE_PARENTHESIS{$$=$3}
            ;
IMPRESSION : EXPRESSION {$$=$1}
            | %empty
            ;

/* CONDITIONAL STATEMENTS */
IFELSESENTENCE :  if S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY {$$={"instruccion":"if","if":$3,"sent":$5}}
                | if S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY else S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY {$$={"instruccion":"if","if":$3,"sent":$5,"else":$10}}
                | if S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY else IFELSESENTENCE {$$={"instruccion":"if","if":$3,"sent":$5,"else":$9}}
            ;

SWITCHSENTENCE : switch S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS S_OPEN_KEY CASELIST OPTDEFAULT S_CLOSE_KEY {$$={"instruccion":"switch","if":$3,"case":$6,"default":$7}}
            ;
CASELIST :   CASELIST case EXPRESSION S_TWOPOINTS SENTENCESLIST {$1.push({"case":$3,"sent":$5});$$=$1;}
            | case EXPRESSION S_TWOPOINTS SENTENCESLIST {$$=[{"case":$2,"sent":$4}]}
            | %empty
            ;
OPTDEFAULT : default S_TWOPOINTS SENTENCESLIST{$$=$3;}
            | %empty
            ;

/* LOOPING STATEMENTS */
FORSENTENCE : for S_OPEN_PARENTHESIS OPTTYPE ASSIGNMENTFOR SEMICOLON EXPRESSION SEMICOLON EXPRESSION INCDEC S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY{$$={"for":"for"}}
            ;
OPTTYPE : TYPE
        | %empty
            ;
ASSIGNMENTFOR : id S_EQUALS EXPRESSION
            ;
INCDEC :  S_PLUSPLUS
        | S_MINUSMINUS
        | %empty
            ;
WHILESENTENCE : while S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY {$$={"while":"while"}}
            ;

DOWHILESENTENCE : do S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY while S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS SEMICOLON {$$={"dowhile":"dowhile"}}
            ;

PARAMETERLISTCALL :   EXPRESSION PLIST
                    | %empty
            ;
PLIST :   S_COMMA EXPRESSION PLIST
        | %empty
            ;
EXPRESSION :  S_MINUS EXPRESSION %prec UMINUS {$$="exp":1}
            | S_NOT EXPRESSION {$$="exp":1}
            | EXPRESSION S_PLUS EXPRESSION{$$="exp":1}
            | EXPRESSION S_MINUS EXPRESSION{$$="exp":1}
            | EXPRESSION S_MULTIPLY EXPRESSION{$$="exp":1}
            | EXPRESSION S_DIVISION EXPRESSION{$$="exp":1}
            | EXPRESSION S_MODULE EXPRESSION{$$="exp":1}
            | EXPRESSION S_POTENCY EXPRESSION{$$="exp":1}
            | EXPRESSION S_MAJOR EXPRESSION{$$="exp":1}
            | EXPRESSION S_MINOR EXPRESSION{$$="exp":1}
            | EXPRESSION S_MAJOREQUALS EXPRESSION{$$="exp":1}
            | EXPRESSION S_MINOREQUALS EXPRESSION{$$="exp":1}
            | EXPRESSION S_EQUALSEQUALS EXPRESSION{$$="exp":1}
            | EXPRESSION S_DIFFERENT EXPRESSION{$$="exp":1}
            | EXPRESSION S_OR EXPRESSION{$$="exp":1}
            | EXPRESSION S_AND EXPRESSION{$$="exp":1}
            | S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS {$$="exp":1}
            | id {$$="exp":1}
            | int{$$="exp":1}
            | double{$$="exp":1}
            | cadena{$$="exp":1}
            | cadena_char{$$="exp":1}
            | res_true{$$="exp":1}
            | res_false{$$="exp":1}
            | id S_OPEN_PARENTHESIS OPPARCALL S_CLOSE_PARENTHESIS{$$="exp":1}
            ;
OPPARCALL : EXPRESSION EXPLIST{$$="exp":1}
           | %empty
;
EXPLIST : S_COMMA EXPRESSION EXPLIST{$$="exp":1}
            | %empty
;

/*
syntax_error
    : error SEMICOLON
      {
        $$ = {"error":$1};
      }
      | error S_CLOSE_KEY
       {
         $$ = {"error":$1};
       }
    ;*/
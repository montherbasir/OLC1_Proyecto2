
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
        | error EOF
                    {
                     return {"AST": {}, "errores":errores};
                    }
            ;

IMPOCLASS : IMPORTLIST CLASSLIST IMPOCLASS
            | error CLASSLIST IMPOCLASS
            |
;

IMPORTLIST : import id SEMICOLON IMPORTLIST
| syntax_error IMPORTLIST
|
            ;

CLASSLIST : class id S_OPEN_KEY INSIDECLASS S_CLOSE_KEY CLASSLIST
| syntax_error CLASSLIST
|
            ;

INSIDECLASS :     TYPE id FUNCTIONORNOT INSIDECLASS
                | void MAINORNOT INSIDECLASS
                | syntax_error INSIDECLASS
                | //Epsilon
            ;
FUNCTIONORNOT :   S_OPEN_PARENTHESIS PARAMETER S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY
                | IDLIST OPTASSIGNMENT SEMICOLON
            ;
MAINORNOT :   main S_OPEN_PARENTHESIS S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY
            | id S_OPEN_PARENTHESIS PARAMETER S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY
            ;

TYPE : res_int | res_double | res_boolean | res_string | res_char
            ;

PARAMETER : PARAMETERDECLARATION
               | error
            | //Epsilon
            ;

PARAMETERDECLARATION : TYPE id PARAMETERLIST
            ;

PARAMETERLIST : S_COMMA PARAMETERDECLARATION
            | // Epsilon
            ;

SENTENCESLIST :  DECLARATIONSENTENCE SENTENCESLIST
                | ASSIGNMENTORCALLSENTENCE SENTENCESLIST
                | PRINTSENTENCE SENTENCESLIST
                | IFELSESENTENCE SENTENCESLIST
                | SWITCHSENTENCE SENTENCESLIST
                | FORSENTENCE SENTENCESLIST
                | WHILESENTENCE SENTENCESLIST
                | DOWHILESENTENCE SENTENCESLIST
                | CONTINUESENTENCE SENTENCESLIST
                | BREAKSENTENCE SENTENCESLIST
                | RETURNSENTENCE SENTENCESLIST
                | syntax_error SENTENCELIST
                | //Epsilon
            ;

CONTINUESENTENCE : continue SEMICOLON
            ;
BREAKSENTENCE : break SEMICOLON
            ;
RETURNSENTENCE : return IMPRESSION SEMICOLON
            ;
DECLARATIONSENTENCE : TYPE DECLARATIONVARIABLES
            ;
DECLARATIONVARIABLES : id IDLIST OPTASSIGNMENT SEMICOLON
            ;
IDLIST :  S_COMMA id IDLIST
        | //Epsilon
            ; // accept Epsilon
OPTASSIGNMENT :   S_EQUALS EXPRESSION
                | //Epsilon
            ;
ASSIGNMENTORCALLSENTENCE : id OPTAORCALL SEMICOLON
            ;
OPTAORCALL :  S_EQUALS EXPRESSION
            | S_OPEN_PARENTHESIS PARAMETERLISTCALL S_CLOSE_PARENTHESIS
            ;

/* PRINT STATEMENTS */
PRINTSENTENCE : System S_POINT out S_POINT PRINTOPT SEMICOLON
            ;
PRINTOPT :    print S_OPEN_PARENTHESIS IMPRESSION S_CLOSE_PARENTHESIS
            | println S_OPEN_PARENTHESIS IMPRESSION S_CLOSE_PARENTHESIS
            ;
IMPRESSION : EXPRESSION
            | //Epsilon
            ;

/* CONDITIONAL STATEMENTS */
IFELSESENTENCE :  if S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY
                | if S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY else S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY
                | if S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY else IFELSESENTENCE
            ;

SWITCHSENTENCE : switch S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS S_OPEN_KEY CASELIST OPTDEFAULT S_CLOSE_KEY
            ;
CASELIST :   case EXPRESSION S_TWOPOINTS SENTENCESLIST CASELIST
            | //Epsilon
            ;
OPTDEFAULT : default S_TWOPOINTS SENTENCESLIST
            | //Epsilon
            ;

/* LOOPING STATEMENTS */
FORSENTENCE : for S_OPEN_PARENTHESIS OPTTYPE ASSIGNMENTFOR SEMICOLON EXPRESSION SEMICOLON EXPRESSION INCDEC S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY
            ;
OPTTYPE : TYPE
        | //Epsilon
            ;
ASSIGNMENTFOR : id S_EQUALS EXPRESSION
            ;
INCDEC :  S_PLUSPLUS
        | S_MINUSMINUS
        | //Epsilon
            ;
WHILESENTENCE : while S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY
            ;

DOWHILESENTENCE : do S_OPEN_KEY SENTENCESLIST S_CLOSE_KEY while S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS SEMICOLON
            ;
PARAMETERLISTCALL :   EXPRESSION PLIST
                    | //Epsilon
            ;
PLIST :   S_COMMA EXPRESSION PLIST
        | //Epsilon
            ;
EXPRESSION :  S_MINUS EXPRESSION %prec UMINUS
            | S_NOT EXPRESSION
            | EXPRESSION S_PLUS EXPRESSION
            | EXPRESSION S_MINUS EXPRESSION
            | EXPRESSION S_MULTIPLY EXPRESSION
            | EXPRESSION S_DIVISION EXPRESSION
            | EXPRESSION S_MODULE EXPRESSION
            | EXPRESSION S_POTENCY EXPRESSION
            | EXPRESSION S_MAJOR EXPRESSION
            | EXPRESSION S_MINOR EXPRESSION
            | EXPRESSION S_MAJOREQUALS EXPRESSION
            | EXPRESSION S_MINOREQUALS EXPRESSION
            | EXPRESSION S_EQUALSEQUALS EXPRESSION
            | EXPRESSION S_DIFFERENT EXPRESSION
            | EXPRESSION S_OR EXPRESSION
            | EXPRESSION S_AND EXPRESSION
            | S_OPEN_PARENTHESIS EXPRESSION S_CLOSE_PARENTHESIS
            | id
            | int
            | double
            | cadena
            | cadena_char
            | res_true
            | res_false
            | id S_OPEN_PARENTHESIS OPPARCALL S_CLOSE_PARENTHESIS
            ;
OPPARCALL : EXPRESSION EXPLIST
           | //epsilon
;
EXPLIST : S_COMMA EXPRESSION EXPLIST
            | //
;

syntax_error
    : error SEMICOLON
      {
        $$ = {"error":$1};
      }
      | error S_CLOSE_KEY
       {
         $$ = {"error":$1};
       }
    ;
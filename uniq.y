%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;

int yylex();

int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

%}
%token ID TIP BGIN END ASSIGN NR OPP CST DFN CLS ACSP IF ELSE DO WHILE SWITCH CASE DEFAULT FOR OPPL OPPLE PRNT STGOPP1 STGOPP2 STRG LGC LGC1 
%start progr
%%
progr: declarations block {printf("program corect sintactic\n");}
     ;

declarations : declaration ';'
             | declarations declaration ';'
             | DFN ID NR
             | declarations DFN ID NR
             | CLS ID '{' classStatements '}'
             | declarations CLS ID '{' classStatements '}'
             | PRNT '(' NR ')' ';'
             | declarations PRNT '(' NR ')' ';'
             ;

classStatements : ACSP ':' classDeclaration 
                | classStatements ACSP ':' classDeclaration
                ;

classDeclaration : declaration ';'
                 | classDeclaration declaration ';'
                 ;

declaration : TIP ID 
            | TIP ID '(' paramList ')'
            | TIP ID '(' ')'
            | CST TIP ID
            | TIP ID dimensions
            ;

dimensions : '[' var ']'
           | dimensions '[' var ']'
           ; 

paramList : param
          | paramList ',' param 
          ;
            
param : TIP ID
      ; 
      
block : BGIN list END  
      ;
     
list :  statement ';' 
     | list statement ';'
     | controlStatement
     | list controlStatement
     ;

statement: ID ASSIGN var 
         | ID ASSIGN questionMarkOperator
         | ID '(' ')'		
         | ID '(' callList ')'
         | ID ASSIGN ID '(' callList ')'
         | ID ASSIGN operation
         | CST TIP ID
         | DFN ID NR
         | ID dimensions ASSIGN var
         | TIP ID dimensions
         | PRNT '(' NR ')'
         | STGOPP1 '(' STRG ')'
         | STGOPP1 '(' ID ')'
         | STGOPP2 '(' STRG ',' STRG ')'
         | STGOPP2 '(' STRG ',' ID ')'
         | STGOPP2 '(' ID ',' STRG ')'
         | STGOPP2 '(' ID ',' ID ')'
         | ID ASSIGN booleanexpr
         | ID ASSIGN expression
         ;

booleanexpr : LGC1 '(' expression ')'
            | LGC1 '(' booleanexpr ')'
            | '(' expression ')'
            | '(' booleanexpr ')'
            | '(' booleanexpr ')' LGC booleanexpr
            | '(' booleanexpr ')' LGC expression  
            | '(' expression ')' LGC booleanexpr
            | expression LGC expression
            | expression LGC booleanexpr
            ;

controlStatement: IF '(' booleanexpr ')' statement ';'
                | IF '(' booleanexpr ')' '{' blockOfStatements '}' 
                | IF '(' booleanexpr ')' '{' blockOfStatements '}' ifElse
                | SWITCH '(' ID ')' '{' statementsForSwitch '}'
                | WHILE '(' booleanexpr ')' statement ';'
                | WHILE '(' booleanexpr ')' '{' blockOfStatements '}'
                | FOR '(' statement ';' booleanexpr ';' statement ')' statement ';'
                | FOR '(' statement ';' booleanexpr ';' statement ')' '{' blockOfStatements '}'
                | DO '{' blockOfStatements '}' WHILE '(' booleanexpr ')' ';'
                | IF '(' expression ')' statement ';'
                | IF '(' expression ')' '{' blockOfStatements '}' 
                | IF '(' expression ')' '{' blockOfStatements '}' ifElse
                | WHILE '(' expression ')' statement ';'
                | WHILE '(' expression ')' '{' blockOfStatements '}'
                | FOR '(' statement ';' expression ';' statement ')' statement ';'
                | FOR '(' statement ';' expression ';' statement ')' '{' blockOfStatements '}'
                | DO '{' blockOfStatements '}' WHILE '(' expression ')' ';'
                ;

questionMarkOperator: expression '?' var ':' var 
                    ;

ifElse: ELSE '{' blockOfStatements '}'
      | ifElse  ELSE '{' blockOfStatements '}'
      ;
        
blockOfStatements : statement ';'
                  | blockOfStatements statement ';'
                  | controlStatement
                  | blockOfStatements controlStatement
                  ;

expression : var OPPL var
           ;

operation : var OPP var 
          | var OPP operation
          | '(' var OPP var ')'
          | '(' var OPP operation ')'
          ;

statementsForSwitch : CASE NR ':' statement ';'
                    | CASE NR ':' statement ';' statementsForSwitch
                    | DEFAULT ':' statement ';'
                    ;

var : ID 
    | NR
    ;

callList : var
         | ID '(' callList ')'
         | callList ',' var
         | callList ',' ID '(' callList ')'
         ;
%%

int main(int argc, char** argv){
yyin = fopen(argv[1],"r");
yyparse();
} 

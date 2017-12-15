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
%token ID TIP BGIN END ASSIGN NR OPP CST DFN CLS ACSP IF ELSE DO WHILE SWITCH FOR OPPL OPPLE
%start progr
%%
progr: declaratii bloc {printf("program corect sintactic\n");}
     ;

declaratii : declaratie ';'
	         | declaratii declaratie ';'
           | DFN ID NR
           | declaratii DFN ID NR
           | CLS ID '{' class_statements '}'
           | declaratii CLS ID '{' class_statements '}'
	         ;

class_statements : ACSP ':' class_declaratie 
                 | class_statements ACSP ':' class_declaratie

class_declaratie : declaratie ';'
                 | class_declaratie declaratie ';'

declaratie : TIP ID 
           | TIP ID '(' lista_param ')'
           | TIP ID '(' ')'
           | CST TIP ID
           | TIP ID dimensions
           ;

dimensions : '[' NR ']'
           | dimensions '[' NR ']'
           | '[' ID ']'
           | dimensions '[' ID ']'
           ; 

lista_param : param
            | lista_param ',' param 
            ;
            
param : TIP ID
      ; 
      
/* bloc */
bloc : BGIN list END  
     ;
     
/* lista instructiuni */
list :  statement ';' 
     | list statement ';'
     | controlStatement
     | list controlStatement
     ;

/* instructiune */
statement: ID ASSIGN var 
         | ID ASSIGN questionMarkOperator
         | ID '(' ')'		
         | ID '(' lista_apel ')'
         | ID ASSIGN ID '(' lista_apel ')'
         | ID ASSIGN operation
         | CST TIP ID
         | DFN ID NR
         | ID dimensions ASSIGN var
         ;

controlStatement: IF '(' expression ')' statement ';'
                | IF '(' expression ')' '{' blockOfStatements '}' 
                | IF '(' expression ')' '{' blockOfStatements '}' ifElse
                | SWITCH '(' ID ')' '{' statementsForSwitch '}'
                | WHILE '(' expression ')' statement ';'
                | WHILE '(' expression ')' '{' blockOfStatements '}'
                | FOR '(' statement ';' expression ';' statement ')' statement ';'
                | FOR '(' statement ';' expression ';' statement ')' '{' blockOfStatements '}'
                | DO '{' blockOfStatements '}' WHILE '(' expression ')' ';'
                ;

questionMarkOperator: expression '?' var ':' var 

ifElse: ELSE '{' blockOfStatements '}'
      | ifElse  ELSE '{' blockOfStatements '}'
 
statementsForSwitch : 'c''a''s''e' NR ':' statement ';'
                    | 'c''a''s''e' NR ':' statement ';' statementsForSwitch
                    | 'd''e''f''a''u''l''t' ':' statement ';'
                    ;
        
 blockOfStatements : statement ';'
                   | blockOfStatements statement ';'
                   | controlStatement
                   | blockOfStatements controlStatement
                   ;

expression : var OPPL var
           | '!' var
           | expression OPPLE '!' var
           | expression OPPLE var OPPL var
           ;

operation : var OPP var 
          | var OPP operation
          ;

var : ID 
    | NR
    ;

lista_apel : var
           | ID '(' lista_apel ')'
           | lista_apel ',' var
           | lista_apel ',' ID '(' lista_apel ')'
           ;
%%

int main(int argc, char** argv){
yyin = fopen(argv[1],"r");
yyparse();
} 

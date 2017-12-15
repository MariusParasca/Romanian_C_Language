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
%token ID TIP BGIN END ASSIGN NR OPP CST DFN CLS ACSP IF OPPL
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
           | IF '(' expression ')' statement ';'
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
     ;

/* instructiune */
statement: ID ASSIGN ID
         | ID ASSIGN NR      
         | ID '(' lista_apel ')'
         | ID ASSIGN operation
         | CST TIP ID
         | DFN ID NR
         | TIP ID dimensions
         | IF '(' expression ')' statement
         ;
        
expression : var OPPL var

operation : var OPP var 
          | var OPP operation
          ;

var : ID 
    | NR
    ;

lista_apel : NR
           | lista_apel ',' NR
           |
           ;
%%

int main(int argc, char** argv){
yyin = fopen(argv[1],"r");
yyparse();
} 

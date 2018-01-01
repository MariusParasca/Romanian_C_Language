%{
#include <stdio.h>
#include <string.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;

typedef struct var{
  char *id;
  char *type;
  int initialized;  /* 1 - initialized explicitly; 0 - not initialized explicitly AKA ID in stanga*/
}var;

var allVariables[100];
int noVariable = 0;

int yylex();

int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

%}

%union{
  char* typeval;
  char* idval;
}

%token <idval>ID FNCTID CLSID <typeval>TIP BGIN END ASSIGN NR OPP CST DFN CLS ACSP IF ELSE DO WHILE SWITCH CASE DEFAULT FOR OPPL OPPLE PRNT STGOPP1 STGOPP2 STRG LGC LGC1 
%start progr

%%
progr: declarations block {printf("program corect sintactic\n");}
     ;

declarations : declaration ';'
             | declarations declaration ';'
             | DFN ID NR
             | declarations DFN ID NR
             | CLS CLSID '{' classStatements '}'
             | declarations CLS CLSID '{' classStatements '}'
             | PRNT '(' NR ')' ';'
             | declarations PRNT '(' NR ')' ';'
             ;

classStatements : ACSP ':' classDeclaration 
                | classStatements ACSP ':' classDeclaration
                ;

classDeclaration : declaration ';'
                 | classDeclaration declaration ';'
                 ;

declaration : TIP ID { 
                      for(int i = 0; i < noVariable; i++){
                        if( strcmp(allVariables[i].id,$2) == 0 ){
                          printf("[Eroare] linia %d : %s este deja folosit\n",yylineno, allVariables[i].id);
                          YYERROR;
                          }
                       }
                       var tempvar; 
                       tempvar.id = $2;
                       tempvar.type = $1;
                       tempvar.initialized = 0;
                       printf("Var %d : %s %s\n",noVariable,tempvar.type, tempvar.id);
                       allVariables[noVariable] = tempvar;
                       noVariable++;
                       }
            | TIP FNCTID '(' paramList ')'
            | TIP FNCTID '(' ')'
            | CST TIP ID
            | TIP ID dimensions{ 
                                for(int i = 0; i < noVariable; i++){
                                  if( strcmp(allVariables[i].id,$2) == 0 ){
                                    printf("[Eroare] linia %d : %s este deja folosit\n",yylineno, allVariables[i].id);
                                    YYERROR;
                                    }
                                 }
                                 var tempvar; 
                                 tempvar.id = $2;
                                 tempvar.type = $1;
                                 tempvar.initialized = 0;
                                 printf("Var %d : %s %s\n",noVariable,tempvar.type, tempvar.id);
                                 allVariables[noVariable] = tempvar;
                                 noVariable++;
                                 }
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
     
list : statement ';' 
     | list statement ';'
     | controlStatement
     | list controlStatement
     ;

statement: ID ASSIGN var { 
                          int isDefined = 0;
                          for(int i = 0; i < noVariable; i++){
                            if( strcmp(allVariables[i].id,$1) == 0 ){
                              isDefined = 1;
                              allVariables[i].initialized = 1;    
                            }
                          }
                          if(isDefined == 0){
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $1);
                            YYERROR;
                          }
                         }
         | FNCTID '(' ')'		
         | FNCTID '(' callList ')'
         | ID ASSIGN FNCTID '(' callList ')' { 
                          int isDefined = 0;
                          for(int i = 0; i < noVariable; i++){
                            if( strcmp(allVariables[i].id,$1) == 0 ){
                              isDefined = 1;
                              allVariables[i].initialized = 1;     
                            }
                          }
                          if(isDefined == 0){
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $1);
                            YYERROR;
                          }
                         }
         | ID ASSIGN operation { 
                          int isDefined = 0;
                          for(int i = 0; i < noVariable; i++){
                            if( strcmp(allVariables[i].id,$1) == 0 ){
                              isDefined = 1;
                              allVariables[i].initialized = 1;     
                            }
                          }
                          if(isDefined == 0){
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $1);
                            YYERROR;
                          }
                         }
         | CST TIP ID
         | DFN ID NR
         | ID dimensions ASSIGN var { 
                          int isDefined = 0;
                          for(int i = 0; i < noVariable; i++){
                            if( strcmp(allVariables[i].id,$1) == 0 ){
                              isDefined = 1;
                              allVariables[i].initialized = 1;     
                            }
                          }
                          if(isDefined == 0){
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $1);
                            YYERROR;
                          }
                         }
         | PRNT '(' NR ')'
         | STGOPP1 '(' STRG ')'
         | STGOPP1 '(' ID ')' { 
                          int isDefined = 0;
                          for(int i = 0; i < noVariable; i++){
                            if( strcmp(allVariables[i].id,$3) == 0 ){
                              isDefined = 1;    
                            }
                          }
                          if(isDefined == 0){
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $3);
                            YYERROR;
                          }
                         }
         | STGOPP2 '(' STRG ',' STRG ')'
         | STGOPP2 '(' STRG ',' ID ')' { 
                          int isDefined = 0;
                          for(int i = 0; i < noVariable; i++){
                            if( strcmp(allVariables[i].id,$5) == 0 ){
                              isDefined = 1;    
                            }
                          }
                          if(isDefined == 0){
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $5);
                            YYERROR;
                          }
                         }
         | STGOPP2 '(' ID ',' STRG ')' { 
                          int isDefined = 0;
                          for(int i = 0; i < noVariable; i++){
                            if( strcmp(allVariables[i].id,$3) == 0 ){
                              isDefined = 1;    
                            }
                          }
                          if(isDefined == 0){
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $3);
                            YYERROR;
                          }
                         }
         | STGOPP2 '(' ID ',' ID ')' { 
                          int isDefined = 0;
                          for(int i = 0; i < noVariable; i++){
                            if (strcmp(allVariables[i].id,$3) == 0) {
                              isDefined = 1;    
                            }
                          }
                          if(isDefined == 0){
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $3);
                            YYERROR;
                          }
                          int isDefined2 = 0;
                          for(int i = 0; i < noVariable; i++){
                            if (strcmp(allVariables[i].id,$5) == 0) {
                              isDefined2 = 1;    
                            }
                          }
                          if(isDefined2 == 0){
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $5);
                            YYERROR;
                          }
                         }
         | ID ASSIGN booleanexpr { 
                          int isDefined = 0;
                          for(int i = 0; i < noVariable; i++){
                            if( strcmp(allVariables[i].id,$1) == 0 ){
                              isDefined = 1;
                              allVariables[i].initialized = 1;     
                            }
                          }
                          if(isDefined == 0){
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $1);
                            YYERROR;
                          }
                         }
         | ID ASSIGN expression { 
                          int isDefined = 0;
                          for(int i = 0; i < noVariable; i++){
                            if( strcmp(allVariables[i].id,$1) == 0 ){
                              isDefined = 1;
                              allVariables[i].initialized = 1;     
                            }
                          }
                          if(isDefined == 0){
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $1);
                            YYERROR;
                          }
                         }
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
                | SWITCH '(' ID ')' '{' statementsForSwitch '}' { 
                                                                  int isDefined = 0;
                                                                  for(int i = 0; i < noVariable; i++){
                                                                    if( strcmp(allVariables[i].id,$3) == 0 ){
                                                                    isDefined = 1;    
                                                                    }
                                                                  }
                                                                  if(isDefined == 0){
                                                                    printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $3);
                                                                    YYERROR;
                                                                  }
                                                                 }
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

var : ID { 
          int isDefined = 0;
          for(int i = 0; i < noVariable; i++){
            if( strcmp(allVariables[i].id,$1) == 0 ){
              isDefined = 1;
              if( allVariables[i].initialized == 0){
                printf("[Eroare] linia %d : %s nu a fost initializata\n", yylineno, $1 );
                YYERROR;
              }    
            }
          }
          if(isDefined == 0){
            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $1);
            YYERROR;
          }



         }
    | NR
    ;

callList : var
         | FNCTID '(' callList ')'
         | callList ',' var
         | callList ',' FNCTID '(' callList ')'
         ;
%%

int main(int argc, char** argv){
yyin = fopen(argv[1],"r");
yyparse();
} 

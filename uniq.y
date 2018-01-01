%{
#include <stdio.h>
#include <string.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;

typedef struct var{
  char* id;
  char* type;
  int initialized;  /* 1 - initialized explicitly; 0 - not initialized explicitly AKA ID in stanga*/
}var;

var allVariables[100];
int noVariable = 0;

typedef struct function{
  char* idFnct;
  char* typeFnct;
  int noParam;
  char* paramtypeVal[100];
}function;

function allFunctions[100];
int noFunctions = 0;

int yylex();

int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int tempNoParams = 0;
char* tempTypeFunct[100];

char* numberType = "number";

%}

%union{
  char* typeval;
  char* idval;
}

%union{
  char* typefnct;
  char* idfnct;
}

%token <idval>ID <idfnct>FNCTID CLSID <typefnct><typeval>TIP BGIN END ASSIGN NR OPP CST DFN CLS ACSP IF ELSE DO WHILE SWITCH CASE DEFAULT FOR OPPL OPPLE PRNT STGOPP1 STGOPP2 STRG LGC LGC1 
%start progr

%type <noParam>paramList

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
            | TIP FNCTID '(' { tempNoParams = 0; memset(tempTypeFunct,0,sizeof(tempTypeFunct)); } paramList ')'{
                                          for(int i = 0; i < noFunctions; i++){
                                            if ( strcmp( allFunctions[i].idFnct, $2) == 0){
                                              if ( allFunctions[i].noParam == tempNoParams){
                                                int diffParamTypes = 0;
                                                for(int j = 0; j < tempNoParams; j++){
                                                  if( strcmp( allFunctions[i].paramtypeVal[j], tempTypeFunct[j] ) == 0){
                                                    diffParamTypes++;
                                                  }
                                                }
                                                if(diffParamTypes == tempNoParams){
                                                  printf("[Eroare] linia %d : functia %s a fost deja definita cu aceasta signatura\n", yylineno, $2);
                                                  YYERROR;
                                                }

                                              }
                                            }
                                          }
                                          function tempFunction;
                                          tempFunction.idFnct = $2;
                                          tempFunction.typeFnct = $1;
                                          tempFunction.noParam = tempNoParams;
                                          printf("Funct %d : %s %s ( ", noFunctions, tempFunction.typeFnct, tempFunction.idFnct);
                                          for(int i = 0; i < tempNoParams; i++){
                                            tempFunction.paramtypeVal[i] = tempTypeFunct[i];
                                            printf("%s ", tempTypeFunct[i]);
                                          }
                                          printf(")\n");
                                          allFunctions[noFunctions] = tempFunction;
                                          noFunctions++;
                                          }
            | TIP FNCTID '(' ')'{
                                  for (int i = 0; i < noFunctions; ++i){
                                    if( strcmp( allFunctions[i].idFnct, $2) == 0){
                                      if( allFunctions[i].noParam == 0){
                                        printf("[Eroare] linia %d : functia %s a fost deja definita\n", yylineno, $2);
                                        YYERROR;
                                      }
                                    }
                                  }

                                  function tempFunction;
                                  tempFunction.idFnct = $2;
                                  tempFunction.typeFnct = $1;
                                  tempFunction.noParam = 0;
                                  printf("Funct %d : %s %s ()\n", noFunctions, tempFunction.typeFnct, tempFunction.idFnct);
                                  allFunctions[noFunctions] = tempFunction;
                                  noFunctions++;
                                }
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

paramList : TIP ID { tempTypeFunct[tempNoParams] = $1; tempNoParams++;}
          | paramList ',' TIP ID { tempTypeFunct[tempNoParams] = $3; tempNoParams++;} 
          ;
      
block : BGIN list END  
      ;
     
list : statement ';' 
     | list statement ';'
     | controlStatement
     | list controlStatement
     ;

statement: ID ASSIGN ID { 
                          int isDefined = 0;
                          char* typeVal1;
                          for(int i = 0; i < noVariable; i++){
                            if( strcmp(allVariables[i].id,$1) == 0 ){
                              isDefined = 1;
                              allVariables[i].initialized = 1; 
                              typeVal1 = strdup(allVariables[i].type);
                            }
                          }
                          if(isDefined == 0){
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $1);
                            YYERROR;
                          }

                          char* typeVal2;
                          for(int i = 0; i < noVariable; i++){
                            if( strcmp(allVariables[i].id,$3) == 0 ){
                              typeVal2 = strdup(allVariables[i].type);
                            }
                          }

                          if(strcmp(typeVal1, typeVal2) != 0){
                            printf("[Eroare] linia %d : %s e tip diferit de %s\n", yylineno, typeVal1, typeVal2);
                            YYERROR;
                          }

                         }
         | ID ASSIGN NR { 
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
         | FNCTID '(' ')'	{
                          int isDefined = 0, withParam = 0;
                          for (int i = 0; i < noFunctions; ++i)
                          {
                            if( strcmp(allFunctions[i].idFnct, $1) == 0 ){
                              if( allFunctions[i].noParam == 0){
                                isDefined = 1;
                              }else{
                                withParam = 1;
                              }
                            }
                          }

                          if( ( isDefined == 0 ) && ( withParam == 1 ) ){
                            printf("[Eroare] linia %d : %s a fost definita dar ai uitat parametrii\n", yylineno, $1);
                            YYERROR; 
                          }

                          if( isDefined == 0) {
                            printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $1);
                            YYERROR;
                          }

                          }
         | FNCTID '(' { tempNoParams = 0; memset(tempTypeFunct,0,sizeof(tempTypeFunct)); } callList ')'{
                                    int isDefined = 0, equalNoParam = 0;
                                    for (int i = 0; i < noFunctions; ++i)
                                    {
                                      if( strcmp(allFunctions[i].idFnct, $1) == 0 ){
                                        isDefined = 1;
                                        if( tempNoParams == allFunctions[i].noParam ){
                                          equalNoParam = 1;
                                          int diffParamTypes = 0;
                                          for(int j = 0; j < tempNoParams; j++){
                                            if( strcmp( allFunctions[i].paramtypeVal[j], tempTypeFunct[j] ) == 0){
                                              diffParamTypes++;
                                            }
                                            if( strcmp(allFunctions[i].paramtypeVal[j], "caracter") != 0 ){
                                              if ( strcmp(allFunctions[i].paramtypeVal[j], "convoi") != 0 ){
                                                if ( strcmp(tempTypeFunct[j], "number") == 0 ){
                                                  diffParamTypes++;
                                                }
                                              }
                                            }
                                          }
                                          if(diffParamTypes < tempNoParams){
                                            printf("[Eroare] linia %d : functia %s este definita, numarul parametrilor coincide dar nu si tipul\n", yylineno, $1);
                                            YYERROR;
                                          }
                                        }
                                      } 
                                    }

                                  if ((isDefined = 1) && (equalNoParam == 0)){
                                    printf("[Eroare] linia %d : functia %s este definta dar neceista alt numar de parametri\n", yylineno, $1);
                                    YYERROR;
                                  }

                                  if(isDefined = 0){
                                    printf("[Eroare] linia %d : functia %s nu a fost definita \n", yylineno, $1);
                                  } 
                                  }
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

callList : ID { 
                int isDefined = 0, isInitialized = 0;
                for(int i = 0; i < noVariable; i++){
                  if( strcmp(allVariables[i].id,$1) == 0 ){
                    isDefined = 1;
                    if( allVariables[i].initialized == 1 ){
                      isInitialized = 1;
                      tempTypeFunct[tempNoParams] = allVariables[i].type; 
                      tempNoParams++;
                    }
                  }
                }

                if( ( isDefined == 1 ) && ( isInitialized == 0 ) ){
                  printf("[Eroare] linia %d : %s este definita dar nu a fost initializata\n", yylineno, $1);
                  YYERROR; 
                }

                if( isDefined == 0){
                    printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $1);
                    YYERROR;
                }
                
              }
         | NR {
                tempTypeFunct[tempNoParams] = numberType;
                tempNoParams++;
              }
         | callList ',' ID { 
                            int isDefined = 0, isInitialized = 0;
                            for(int i = 0; i < noVariable; i++){
                              if( strcmp(allVariables[i].id,$3) == 0 ){
                                isDefined = 1;
                                if( allVariables[i].initialized == 1 ){
                                  isInitialized = 1;
                                  tempTypeFunct[tempNoParams] = allVariables[i].type; 
                                  tempNoParams++;
                                }
                              }
                            }

                            if( ( isDefined == 1 ) && ( isInitialized == 0 ) ){
                              printf("[Eroare] linia %d : %s este definita dar nu a fost initializata\n", yylineno, $3);
                              YYERROR; 
                            }

                            if( isDefined == 0){
                                printf("[Eroare] linia %d : %s nu a fost definita\n", yylineno, $3);
                                YYERROR;
                            }
                          }
         | callList ',' NR {
                            tempTypeFunct[tempNoParams] = numberType;
                            tempNoParams++;
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
%%

int main(int argc, char** argv){
yyin = fopen(argv[1],"r");
yyparse();
} 

%{
#include <stdio.h>
#include "y.tab.h"
%}
%%
"int"|"float"|"char"|"string"|"double"|"long" {return TIP;}
"begin_progr" {return BGIN;}
"end_progr" {return END;}
"const" {return CST;}
"#define" {return DFN;}
"class" {return CLS;}
"public"|"private" {return ACSP;}
"if" {return IF;}
@[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
":=" {return ASSIGN;}
"+"|"-"|"*"|"/" {return OPP;}
"<"|">"|"=="|"!="|">="|"<=" {return OPPL;}
[0-9]+ {return NR;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

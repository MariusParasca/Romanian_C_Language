%{
#include <stdio.h>
#include "y.tab.h"
%}
%%
"intreg"|"rational"|"caracter"|"convoi"|"maiRational"|"rationalLung" {return TIP;}
"incepem" {return BGIN;}
"terminam" {return END;}
"constanta" {return CST;}
"#defineste" {return DFN;}
"grup" {return CLS;}
"accesibil"|"confidential" {return ACSP;}
"daca" {return IF;}
"dacaNu" {return ELSE;}
"actioneaza" {return DO;}
"catTimp" {return WHILE;}
"ciclu" {return FOR;}
"striga" {return PRNT;}
"lungimeConvoi"|"minusculConvoi"|"majusculConvoi" {return STGOPP1; }
"copieConvoi"|"concatenareConvoi"|"comparareConvoi" {return STGOPP2; }
"SI"|"SAU" {return LGC;}
"NEG" {return LGC1;}
"~"[a-zA-Z0-9]* {return STRG;}
"selecteaza" {return SWITCH;}
"caz" {return CASE;}
"implicit" {return DEFAULT;}
"$"[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
"@"[_a-zA-Z][_a-zA-Z0-9]* {return FNCTID;}
"#"[_a-zA-Z][_a-zA-Z0-9]* {return CLSID;}
"->" {return ASSIGN;}
"+"|"-"|"*"|"/" {return OPP;}
"<"|">"|"=="|"!="|">="|"<=" {return OPPL;}
[0-9]+ {return NR;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

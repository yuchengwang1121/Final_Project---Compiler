%{
#include "final.tab.h"
%}
separator [ ]|\r|\n|\t
letter [a-z]
digit [0-9]
op ([+]|[-]|[*]|[/]|mod|[>]|[<]|[=])
number {digit}|[1-9]{digit}*|-[1-9]{digit}*
id {letter}({letter}|{digit}|-)*

%%
{number} {yylval.ival = atoi(yytext); /*printf("number\n");*/return(number);}
{op} {yylval.word = strdup(yytext); /*printf("op\n");*/return(numop);}
print\-num|print\-bool {yylval.word = strdup(yytext); /*printf("print\n");*/return(print);}
and|or|not {yylval.word=strdup(yytext);/*printf("logicop\n");*/return(logicop);}
if {yylval.word=strdup(yytext);/*printf("IF\n");*/return(IF);}
define {yylval.word =strdup(yytext); /*printf("define\n");*/return(define);}
fun {yylval.word =strdup(yytext); /*printf("fun\n");*/return(func);}
#t {yylval.ival = 1; /*printf("boolt\n");*/return(boolean);}
#f {yylval.ival = 0; /*printf("boolf\n");*/return(boolean);}
\( {yylval.word = strdup(yytext); /*printf("LP\n");*/return(lp);}
\) {yylval.word = strdup(yytext); /*printf("RP\n");*/return(rp);}
{id} {yylval.word = strdup(yytext); /*printf("id\n");*/return(id);}
{separator} {}
. {return(yytext[0]);}

%%
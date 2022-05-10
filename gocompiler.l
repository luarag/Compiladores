	/* Filipa Martins 2016267248 Ana Luisa Oliveira 2014194117  */

%{
	#include <stdio.h>
	#include <string.h> 
	#include "ast.h"
	#include "y.tab.h"
	
	int column = 1;   
	int line = 1;
	int flag = 0; 
	int ast = 0;
	int pontvirgula = 0;  
	int commentline;
	int commentcolumn;
	int stringline;
	int stringcolumn;
	int eof_flag = 0;
	int eof_column = 0;
%}

%X COMMENT COMMENT2 STRINGLIT

number		[0-9]+
float		[0-9]+["."","][0-9]+
expoente	("e"|"E")[+-]?{number}

NEWLINE		"\n"|"\r"|"\r\n"
SPACE		" "|"\t"
SEMICOLON 	";"
BLANKID 	_
PACKAGE 	package
RETURN		return
AND 		&&
ASSIGN 		"="
STAR 		"*"
COMMA 		,
DIV 		"/"
EQ			==
GE 			>=
GT 			>
LBRACE 		"{"
LE 			<=
LPAR 		"("
LSQ 		"["
LT 			<
MINUS 		"-"
MOD 		%
NE 			!=
NOT 		!	
OR 			"||"
PLUS 		"+"
RBRACE 		"}"
RPAR 		")"
RSQ 		"]"
ELSE 		else
FOR 		for
IF 			if
VAR 		var
INT 		int	
FLOAT32 	float32
BOOL 		bool
STRING 		string
PRINT 		fmt.Println
PARSEINT 	strconv.Atoi
FUNC 		func
CMDARGS 	os.Args

RESERVED	"++"|"--"|break|case|default|chan|const|interface|select|defer|go|map|struct|goto|switch|fallthrough|range|type|continue|import       
ID  		[a-zA-Z_][a-zA-Z_0-9]*
INTLIT		(0[xX][0-9a-fA-F]+)|({number}+?)|(0[0-7]+?)
REALLIT		{number}"."?{expoente}?|{number}?"."{number}{expoente}?
STRLIT 		([^\\"\n\r]|\\[fnrt\\"])*
			

%%
"/*"	 			{commentline = line; commentcolumn = column; column += yyleng;  BEGIN COMMENT;}  
<COMMENT>{NEWLINE}	{line++; column = 1;}	
<COMMENT>.			{column += yyleng;}
<COMMENT>"*/"		{BEGIN 0; column += yyleng;}
<COMMENT><<EOF>>	{printf("Line %d, column %d: unterminated comment\n", commentline, commentcolumn); pontvirgula = 0; BEGIN 0;}
"//"				{column += yyleng; if(flag==1); BEGIN COMMENT2;} 
<COMMENT2>.			{column += yyleng;}
<COMMENT2>{NEWLINE}	{line++; column = 1; if(flag==1); BEGIN 0;}



\"						{stringline = line; stringcolumn = column; column+= yyleng; BEGIN STRINGLIT;}
<STRINGLIT>{NEWLINE}    {printf("Line %d, column %d: unterminated string literal\n", stringline, stringcolumn); BEGIN 0; pontvirgula = 0; line++; column = 1;}
<STRINGLIT><<EOF>>	    {printf("Line %d, column %d: unterminated string literal\n", stringline, stringcolumn); pontvirgula = 0; BEGIN 0;}
<STRINGLIT>{STRLIT}    	{column+= yyleng;}
<STRINGLIT>\\.?      	{printf("Line %d, column %d: invalid escape sequence (%s)\n", stringline, column, yytext); column+= yyleng; pontvirgula = 0;} 
<STRINGLIT>\"			{column += yyleng; BEGIN 0;pontvirgula = 0;} 


\"{STRLIT}\"	{column += yyleng; pontvirgula = 1; if(flag==1) printf("STRLIT(%s)\n", yytext); else {yylval.string = strdup(yytext); return STRLIT;}}	


{NEWLINE}	{line++; eof_column = column;column = 1; if((pontvirgula == 1) && (flag == 1)) {printf("SEMICOLON\n"); pontvirgula  = 0;} else if(pontvirgula == 1){ pontvirgula  = 0; return SEMICOLON;} pontvirgula=0; }
{SPACE}		{column += yyleng;}
{SEMICOLON} {column += yyleng; pontvirgula = 0; if(flag==1) printf("SEMICOLON\n"); else return SEMICOLON;}
{BLANKID} 	{column += yyleng; pontvirgula = 0; if(flag==1) printf("BLANKID\n"); else return BLANKID;}
{PACKAGE} 	{column += yyleng; pontvirgula = 0; if(flag==1) printf("PACKAGE\n"); else return PACKAGE;}
{RETURN}	{column += yyleng; pontvirgula = 1; if(flag==1) printf("RETURN\n"); else return RETURN;}
{AND} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("AND\n"); else return AND;}
{ASSIGN} 	{column += yyleng; pontvirgula = 0; if(flag==1) printf("ASSIGN\n"); else return ASSIGN;}
{STAR} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("STAR\n"); else return STAR;}
{COMMA} 	{column += yyleng; pontvirgula = 0; if(flag==1) printf("COMMA\n"); else return COMMA;}
{DIV} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("DIV\n"); else return DIV;}
{EQ}		{column += yyleng; pontvirgula = 0; if(flag==1) printf("EQ\n"); else return EQ;}
{GE} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("GE\n"); else return GE;}
{GT} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("GT\n"); else return GT;}
{LBRACE} 	{column += yyleng; pontvirgula = 0; if(flag==1) printf("LBRACE\n"); else return LBRACE;}
{LE} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("LE\n"); else return LE;}
{LPAR} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("LPAR\n"); else return LPAR;}
{LSQ} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("LSQ\n"); else return LSQ;}
{LT} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("LT\n"); else return LT;}
{MINUS} 	{column += yyleng; pontvirgula = 0; if(flag==1) printf("MINUS\n"); else return MINUS;}
{MOD} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("MOD\n"); else return MOD;}
{NE} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("NE\n"); else return NE;}
{NOT} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("NOT\n"); else return NOT;}	
{OR} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("OR\n"); else return OR;}
{PLUS} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("PLUS\n"); else return PLUS;}
{RBRACE} 	{column += yyleng; pontvirgula = 1; if(flag==1) printf("RBRACE\n"); else return RBRACE;}
{RPAR} 		{column += yyleng; pontvirgula = 1; if(flag==1) printf("RPAR\n"); else return RPAR;}
{RSQ} 		{column += yyleng; pontvirgula = 1; if(flag==1) printf("RSQ\n"); else return RSQ;}
{ELSE} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("ELSE\n"); else return ELSE;}
{FOR} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("FOR\n"); else return FOR;}
{IF} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("IF\n"); else return IF;}
{VAR} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("VAR\n"); else return VAR;}
{INT} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("INT\n"); else return INT;}
{FLOAT32} 	{column += yyleng; pontvirgula = 0; if(flag==1) printf("FLOAT32\n"); else return FLOAT32;}
{BOOL} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("BOOL\n"); else return BOOL;}
{STRING} 	{column += yyleng; pontvirgula = 0; if(flag==1) printf("STRING\n"); else return STRING;}
{PRINT} 	{column += yyleng; pontvirgula = 0; if(flag==1) printf("PRINT\n"); else return PRINT;}
{PARSEINT} 	{column += yyleng; pontvirgula = 0; if(flag==1) printf("PARSEINT\n"); else return PARSEINT;}
{FUNC} 		{column += yyleng; pontvirgula = 0; if(flag==1) printf("FUNC\n"); else return FUNC;}
{CMDARGS} 	{column += yyleng; pontvirgula = 0; if(flag==1) printf("CMDARGS\n"); else return CMDARGS;}
{RESERVED}	{column += yyleng; pontvirgula = 0; if(flag==1) printf("RESERVED(%s)\n", yytext); else{yylval.string = strdup(yytext); return RESERVED;}}

{ID}		{column += yyleng; pontvirgula = 1; if(flag==1) printf("ID(%s)\n", yytext); else {yylval.string = strdup(yytext); return ID;}}
{INTLIT} 	{column += yyleng; pontvirgula = 1; if(flag==1) printf("INTLIT(%s)\n", yytext); else {yylval.string = strdup(yytext); return INTLIT;}}
{REALLIT} 	{column += yyleng; pontvirgula = 1; if(flag==1) printf("REALLIT(%s)\n",yytext); else {yylval.string = strdup(yytext); return REALLIT;}}

.			{pontvirgula = 0; printf("Line %d, column %d: illegal character (%s)\n", line, column, yytext); column += yyleng;} 


%%

int main(int argc, const char* argv[]) {
	if(argc>1 ){ 
		if(strcmp(argv[1],"-l")==0 || atoi(argv[1]) == -1)//erros lexicais e tokens
			flag= 1;	
		else if(strcmp(argv[1],"-t")==0) //imprimir arvore se nao houver erros sintaxe
			ast= 1; 
	}
	yyparse();
	
	return 0; 
}

int yywrap(){

	return 1;
}
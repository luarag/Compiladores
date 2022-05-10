	/* Filipa Martins 2016267248 Ana Luisa Oliveira 2014194117 */

%{
	#include <stdio.h>
	#include <string.h> 
	#include <stdlib.h> 
	#include "ast.h"
	int yylex(void);
	void yyerror(const char* s);
	
	extern int column;   
	extern int line;
	extern int flag; 
	extern int ast;
	extern int eof_flag;
	extern int eof_column;
	extern char* yytext;
	extern int yyleng;
	int eof_line;
	int errors=0;
	
%}

%union { 
	
	char* string; 
	ptr_node ptrNo;
	ptr_list ptrList;
}
		
%token SEMICOLON 	
%token BLANKID 	
%token PACKAGE
%token RETURN		
%token AND 	
%token ASSIGN 		
%token STAR 		
%token COMMA 		
%token DIV 		
%token EQ			
%token GE 		
%token GT 			
%token LBRACE 		
%token LE 			
%token LPAR 		
%token LSQ 		
%token LT 			
%token MINUS 		
%token MOD 		
%token NE 			
%token NOT 			
%token OR 			
%token PLUS 		
%token RBRACE 		
%token RPAR 		
%token RSQ 		
%token ELSE 		
%token FOR 		
%token IF 			
%token VAR 		
%token INT 		
%token FLOAT32 	
%token BOOL 		
%token STRING 		
%token PRINT 		
%token PARSEINT 	
%token FUNC 		
%token CMDARGS 	

%token <string> RESERVED	    
%token <string> ID  		
%token <string> INTLIT		
%token <string> REALLIT		
%token <string> STRLIT 	



%right ASSIGN 
%left OR 
%left AND
%left LT GT LE GE EQ NE
%left PLUS MINUS 
%left STAR DIV MOD
%right NOT UNARY

%right RPAR RBRACE RSQ
%left LPAR LBRACE LSQ  
%left COMMA SEMICOLON


%nonassoc IFF
%nonassoc FORR
%nonassoc ELSE

%type <ptrNo> Program
%type <ptrList> Declarations 
%type <ptrList> VarDeclaration 
%type <ptrList> VarSpec 
%type <ptrList> Comid 
%type <ptrNo> Type
%type <ptrNo> FuncDeclaration
%type <ptrNo> FuncHeader
%type <ptrList> Parameters
%type <ptrList> Comidt
%type <ptrNo> FuncBody
%type <ptrList> VarsAndStatements
%type <ptrNo> Statement
%type <ptrList> Statesemi
%type <ptrNo> ParseArgs
%type <ptrNo> FuncInvocation
%type <ptrList> Comaexp
%type <ptrNo> Expr





%%
Program: PACKAGE ID SEMICOLON Declarations 									{if(ast==1 && errors==0) {ptr_list sons=createList(); if($4!=NULL){sons=join(sons,$4);} ptr_node prog=createNode("Program",sons,NULL); print(prog,0); $$=prog; deleteTree(prog);}}


Declarations: Declarations VarDeclaration SEMICOLON 						{if(ast==1 && errors==0) {ptr_list l = createList(); if($1!=NULL){join(l,$1);} if($2!=NULL){join(l,$2);} $$=l;}}
	| Declarations FuncDeclaration SEMICOLON 								{if(ast==1 && errors==0) {ptr_list l = createList(); if($1!=NULL){join(l,$1);} if($2!=NULL){addnode(l,$2);} $$=l;}}
	|																		{if(ast==1 && errors==0) $$ = NULL;}
	;

VarDeclaration: VAR VarSpec 												{if(ast==1 && errors==0) $$ = $2;}	
	| VAR LPAR VarSpec SEMICOLON RPAR 										{if(ast==1 && errors==0) $$ = $3;}
	;
VarSpec: ID Comid Type 														{if(ast==1 && errors==0) {ptr_list l=createList(); addnode(l,createNode("Id",NULL,$1)); if($2!=NULL)l=join(l,$2);$$=declareVar($3,l);}}
	;

Comid: Comid COMMA ID 														{if(ast==1 && errors==0) {ptr_list l=createList(); if($1!=NULL){l=join(l,$1);}addnode(l,createNode("Id",NULL,$3));$$=l;}}
	| 																		{if(ast==1 && errors==0) $$ = NULL;}
	;

Type: INT 																	{if(ast==1 && errors==0); $$=createNode("Int",NULL,NULL);}
	| FLOAT32 																{if(ast==1 && errors==0); $$=createNode("Float32",NULL,NULL);}
	| BOOL 																	{if(ast==1 && errors==0); $$=createNode("Bool",NULL,NULL);}
	| STRING 																{if(ast==1 && errors==0); $$=createNode("String",NULL,NULL);}
	;	

FuncDeclaration: FuncHeader FuncBody										{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1);addnode(sons,$2);$$=createNode("FuncDecl",sons,NULL);}}
				;

FuncHeader: FUNC ID LPAR Parameters RPAR Type								{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,createNode("Id",NULL,$2)); addnode(sons,$6); addnode(sons,createNode("FuncParams",$4,NULL)); $$=createNode("FuncHeader",sons,NULL);}}   
	| FUNC ID LPAR RPAR Type 												{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,createNode("Id",NULL,$2)); addnode(sons,$5); addnode(sons,createNode("FuncParams",NULL,NULL));  $$=createNode("FuncHeader",sons,NULL);}}    
	| FUNC ID LPAR Parameters RPAR 											{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,createNode("Id",NULL,$2)); addnode(sons,createNode("FuncParams",$4,NULL)); $$=createNode("FuncHeader",sons,NULL);}}  
	| FUNC ID LPAR RPAR														{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,createNode("Id",NULL,$2)); addnode(sons,createNode("FuncParams",NULL,NULL)); $$=createNode("FuncHeader",sons,NULL);}}  
	;




Parameters: ID Type Comidt 													{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$2); addnode(sons,createNode("Id",NULL,$1)); ptr_node n=createNode("ParamDecl",sons,NULL);ptr_list l=createList(); addnode(l,n); if($3!=NULL) {l=join(l,$3);}$$=l;}}
	;

Comidt: Comidt COMMA ID Type 												{if(ast==1 && errors==0) {ptr_list sons = createList(); ptr_list l=createList(); if($1!=NULL){l=join(l,$1);} addnode(sons,$4); addnode(sons,createNode("Id",NULL,$3)); ptr_node no = createNode("ParamDecl",sons,NULL); addnode(l,no); $$=l;}}
	| 																		{if(ast==1 && errors==0) $$ = NULL; }
	;
FuncBody: LBRACE VarsAndStatements RBRACE 									{if(ast==1 && errors==0) {$$=createNode("FuncBody",$2,NULL);}}
	;
VarsAndStatements: VarsAndStatements VarDeclaration SEMICOLON 				{if(ast==1 && errors==0){ptr_list l=createList();if($1!=NULL){l=join(l,$1);}join(l,$2); $$=l;}} 
	|VarsAndStatements Statement SEMICOLON 									{if(ast==1 && errors==0){ptr_list l=createList();if($1!=NULL){l=join(l,$1);}addnode(l,$2); $$=l;}}
	|VarsAndStatements SEMICOLON 											{if(ast==1 && errors==0) $$ = $1;}
	|																		{if(ast==1 && errors==0) $$= NULL;}
	;
Statement: ID ASSIGN Expr 													{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,createNode("Id",NULL,$1)); addnode(sons,$3); $$=createNode("Assign",sons,NULL);}}
	|LBRACE Statesemi RBRACE 												{if(ast==1 && errors==0) {ptr_list l=$2; if(l==NULL){$$=NULL;}else{ if(l->root == NULL){$$=NULL;}else if(l->root!=NULL && l->root->next ==NULL){ $$=l->root;}else{$$=createNode("Block",l,NULL);}}}}
	|IF Expr LBRACE Statesemi RBRACE %prec IFF								{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$2); addnode(sons,createNode("Block",NULL,NULL)); if($4!=NULL){addnode(sons,createNode("Statesemi",$4,NULL));}  addnode(sons,createNode("Block",NULL,NULL)); $$=createNode("If",sons,NULL);}}
	|IF Expr LBRACE Statesemi RBRACE ELSE LBRACE Statesemi RBRACE 			{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$2); addnode(sons,createNode("Block",NULL,NULL)); if($4!=NULL){addnode(sons,createNode("Statesemi",$4,NULL));}  addnode(sons,createNode("Block",NULL,NULL)); if($8!=NULL){addnode(sons,createNode("Statesemi",$8,NULL));} $$=createNode("If",sons,NULL);}} 
	|FOR Expr LBRACE Statesemi RBRACE %prec FORR							{if(ast==1 && errors==0) {ptr_list sons=createList(); if($2!=NULL){addnode(sons,$2);} else{addnode(sons, createNode("Block",NULL,NULL));} addnode(sons,createNode("Block",NULL,NULL)); if($4!=NULL){addnode(sons,createNode("Statesemi",$4,NULL));} ;$$=createNode("For",sons,NULL);}} 
	|FOR LBRACE Statesemi RBRACE %prec FORR									{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,createNode("Block",NULL,NULL)); if($3!=NULL){addnode(sons,createNode("Statesemi",$3,NULL));} $$=createNode("For",sons,NULL);}} 
	|RETURN Expr 															{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$2); $$=createNode("Return",sons,NULL);}} 
	|RETURN 																{if(ast==1 && errors==0) {$$=createNode("Return",NULL,NULL);}}
	|FuncInvocation 														{if(ast==1 && errors==0) $$ = $1; }
	|ParseArgs 																{if(ast==1 && errors==0) $$ = $1; }
	|PRINT LPAR Expr RPAR													{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$3); $$=createNode("Print",sons,NULL);}}
	|PRINT LPAR STRLIT RPAR 												{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,createNode("StrLit",NULL,$3)); $$=createNode("Print",sons,NULL);}} 
	|error																	{}
	;

Statesemi: Statesemi Statement SEMICOLON 									{if(ast==1 && errors==0) {ptr_list sons=createList(); if($1!=NULL){sons=join(sons,$1);}addnode(sons,$2); $$=sons;}}
	| 																		{if(ast==1 && errors==0) $$=NULL;}
	;
ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR 	{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,createNode("Id",NULL,$1)); addnode(sons,$9); $$=createNode("ParseArgs",sons,NULL);}}
	|ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR				 		{}
	;
FuncInvocation: ID LPAR Expr Comaexp RPAR 									{if(ast==1 && errors==0) {ptr_list sons=createList();addnode(sons,createNode("Id",NULL,$1));addnode(sons,$3); if($4!=NULL){sons=join(sons,$4);}$$=createNode("Call",sons,NULL);}} 
	|ID LPAR RPAR 															{if(ast==1 && errors==0) {ptr_list sons=createList();addnode(sons,createNode("Id",NULL,$1));$$=createNode("Call",sons,NULL);}} 
	|ID LPAR error RPAR														{}
	;
Comaexp: Comaexp COMMA Expr 												{if(ast==1 && errors==0) {ptr_list sons=createList();if($1!=NULL){sons=join(sons,$1);} addnode(sons,$3); $$=sons;}}
	| 																		{if(ast==1 && errors==0) $$=NULL;}
	;

Expr: Expr OR Expr 															{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("Or",sons,NULL);}}
	| Expr AND Expr 														{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("And",sons,NULL);}}
	| Expr LT Expr 															{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("Lt",sons,NULL);}}
	| Expr GT Expr 															{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("Gt",sons,NULL);}}
	| Expr EQ Expr 															{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("Eq",sons,NULL);}}
	| Expr NE Expr 															{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("Ne",sons,NULL);}}
	| Expr LE Expr															{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("Le",sons,NULL);}}
	| Expr GE Expr 															{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("Ge",sons,NULL);}}
	| Expr PLUS Expr														{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("Add",sons,NULL);}}
	| Expr MINUS Expr														{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("Sub",sons,NULL);}}
	| Expr STAR Expr 														{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("Mul",sons,NULL);}}
	| Expr DIV Expr 														{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("Div",sons,NULL);}}
	| Expr MOD Expr 														{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$1); addnode(sons,$3); $$=createNode("Mod",sons,NULL);}}
	| NOT Expr %prec UNARY													{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$2); $$=createNode("Not",sons,NULL);}}
	| MINUS Expr %prec UNARY												{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$2); $$=createNode("Minus",sons,NULL);}}
	| PLUS Expr %prec UNARY													{if(ast==1 && errors==0) {ptr_list sons=createList(); addnode(sons,$2); $$=createNode("Plus",sons,NULL);}}
	| INTLIT 																{if(ast==1 && errors==0) $$=createNode("IntLit",NULL,$1);}
	| REALLIT 																{if(ast==1 && errors==0) $$=createNode("RealLit",NULL,$1);}
	| ID 																	{if(ast==1 && errors==0) $$=createNode("Id",NULL,$1);}
	| FuncInvocation 														{if(ast==1 && errors==0) {$$=$1;}}
	| LPAR Expr RPAR 														{if(ast==1 && errors==0) {$$=$2;}}
	| LPAR error RPAR														{}
	;

%%

void yyerror(const char *s){
	errors++;
	
	if (flag == 0){
		printf("Line %d, column %d: %s: %s\n", line, (int)(column-strlen(yytext)), s, yytext);
	}
	
}



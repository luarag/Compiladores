#include <stdio.h>
#include <stdlib.h>
#include "structs.h"
#include <string.h>

/* Filipa Martins 2016267248 Ana Luisa Oliveira 2014194117 */

ptr_list createList(){
	ptr_list list;
	list = (ptr_list)malloc(sizeof(List));
	list->root = NULL;
	return list;
}

ptr_node createNode(char* type, ptr_list sons,char* value){
	ptr_node node;
	node =(ptr_node)malloc(sizeof(Node));
	
	if(sons == NULL)
		sons = createList();
	node->sons = sons;
	node->next = NULL;
    node->type = (char*)malloc((strlen(type)+1)*sizeof(char));
    strcpy(node->type, type);
    
	if(strcmp("Id",type)==0 || strcmp("IntLit",type)==0 || strcmp("RealLit",type)==0 || strcmp("StrLit",type)==0 ){
		node->value = (char*)malloc((strlen(value)+1)*sizeof(char));
		strcpy(node->value, value);
	}
	return node;
}


void addnode(ptr_list list,ptr_node no){
	ptr_node aux = list->root;
	if(no!=NULL){
		if(list != NULL && aux == NULL){
	        list->root=createNode(no->type,no->sons,no->value);
	        return;
		}
		while(aux->next!=NULL){
			aux=aux->next;
		}
		aux->next=createNode(no->type,no->sons,no->value);
	}
	return;
}

ptr_list join(ptr_list l1, ptr_list l2){
   	ptr_node temp=l1->root;

    if(l2->root!=NULL && l2!=NULL && l1!=NULL){
	
		if(l1->root==NULL){ 
			l1->root=l2->root; 
			free(l2); 
			return l1;
		}
	    else{
			while(temp->next!= NULL)
				temp=temp->next;
			temp->next=l2->root;
			free(l2);
		}
	}
	return l1;
}


void print(ptr_node no,int points){
	char* type=no->type;
	int i;
	for(i=0;i<points;i++){
		if(strcmp("Statesemi",type)!=0){
			printf("..");
		}
	}
	
	if(strcmp("Statesemi",type)!=0){
		printf("%s",type);
	}
	if(strcmp("Id",type)==0 || strcmp("IntLit",type)==0 || strcmp("RealLit",type)==0 || strcmp("StrLit",type)==0 ){
		printf("(%s)",no->value);
	}
	if(strcmp("Statesemi",type)!=0){
		printf("\n");
	}
	
	ptr_node aux=no->sons->root;
	while(aux){
		print(aux,points+1);
		aux=aux->next;
	}	
}


void deleteTree(ptr_node no){
	ptr_node aux;
	if(no->sons->root!=NULL){
		while(no->sons->root !=NULL){
			aux = no->sons->root;
			no->sons->root = no->sons->root->next; 
			deleteTree(aux);	
		}
		free(no->sons);
		free(no);
	}
}


ptr_list declareVar(ptr_node type, ptr_list list_ids){

	ptr_node temp=list_ids->root;
    ptr_node prox;
    ptr_list decVar=createList();
    
	while(temp!=NULL){ 
	    prox=temp->next;
	    ptr_list sons=createList();
	    ptr_node id = createNode(strdup(temp->type),temp->sons,strdup(temp->value));
		addnode(sons, type);
		addnode(sons, id);
	    addnode(decVar,createNode("VarDecl",sons,NULL));
	    temp=prox;
    }
	free(list_ids);
	return decVar;
}





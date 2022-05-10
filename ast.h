#ifndef AST_H
#define AST_H
#include "structs.h"


ptr_node createNode(char* type, ptr_list sons,char* value);
ptr_list createList();
void addnode(ptr_list list,ptr_node no);
ptr_list join(ptr_list l1,ptr_list l2);
void print(ptr_node no, int points);
void deleteTree(ptr_node no);
ptr_list declareVar(ptr_node type,ptr_list list_ids);

#endif
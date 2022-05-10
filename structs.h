#ifndef STRUCTS_H
#define STRUCTS_H

/*Estruturas*/

typedef struct node* ptr_node;
typedef struct list* ptr_list;

typedef struct node{
	char *type;
	char *value; 
	ptr_list sons; 
	ptr_node next; 
}Node;


typedef struct list{
	ptr_node root;
}List;


#endif /* STRUCTS_H */
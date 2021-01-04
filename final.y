%{
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <limits.h>

typedef struct Node{//create the struct type for all node
    int number;
    char* work;//the job node do
    char* type; //the type of the node
    struct Node* Child[100];
    struct Node* Par;
    struct Node* Fun;
    int Childs;
    int MChilds;
    char *var;
}nodepointer;

int Varpointer=-1;
int i;
struct Node *initial;//the first node
struct Node *Gpar = NULL;//used to point the node 
struct Node *newnode;
struct Node *Varstack[100];//to store the Var and Funname
void yyerror(const char *message);
void createnode(char* type,int num);
void setnode(char* work);
void Puttostack();
void Count();
void anstonode();
void Printresult(struct Node *node);
%}
%union{
int ival;
char* word;
}

%token<ival> boolean
%token<ival> number
%token<word> id
%token<word> numop
%token<word> print
%token<word> define
%token<word> IF
%token<word> func
%token<word> logicop
%token<word> lp
%token<word> rp

%type<word> LP
%type<word> RP
%%
PROGRAM		: STMT2 /*recurrence*/
STMT2 : STMT 
STMT	: EXP  | DEFSTMT | PRINTSTMT  | STMT STMT2 
EXP		: boolean{createnode("bool",$1);} | number{createnode("num",$1);} | VARIABLE
| NUMOP | LOGICOP| FUNEXP 
| FUNCALL | IFEXP  
| numop {setnode($1);}
;
DEFSTMT : LP define {setnode($2);} VARIABLE EXP RP
PRINTSTMT	: LP  print{setnode($2);} EXP RP 
NUMOP		:LP numop{setnode($2);} EXP EXP2 RP
| LP numop{setnode($2);} RP
; 
LOGICOP : 
LP Log_OP EXP EXP2 RP
|
LP Log_OP EXP RP
Log_OP:logicop {setnode($1);}
IFEXP : LP IF{setnode($2);} EXP EXP2 RP
EXP2 : EXP
|EXP EXP2
;
FUNCALL : LP FUNEXP EXP RP
|LP FUNEXP EXP EXP2 RP
|LP FUNCNAME EXP RP
|LP FUNCNAME EXP EXP2 RP
|LP FUNCNAME RP
;
FUNEXP : LP func{setnode($2);} funID EXP RP
;
funID :LP{setnode("varfunused");} funvar RP
|LP{setnode("varfunused");} RP
;
funvar : funvar2 | funvar funvar2
;
funvar2 : id{
  createnode("funvar",0);
  newnode->var = $1;
  // printf("the char is %s\n",newnode->var);
}
FUNCNAME : id{//find
  bool exist=0;
  if(Varpointer!=-1){//the funcname have been stored in stack
      for(i=0;i<=Varpointer;i++){
        if(!strcmp(Varstack[i]->var,$1)){//if the var is in stack
        exist = 1;
        // printf("existed in Funstack %d\n" ,exist);
        }
      }
    }
  if(exist == 1){//only need to check whether in stack, VARIABLE will create node and store
    for(i=0;i<=Varpointer;i++){
      if(!strcmp(Varstack[i]->var,$1)){//if the var is in stack, create new node to put fun tree
        // printf("the Gpar %p\n",Gpar);
        // printf("the Gpar's child %p\n",Gpar->Child[0]);
        // printf("the child is at %p\n",Varstack[i]->Child[0]);
        Gpar->Childs=Gpar->Childs+1;
        Gpar->Child[Gpar->Childs] = Varstack[i]->Child[0];//connet the define func to print's child
      }
    }
  }else{
    printf("haven't difine fun yet\n");
    yyerror("");
  }
}
VARIABLE : id {
  bool exist=0;
  bool isfunvar=0;
  int i;
  if(initial->Childs==1){//the "fun" will at [1]
    if(!strcmp(initial->Child[1]->Child[0]->work,"varfunused")){//the node store var for fun
    isfunvar = 1;
    for(i=0;i<=initial->Child[1]->Child[0]->Childs;i++){
      if(!strcmp(initial->Child[1]->Child[0]->Child[i]->var,$1)){//if same var same as id
        newnode=initial->Child[1]->Child[0]->Child[i];
        createnode("var",0);break;
      }
    }
  }
  }
  if(isfunvar == 0){ //if the tree have no "varfunused", means its just define
    if(Varpointer!=-1){//have var store in stack, check if exist
      for(i=0;i<=Varpointer;i++){
        if(!strcmp(Varstack[i]->var,$1)){//if the var is in stack
        exist = 1;
        printf("existed in var stack %d" ,exist);
        }
      }
    }
    if(exist == 0){// if not exist,create new node and put address in Varstack,then connect the newnode and Gpar
      newnode=malloc(sizeof(struct Node));
      newnode->var = $1;
      newnode->work = "var";
      // printf("the var is %s\n",newnode->var);
      // printf("the node address is %p\n",newnode);
      // printf("the newnode work is %s\n",newnode->work);
      newnode->Childs = -1;
      Varstack[++Varpointer]= newnode;
      Gpar->Childs=Gpar->Childs+1; 
      // printf("the childsize of Gpar is %d \n",Gpar->Childs);
      Gpar->Child[Gpar->Childs] = newnode;
      // printf("the Child[%d] have new node\n",Gpar->Childs);
      newnode->Par=Gpar;
    }else{//for fun call
     for(i=0;i<=Varpointer;i++){
      if(!strcmp(Varstack[i]->var,$1)){//if the var is in stack, connect the child node to exist var address
        // printf("hehehe %s\n",Varstack[i]->var);
        // printf("hehehe %p\n",Varstack[i]);
        // printf("ohohoh %s\n",$1);
        // printf("the Gpar %p\n",Gpar);
        // printf("the Gpar's child %p\n",Gpar->Child[0]);
        Gpar->Childs=Gpar->Childs+1;
        Gpar->Child[Gpar->Childs] = Varstack[i];
      }
    }
  }
}
}

LP : lp{
newnode = malloc(sizeof(struct Node));//create new node when met (
// printf("newnode 的位址：%p\n", newnode);
newnode->type=NULL;
newnode->Par=NULL;
newnode->Fun=NULL;
newnode->work="(";
// printf("the work is %s \n",newnode->work);
newnode->Childs=-1;
newnode->MChilds=INT_MIN;
newnode->number=INT_MAX;
if(Gpar == NULL){//no node to linked
initial = newnode;
Gpar=initial;//let global parent point initial
/*printf("initial (Gpar) 的位址：%p\n", Gpar);*/
}else{//otherwise
Puttostack();
}
}

RP : rp{
  // printf("the parent of Gpar %p\n",Gpar->Par);
  if(Gpar->Par!=NULL){//if not at top , Gpar go up
    Gpar = Gpar->Par;
    // printf("the Gpar change to %p\n",Gpar);
  }else{
    if((!strcmp(initial->work,"print-num")||!strcmp(initial->work,"print-bool"))&&initial->Childs>0){//if its print fun
      int i;
      if(!strcmp(initial->Child[2]->work,"(")){//the recall of fun's Child[2] must be "("
          int i;
          if(initial->Child[2]->number==INT_MAX){//if the "(" haven't had value yet
            for(i=initial->Childs; i>2; i-=2){//count even put to odd node
            Count(initial->Child[i]);
            anstonode(initial->Child[i-1],initial->Child[i]);
            // printf("the number is %d and the type is %s\n",initial->Child[i-1]->number,initial->Child[i-1]->type);
            // printf("the Child [%d] work is %s\n",i-1,initial->Child[i-1]->work);
            }
          }else{//have value to calculate
            int p=initial->Child[1]->Child[0]->Childs;
              for(i=initial->Childs-1;i>1;i-=2){
              anstonode(initial->Child[1]->Child[0]->Child[p--],initial->Child[i]);
            }
            initial->Child[0]=initial->Child[1];//put to first child node
            initial->Childs=0;
        }
      }else{//only fun
      // printf("the childs is %d the childs of initial %d\n",initial->Child[1]->Child[0]->Childs,initial->Childs);
      int i;
      int p=initial->Child[1]->Child[0]->Childs;//the size of vars
      for(i=initial->Childs;i>1;i--){//for all child the fun is at [1] num is at [1++]
        anstonode(initial->Child[1]->Child[0]->Child[p--],initial->Child[i]);//set numnode's num &type back
        // printf("the child 0 at %p the child 1 at%p\n",initial->Child[0],initial->Child[1]);
      }
      initial->Child[0]=initial->Child[1];
      initial->Childs=0;
      }
    }else{//calculate the result
      // printf("in the count\n");
      Count(initial);
      Gpar=NULL;//after count, release the Gpar
    }
  }
}
%%
void Puttostack(){//put in the parent's childs stack then connect
   Gpar->Childs=Gpar->Childs+1; 
   /* printf("the childsize of Gpar is %d \n",Gpar->Childs); */
   Gpar->Child[Gpar->Childs] = newnode;
   /* printf("the Child[%d] have new node\n",Gpar->Childs); */
   newnode->Par=Gpar;
}

void anstonode(struct Node *node,struct Node *ans){//return the answer up to the node
  node->number = ans->number;/*printf("the ans num is %d and the node num is %d \n",newnode->number,ans->number);*/
  node->type = ans->type;/*printf("the ans type is %s and the node type is %s\n",newnode->type,ans->type);*/
}

void createnode(char* type,int num){//create the node and give its type and number
  if(strcmp(type,"var"))newnode=malloc(sizeof(struct Node));//if is "var" ,dont malloc,else create new node
  /* printf("Gpar 的位址：%p\n", Gpar);
  printf("Gpar numeber %d\n", Gpar->number);
  printf("the newnode(create) 的位址：%p\n", newnode); */
  newnode->work = type; 
  /* printf("the newnode(create) type is %s \n",newnode->work); */
  newnode->number = num;
  /* printf("the newnode(create) num is %d \n",newnode->number); */
  newnode->Childs = -1;
  Puttostack();

  //give the node its type
  if(!strcmp(type,"num")||!strcmp(type,"boolean"))newnode->type = type;
}

void setnode(char* work){//give the node its work
  if(strcmp(newnode->work,"(")){
    printf("syntax error\n");
    yyerror("");
  }
  /* printf("newnode 的位址：%p\n", newnode); */
  
  newnode->work = work;//replace "(" to operator
  /* printf("the newnode work is %s\n",newnode->work);  */
  /* printf("the parent of Gpar %p\n",Gpar->Par); */
  Gpar=newnode;//child to parent
  newnode= NULL;//child release
  /* printf("Gpar 的位址：%p\n", Gpar); */
  int i;
  /* printf("the childs of Gpar is %d\n",Gpar->Childs); */
  //set the node's type
  if(!strcmp(work,"and")||!strcmp(work,"or")||!strcmp(work,"not")||!strcmp(work,">")||!strcmp(work,"<")||!strcmp(work,"=")){
    Gpar->type="bool";
  }
  else if(!strcmp(work,"+")||!strcmp(work,"-")||!strcmp(work,"*")||!strcmp(work,"/")){
    Gpar->type="num";
  }
  //set the child max size
  if(!strcmp(work,"not"))Gpar->MChilds=1;
  else if (!strcmp(work,"-")||!strcmp(work,"/")||!strcmp(work,"mod")||!strcmp(work,">")||!strcmp(work,"<"))Gpar->MChilds=2;
  else if (!strcmp(work,"+")||!strcmp(work,"*")||!strcmp(work,"=")||!strcmp(work,"and")||!strcmp(work,"or"))Gpar->MChilds=INT_MAX;
}

void Printresult(struct Node *node){//print the result
  if(!strcmp(node->work ,"print-num")){
    printf("-> %d\n",node->Child[0]->number);
  }else if(!strcmp(node->work ,"print-bool")){
    if(node->Child[0]->number){
      printf("-> #t\n");
    }else{
      printf("-> #f\n");
    }
  }
}

void Count(struct Node *node){//calculate
  int size=0;
  int answer=0;
  if(!strcmp(node->work,"print-num")||!strcmp(node->work,"print-bool")){//if initial is printstmt
    /* printf("before the result node %p %d\n",node,node->Childs); */
    Count(node->Child[node->Childs]);//count the Child[0]
    Printresult(node);//print result
  }else if(!strcmp(node->work,"if")){//count 3 node first->condition ;second->"if"value;third->"else" value
    Count(node->Child[0]);
    Count(node->Child[1]);
    Count(node->Child[2]);
    /* printf("the bool of if is %d\n",node->Child[0]->number);
    printf("%d\n",node->Child[1]->number);
    printf("%d\n",node->Child[2]->number); */
    if(node->Child[0]->number == 0){//then
      answer = node->Child[2]->number;
    }else if(node->Child[0]->number == 1){//if
      answer = node->Child[1]->number;
    }
    node->number = answer;
  }else if(!strcmp(node->work,"define")){
    if(!strcmp(node->Child[1]->work,"fun")){//if is define func, give fun node
      /* printf("the tree has been connect from node->Child[1] %p to node->Child[0]->Child[0]%p\n",node->Child[1],node->Child[0]->Child[0]); */
      node->Child[0]->Child[0] = node->Child[1];
      /* printf("the tree has been connect from node->Child[1] %p to node->Child[0]->Child[0]%p\n",node->Child[1],node->Child[0]->Child[0]); */
    }else{//only define first->"var"; second->"number"
    Count(node->Child[0]);
    Count(node->Child[1]);
    node->Child[0]->number = node->Child[1]->number;
    }
    
  }else if(!strcmp(node->work,"fun")){//only func
		Count(node->Child[1]);//count the "fun" node
		anstonode(node,node->Child[1]);
  }else if(!strcmp(node->work,"num")||!strcmp(node->work,"bool")){//do nothing
      
  }else if(node->Childs==-1){//syntax error
    if(!strcmp(node->work,"+")||!strcmp(node->work,"-")||!strcmp(node->work,"*")||!strcmp(node->work,"/")||!strcmp(node->work,"mod")||!strcmp(node->work,">")||!strcmp(node->work,"<")||!strcmp(node->work,"=")){
      printf("syntax error , no number\n");
    }
  }else if(node->Childs==0&&strcmp(node->work,"not")){
    if(!strcmp(node->work,"+")||!strcmp(node->work,"-")||!strcmp(node->work,"*")||!strcmp(node->work,"/")||!strcmp(node->work,"mod")||!strcmp(node->work,">")||!strcmp(node->work,"<")||!strcmp(node->work,"=")){
      printf("syntax error, only 1 number\n");
    }
  }
  else{//the numeric and logic counting
    int size=0;
    while(size<=node->Childs){
		Count(node->Child[size++]);
  }
  if(!strcmp(node->work,"not")){//when not
    if(node->Child[0]->number == 0){
      answer = node->Child[0]->number = 1;
    }else if(node->Child[0]->number == 1){
      answer = node->Child[0]->number = 0;
    }
  }else if(!strcmp(node->work,"-")){//when minus
    answer = node->Child[0]->number - node->Child[1]->number;
  }else if(!strcmp(node->work,"/")){//when divide
    answer = node->Child[0]->number / node->Child[1]->number;
  }else if(!strcmp(node->work,"mod")){//when mod
    answer = node->Child[0]->number % node->Child[1]->number;
  }else if(!strcmp(node->work,">")){//when >
    if(node->Child[0]->number > node->Child[1]->number)
      answer = 1;
    else{
      answer = 0;
    }
  }else if(!strcmp(node->work,"<")){//when <
    if(node->Child[0]->number < node->Child[1]->number){
      answer = 1;
     }else{
      answer = 0;
    }
  }else if(!strcmp(node->work,"+")){//when plus
    int i;
    int temp;
    for(i=node->Childs; i>=0; i--){
      temp = answer + node->Child[i]->number;
      answer = temp;
    }
    answer = temp;
  }else if(!strcmp(node->work,"*")){//when multiple
    int i;
    int temp;
    answer = 1;
    for(i=node->Childs; i>=0; i--){
      temp = answer * node->Child[i]->number;
      answer = temp;
    }
    answer = temp;
  }else if(!strcmp(node->work,"=")){//when equal
    int i;
    answer = 1;
    for(i=node->Childs; i>0; i--){
      if(node->Child[i]->number != node->Child[i-1]->number){
          answer = 0;
      }
    }
  }else if(!strcmp(node->work,"and")){//when and
    int i;
    answer = 1;
    for(i=node->Childs; i>=0; i--){
      if(node->Child[i]->number == 0){
          answer = 0;
      }
    }
  }else if(!strcmp(node->work,"or")){//when or
    int i;
    for(i=node->Childs; i>=0; i--){
      if(node->Child[i]->number == 1){
          answer = 1;
      }
    }
  }

  node->number = answer;
  /* printf("th answer is %d\n",node->number); */
  }
}
int main(int argc, char*argv[])
{
    yyparse();
    return 0;
}

void yyerror(const char *message)
{
    fprintf(stderr,"%s\n", message);
    exit(0);
}
# Final_Project---Compiler

## Overview
* LISP is an ancient programming language based on S-expressions and lambda calculus. All operations in Mini-LISP are written in parenthesized prefix notation. For example, a simple mathematical formula $(1 + 2) * 3$ written in Mini-LISP is: $(* (+ 1 2) 3)$

* As a simplified language, Mini-LISP has only three types (Boolean, number and function) and a few operations. 
## Operation Overview
|Name|Symbol|Example|
|:---:|:---:|:---:|
|Plus|+|(+ 1 2) => 3|
|Minus|-|(- 1 2) => -1|
|Multiply|#|(* 2 3) => 6|
|Divide|/|(/ 6 3) => 2|
|Modulus|mod|(mod 8 3) => 2|
|Greater|>|(> 1 2) => #f|
|Smaller|<|(< 1 2) => #t|
|Equal|=|(= 1 2) => #f|
|And|and|(and #t #f) => #f|
|Or|or|(or #t #f) => #t|
|Not|not|(not #t) => #f|

## Implementation
* **How to count**
    I use `Node` to build the tree. After constructing the tree, track back the tree with result value of child tree.

* **Important Node**
    Mainly use these three `stucrt Node` to build the tree.
    
    ![image](https://user-images.githubusercontent.com/73687292/205603056-bc624c0e-bdd7-4708-a7ca-67daa06224ab.png)
* **Create the Node**
    ```yacc
    void createnode(char* type,int num){//create the node and give its type and number
          if(strcmp(type,"var"))newnode=malloc(sizeof(struct Node));//if is "var" ,dont malloc,else create new node
          newnode->work = type; 
          newnode->number = num;
          newnode->Childs = -1;
          Puttostack();

          //give the node its type
          if(!strcmp(type,"num")||!strcmp(type,"boolean"))newnode->type = type;
     }
    ```
* **Connect Child & Parent**
    ```yacc
    void Puttostack(){//put in the parent's childs stack then connect
       Gpar->Childs=Gpar->Childs+1; 
       /* printf("the childsize of Gpar is %d \n",Gpar->Childs); */
       Gpar->Child[Gpar->Childs] = newnode;
       /* printf("the Child[%d] have new node\n",Gpar->Childs); */
       newnode->Par=Gpar;
    }
    ```
    
* **Setting the Node & Move `Gpar` to `newnode`**
    ```yacc
    void setnode(char* work){ //give the node its work
      if(strcmp(newnode->work,"(")){
        printf("syntax error\n");
        yyerror("");
      }
      
      newnode->work = work;   //replace "(" to operator
      Gpar=newnode;//child to parent
      newnode= NULL;//child release
      int i;
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
    ```
    
* **Example of how it works**
  * EX : (print-num(+ 1 2 3))
    ![image](https://user-images.githubusercontent.com/73687292/205605979-d3211ae0-b5d1-48eb-ae19-60d4bc11623f.png)

## Final Result
* **Syntax Validatioin**
  1. Input with operator without operant

     ![image](https://user-images.githubusercontent.com/73687292/205602059-d66e7183-82c0-49fe-87a2-dd5385182cb0.png)
  2. Input with expression doesn't comply with the rules

     ![image](https://user-images.githubusercontent.com/73687292/205602102-35877f15-383b-43b3-9349-1f191cca66bd.png)
  3. Calling the function that hasn't defined yet

     ![image](https://user-images.githubusercontent.com/73687292/205602159-e06f0a89-54c5-42c9-8c11-a19c75d486ef.png)

* **Print**
    When meeting `print-num` or `print-bool`, output the value according to the type of Interger or Boolean, otherwise omit

     ![image](https://user-images.githubusercontent.com/73687292/205606785-c4a8e70b-0eba-4ebf-9e32-cf1c0d1bfde3.png)

* **Numerical Logical Operations**
    General digital and logical calculations, where {+,*,=,and,or} can input multiple data, and {-,/,mod,>,<} can input two data. And least, {not} can only with one input. Otherwise, output error message.
    
    ![image](https://user-images.githubusercontent.com/73687292/205608359-dd20d035-4741-4248-a912-44b8418806c6.png)

* **IF Expression**
* **Variable Define**
* 


wrriten by corn2021/01/05
modify by corn2022/12/05

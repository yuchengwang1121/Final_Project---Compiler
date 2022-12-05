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
    Use `Node` to build the tree. After constructing the tree, track back the tree with result value of child tree.
    Use `Varstacj` to store all variable's `id`. Then use `Varpointer` to find if it exist.
    If the var isn't in the stack, then create one and push into the stack.
    Else, pass the index of the stack where the variable exist to `Gpar`
    
    ![image](https://user-images.githubusercontent.com/73687292/205603056-bc624c0e-bdd7-4708-a7ca-67daa06224ab.png)
    ![image](https://user-images.githubusercontent.com/73687292/205622146-c011c7d4-6d76-4e6e-9562-24682e08cd48.png)
    ```yacc
    if(exist == 0){// if not exist,create new node and put address in Varstack,then connect the newnode and Gpar
          newnode=malloc(sizeof(struct Node));
          newnode->var = $1;
          newnode->work = "var";
          newnode->Childs = -1;
          Varstack[++Varpointer]= newnode;
          Gpar->Childs=Gpar->Childs+1; 
          Gpar->Child[Gpar->Childs] = newnode;
          newnode->Par=Gpar;
      }else{//for fun call
         for(i=0;i<=Varpointer;i++){
            if(!strcmp(Varstack[i]->var,$1)){//if the var is in stack, connect the child node to exist var address
                Gpar->Childs=Gpar->Childs+1;
                Gpar->Child[Gpar->Childs] = Varstack[i];
            }
         }
      }
    ```
    
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
  * EX : (define y(+ 1 2 3))
         (print-num y)
    ![image](https://user-images.githubusercontent.com/73687292/205633032-8e887de2-1450-4cb3-8cf6-fc93d6ce566d.png)


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
    When meeting the keyword `if`,  judge the condition first. If the condition is $True$, print the front expressioin. Else, print the other one.
    Also, the Expression can be a operand or the computation.

    ![image](https://user-images.githubusercontent.com/73687292/205621367-731eb1b9-7caa-477e-a47f-352d7dfda4fe.png)

* **Variable Define**
* ****


wrriten by corn2021/01/05
modify by corn2022/12/05

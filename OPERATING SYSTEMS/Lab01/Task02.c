/*
STEP 1: Start the program.
STEP 2: Declare the variables pid,pid1,pid2.
STEP 3: Call fork() system call to create process.
STEP 4: If pid==-1, exit.
STEP 5: If pid!=-1, get the process id using getpid().
STEP 6: Print the process id.
STEP 7: Stop the program.
*/

#include<stdio.h>
#include<unistd.h>
#include<cstdlib>
int main() {
    int pid,pid1,pid2;
    pid=fork();
    if(pid==-1){
        printf("ERROR IN PROCESS CREATION \n");
        exit(1);
    }
    if(pid!=0){
        pid1=getpid();
        printf("\n the parent process ID is %d\n", pid1);
    }
    else{
        pid2=getpid();
        printf("\n the child process ID is %d\n", pid2);
    }
}

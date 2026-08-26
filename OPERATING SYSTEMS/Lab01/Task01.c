/*
STEP 1: Start the program. 
STEP 2: Create struct dirent.
STEP 3: declare the variable buff and pointer dptr. 
STEP 4: Get the directory name.
STEP 5: Open the directory.
STEP 6: Read the contents in the directory and print it. 
STEP 7: Close the directory.
*/

#include<stdio.h> 
#include<dirent.h>
#include<cstdlib>

struct dirent *dptr;
int main(int argc, char *argv[]){
    char buff[100]; DIR *dirp;
    printf("\n\n ENTER DIRECTORY NAME: "); 
    scanf("%s", buff); 
    if((dirp=opendir(buff))==NULL){
        printf("The given directory does not exist"); exit(1);
    }
    while(dptr=readdir(dirp)){
        printf("%s\n",dptr->d_name);
    }
    closedir(dirp);
}

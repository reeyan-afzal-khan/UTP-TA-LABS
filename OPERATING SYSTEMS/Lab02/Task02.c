/*
STEP 1: Start the program
STEP 2: Open the directory with directory object dp
STEP 3: Read the directory content and print it.
STEP 4: Close the directory.
*/

#include<stdio.h>
#include<dirent.h>

int main(int argc, char **argv){
    DIR *dp;
    struct dirent *link; dp=opendir(argv[1]);
    printf("\n contents of the directory %s are \n", argv[1]);
    while((link=readdir(dp))!=0) {
    printf("%s",link->d_name);
    closedir(dp);
    }
}

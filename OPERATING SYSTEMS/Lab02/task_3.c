/*
STEP 1: Start the program
STEP 2: Declare the variables fline[max], count=0, occurrences=0 and pointers *fp, *newline.
STEP 3: Open the file in read mode.
STEP 4: In while loop check fgets(fline,max,fp)!=NULL
STEP 5: Increment count value.
STEP 6: Check newline=strchr(fline, '\n')
STEP 7: print the count,fline value and increment the occurrence value.
STEP 8: Stop the program
*/

#include<stdio.h>
#include<string.h>
#include<cstdlib>

#define max 1024

void usage(){
    printf("usage:\t. /a.out filename word \n ");
}

int main(int argc, char *argv[]){
    FILE *fp;
    char fline[max]; char *newline; int count=0;
    int occurrences=0;
    if(argc!=3){
    	usage();
    	exit(1);
    }
    if(!(fp=fopen(argv[1],"r"))){
    	printf("grep: couldnot open file : %s \n",argv[1]);
    	exit(1);
    }
    while(fgets(fline,max,fp)!=NULL){
    	count++; if(newline=strchr(fline, '\n'))
    	*newline='\0';
    	if(strstr(fline,argv[2])!=NULL){
    		printf("%s: %d %s \n", argv[1],count, fline);
    occurrences++;
    }
}

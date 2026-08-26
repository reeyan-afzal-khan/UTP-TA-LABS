/*
Step 1:Define the max as 25.
Step 2: Declare the variable frag[max],b[max],f[max],i,j,nb,nf,temp, highest=0, bf[max],ff[max]. 
Step 3: Get the number of blocks,files,size of the blocks using for loop.
Step 4: In for loop check bf[j]!=1, if so temp=b[j]-f[i]
Step 5: Check lowest>temp,if so assign ff[i]=j,highest=temp 
Step 6: Assign frag[i]=lowest, bf[ff[i]]=1,lowest=10000 
Step 7: Repeat step 4 to step 6.
Step 8: Print file no,size,block no,size and fragment. Step 9: Stop the program.
*/ 

#include <stdio.h>
#define MAX 25

int main(){
    int frag[MAX], b[MAX], f[MAX], bf[MAX] = {0}, ff[MAX] = {0};
    int nb, nf, temp, lowest;

    printf("\n\tMemory Management Scheme - Best Fit\n");

    printf("Enter the number of blocks: ");
    scanf("%d", &nb);

    printf("Enter the number of files: ");
    scanf("%d", &nf);

    printf("\nEnter the size of the blocks:\n");
    for (int i = 0; i < nb; i++){
        printf("Block %d: ", i + 1);
        scanf("%d", &b[i]);
    }

    printf("\nEnter the size of the files:\n");
    for (int i = 0; i < nf; i++){
        printf("File %d: ", i + 1);
        scanf("%d", &f[i]);
    }

    // Best Fit Allocation
    for (int i = 0; i < nf; i++){
        lowest = 10000; // Reset for each file
        ff[i] = -1;     // Initially not allocated
  
        for (int j = 0; j < nb; j++){
            if (bf[j] == 0){
                temp = b[j] - f[i];
                if (temp >= 0 && temp < lowest){
                    ff[i] = j;
                    lowest = temp;
                }
            }
        }

        if (ff[i] != -1){
            frag[i] = lowest;
            bf[ff[i]] = 1;
        }
        else{
            frag[i] = -1; // No suitable block found
        }
    }

    printf("\nFile_no\tFile_size\tBlock_no\tBlock_size\tFragment\n");
    for (int i = 0; i < nf; i++){
        if (ff[i] != -1){
            printf("%d\t\t%d\t\t%d\t\t%d\t\t%d\n",
                   i + 1, f[i], ff[i] + 1, b[ff[i]], frag[i]);
        }
        else{
            printf("%d\t\t%d\t\tNot Allocated\t-\t\t-\n", i + 1, f[i]);
        }
    }

    return 0;
}

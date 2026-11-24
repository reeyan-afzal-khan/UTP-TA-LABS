#import "/.shared/typst/utp.typ": *
#unit("labs", "07-trees-i")

#labsection(7, label: <sec:lab07>)[Tree representation and traversal]

#labproject[Represent the same binary tree two ways][
  #note[
    #strong[Official Lab Manual --- Lab VII.] Array/linked tree representations; traversal, update, insertion, and deletion.
  ]

  #strong[Goal.] Represent one binary tree twice and compare traversal results.

  #strong[Recall first.] Review the #link(<ch:trees-i>)[Tree Representation and Traversal] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Save each one in your `Lab07` folder and build it on its own with #strong[Ctrl+Shift+B] (#secref(<sec:build-run>)); the supplied copies are in `all_experiments/Lab07`.

  #include "programs/binary_tree.typ"
]

#element-head([Rebuild a tree from two traversals])

A preorder and an inorder listing together fix a binary tree whose values are all different. The first preorder value is the root; in the inorder listing it splits the remaining values into the left and the right subtree, and the same rule then applies inside each part. Rebuild this lab's tree from preorder 8 4 2 6 12 and inorder 2 4 6 8 12 on paper, and compare your drawing with the index table. Then rebuild a tree you have not seen, from preorder 1 2 4 5 3 6 and inorder 4 2 5 1 6 3. Store it in the array layout and confirm with the program that its postorder is 4 5 2 6 3 1.

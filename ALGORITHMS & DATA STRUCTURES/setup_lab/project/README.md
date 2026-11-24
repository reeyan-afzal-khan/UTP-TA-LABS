# Algorithms & Data Structures labs

My C++17 programs for the UTP Algorithms & Data Structures labs, one folder per lab.

## Build and run

Open this folder in VS Code (**File > Open Folder**), open a `.cpp` file, then:

| Keys | What happens |
| --- | --- |
| **Ctrl+Shift+B** (**Cmd+Shift+B** on macOS) | Builds the open file and runs it in the terminal |
| **F5** | Builds it and runs it in the debugger; press **F9** on a line first to stop there |

From a terminal, inside a lab folder:

```sh
g++ -std=c++17 -Wall -Wextra singly_linked_list.cpp -o singly_linked_list
./singly_linked_list
```

The settings in `.vscode/` come from the course's `setup_lab` folder.

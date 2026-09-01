// Lab 5, Task 5 --- Infix to postfix conversion using a stack.
//
//   A + B * C    becomes    A B C * +
//   (A + B) * C  becomes    A B + C *
//
// Operands stream straight to the output. Operators wait on a stack until an
// operator of equal-or-lower precedence (or the end of input) flushes them
// out, so higher-precedence work is emitted first. A '(' creates a fence on
// the stack that only its matching ')' removes --- that is exactly how
// parentheses override precedence.
//
// Build: g++ -std=c++17 -Wall -Wextra Task05.cpp -o task05

#include <iostream>
#include <stack>
#include <string>
#include <cctype>

using namespace std;

int precedence(char op) {
    if (op == '^') return 3;
    if (op == '*' || op == '/') return 2;
    if (op == '+' || op == '-') return 1;
    return 0;   // '(' sits on the stack with the lowest rank
}

string infixToPostfix(const string& infix) {
    stack<char> ops;
    string postfix;

    for (char c : infix) {
        if (isspace(static_cast<unsigned char>(c))) continue;

        if (isalnum(static_cast<unsigned char>(c))) {
            postfix += c;                    // operands never wait
        } else if (c == '(') {
            ops.push(c);
        } else if (c == ')') {
            // Flush back to the fence; the parentheses themselves vanish.
            while (!ops.empty() && ops.top() != '(') {
                postfix += ops.top();
                ops.pop();
            }
            if (ops.empty()) {
                cout << "Error: ')' without matching '('\n";
                return "";
            }
            ops.pop();                       // discard the '('
        } else {
            // An operator pops everything of >= precedence first, so
            // A - B + C  keeps its left-to-right meaning.
            // ('^' is right-associative, so equal precedence stays.)
            while (!ops.empty() && ops.top() != '(' &&
                   (precedence(ops.top()) > precedence(c) ||
                    (precedence(ops.top()) == precedence(c) && c != '^'))) {
                postfix += ops.top();
                ops.pop();
            }
            ops.push(c);
        }
    }

    while (!ops.empty()) {
        if (ops.top() == '(') {
            cout << "Error: '(' without matching ')'\n";
            return "";
        }
        postfix += ops.top();
        ops.pop();
    }
    return postfix;
}

void demo(const string& infix) {
    cout << infix << "  ->  " << infixToPostfix(infix) << '\n';
}

int main() {
    cout << "-- Lab sheet test expressions --\n";
    demo("A+B*C");        // multiplication binds tighter: A B C * +
    demo("(A+B)*C");      // parentheses force the addition first: A B + C *

    cout << "\n-- More coverage --\n";
    demo("A-B+C");        // left associativity: A B - C +
    demo("A^B^C");        // right associativity: A B C ^ ^
    demo("A*(B+C*D)+E");  // nesting: A B C D * + * E +

    cout << "\n-- Malformed input is reported --\n";
    demo("(A+B");
    demo("A+B)");

    return 0;
}

// Lab 5 - Stack ADT and expression processing
// The lab manual's stack application: convert an infix expression to postfix.
// Operands go straight to the output; operators wait on a stack until an
// operator of lower precedence (or a closing parenthesis) arrives.
//
// Rules used (Chapter 5): * and / bind tighter than + and -; ^ binds tightest
// and is right-associative; the others are left-associative. Operands are
// single letters or digits; spaces are ignored.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra infix_to_postfix.cpp -o infix_to_postfix
//     ./infix_to_postfix

#include <cctype>
#include <iostream>
#include <stack>
#include <string>
using namespace std;

int precedence(char op) {
    if (op == '^') return 3;
    if (op == '*' || op == '/') return 2;
    if (op == '+' || op == '-') return 1;
    return 0;
}

bool isOperator(char c) { return precedence(c) > 0; }
bool rightAssociative(char op) { return op == '^'; }

// Returns false (and leaves postfix incomplete) for unbalanced parentheses
// or an unexpected character.
bool toPostfix(const string& infix, string& postfix, bool trace) {
    stack<char> ops;
    postfix.clear();

    for (char c : infix) {
        if (c == ' ') continue;

        if (isalnum(static_cast<unsigned char>(c))) {
            postfix += c;                                    // operand: output directly
        } else if (c == '(') {
            ops.push(c);
        } else if (c == ')') {
            while (!ops.empty() && ops.top() != '(') {       // pop back to the '('
                postfix += ops.top();
                ops.pop();
            }
            if (ops.empty()) return false;                   // no matching '('
            ops.pop();                                       // discard the '('
        } else if (isOperator(c)) {
            while (!ops.empty() && isOperator(ops.top()) &&
                   (precedence(ops.top()) > precedence(c) ||
                    (precedence(ops.top()) == precedence(c) && !rightAssociative(c)))) {
                postfix += ops.top();
                ops.pop();
            }
            ops.push(c);
        } else {
            return false;
        }

        if (trace) {
            string stackText;
            for (stack<char> copy = ops; !copy.empty(); copy.pop()) stackText = copy.top() + stackText;
            cout << "  read " << c << "   stack [" << stackText << "]   output " << postfix << '\n';
        }
    }

    while (!ops.empty()) {
        if (ops.top() == '(') return false;                  // no matching ')'
        postfix += ops.top();
        ops.pop();
    }
    return true;
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    string postfix;

    cout << "== Trace of A+B*C-D (the Chapter 5 figure) ==\n";
    toPostfix("A+B*C-D", postfix, true);
    cout << "result: " << postfix << "\n\n";

    struct Case { string infix, expected; };
    const Case cases[] = {
        {"A+B*C",       "ABC*+"},    // precedence: * before +
        {"(A+B)*C",     "AB+C*"},    // parentheses override precedence
        {"A+B*C-D",     "ABC*+D-"},
        {"A*(B+C)/D",   "ABC+*D/"},  // left-associative * and /
        {"A-B-C",       "AB-C-"},    // left-associative -
        {"A^B^C",       "ABC^^"},    // right-associative ^
    };

    cout << "== Test expressions ==\n";
    for (const Case& c : cases) {
        bool ok = toPostfix(c.infix, postfix, false);
        check(c.infix + "  ->  " + postfix + "   (expected " + c.expected + ")",
              ok && postfix == c.expected);
    }

    cout << "\n== Malformed input ==\n";
    check("unbalanced \"(A+B\" is rejected", !toPostfix("(A+B", postfix, false));
    check("unbalanced \"A+B)\" is rejected", !toPostfix("A+B)", postfix, false));
    return 0;
}

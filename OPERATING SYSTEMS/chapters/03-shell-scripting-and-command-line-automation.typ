#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-shell-scripting-and-command-line-automation")


#heading(level: 1)[Shell Scripting and Command-Line Automation]
<ch:shell> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Chapter 2: files, command-line utilities, and exit status.

*By the end, you can:* use variables, quoting, redirection, pipelines, conditions, and loops to automate repeatable OS observations in Lab 3.]


#heading(level: 2)[Why the shell belongs in an operating-systems course]
 A shell such as Bash is an ordinary user-space program, but it is unusually useful for observing an operating system. It starts other programs, connects their input and output, reports whether they succeeded, and gives us a small programming language for repeating tasks.

This makes the shell a convenient bridge between theory and experiment. Instead of writing C code every time we want to inspect a process or count log messages, we can combine existing tools such as `ps`, `grep`, `wc`, `df`, and `uname`.

#callout("keyidea", title: [Key idea])[A good shell script is usually not doing everything itself. It coordinates small programs and lets the operating system connect them through processes, files, and standard streams.]


#heading(level: 2)[What happens when you run a command]
 When you enter an external command such as `ps`, the shell performs a simple sequence conceptually:

+ interpret the command line and expand variables;

+ prepare redirection or pipes if requested;

+ start the requested program;

+ wait for it if it is a foreground command;

+ collect its exit status.

You do not need to implement these steps in Bash, but recognising them helps connect shell work to processes, file descriptors, `fork()`, and `exec()`.


#heading(level: 2)[Variables, arguments, and quoting]
 A shell variable stores text. Script arguments are available as `$1`, `$2`, and so on. Quoting matters because the shell processes text before the final command runs.

#code-block("file=${1:-report.txt}\necho \"Writing report to: $file\"\ndf -h . > \"$file\"", lang: "bash")

The double quotes around `"$file"` preserve a filename containing spaces as one argument.

#callout("pitfall", title: [Common mistake])[Unquoted variables are a common source of scripting errors. If `file="OS Lab.txt"`, then `cat $file` can be interpreted as two filenames. Prefer `cat "$file"`.]


#heading(level: 2)[Standard input, output, and error]
 Most command-line programs begin with three standard streams:

- #strong[standard input] --- where normal input is read;

- #strong[standard output] --- where normal results are written;

- #strong[standard error] --- where diagnostics are written.

The shell can redirect these streams without changing the program.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Syntax], [Meaning], [Example],),
    table.hline(),
    [`>`], [replace a file with standard output], [`ps > processes.txt`],
    [`>>`], [append standard output], [`date >> history.txt`],
    [`<`], [take standard input from a file], [`wc -l < events.log`],
    [`2>`], [redirect standard error], [`cmd 2> errors.txt`],
    [`|`], [connect one program's output to another's input], [`ps | grep bash`],
  )]
  , kind: table
  )


#heading(level: 2)[Pipelines are process composition]
 Consider: #code-block("ps -eo pid,ppid,stat,comm | grep bash", lang: "bash") The first process produces text. The shell connects that output to a pipe. The second process reads from the pipe and keeps selected lines. The programs do not need to know each other's implementation.

#callout("intuition", title: [Plain idea])[A pipeline is like an assembly line for bytes. Each program performs one small job, while the shell and operating system arrange the connections.]


#heading(level: 2)[Exit status is part of the interface]
 Every command returns an integer status. By convention, 0 means success and a non-zero value means failure or a false result. The shell stores the most recent status in `$?`.

#code-block("grep kernel notes.txt\necho $?", lang: "bash") This is why commands can be composed inside `if`, `&&`, and `||` expressions.

#callout("workedexample", title: [Worked example])[A search tool can use status 0 for "match found", 1 for "no match", and 2 for "could not read the file". A script can then react to the condition without trying to interpret printed sentences.]


#heading(level: 2)[Conditions and loops for repeatable observations]
 Shell conditions and loops are most useful here when they automate repeated OS observations. For example, a script can count several log levels using one loop: #code-block("for level in INFO WARN ERROR; do\n    count=$(grep -c \"^$level \" events.log || true)\n    echo \"$level: $count\"\ndone", lang: "bash") The mathematics is simple; the important idea is repeatability. If the log changes, rerunning the same script applies the same method again.


#heading(level: 2)[Background work and process observation]
 Adding `&` runs a command in the background: #code-block("sleep 30 &\nps -o pid,ppid,state,comm\nwait", lang: "bash") This provides an easy way to create a temporary process and then inspect it. The `wait` command asks the shell to wait for its outstanding background job.


#heading(level: 2)[A professional scripting workflow]
 For a student lab script, a reliable workflow is:

+ define the intended input and output;

+ make one normal case work;

+ quote variables and check required arguments;

+ add one failure or boundary test;

+ return a meaningful exit status;

+ add a short usage message if another person will run the script.

#callout("keyidea", title: [Key idea])[The goal of Bash in this course is not to memorise syntax. It is to make OS observations reproducible: the same commands, in the same order, with failures handled clearly.]

#callout("quickcheck", title: [Check your understanding])[+ Why should a filename variable usually be quoted?

+ What OS idea is visible in a pipeline such as `ps | grep bash`?

+ Why is exit status more useful to another program than a human-readable sentence alone?

+ What does appending `&` change about how the shell treats a command?]

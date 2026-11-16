#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-shell-scripting-and-command-line-automation")

= Shell Scripting and Command-Line Automation <ch:shell>

#chapterguide[Chapter 2: files, command-line utilities, and exit status.][use variables, quoting, redirection, pipelines, conditions, and loops to automate repeatable OS observations in Lab 3.]

== Why the shell belongs in an operating-systems course

A shell such as Bash is an ordinary user-space program, but it is unusually useful for observing an operating system. It starts other programs, connects their input and output, reports whether they succeeded, and gives us a small programming language for repeating tasks.

This makes the shell a convenient bridge between theory and experiment. Instead of writing C code every time we want to inspect a process or count log messages, we can combine existing tools such as `ps`, `grep`, `wc`, `df`, and `uname`.

#note[
  A good shell script is usually not doing everything itself. It coordinates small programs and lets the operating system connect them through processes, files, and standard streams.
]

== What happens when you run a command

When you enter an external command such as `ps`, the shell performs a simple sequence conceptually:

+ interpret the command line and expand variables;
+ prepare redirection or pipes if requested;
+ start the requested program;
+ wait for it if it is a foreground command;
+ collect its exit status.

You do not need to implement these steps in Bash, but recognising them helps connect shell work to processes, file descriptors, `fork()`, and `exec()`.

== Variables, arguments, and quoting

A shell variable stores text. Script arguments are available as `$1`, `$2`, and so on. Quoting matters because the shell processes text before the final command runs.

```bash
file=${1:-report.txt}
echo "Writing report to: $file"
df -h . > "$file"
```

The double quotes around `"$file"` preserve a filename containing spaces as one argument.

#warning[
  Unquoted variables are a common source of scripting errors. If `file="OS Lab.txt"`, then `cat $file` can be interpreted as two filenames. Prefer `cat "$file"`.
]

== Standard input, output, and error

Most command-line programs begin with three standard streams:

- #strong[standard input] --- where normal input is read;
- #strong[standard output] --- where normal results are written;
- #strong[standard error] --- where diagnostics are written.

The shell can redirect these streams without changing the program.

#utptable[
  #tabularx(
    columns: (10%, 1fr, 38%),
    styles: (navy-bold,),
    header: ([Syntax], [Meaning], [Example]),
    [`>`], [replace a file with standard output], [`ps > processes.txt`],
    [`>>`], [append standard output], [`date >> history.txt`],
    [`<`], [take standard input from a file], [`wc -l < events.log`],
    [`2>`], [redirect standard error], [`cmd 2> errors.txt`],
    [`|`], [connect one program’s output to another’s input], [`ps | grep bash`],
  )
]

== Pipelines are process composition

Consider:

```bash
ps -eo pid,ppid,stat,comm | grep bash
```

The first process produces text. The shell connects that output to a pipe. The second process reads from the pipe and keeps selected lines. The programs do not need to know each other’s implementation.

#note[
  A pipeline is like an assembly line for bytes. Each program performs one small job, while the shell and operating system arrange the connections.
]

== Exit status is part of the interface

Every command returns an integer status. By convention, 0 means success and a non-zero value means failure or a false result. The shell stores the most recent status in `$?`.

```bash
grep kernel notes.txt
echo $?
```

This is why commands can be composed inside `if`, `&&`, and `||` expressions.

#example[
  A search tool can use status 0 for “match found”, 1 for “no match”, and 2 for “could not read the file”. A script can then react to the condition without trying to interpret printed sentences.
]

== Conditions and loops for repeatable observations

Shell conditions and loops are most useful here when they automate repeated OS observations. For example, a script can count several log levels using one loop:

```bash
for level in INFO WARN ERROR; do
    count=$(grep -c "^$level " events.log || true)
    echo "$level: $count"
done
```

The mathematics is simple; the important idea is repeatability. If the log changes, rerunning the same script applies the same method again.

== Background work and process observation

Adding `&` runs a command in the background:

```bash
sleep 30 &
ps -o pid,ppid,state,comm
wait
```

This provides an easy way to create a temporary process and then inspect it. The `wait` command asks the shell to wait for its outstanding background job.

== A professional scripting workflow

For a student lab script, a reliable workflow is:

+ define the intended input and output;
+ make one normal case work;
+ quote variables and check required arguments;
+ add one failure or boundary test;
+ return a meaningful exit status;
+ add a short usage message if another person will run the script.

#note[
  The goal of Bash in this course is not to memorise syntax. It is to make OS observations reproducible: the same commands, in the same order, with failures handled clearly.
]

#questions[
  + Why should a filename variable usually be quoted?
  + What OS idea is visible in a pipeline such as `ps | grep bash`?
  + Why is exit status more useful to another program than a human-readable sentence alone?
  + What does appending `&` change about how the shell treats a command?
]

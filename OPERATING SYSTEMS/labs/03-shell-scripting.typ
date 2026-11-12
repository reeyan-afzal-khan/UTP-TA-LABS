#import "/.shared/typst/utp.typ": *
#unit("labs", "03-shell-scripting")

#labsection(3, label: <sec:lab03>)[Shell scripting for OS observation and automation]

#labproject[Turn repeatable terminal observations into readable Bash scripts][
  #strong[Coverage.] Chapter~#ref(<ch:shell>): quoting, pipelines, redirection, exit status. \

  #strong[Goal.] Read and run three scripts that inspect the actual Linux environment. \

  #strong[Explain.] Explain what data each command produces and where that data flows next.

  #include "visuals/03-flow.typ"

  #heading(depth: 2, numbering: none)[Source code]

  #labsourcecard[`system_report.sh`][Collect a compact system report and optionally redirect it to a named file.][The function produces normal output; the final `if` decides whether it goes to the terminal or a file.]

  #strong[Start the file.] `system_report.sh`, lines 1--26.

  #include "visuals/03-trace.typ"

  #strong[Use the chapter while coding.] Revisit #link(<ch:shell>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] Run once without an argument, then with a scratch filename containing spaces. Quoting preserves the filename as one argument. The script uses replacement redirection, so use a new practice file rather than a file whose contents you need.

  #include "visuals/03-worked-case.typ"

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab03/system_report.sh", first: 1, last: 26, lang: "bash")]

  #labsourcecard[`process_summary.sh`][Filter the process table by command name.][`ps` produces rows; `awk` filters; `wc` counts; exit status 1 means no match.]

  #strong[Start the file.] `process_summary.sh`, lines 1--19.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab03/process_summary.sh", first: 1, last: 19, lang: "bash")]

  #labsourcecard[`log_summary.sh`][Count log levels and print error lines.][Quoted filenames, a loop over log levels, and `grep -c` make the script reusable.]

  #strong[Start the file.] `log_summary.sh`, lines 1--18.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab03/log_summary.sh", first: 1, last: 18, lang: "bash")]

  #heading(depth: 2, numbering: none)[Task 1 --- Syntax check before execution]

  ```bash
  cd all_experiments/Lab03
  bash -n system_report.sh
  bash -n process_summary.sh
  bash -n log_summary.sh
  ```

  No output means Bash found no syntax error.

  #heading(depth: 2, numbering: none)[Task 2 --- System report and redirection]

  ```bash
  bash system_report.sh
  bash system_report.sh my-system.txt
  cat my-system.txt
  ```

  Mark three facts that came from commands rather than hard-coded text.

  #heading(depth: 2, numbering: none)[Task 3 --- Process observation]

  ```bash
  bash process_summary.sh bash
  echo "status=$?"
  bash process_summary.sh definitely_not_running
  echo "status=$?"
  ```

  Explain why the second call can be a valid execution even though its status is non-zero.

  #heading(depth: 2, numbering: none)[Task 4 --- Log pipeline]

  ```bash
  bash log_summary.sh events.log
  ```

  Open `events.log` in Vim, add one new line beginning with #raw("ERROR "), save, and run the script again. The ERROR count should increase by exactly one.

  #utptable[
    #tabularx(
      columns: (30%, 1fr),
      styles: (navy-bold,),
      header: ([Shell feature], [Where you saw it]),
      [Quoting], [`"$log"`, `"$output"`],
      [Pipeline], [`ps | awk`, then text passed onward],
      [Command substitution], [`$(...)` captures command output],
      [Redirection], [`make_report > "$output"`],
      [Exit status], [success, no-match, and error cases differ],
    )
  ]

  #quickcheck[
    + What is the difference between redirection and a pipeline?
    + Why should shell variables that contain filenames normally be quoted?
    + What does a non-zero exit status tell the script that called a command?
  ]

  #verification[
    #strong[Explain and extend your result.] Run the script with a valid value, an empty value and a value containing spaces. Record the exit status and explain which validation branch handles each case.

    - `bash -n` reports no syntax error before any script is run.
    - At least three facts in `my-system.txt` come from commands rather than hard-coded text.
    - Both process queries are recorded with their exit statuses, and the non-zero one is explained.
    - The ERROR count rises by exactly one after the log line is added.
  ]
]

#import "/.shared/typst/utp.typ": *
#unit("labs", "05-ftp")

#lab("5")[FTP: a service on top of a working network] <sec:lab05-ftp>

#callout("labproject", title: [Turn a router into a file server, in the right order])[#strong[Coverage.] Chapter~#ref(label("ch:ftp"), supplement: none). \
#strong[Goal.] Configure an FTP server and client, and internalise the habit of proving each layer before building on it.


#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/05-flow.typ"


#strong[Worked implementation: FTP over the verified two-router link.] Use fresh lab devices. These blocks target the classic eNSP VRP command family used in the chapter. Match interface names with `display interface brief`. Enter each block on its named device; respond to interactive prompts before continuing.

#strong[R1 server.] Cable R1 GE0/0/0 to R2 GE0/0/0. This credential is only for the isolated classroom topology. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab05-01.txt", first: 1, last: none, lang: "text")

#strong[R2 client.] Configure R2, then prove connectivity. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab05-02.txt", first: 1, last: none, lang: "text")

#strong[Server file.] On R1 save a lab configuration, confirming the prompt. Run dir and use the exact filename shown. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab05-03.txt", first: 1, last: none, lang: "text")

#strong[Client session.] On R2 connect, enter ftpuser and the lab password when prompted. In the FTP prompt run binary, dir and get. If the server stored a different filename, substitute it. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab05-04.txt", first: 1, last: none, lang: "text")

#strong[Expected evidence.] The retrieved file must exist on R2 and have the same byte count as on R1. A ping alone does not prove a successful FTP transfer.

#callout("labmode", title: [How to use this lab])[This lab is short, and its real lesson is diagnostic order. Every step below verifies the layer beneath it before adding anything. Skip a verification and a later failure becomes ambiguous --- you will not know whether the problem is routing, authentication, or the file system.]

#strong[Step 1 --- Prove IP connectivity first.]

Before touching FTP, ping the server from the client.

#callout("keyidea", title: [Key idea])[FTP is an application-layer service riding on TCP, riding on IP. If IP does not work, FTP cannot, and every FTP symptom you see will be misleading.

Ping first. Always. It costs five seconds and eliminates three layers of possible causes.]

#strong[Step 2 --- Enable the server and set its directory.]


#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/05-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:ftp"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Use the filename from the save step exactly. If authentication succeeds but retrieval fails, inspect the remote directory and transfer result separately. Keep the classroom credentials restricted to this practice topology. 
#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/05-worked-case.typ"


#code-block("system-view\nftp server enable", lang: "text")

Confirm the file system has something to serve:

#code-block("<R1> dir flash:", lang: "text")

#strong[Step 3 --- Authorise a user.]

#code-block("aaa\n local-user ftpuser password cipher Huawei@123\n local-user ftpuser privilege level 15\n local-user ftpuser service-type ftp\n local-user ftpuser ftp-directory flash:\nquit", lang: "text")

#callout("pitfall", title: [Common mistake])[All four `local-user` lines are required, and omitting any one produces a different, confusing failure:

No `service-type ftp` --- login is refused even with the correct password. \
No `ftp-directory` --- login succeeds, then `dir` returns nothing or errors. \
Insufficient `privilege level` --- read works, upload is denied. \
Wrong password --- the only failure that says what it means.

If login behaves oddly, re-read this block before suspecting the network.]

#strong[Step 4 --- Verify the server is listening.]

#code-block("<R1> display ftp-server", lang: "text")

#strong[Step 5 --- Connect from the client.]

#code-block("<R2> ftp 192.168.1.1\nTrying 192.168.1.1 ...\nPress CTRL+K to abort\nConnected to 192.168.1.1.\n220 FTP service ready.\nUser(192.168.1.1:(none)):ftpuser\n331 Password required for ftpuser.\nEnter password:\n230 User logged in.\n[R2-ftp]", lang: "text")

The numeric codes are the protocol telling you where you are. Learn the four that matter:

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Code], [Meaning],),
    table.hline(),
    [220], [Server ready --- TCP reached the FTP service],
    [331], [Username accepted, password required],
    [230], [Authenticated],
    [530], [Login failed --- credentials or `service-type`],
    [550], [Action not taken --- permissions or missing file],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[Reaching `220` means IP, TCP, and the FTP service are all working. A failure after 220 is authentication or file permissions --- never routing.

That single observation splits your troubleshooting in half.]

#strong[Step 6 --- Transfer in both directions.]

#code-block("[R2-ftp] dir\n[R2-ftp] binary\n[R2-ftp] get vrpcfg.zip\n[R2-ftp] put test.txt\n[R2-ftp] quit", lang: "text")

#callout("pitfall", title: [Common mistake])[Set `binary` before transferring anything that is not plain text.

ASCII mode rewrites line endings, which silently corrupts compressed files, images, and firmware. The transfer reports success and the file is unusable --- one of the more frustrating faults to diagnose, because nothing announces it.]

#callout("troubleshoot", title: [Troubleshooting])[#strong[Connection refused.] `ftp server enable` not applied, or you are pinging a different interface than the one you connected to.

#strong[530 login failed.] Missing `service-type ftp`, or the password was entered in plaintext where cipher was configured.

#strong[Logged in but `dir` is empty.] `ftp-directory` not set, or set to a path that does not exist.

#strong[`put` returns 550.] Privilege level too low, or the flash file system is full. Check with `dir flash:`.]

#callout("tryit", title: [Try it yourself])[Capture the session in Wireshark using the skills from Lab~#link(label("sec:lab01-wireshark"))[1], filtered with `ftp`.

Find your password in the capture. It is there in plaintext, because FTP does not encrypt the control channel. Then state in one sentence why FTP should not cross an untrusted network, and name the protocol you would use instead.]]

#strong[Chapter connection.] Revisit #link(label("ch:ftp"))[the chapter explanation] and map its states to the steps below. 
#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/05-ftp-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Download the saved demo configuration and compare its byte count and contents with the intended source. Record control-session evidence and transfer evidence separately.

- Ping succeeded before any FTP configuration was attempted.

- `display ftp-server` confirms the service is enabled.

- Session transcript includes the 220, 331, and 230 codes.

- Both `get` and `put` demonstrated, with `binary` set.

- Wireshark capture shows the credentials in plaintext.]

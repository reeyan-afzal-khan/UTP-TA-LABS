#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-ftp")


#heading(level: 1)[FTP Service and File Transfer]
<ch:ftp> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Direct IPv4 reachability between two routers and basic VRP user/configuration views.

*By the end, you can:* Enable an FTP server, configure an authorized FTP user, connect from a client router, list files, transfer files in binary mode, verify transfers, close the session, and clean up safely.]


#heading(level: 2)[Service model]
 FTP transfers files between a client and server. Here R1 is the server, R2 the client, and both share `10.0.12.0/24`.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/ftp-topology.png", width: 90%)], caption: [The R1--R2 FTP topology from the supplied Lab~5 slide. R1 is the server and R2 the client, both on `10.0.12.0/24`.]) <fig:ftp-topology>


#heading(level: 3)[FTP uses two connections, not one]
 This is the detail that makes FTP behave oddly through firewalls and the reason a transfer can stall while the session still responds. Commands travel on one TCP connection; file data travels on a second one opened per transfer.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA COMMUNICATION & NETWORKING/figures/diagrams/470141fef5b2148f.svg")], caption: [The control channel stays open for the whole session. A separate data channel opens for each `dir`, `get` or `put`, and closes when that transfer ends.]) <fig:ftp-channels>

#callout("keyidea", title: [Key idea])[A login that succeeds but a `dir` that hangs is the signature of a blocked data channel: the control connection is clearly working, since the login was answered.]

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Device], [Role], [Interface], [Address],),
    table.hline(),
    [R1], [FTP server], [G0/0/1], [`10.0.12.1/24`],
    [R2], [FTP client], [G0/0/1], [`10.0.12.2/24`],
  )]
  , kind: table
  )


#heading(level: 2)[Step 1: prove IP connectivity before touching FTP]
 #code-block("[R1] interface GigabitEthernet 0/0/1\n[R1-GigabitEthernet0/0/1] ip address 10.0.12.1 24\n[R2] interface GigabitEthernet 0/0/1\n[R2-GigabitEthernet0/0/1] ip address 10.0.12.2 24\n<R1> ping 10.0.12.2", lang: "text")

#callout("keyidea", title: [Key idea])[Verify IP reachability before troubleshooting FTP.]


#heading(level: 2)[Step 2: enable the FTP server and define its working directory]
 Enable the server on R1 and set its default directory to `flash:/`. #code-block("[R1] ftp server enable\n[R1] set default ftp-directory flash:/", lang: "text")


#heading(level: 2)[Step 3: authorize an FTP user]
 Under AAA, create user `huawei`, set its password, service type, privilege, and FTP directory. #code-block("[R1] aaa\n[R1-aaa] local-user huawei password cipher huawei123\n[R1-aaa] local-user huawei service-type ftp\n[R1-aaa] local-user huawei privilege level 15\n[R1-aaa] local-user huawei ftp-directory flash:/", lang: "text")


#heading(level: 2)[Step 4: verify the server process]
 Use `display ftp-server` to confirm that the service is running on TCP port 21.

#callout("vrpbox", title: [])[\<R1\> display ftp-server #code-block("FTP server is (*\\higreen{running}*)\n  Max user number             5\n  User count                  0\n  Timeout value(in minute)    30\n  Listening port              21\n  Acl number                  0\n  FTP server's source address 0.0.0.0", lang: "text")] `running` confirms the service started, and `Listening port 21` is the control channel from #ref(label("fig:ftp-channels"), supplement: [Figure]). `User count 0` is expected before R2 connects.

#callout("verification", title: [Verification checklist])[Before login, prove that IP works, the server is running, and the user has the correct service type and directory.]


#heading(level: 2)[Step 5: log in from R2]
 #code-block("<R2> ftp 10.0.12.1\nUser(10.0.12.1:(none)): huawei\nEnter password: ********\n[R2-ftp]", lang: "text")

#callout("vrpbox", title: [])[\<R2\> ftp 10.0.12.1 #code-block("Trying 10.0.12.1 ...\nPress CTRL+K to abort\nConnected to 10.0.12.1.\n220 FTP service ready.\nUser(10.0.12.1:(none)):huawei\n331 Password required for huawei.\nEnter password:\n(*\\higreen{230 User logged in.}*)\n[ftp]", lang: "text")] the reply codes are the evidence, not the absence of an error. `220` is the server greeting, `331` means the username was accepted and a password is wanted, `230` means the session is authenticated. The prompt changing to `[ftp]` confirms you are now in the FTP client view.

The `[R2-ftp]` prompt confirms that the device is now in the FTP client session view.


#heading(level: 2)[Step 6: inspect, download, and upload files]
 Use `dir` before and after transfers, and select binary mode for the configuration archive. #code-block("[R2-ftp] dir\n[R2-ftp] binary\n[R2-ftp] get vrpcfg.zip vrpnew.zip\n[R2-ftp] bye", lang: "text") If `vrpcfg.zip` is absent on R1, run `save` to create it.

To upload a file: #code-block("[R2-ftp] put vrpnew.zip vrpnew2.zip", lang: "text") Then check the server directory.

#callout("conceptmap", title: [Concept map])[#strong[dir] = inspect remote files $\|$ #strong[get] = server $arrow.r$ client $\|$ #strong[put] = client $arrow.r$ server $\|$ #strong[bye] = close the FTP session.]


#heading(level: 2)[Step 7: clean up carefully]
 Remove only the test files created by the exercise. #code-block("<R1> delete flash:/vrpnew2.zip\n<R2> delete flash:/vrpnew.zip", lang: "text")

#callout("pitfall", title: [Common mistake])[Deletion is destructive. Verify the full path and filename; never erase the entire `flash:/` directory.]


#heading(level: 2)[A practical troubleshooting order]


+ Ping the server IP from the client.

+ Run `display ftp-server` on R1 and confirm the service is running.

+ Check the local user's password, service type, privilege, and FTP directory.

+ Attempt login and distinguish a connectivity failure from an authentication failure.

+ Use `dir` to verify the expected file and directory before transfer.

+ After `get` or `put`, inspect the destination directory to prove the file arrived.

#callout("quickcheck", title: [Check your understanding])[+ Why does the lab ping R2 before configuring the FTP application?

+ Which command proves that the FTP server is running?

+ What is the direction of a `get` operation?

+ Why does the lab use `dir` both before and after transfers?]

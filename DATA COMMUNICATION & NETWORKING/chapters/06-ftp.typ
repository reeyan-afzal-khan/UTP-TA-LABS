#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-ftp")

= FTP Service and File Transfer <ch:ftp>

#chapterguide[Direct IPv4 reachability between two routers and basic VRP user/configuration views.][Enable an FTP server, configure an authorized FTP user, connect from a client router, list files, transfer files in binary mode, verify transfers, close the session, and clean up safely.]

== Service model

FTP transfers files between a client and server. Here R1 is the server, R2 the client, and both share `10.0.12.0/24`.

#utpfig([The R1--R2 FTP topology from the supplied Lab~5 slide. R1 is the server and R2 the client, both on `10.0.12.0/24`.], label: <fig:ftp-topology>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/ftp-topology.png", width: 76%, height: 404.7848pt)
]

=== FTP uses two connections, not one

This is the detail that makes FTP behave oddly through firewalls and the
reason a transfer can stall while the session still responds. Commands
travel on one TCP connection; file data travels on a second one opened
per transfer.

#utpfig([The control channel stays open for the whole session. A separate data channel opens for each `dir`, `get` or `put`, and closes when that transfer ends.], label: <fig:ftp-channels>)[
  #canvas({
    node((0, 0), [R2], name: "c", ..router)
    node((7, 0), [R1], name: "s", ..server)
    node(below-of("c", 0.1), [client 10.0.12.2], ..netlabel)
    node(below-of("s", 0.1), [server 10.0.12.1], ..netlabel)
    connect((rel: (0.55, 0.45), to: "c"), (rel: (-0.9, 0.45), to: "s"), ..flowarrow, draw: teal, start: arrow-tip("to", line: 0.4pt), end: arrow-tip("to", line: 0.4pt))
    node(along((rel: (0.55, 0.45), to: "c"), (rel: (-0.9, 0.45), to: "s"), t: 50%), [control --- TCP port 21], ..netlabel, text: teal, anchor: "south")
    connect((rel: (0.55, -0.45), to: "c"), (rel: (-0.9, -0.45), to: "s"), ..flowarrow, draw: orange, dash: "dashed", start: arrow-tip("to", line: 0.4pt), end: arrow-tip("to", line: 0.4pt))
    node(along((rel: (0.55, -0.45), to: "c"), (rel: (-0.9, -0.45), to: "s"), t: 50%), [data --- TCP port 20, one per transfer], ..netlabel, text: orange, anchor: "north")
    node((-0.4, -1.6), [#strong[Control] carries `USER`, `PASS`, `dir`, `get`, `bye` --- and every reply code.], anchor: "west", font: font("script", fill: muted), text-width: 5.2, align: left)
    node((5.4, -1.6), [#strong[Data] carries the file bytes and the directory listing. It opens and closes around each command.], anchor: "west", font: font("script", fill: muted), text-width: 5.2, align: left)
  })
]

#note[
  A login that succeeds but a `dir` that hangs is the signature of a
  blocked data channel: the control connection is clearly working, since
  the login was answered.
]

#utptable[
  #tabularx(
    columns: (auto, auto, auto, auto),
    header: ([Device], [Role], [Interface], [Address]),
    [R1], [FTP server], [G0/0/1], [`10.0.12.1/24`],
    [R2], [FTP client], [G0/0/1], [`10.0.12.2/24`],
  )
]

== Step 1: prove IP connectivity before touching FTP

```terminal
[R1] interface GigabitEthernet 0/0/1
[R1-GigabitEthernet0/0/1] ip address 10.0.12.1 24
[R2] interface GigabitEthernet 0/0/1
[R2-GigabitEthernet0/0/1] ip address 10.0.12.2 24
<R1> ping 10.0.12.2
```

#note[
  Verify IP reachability before troubleshooting FTP.
]

== Step 2: enable the FTP server and define its working directory

Enable the server on R1 and set its default directory to `flash:/`.

```terminal
[R1] ftp server enable
[R1] set default ftp-directory flash:/
```

== Step 3: authorize an FTP user

Under AAA, create user `huawei`, set its password, service type, privilege, and FTP directory.

```terminal
[R1] aaa
[R1-aaa] local-user huawei password cipher huawei123
[R1-aaa] local-user huawei service-type ftp
[R1-aaa] local-user huawei privilege level 15
[R1-aaa] local-user huawei ftp-directory flash:/
```

== Step 4: verify the server process

Use `display ftp-server` to confirm that the service is running on TCP port 21.

#vrpbox[\<R1\> display ftp-server][
  #vrp(
    (raw("  FTP server is "), [#higreen[running]]),
    (raw("  Max user number             5"),),
    (raw("  User count                  0"),),
    (raw("  Timeout value(in minute)    30"),),
    (raw("  Listening port              21"),),
    (raw("  Acl number                  0"),),
    (raw("  FTP server's source address 0.0.0.0"),),
  )
]

#vrpread[`running` confirms the service started, and `Listening port 21` is the control channel from #figref(<fig:ftp-channels>). `User count 0` is expected before R2 connects.]

#checklist[
  Before login, prove that IP works, the server is running, and the user has the correct service type and directory.
]

== Step 5: log in from R2

```terminal
<R2> ftp 10.0.12.1
User(10.0.12.1:(none)): huawei
Enter password: ********
[R2-ftp]
```

#vrpbox[\<R2\> ftp 10.0.12.1][
  #vrp(
    (raw("Trying 10.0.12.1 ..."),),
    (raw("Press CTRL+K to abort"),),
    (raw("Connected to 10.0.12.1."),),
    (raw("220 FTP service ready."),),
    (raw("User(10.0.12.1:(none)):huawei"),),
    (raw("331 Password required for huawei."),),
    (raw("Enter password:"),),
    ([#higreen[230 User logged in.]],),
    (raw("[ftp]"),),
  )
]

#vrpread[the reply codes are the evidence, not the absence of an error. `220` is the server greeting, `331` means the username was accepted and a password is wanted, `230` means the session is authenticated. The prompt changing to `[ftp]` confirms you are now in the FTP client view.]

The `[R2-ftp]` prompt confirms that the device is now in the FTP client session view.

== Step 6: inspect, download, and upload files

Use `dir` before and after transfers, and select binary mode for the configuration archive.

```terminal
[R2-ftp] dir
[R2-ftp] binary
[R2-ftp] get vrpcfg.zip vrpnew.zip
[R2-ftp] bye
```

If `vrpcfg.zip` is absent on R1, run `save` to create it.

To upload a file:

```terminal
[R2-ftp] put vrpnew.zip vrpnew2.zip
```

Then check the server directory.

#note[
  #strong[dir] = inspect remote files #h(1em)$|$ #h(1em)#strong[get] = server $arrow.r$ client #h(1em)$|$ #h(1em)#strong[put] = client $arrow.r$ server #h(1em)$|$ #h(1em)#strong[bye] = close the FTP session.
]

== Step 7: clean up carefully

Remove only the test files created by the exercise.

```terminal
<R1> delete flash:/vrpnew2.zip
<R2> delete flash:/vrpnew.zip
```

#warning[
  Deletion is destructive. Verify the full path and filename; never erase the entire `flash:/` directory.
]

== A practical troubleshooting order

#utpsteps[
  + Ping the server IP from the client.
  + Run `display ftp-server` on R1 and confirm the service is running.
  + Check the local user’s password, service type, privilege, and FTP directory.
  + Attempt login and distinguish a connectivity failure from an authentication failure.
  + Use `dir` to verify the expected file and directory before transfer.
  + After `get` or `put`, inspect the destination directory to prove the file arrived.
]

#questions[
  + Why does the lab ping R2 before configuring the FTP application?
  + Which command proves that the FTP server is running?
  + What is the direction of a `get` operation?
  + Why does the lab use `dir` both before and after transfers?
]

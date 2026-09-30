#!/usr/bin/env bash
set -eu

rm -rf demo_tree
mkdir -p demo_tree/home/student/projects demo_tree/etc demo_tree/tmp
printf 'OS lab notes\n' > demo_tree/home/student/notes.txt
printf '#include <stdio.h>\n' > demo_tree/home/student/projects/code.c
printf 'mode=student\n' > demo_tree/etc/config
ln demo_tree/home/student/notes.txt demo_tree/home/student/notes-hardlink.txt
ln -s projects/code.c demo_tree/home/student/code-link.c
printf 'Created demo_tree with one hard link and one symbolic link.\n'

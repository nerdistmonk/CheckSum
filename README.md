CheckSum! The File Integrity Tabulator With The Right Stuff!

NOTE: MD5 is great for checking against bitrot, but it is NOT SAFE for
checking against intentional tampering, MD5 is not useful for encryption
related purposes anymore, though it is possible to alter this script to use
a different hash system. (Some options would be sha256sum, sha384sum,
sha512sum and so on)

Script to create md5 hashes for files in and below the current directory
or the directory passed at the commandline
In the first run, create the sums for all files.
In the second run,
 - if the files have not changed, keep the entries
 - if the files have been deleted, forget the entry
 - if the files have changed, create new md5 hash.

To use, run (name of program) (name of manifest)
Make up a name if it's the first time use of the program.

Version 1.0 / 05-09-23 - "Initial Release"
Version 2.0 / 09-01-24 - "Major logic error fix release"
Version 2.1 / 09-02-24 - "Minor Bug Fix Release"
Version 2.5 / 09-03-24 - "Color Release"
Version 2.6 / 09-04-24 - "Bait and Tackle Release"
Version 2.6.1 / 09-04-24 - "Murphy's Release"

Developed by nerdistmonk
Original Concept by Ridgy of the askubuntu forums / 12-29-17
Visit yestertech on OFTC

Released under General Public License 3.0

#!/bin/bash
#
# CheckSum! The File Integrity Tabulator With The Right Stuff!
#
# NOTE: MD5 is great for checking against bitrot, but it is NOT SAFE for
# checking against intentional tampering, MD5 is not useful for encryption
# related purposes anymore, though it is possible to alter this script to use
# a different hash system. (Some options would be sha256sum, sha384sum,
# sha512sum and so on) 
#
# Script to create md5 hashes for files in and below the current directory
# or the directory passed at the commandline
# In the first run, create the sums for all files.
# In the second run,
#  - if the files have not changed, keep the entries
#  - if the files have been deleted, forget the entry
#  - if the files have changed, create new md5 hash.
#
# To use, run (name of program) (name of manifest)
# Make up a name if it's the first time use of the program.
#
# Version 1.0 / 05-09-23 - "Initial Release"
# Version 2.0 / 09-01-24 - "Major logic error fix release"
# Version 2.1 / 09-02-24 - "Minor Bug Fix Release"
# Version 2.5 / 09-03-24 - "Color Release"
# Version 2.6 / 09-04-24 - "Bait and Tackle Release"
# Versuib 2.6.1 / 09-04-24 - "Murphy's Release"
#
# Developed by nerdistmonk
# Original Concept by Ridgy of the askubuntu forums / 12-29-17
# Visit #yestertech on OFTC
#
# Released under General Public License 3.0
#
# Color Codes = 31 red, 32 = green, 33 = orange, 34 = blue, 36 = cyan
#

# Logic for instructions

if [ $# -lt 1 ] ; then
  echo "\e[34mUsage:\e[0m"
  echo "$0 <hashfile> [<topdir>]"
  echo
  exit
fi

# Here we set all of our global variables

export HASHFILE=$1
export PROG=$0
export TOPDIR='.'
if [ $# -eq 2 ] ; then TOPDIR=$2; fi

export BACKFILE="$HASHFILE".bck
export TMPFILE="$HASHFILE".tmp
export WRKFILE=1.tmp
export WRKFILE2=2.tmp
export WRKFILE3=3.tmp

# Asks user if they want to verify or update the checksum manifest

clear
echo -ne "\e[34mDo you want to verify manifest or update manifest? \e[0m"
read -p "(v/u) " vu

case $vu in 
	v ) echo -e "\e[33mVerifying Checksums...Stand By\e[0m";
		sed  $'s/\r//' "$HASHFILE" | md5sum -c - > 0results.txt;
		sed -i '/: OK/d' 0results.txt;
		exit 1;;
	u ) echo -e "\e[34mProceeding to Update...\e[0m";;
	* ) echo "\e[31minvalid response\e[0m";
		exit 1;;
esac

# In the first run, we create the file "$HASHFILE" if it does not exist
# You have to make sure that "$HASHFILE" does not contain any garbage for the first run!!

if [ ! \( -f "$HASHFILE" -a -s "$HASHFILE" \) ]; then
  echo -ne "\e[33mCreating "$HASHFILE" for the first time, Stand By\e[0m"
  find "$TOPDIR" ! -wholename "./$HASHFILE" ! -wholename "$PROG" -type f -print0 | xargs -0 md5sum > "$HASHFILE"
  echo -e "\e[32mdone.\e[0m"
  exit
fi

# In the second run, we proceed to find the differences.
# First, find files with newer date than the hashfile
# We will also make a backup copy of the hash manifest.
# We also pre-create all working files so the logic can ignore
# them during operation.
#
# Alternate unused logic based on modification time of files
#find "$TOPDIR" -type f -newermm "$HASHFILE" -print > "$TMPFILE"

cp "$HASHFILE" "$BACKFILE"
touch "$TMPFILE"
touch "$WRKFILE"
touch "$WRKFILE2"
touch "$WRKFILE3"
find "$TOPDIR" ! -wholename "./$HASHFILE" ! -wholename "$PROG" ! -wholename "./$BACKFILE" ! -wholename "./$TMPFILE" \
! -wholename "./$WRKFILE" ! -wholename "./$WRKFILE2" ! -wholename "./$WRKFILE3" -type f -cnewer "$HASHFILE" -print >> "$TMPFILE"
rm "$HASHFILE"

# Begin Processing of files with newer dates than manifest

echo -ne "\e[33mProcessing new or modified files, Stand By...\e[0m"
cat "$TMPFILE" | while read filename ; do
  md5sum "$filename" >> "$HASHFILE"
done
echo -e "\e[32mdone.\e[0m"

# Now walk through the old file and process to new file

cat "$BACKFILE" | while read md5 filename ; do
  # Does the file still exist?
  if [ -f "$filename" ] ; then
    # Has the file been modified?
    if grep -q -F "$filename" "$TMPFILE" ; then 
      echo -e "\e[31m$filename has changed!\e[0m"
    else
      echo "$md5  $filename" >> "$HASHFILE"
      #echo "$filename has not changed."
    fi
  else
    echo -e "\e[36m$filename has been removed!\e[0m"
  fi
done

# Generate a diff showing files not currently present in the manifest hashfile
# sed is used to trim the hash from each line, presenting diff with a clean file of just filenames
# cat is used to then read the final workfile into md5sum which then appends the computed hashes
# and adds them to the hashfile.

echo -e "\e[33mRunning final scan for newly added files, Stand By.\e[0m"
find "$TOPDIR" ! -wholename "./$HASHFILE" ! -wholename "$PROG" ! -wholename "./$BACKFILE" ! -wholename "./$WRKFILE" \
! -wholename "./$WRKFILE2" ! -wholename "./$WRKFILE3" ! -wholename "./$TMPFILE" -type f -print >> "$WRKFILE"
sort -o "$WRKFILE" "$WRKFILE"
sed 's/^.\{34\}//' "$HASHFILE" > "$WRKFILE2"
sort -o "$WRKFILE2" "$WRKFILE2"
diff --old-line-format= \
--unchanged-line-format= \
--new-line-format=%L "$WRKFILE2" "$WRKFILE" > "$WRKFILE3"
sort -o "$WRKFILE3" "$WRKFILE3"
cat "$WRKFILE3" | while read filename ; do
  md5sum "$filename" >> "$HASHFILE"
done

# We now may delete temporary files
rm "$BACKFILE"
rm "$TMPFILE"
rm "$WRKFILE"
rm "$WRKFILE2"
rm "$WRKFILE3"

exit

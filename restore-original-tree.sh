#!/usr/bin/env bash
#
# restore-original-tree.sh
# Copyright (C) 2022  k-aito
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Restore tree of directory saved with "save-original-tree.sh" as hardlink
# It uses the ./original_tree as reference file to hardlink each file properly and recreate directories
#

# Go to directory
cd "$1" || exit 1

# Define operation (move, hardlink, symlink)
if [[ -n "$2" ]] ; then
  declare -r OPERATION="$2"
else
  declare -r OPERATION='hardlink'
fi

# Define OPERATION_COMMAND
if [[ "${OPERATION,,}" = 'move' ]] ; then
  declare -r OPERATION_COMMAND='mv'
elif [[ "${OPERATION,,}" = 'hardlink' ]] ; then
  declare -r OPERATION_COMMAND='ln'
elif [[ "${OPERATION,,}" = 'symlink' ]] ; then
  declare -r OPERATION_COMMAND='ln -s'
else
  declare -r OPERATION_COMMAND='ln'
fi

# Keep the ACTUAL_MAINPATH in variable
declare -r ACTUAL_MAINPATH="$(pwd)"

# Compute hash for each file and path of the actual directory
test -f ./actual_tree && rm ./actual_tree
find . -type f -exec md5sum -b "{}" >> ./actual_tree \;

# Find the main directory from ./original_tree
# It is the first line
declare -r MAINDIR="$(head -n1 ./original_tree)"

# Create and go to the MAINDIR
mkdir ./"$MAINDIR" && cd ./"$MAINDIR"

# Read ../original_tree without first line
while read -r line ; do
  md5="$(cut -d ' ' -f1 <<< "$line")"
  filepath="$(cut -d '*' -f2 <<< "$line")"
  # Search md5 in ../actual_tree
  grep_result="$(grep "$md5" ../actual_tree)"
  # If not empty, make hardlink from ../actual_tree line to path
  # Else display filepath and md5 and quit
  if [[ -n "$grep_result" ]] ; then
    actual_filepath="$(cut -d '*' -f2 <<< "$grep_result" | sed 's|^./||g')"
    printf '[INFO] %s %s/%s to %s/%s\n' "${OPERATION,,}" "$ACTUAL_MAINPATH" "$actual_filepath" "$MAINDIR" "$filepath"
    test -e "$(dirname "$filepath")" || mkdir -p "$(dirname "$filepath")"
    command -- "$OPERATION_COMMAND" "$ACTUAL_MAINPATH/$actual_filepath" "$filepath"
  else
    if ! [[ "$filepath" = './original_tree' ]] ; then
      printf '[ERROR]: the file %s with md5 %s is not found in ./actual_tree\n' "$filepath" "$md5"
      exit 1
    fi
  fi
done < <(tail -n+2 ../original_tree)

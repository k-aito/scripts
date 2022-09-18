#!/usr/bin/env bash
#
# save-original-tree.sh
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
# Save tree of directory to ./original_tree file
# The first line will be the main directory and it will keep the md5sum of the files
#

# Go to directory
cd "$1" || exit 1

# Save the main directory
basename "$(pwd)" >> ./original_tree

# Save hash for each file and path
find . -type f -exec md5sum -b "{}" >> ./original_tree \;

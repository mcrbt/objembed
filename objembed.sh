#!/bin/bash
##
##          Copyright Daniel Haase 2020.
## Distributed under the Boost Software License, Version 1.0.
##      (See accompanying file LICENSE or copy at
##        https://www.boost.org/LICENSE_1_0.txt)
##
## This file belongs to objembed.
##
## Author: Daniel Haase
##
## possible exit codes:
##   0 - success
##   1 - missing dependency
##   2 - not a Linux system
##   3 - invalid command line syntax
##   4 - input file not found
##   5 - unsupported architecture
##   6 - operation failed (objcopy error)
##

TITLE="objembed"
VERSION="0.1.0"
AUTHOR="Daniel Haase"
COPYRIGHT="copyright (c) 2020 $AUTHOR"
ARCH="32"
ELF="elf32-i386"
CMD="$0"

function checkcmd
{
  local c="$1"
  if [ $# -eq 0 ] || [ -z "$c" ]; then return 0; fi
  which "$c" &> /dev/null
  if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 1; fi
  return 0
}

function setarch
{
  local kernel=$(uname -s)
  local os=$(uname -o)
  local arch=$(uname -m)

  if [ "$kernel" != "Linux" ] && [[ "$os" != *"Linux"* ]]
  then echo "not a Linux system"; exit 2; fi

  if [ "$arch" == "x86_64" ]
  then ARCH="64"; ELF="elf64-x86-64"
  else ARCH="32"; ELF="elf32-i386"; fi
  return 0
}

function version
{
  echo "$TITLE version $VERSION"
  echo "$COPYRIGHT"
  echo " - embed plain text in object files"
}

function usage
{
  echo ""
  version
  echo ""
  echo "usage:  $CMD <txtfile> <objfile> [<arch>]"
  echo "        $CMD [-h | -V]"
  echo ""
  echo "$TITLE uses \"objcopy\" to convert the text file <txtfile>"
  echo "to an object file <objfile>. \"objcopy\" adds the linker symbols"
  echo "    \"_binary_<filename>_<ext>_start\" and"
  echo "    \"_binary_<filename>_<ext>_end\""
  echo "around the contents of <txtfile> which can be used in C code"
  echo "to extract the text. the resulting <objfile> can be statically"
  echo "linked against a C project by passing <objfile> directly to"
  echo "the linker. Here, <filename> is the basename of <txtfile>"
  echo "without its file name extension <ext> (i.e. the dot ('.') in"
  echo "\"filename.ext\" gets replaced by an underscore ('_') character)."
  echo ""
  echo "  <txtfile>"
  echo "    path to text file containing ASCII plain text"
  echo "    to be embedded in <objfile>"
  echo ""
  echo "  <objfile>"
  echo "    object file output filename/path containing the"
  echo "    contents of <txtfile>"
  echo ""
  echo "  <arch>"
  echo "    target machine architecture"
  echo "    (defaults to architecture of current machine)"
  echo ""
  echo "  -h | --help"
  echo "    print this usage information and exit"
  echo ""
  echo "  -V | --version"
  echo "    print version information and exit"
  echo ""
}

checkcmd "basename"
checkcmd "objcopy"
checkcmd "uname"

setarch

CMD="$(basename $CMD)"

if [ $# -eq 1 ]; then
  if [ "$1" == "-h" ] || [ "$1" == "--help" ]
  then usage; exit 0
  elif [ "$1" == "-V" ] || [ "$1" == "--version" ]
  then version; exit 0
  else usage; exit 3; fi
elif [ $# -eq 2 ]; then
  if [[ "$1" == "-"* ]] || [[ "$2" == "-"* ]]
  then usage; exit 3; fi

  TXTFL="$1"
  OBJFL="$2"
elif [ $# -eq 3 ]; then
  if [[ "$1" == "-"* ]] || [[ "$2" == "-"* ]] \
  || [[ "$3" == "-"* ]]; then usage; exit 3; fi

  TXTFL="$1"
  OBJFL="$2"
  ARCSP="$3"
else usage; exit 3; fi

if [ ! -f "$TXTFL" ]; then
  echo "file \"$TXTFL\" not found"
  exit 4
fi

if [ -f "$OBJFL" ]; then
  echo "file \"$OBJFL\" already exists"
  echo "override? [y|N] "
  read ans

  if [ "$ans" != "y" ] && [ "$ans" != "Y" ] \
  && [ "$ans" != "yes" ] && [ "$ans" != "YES" ] \
  && [ "$ans" != "Yes" ]; then exit 0; fi
fi

if [ ! -z "$ARCSP" ]; then
  if [[ "$ARCSP" == *"86" ]]; then
    if [[ "$ARCSP" == *"386" ]]; then ARCH="i386"
    elif [[ "$ARCSP" == *"486" ]]; then ARCH="i486"
    elif [[ "$ARCSP" == *"586" ]]; then ARCH="i586"
    elif [[ "$ARCSP" == *"686" ]]; then ARCH="i686"
    elif [ "$ARCSP" == "x86" ]; then ARCH="i386"
    else echo "unknown x86 architecture"; exit 5; fi
    ELF="elf32-$ARCH"
  elif [ "$ARCSP" == "32" ]; then ARCH="i386"; ELF="elf32-i386"
  elif [[ "$ARCSP" == *"64" ]]; then ARCH="i386:x86-64"; ELF="elf64-x86-64"
  else ARCH="$ARCSP"; ELF="elf32-$ARCH"; fi
else
  if [ "$ARCH" == "64" ]; then ARCH="i386:x86-64"; ELF="elf64-x86-64"
  else ARCH="i386"; ELF="elf32-$ARCH"; fi
fi

objcopy --input binary --output "$ELF" --binary-architecture "$ARCH" \
  "$TXTFL" "$OBJFL" &> /dev/null
if [ $? -ne 0 ]; then echo "operation failed"; exit 6; fi

echo "successfully generated \"$OBJFL\""
exit 0

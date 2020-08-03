#!/bin/bash
# Written by Draco (tytydraco @ GitHub)

# Constants
DEBUG=1
MODULES_DIR="/sbin/.magisk/modules"

# Add busybox components from Magisk
[[ -d "/sbin/.magisk/busybox" ]] && [[ "$PATH" != *"/sbin/.magisk/busybox"* ]] &&
	export PATH="$PATH:/sbin/.magisk/busybox"

# Log in red and exit
err() {
	echo -e "\e[91m[!] $@\e[39m"
	exit 1
}

# Log in red and continue
warn() {
	echo -e "\e[93m[#] $@\e[39m"
}

# Log in white and continue (unnecessary)
dbg() {
	[[ "$DEBUG" -eq 1 ]] && echo -e "[*] $@"
}

# Log in white and continue (necessary)
log() {
	echo -e "[*] $@"
}

# Print MRM command list and syntax
usage() {
	echo -n "Usage: `basename $0` <COMMAND> [ARGUMENTS]
Options:
  add AUTHOR:NAME	Install module from author
  del NAME		Delete installed module
  upgrade NAME		Upgrade an existing module
  list			List all installed modules
  help			Show usage
"
}

add() {
	# Bail if invalid format
	[[ "$1" != *":"* ]] &&
		err "Module must be in AUTHOR:NAME format. Exiting."

	# Parse input and separate
	local author=`echo "$1" | cut -d ":" -f1`
	local name=`echo "$1" | cut -d ":" -f2`
	dbg "Author: $author"
	dbg "Name: $name"

	# Bail if module already exists
	[[ -d "$MODULES_DIR/$author:$name" ]] && err "Module already exists. Exiting."

	# Fetch the archive
	local url="https://github.com/$author/$name/archive/master.tar.gz"
	dbg "Fetching archive from $url."
	curl -L -s -o "$MODULES_DIR/tmp.tar.gz" "$url"	

	# Check for curl success
	[[ $? -ne 0 ]] && err "Failed to fetch archive from $url. Exiting."

	# Prepare for extraction
	mkdir "$MODULES_DIR/tmp"

	# Extract
	dbg "Extracting archive."
	tar xf "$MODULES_DIR/tmp.tar.gz" -C "$MODULES_DIR/tmp"

	# Rename with MRM folder structure
	dbg "Moving contents to MRM folder structure."
	local dirname=`ls "$MODULES_DIR/tmp"`
	mv "$MODULES_DIR/tmp/$dirname" "$MODULES_DIR"
	mv "$MODULES_DIR/$dirname" "$MODULES_DIR/$author:$name"

	# Cleanup
	dbg "Cleaning up."
	rm "$MODULES_DIR/tmp.tar.gz"
	rm -rf "$MODULES_DIR/tmp"

	dbg "Installed $author:$name."
}

del() {
	# Bail if invalid format
	[[ "$1" != *":"* ]] &&
		err "Module must be in AUTHOR:NAME format. Exiting."

	# Parse input and separate
	local author=`echo "$1" | cut -d ":" -f1`
	local name=`echo "$1" | cut -d ":" -f2`
	dbg "Author: $author"
	dbg "Name: $name"

	# Bail if module does not exist
	[[ ! -d "$MODULES_DIR/$author:$name" ]] && err "Module does not exist exists. Exiting."

	dbg "Deleting module."
	rm -rf "$MODULES_DIR/$author:$name"

	dbg "Deleted $author:$name."
}

list() {
	ls "$MODULES_DIR"
}

# Check for root permissions
[[ `id -u` -ne 0 ]] && err "No root permissions. Exiting."

# Ensure modules folder exists
[[ ! -d "$MODULES_DIR" ]] &&
	err "No modules directory found at $MODULES_DIR. Exiting."

# Handle commands and arguments passed
case "$1" in
	"add")
		add "$2"
		;;
	"del")
		del "$2"
		;;
	"list")
		list
		;;
	"upgrade")
		;;
	"help")
		usage
		exit 0
		;;
	"")
		usage
		exit 0
		;;
	*)
		err "Unknown command: $1. Exiting."
		;;
esac

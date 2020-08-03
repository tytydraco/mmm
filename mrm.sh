#!/bin/bash
# Written by Draco (tytydraco @ GitHub)

# Exit on errors
set -e

# Declarations
DATA_DIR="/data/local/mrm"
REPOLIST="$DATA_DIR/repolist"
DEBUG=1

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
	[[ "$DEBUG" -eq 1 ]] && echo -e "[*] $@" || true
}

# Log in white and continue (necessary)
log() {
	echo -e "[*] $@" || true
}

# Print MRM command list and syntax
usage() {
	echo -n "Usage: `basename $0` <COMMAND> [ARGUMENTS]
Options:
  add-repo URL		Add repository to the repolist
  del-repo URL		Delete a repository from the repolist
  ls-repo		List all existing repolist entries
  install NAME		Install a module from the repolist
  update		Update all repository listings
  help			Show usage
"
}

# Sanity check of directory structure
sanity() {
	# Check for root permissions
	[[ `id -u` -ne 0 ]] && err "No root permissions. Exiting."

	if [[ ! -d "$DATA_DIR" ]]
	then
		warn "Data directory non-existent at $DATA_DIR. Creating one."
		mkdir -p "$DATA_DIR"
	fi

	if [[ ! -f "$REPOLIST" ]]
	then
		warn "Repolist non-existent at $REPOLIST. Creating one."
		touch "$REPOLIST"
	fi
}

_add-repo() {
	# Bail if multi-word or multi-line
	[[ `echo "$1" | wc -w` -ne 1 ]] &&
		err "Invalid URL format: $1. Exiting."

	# Bail if entry already exists
	`cat "$REPOLIST" | grep -q -x "$1"` &&
		err "Repository $1 already exists in the repolist."

	# Add entry to the repolist
	echo "$1" >> "$REPOLIST"

	dbg "Added $1 to the repolist."
}

_del-repo() {
	# Bail if multi-word or multi-line
	[[ `echo "$1" | wc -w` -ne 1 ]] &&
		err "Invalid URL format: $1. Exiting."

	# Bail if entry does not exists
	! `cat "$REPOLIST" | grep -q -x "$1"` &&
		err "Repository $1 does not exist in the repolist."

	# Remove entry from the repolist
	sed -i "/^$1\$/d" "$REPOLIST"

	dbg "Deleted $1 to the repolist."
}

_ls-repo() {
	local repolist_ents=`cat "$REPOLIST"`

	# Warn if the repo list is empty
	if [[ -z "$repolist_ents" ]]
	then
		dbg "Repolist is empty."
		return 0
	fi

	echo "$repolist_ents"
}

# Handle commands and arguments passed
command_handler() {
	case "$1" in
		"add-repo")
			_add-repo "$2"
			;;
		"del-repo")
			_del-repo "$2"
			;;
		"ls-repo")
			_ls-repo
			;;
		"install")
			;;
		"update")
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
}

# Perform initial sanity check
sanity

# Pass command line command and arguments
command_handler "$1" "${@:2}"

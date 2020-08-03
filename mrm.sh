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

# Log in white and continue
dbg() {
	[[ "$DEBUG" -eq 1 ]] && echo -e "[*] $@" || true
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

# Handle commands and arguments passed
command_handler() {
	case "$1" in
		"add-repo")
			;;
		"del-repo")
			;;
		"ls-repo")
			;;
		"install")
			;;
		"update")
			;;
		"help")
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

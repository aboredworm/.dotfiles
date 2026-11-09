#!/bin/sh

set -eu

HYPRSHADE=/usr/bin/hyprshade
SHADER=blue-light-filter

case "${1:-auto}" in
	auto)
		"$HYPRSHADE" auto
		;;
	on)
		"$HYPRSHADE" on "$SHADER"
		;;
	off)
		"$HYPRSHADE" off
		;;
	toggle)
		"$HYPRSHADE" toggle "$SHADER"
		;;
	*)
		printf 'usage: nightlight [auto|on|off|toggle]\n' >&2
		exit 1
		;;
esac

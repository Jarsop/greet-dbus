#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

ok() {
	echo -e "${GREEN}$1${NC}"
}

fail() {
	echo -e "${RED}$1${NC}"
	exit 1
}

check_interface() {
	if gdbus introspect --session -d je.sappel.Greet -o /je/sappel/Greet -x |
		grep -A4 '<interface name="je.sappel.Greet">' |
		grep -A2 '<method name="Greet">' |
		grep -q '<arg direction="in" type="s"/>'; then
		ok "Method Greet is available"
	else
		fail "Method Greet is not available"
	fi

	if gdbus introspect --session -d je.sappel.Greet -o /je/sappel/Greet -x |
		grep -A4 '<interface name="je.sappel.Greet">' |
		grep -q '<property name="Name" type="s" access="read"/>'; then
		ok "Property Name is available"
	else
		fail "Property Name is not available"
	fi
}

wait_property_changed() {
	gdbus monitor --session -d je.sappel.Greet -o /je/sappel/Greet | {
		read -r line
		read -r line
		read -r line
		if echo "$line" | grep -q "/je/sappel/Greet: org.freedesktop.DBus.Properties.PropertiesChanged ('je.sappel.Greet', {'Name': <'jp'>}, @as \[\])"; then
			ok "Property Name has been changed"
		else
			fail "Property Name has not been changed"
		fi
	}
}

set_name() {
	gdbus call --session -d je.sappel.Greet -o /je/sappel/Greet -m je.sappel.Greet.Greet "jp" >/dev/null
}

main() {
	check_interface
	wait_property_changed &
	set_name
}

main

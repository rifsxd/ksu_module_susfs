#!/system/bin/sh
PATH=/data/adb/ksu/bin:$PATH
## susfs_clone_perm <file/or/dir/perm/to/be/changed> <file/or/dir/to/clone/from>
susfs_clone_perm() {
	TO=$1
	FROM=$2
	if [ -z "${TO}" -o -z "${FROM}" ]; then
		return
	fi
	CLONED_PERM_STRING=$(stat -c "%a %U %G" ${FROM})
	set ${CLONED_PERM_STRING}
	chmod $1 ${TO}
	chown $2:$3 ${TO}
	busybox chcon --reference=${FROM} ${TO}
}

## susfs_hexpatch_props <target_prop_name> <spoofed_prop_name> <spoofed_prop_value>
susfs_hexpatch_props() {
	TARGET_PROP_NAME=$1
	SPOOFED_PROP_NAME=$2
	SPOOFED_PROP_VALUE=$3
	if [ -z "${TARGET_PROP_NAME}" -o -z "${SPOOFED_PROP_NAME}" -o -z "${SPOOFED_PROP_VALUE}" ]; then
		return 1
	fi
	if [ "${#TARGET_PROP_NAME}" != "${#SPOOFED_PROP_NAME}" ]; then
		return 1
	fi
	resetprop -n ${TARGET_PROP_NAME} ${SPOOFED_PROP_VALUE}
	magiskboot hexpatch /dev/__properties__/$(resetprop -Z ${TARGET_PROP_NAME}) $(echo -n ${TARGET_PROP_NAME} | xxd -p | tr "[:lower:]" "[:upper:]") $(echo -n ${SPOOFED_PROP_NAME} | xxd -p | tr "[:lower:]" "[:upper:]")
}

check_reset_prop() {
  local NAME=$1
  local EXPECTED=$2
  local VALUE=$(resetprop $NAME)
  [ -z $VALUE ] || [ $VALUE = $EXPECTED ] || resetprop $NAME $EXPECTED
}

contains_reset_prop() {
  local NAME=$1
  local CONTAINS=$2
  local NEWVAL=$3
  [[ "$(resetprop $NAME)" = *"$CONTAINS"* ]] && resetprop $NAME $NEWVAL
}

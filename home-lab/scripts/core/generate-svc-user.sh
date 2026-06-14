#!/bin/bash

# Make sure a username is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <app_name> [svc_type]"
  echo "  svc_type defaults to 'app'"
  exit 1
fi

# Make sure the script is run with admin privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script as root or with sudo."
  exit 1
fi

SVC_NAME="$1"
SVC_TYPE="${2:-app}"
TARGET_NAME="srv-${SVC_NAME}-${SVC_TYPE}"
TARGET_UID=2001

# Check if user or group already exists
if getent passwd "${TARGET_NAME}" > /dev/null 2>&1; then
  echo "Error: User '${TARGET_NAME}' already exists."
  exit 1
fi

if getent group "${TARGET_NAME}" > /dev/null 2>&1; then
  echo "Error: Group '${TARGET_NAME}' already exists."
  exit 1
fi

# Keep adding 1 to TARGET_UID until we find one that is not taken
while getent passwd "$TARGET_UID" > /dev/null 2>&1; do
  TARGET_UID=$((TARGET_UID + 1))
done

# Create the group with the first available GID
groupadd -g "${TARGET_UID}" "${TARGET_NAME}"

# Create the user with the first available UID
useradd -u "$TARGET_UID" -g "${TARGET_UID}" -M -s /sbin/nologin "${TARGET_NAME}"

# Check if the command worked
if [ $? -eq 0 ]; then
  echo "Success: User '${TARGET_NAME}' was created with UID ${TARGET_UID}."
else
  echo "Error: Failed to create user."
fi

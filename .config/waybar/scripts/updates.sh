#!/usr/bin/env bash
dnf check-update -q 2>/dev/null | grep -Ec '^[[:alnum:]._+-]+\.[[:alnum:]_]+[[:space:]]+[0-9]' || true

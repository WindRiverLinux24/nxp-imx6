#
# Copyright (C) 2020 Wind River Systems, Inc.
#

COMPATIBLE_MACHINE:nxp-imx6 = "nxp-imx6"
TARGET_SUPPORTED_KTYPES:nxp-imx6 = "standard preempt-rt"

FILESEXTRAPATHS:prepend:nxp-imx6 := "${THISDIR}/files:"
SRC_URI:append:nxp-imx6 = " \
    file://0001-mxc-IPU3-Prevent-NULL-pointer-access-in-ipu_task_thr.patch \
"


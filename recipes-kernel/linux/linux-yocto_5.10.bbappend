#
# Copyright (C) 2021 Wind River Systems, Inc.
#
FILESEXTRAPATHS_prepend := "${FILE_DIRNAME}/${PN}:"

SRC_URI_append_nxp-imx6 = " file://nxp-imx6-standard.scc"

require linux-yocto-nxp-imx6.inc
KBRANCH_nxp-imx6 = "v5.10/standard/base"

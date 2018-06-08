# This revision is the v2017.09 release
SRCREV_nxp-imx6 = "a57b13b942d59719e3621179e98bd8a0ab235088"

LIC_FILES_CHKSUM_nxp-imx6 = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

PV_nxp-imx6 = "2017.09"

DEPENDS_nxp-imx6 += "dtc-native"

# the following variables can be passed from the env
# using BB_ENV_WHITELIST to override the defaults
UBOOT_REPO_nxp-imx6 ?= "git://git.freescale.com/imx/uboot-imx.git"
UBOOT_BRANCH_nxp-imx6 ?= "imx_v2016.03_4.1.15_2.0.0_ga"
UBOOT_PROT_nxp-imx6 ?= "http"

SRC_URI_nxp-imx6 = "${UBOOT_REPO};protocol=${UBOOT_PROT};branch=${UBOOT_BRANCH}"

FILESEXTRAPATHS_prepend_nxp-imx6 := "${THISDIR}/${PN}:"
SRC_URI_append_nxp-imx6 = " file://0001-tools-fix-cross-compiling-tools-when-HOSTCC-is-overr.patch\
                 "

do_compile_nxp-imx6 () {
        oe_runmake ${UBOOT_MACHINE}
        oe_runmake env
}

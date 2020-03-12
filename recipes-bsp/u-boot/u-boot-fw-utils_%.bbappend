# This revision is the v2019.04 release
FILESEXTRAPATHS_prepend_nxp-imx6 := "${THISDIR}/${PN}:"

SRCREV_nxp-imx6 = "4d377539a1190e838eae5d8b8a794dde0696d572"

LIC_FILES_CHKSUM_nxp-imx6 = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS_nxp-imx6 += "dtc-native flex-native bison-native"

UBOOT_SRC_nxp-imx6 ?= "git://source.codeaurora.org/external/imx/uboot-imx.git;protocol=https"
SRCBRANCH_nxp-imx6 ?= "imx_v2019.04_4.19.35_1.1.0"

SRC_URI_nxp-imx6 = "${UBOOT_SRC};branch=${SRCBRANCH}"
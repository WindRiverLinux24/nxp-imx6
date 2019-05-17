# This revision is the v2018.03 release
FILESEXTRAPATHS_prepend_nxp-imx6 := "${THISDIR}/${PN}:"

SRCREV_nxp-imx6 = "654088cc211e021387b04a8c33420739da40ebbe"

LIC_FILES_CHKSUM_nxp-imx6 = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS_nxp-imx6 += "dtc-native"

UBOOT_SRC_nxp-imx6 ?= "git://source.codeaurora.org/external/imx/uboot-imx.git;protocol=https"
UBOOT_REPO_nxp-imx6 ?= "git://github.com/altera-opensource/u-boot-socfpga.git"
SRCBRANCH_nxp-imx6 ?= "imx_v2018.03_4.14.78_1.0.0_ga"

SRC_URI_nxp-imx6 = "${UBOOT_SRC};branch=${SRCBRANCH}"
SRC_URI_nxp-imx6_append = " file://0001-efi_loader-avoid-make-race-condition.patch"

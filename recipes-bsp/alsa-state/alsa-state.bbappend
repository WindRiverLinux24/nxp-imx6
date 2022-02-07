# Append path for freescale layer to include alsa-state asound.conf
FILESEXTRAPATHS_prepend_nxp-imx6 := "${THISDIR}/${PN}:"

SRC_URI_append_nxp-imx6 = " \
	file://asound.state \
"

PACKAGE_ARCH_nxp-imx6 = "${MACHINE_ARCH}"

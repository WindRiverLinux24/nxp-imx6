# Append path for freescale layer to include alsa-state asound.conf
FILESEXTRAPATHS:prepend_nxp-imx6 := "${THISDIR}/${PN}:"

SRC_URI:append_nxp-imx6 = " \
	file://asound.state \
"

PACKAGE_ARCH_nxp-imx6 = "${MACHINE_ARCH}"

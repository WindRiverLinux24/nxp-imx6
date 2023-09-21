require linux-yocto-nxp-imx6.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:nxp-imx6 = " \
    file://0001-ARM-imx-use-raw_spin_lock-instead-of-spin_lock.patch \
    "

KBRANCH:nxp-imx6  = "v6.1/standard/preempt-rt/nxp-sdk-6.1/nxp-soc"

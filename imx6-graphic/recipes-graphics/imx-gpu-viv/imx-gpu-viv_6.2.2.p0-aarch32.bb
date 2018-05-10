# Copyright (C) 2013-2016 Freescale Semiconductor
# Copyright 2017 NXP
# Released under the MIT license (see COPYING.MIT for the terms)

require recipes-graphics/imx-gpu-viv/imx-gpu-viv-v6.inc

SRC_URI = "${FSL_MIRROR}/${PN}-${PV}.bin;fsl-eula=true"

S="${WORKDIR}/${PN}-${PV}"

SRC_URI[md5sum] = "7d43f73b8bc0c1c442587f819218a1d5"
SRC_URI[sha256sum] = "4f93a4412c93ca5959aa2437bfed2ecbaf983b5b272be5977f76a967de5db150"

MACHINE_HAS_VIVANTE_KERNEL_DRIVER_SUPPORT = "1"

PACKAGE_FP_TYPE = "hardfp"

COMPATIBLE_MACHINE = "nxp-imx6"

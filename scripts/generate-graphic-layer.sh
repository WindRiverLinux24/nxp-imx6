#!/bin/sh
#
# i.MX6 Graphic Layer Generation Script
#
# Copyright (C) 2019 WindRiver
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


CWD=`pwd`
BSP_NAME=nxp-imx6
echo "\nGenerate graphic layer for BSP" $BSP_NAME
echo

usage()
{
    echo "\n Usage: source generate-graphic-layer.sh
    Optional parameters: [-s source-dir] [-d destination-dir] [-h]"
    echo "
    * [-s source-dir]: Source directory where the graphic layer come from
    * [-d destination-dir]: Destination directory where the graphic will be merged into
    * [-h]: help
    "
}

clean_up()
{
    unset CWD GRAPHIC_SRC GRAPHIC_DTS
    unset usage clean_up
}


cat <<EOF
Warning: Once customer generats imx6 graphic layer, and then build with this layer.
There are some libraries and packages which are covered by Freescale's End User
License Agreement (EULA). To have the right to use these binaries in your images,
please read EULA carefully firstly.
WindRiver doesn't support imx6's GPU or VPU hardware acceleration feature in product
release. Customers who want to enable graphic hardware acceleration feature need to
run this script on their own PC to generate imx6-graphic layer.
EOF

echo
REPLY=
while [ -z "$REPLY" ]; do
	echo -n "Do you read the WARNING carefully? (y/n) "
	read REPLY
	case "$REPLY" in
		y|Y)
		echo "WARNING has been read."
		;;
		n|N)
		echo "WARNING has not been read."
		return 1
		;;
		*)
		echo "WARNING has not been read."
		return 1
		;;
	esac
done

# get command line options
OLD_OPTIND=$OPTIND
while getopts "s:d:h" fsl_setup_flag
do
    case $fsl_setup_flag in
        s) GRAPHIC_SRC="$OPTARG";
           echo "\n Graphic source directory is " $GRAPHIC_SRC
           ;;
        d) GRAPHIC_DTS="$OPTARG";
           echo "\n Graphic destination directory is " $GRAPHIC_DTS
           ;;
        h) fsl_setup_help='true';
           ;;
        \?) fsl_setup_error='true';
           ;;
    esac
done
shift $((OPTIND-1))
if [ $# -ne 0 ]; then
    fsl_setup_error=true
    echo "Invalid command line ending: '$@'"
fi
OPTIND=$OLD_OPTIND
if test $fsl_setup_help; then
    usage && clean_up && return 1
elif test $fsl_setup_error; then
    clean_up && return 1
fi

mkdir -p $GRAPHIC_DTS/imx6-graphic/conf
if [ ! -f $GRAPHIC_DTS/imx6-graphic/conf/layer.conf ]; then
cat > $GRAPHIC_DTS/imx6-graphic/conf/layer.conf << "EOF"
#
# Copyright (C) 2016-2017 Wind River Systems, Inc.
#

# We have a conf and classes directory, add to BBPATH
BBPATH .= ":${LAYERDIR}"

require nxp-imx6-graphic.inc

# We have a packages directory, add to BBFILES
BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
	${LAYERDIR}/recipes-*/*/*.bbappend \
	${LAYERDIR}/classes/*.bbclass"

BBFILE_COLLECTIONS += "imx6-graphic-layer"
BBFILE_PATTERN_imx6-graphic-layer := "^${LAYERDIR}/"
BBFILE_PRIORITY_imx6-graphic-layer = "7"

INHERIT += "machine-overrides-extender"
MACHINEOVERRIDES_EXTENDER_nxp-imx6   = "imxfbdev:imxipu:imxvpu:imxvpucnm:imxgpu:imxgpu2d:imxgpu3d"
MACHINE_SOCARCH = "nxp_imx6"

IMAGE_INSTALL_append += "assimp devil imx-gpu-viv xf86-video-imx-vivante imx-gpu-g2d imx-gpu-apitrace imx-gpu-sdk imx-lib imx-vpu imx-gpu-viv-demos"
BANNER[nxp-imx6_default] = "The nxp-imx6 layer includes third party components, where additional third party licenses may apply."

LAYERSERIES_COMPAT_imx6-graphic-layer = "thud"
EOF
fi


if [ ! -f $GRAPHIC_DTS/imx6-graphic/conf/nxp-imx6-graphic.inc ]; then
cat > $GRAPHIC_DTS/imx6-graphic/conf/nxp-imx6-graphic.inc << EOF
PREFERRED_PROVIDER_virtual/egl_$BSP_NAME = "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libgles1_$BSP_NAME = "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libgles2_$BSP_NAME = "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libgl_$BSP_NAME = "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libg2d_$BSP_NAME = "imx-gpu-g2d"
PREFERRED_VERSION_imx-vpu = "5.4.38"

PNWHITELIST_openembedded-layer += 'freeglut'
PNWHITELIST_imx6-graphic-layer += 'imx-gpu-viv'
PNWHITELIST_imx6-graphic-layer += 'imx-gpu-viv-demos'
PNWHITELIST_imx6-graphic-layer += 'imx-gpu-g2d'
PNWHITELIST_imx6-graphic-layer += 'imx-gpu-sdk'
PNWHITELIST_imx6-graphic-layer += 'imx-vpu'
PNWHITELIST_imx6-graphic-layer += 'assimp'
PNWHITELIST_imx6-graphic-layer += 'devil'
PNWHITELIST_imx6-graphic-layer += 'imx-lib'
PNWHITELIST_imx6-graphic-layer += 'xf86-video-imx-vivante'
PNWHITELIST_imx6-graphic-layer += 'imx-gpu-apitrace'
PNWHITELIST_imx6-graphic-layer += 'systemd-gpuconfig'
EOF
fi

file_copy()
{
	src_file=$SOURCE_DIR/$1
	dts_file=$DESTINATION_DIR/$1

	if [ -f $dts_file ]; then
		return 1
	fi

	if [ ! -f $src_file ]; then
		echo "No file $src_file"
		return 1
	fi

	mkdir -p $DESTINATION_DIR/`dirname $1`
	shift

	cp $src_file $dts_file

	while test -n "$1"; do
		sed -i "$1" $dts_file
		shift
	done
}

SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/
DESTINATION_DIR=$GRAPHIC_DTS/imx6-graphic/

file_copy recipes-bsp/imx-lib/imx-lib_git.bb \
			"s/mx6q/nxp-imx6/g" \
			"s/(mx6|mx7)/nxp-imx6/g"

file_copy recipes-bsp/imx-vpu/imx-vpu_5.4.38.bb \
			"s/imxvpucnm/nxp-imx6/g"

file_copy recipes-core/systemd/systemd/0001-socket-util-fix-getpeergroups-assert-fd-8080.patch
file_copy recipes-core/systemd/systemd/0020-logind.conf-Set-HandlePowerKey-to-ignore.patch
file_copy recipes-core/systemd/systemd/0021-systemd-udevd.service.in-Set-MountFlags-as-shared-to.patch
file_copy recipes-core/systemd/systemd_%.bbappend \
			"/0021-systemd-udevd.service.in-Set-MountFlags-as-shared-to.patch/d" \
			"/0001-socket-util-fix-getpeergroups-assert-fd-8080.patch/d"
file_copy recipes-core/systemd/systemd-gpuconfig/gpuconfig
file_copy recipes-core/systemd/systemd-gpuconfig/gpuconfig.service
file_copy recipes-core/systemd/systemd-gpuconfig_1.0.bb

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale-distro/

file_copy recipes-graphics/devil/devil/Fix-GCC-5.2-erros.patch
file_copy recipes-graphics/devil/devil/il_manip_c.patch
file_copy recipes-graphics/devil/devil/il_manip_h.patch
file_copy recipes-graphics/devil/devil/M4Patch.patch
file_copy recipes-graphics/devil/devil_1.7.8.bb

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/

mkdir -p $GRAPHIC_DTS/imx6-graphic/recipes-graphics/drm/libdrm/nxp-imx6
if [ ! -f $GRAPHIC_DTS/imx6-graphic/recipes-graphics/drm/libdrm/nxp-imx6/drm-update-arm.patch ]; then
	cp $GRAPHIC_SRC/meta-freescale/recipes-graphics/drm/libdrm/mx6/drm-update-arm.patch $GRAPHIC_DTS/imx6-graphic/recipes-graphics/drm/libdrm/nxp-imx6/
fi
file_copy recipes-graphics/drm/libdrm_%.bbappend


mkdir -p $GRAPHIC_DTS/imx6-graphic/recipes-graphics/freeglut
if [ ! -f $GRAPHIC_DTS/imx6-graphic/recipes-graphics/freeglut/freeglut_%.bbappend ]; then
cat > $GRAPHIC_DTS/imx6-graphic/recipes-graphics/freeglut/freeglut_%.bbappend << "EOF"
DEPENDS += "${@bb.utils.contains("DISTRO_FEATURES", "x11", "mesa", "", d)}"
EOF
fi


SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/
file_copy recipes-graphics/imx-gpu-apitrace/imx-gpu-apitrace_7.1.0.bb \
			"s/(mx6q|mx6dl|mx6sx|mx6sl|mx7ulp|mx8)/nxp-imx6/g"


file_copy recipes-graphics/imx-gpu-g2d/imx-gpu-g2d_6.2.4.p2.3-aarch32.bb
file_copy recipes-graphics/imx-gpu-g2d/imx-gpu-g2d.inc \
			"/COMPATIBLE_MACHINE_imxdpu/d"


mkdir -p $GRAPHIC_DTS/imx6-graphic/recipes-graphics/imx-gpu-sdk/imx-gpu-sdk
if [ ! -f $GRAPHIC_DTS/imx6-graphic/recipes-graphics/imx-gpu-sdk/imx-gpu-sdk/0001-imx-gpu-sdk-open-https-link-without-ssl-certificate-.patch ]; then
cat > $GRAPHIC_DTS/imx6-graphic/recipes-graphics/imx-gpu-sdk/imx-gpu-sdk/0001-imx-gpu-sdk-open-https-link-without-ssl-certificate-.patch << "EOF"
From 052ea73778cc7dc7e2aae380dac0037af630010e Mon Sep 17 00:00:00 2001
From: Limeng <Meng.Li@windriver.com>
Date: Tue, 12 Mar 2019 21:22:10 +0800
Subject: [PATCH] imx-gpu-sdk: open https link without ssl certificate
 verification

When open a https protocol web page with Python(version > 2.7.9)
interface, it is need to verify certificate signatures. But there
is no appropriate crt file in wrlinux build system, so implement a
workaround to ignore certificate verification.

Signed-off-by: Meng Li <Meng.Li@windriver.com>
---
 .Config/FslBuild.py | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/.Config/FslBuild.py b/.Config/FslBuild.py
index 05b9ff2..ce7e601 100755
--- a/.Config/FslBuild.py
+++ b/.Config/FslBuild.py
@@ -37,4 +37,7 @@ PythonVersionCheck.CheckVersion()
 from FslBuildGen.Tool import ToolAppMain
 from FslBuildGen.Tool.Flow.ToolFlowBuild import ToolAppFlowFactory
 
+import ssl
+ssl._create_default_https_context = ssl._create_unverified_context
+
 ToolAppMain.Run(ToolAppFlowFactory())
-- 
2.7.4

EOF
fi
SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-sdk/
file_copy recipes-graphics/imx-gpu-sdk/imx-gpu-sdk_5.2.0.bb \
			"s/mx6q/nxp-imx6/g" \
			"s/'DISTRO_FEATURES', 'wayland'/'DISTRO_FEATURES', 'weston-demo'/g" \
			"24iSRC_URI_append_nxp-imx6 = \" file://0001-imx-gpu-sdk-open-https-link-without-ssl-certificate-.patch\"" \
			"54i    export GIT_SSL_NO_VERIFY=true"


SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/
file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv_6.2.4.p2.3-aarch32.bb \
			"6iMACHINE_HAS_VIVANTE_KERNEL_DRIVER_SUPPORT = \"1\"" \
			"s/(mx6q|mx6dl|mx6sx|mx6sl|mx7ulp)/nxp-imx6/g"
file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv-v6.inc \
			"s/'DISTRO_FEATURES', 'wayland'/'DISTRO_FEATURES', 'weston-demo'/g" \
			"s/\"DISTRO_FEATURES\", \"wayland\"/\"DISTRO_FEATURES\", \"weston-demo\"/g" \
			"s/mx6q/nxp-imx6/g" \
			"/RDEPENDS_libgal-imx/d" \
			"/COMPATIBLE_MACHINE/d" \
			"/RPROVIDES_libwayland-viv-imx/d" \
			"302iRDEPENDS_libegl-imx += \"\${@bb.utils.contains('DISTRO_FEATURES', 'weston-demo', 'libgc-wayland-protocol-imx libwayland-viv-imx libgc-wayland-protocol-imx', '', d)}\"" \
			"303iRDEPENDS_libegl-imx-dev += \"\${@bb.utils.contains('DISTRO_FEATURES', 'weston-demo', 'libwayland-egl-imx-dev', '', d)}\"" \
			"368iRPROVIDES_libwayland-viv-imx += \"\${@bb.utils.contains('DISTRO_FEATURES', 'weston-demo', \\\ " \
			"369i	\\\t				bb.utils.contains('DISTRO_FEATURES', 'x11', '', \\\ " \
			"370i	\\\t				'xf86-video-imx-vivante', d), '', d)}\""


file_copy recipes-graphics/matchbox-wm/matchbox-wm_%.bbappend
file_copy recipes-graphics/matchbox-wm/matchbox-wm/fix-close-button-do-not-response-to-multitouch.patch


file_copy recipes-graphics/mesa/mesa_%.bbappend \
			"s/egl gbm/egl/g" \
			"s/'DISTRO_FEATURES', 'wayland'/'DISTRO_FEATURES', 'weston-demo'/g" \
			"12c\          \${D}\${includedir}/GL/glx.h \\\ " \
			"12i\    rm -f \${D}\${libdir}/libGL.* \\\ " \
			"13i\          \${D}\${includedir}/GL/gl.h \\\ " \
			"14i\          \${D}\${includedir}/GL/glext.h \\\ "
file_copy recipes-graphics/mesa/mesa-demos_%.bbappend
file_copy recipes-graphics/mesa/mesa-demos/Additional-eglSwapBuffer-calling-makes-wrong-throttl.patch
file_copy recipes-graphics/mesa/mesa-demos/Add-OpenVG-demos-to-support-wayland.patch
file_copy recipes-graphics/mesa/mesa-demos/fix-clear-build-break.patch
file_copy recipes-graphics/mesa/mesa-demos/Replace-glWindowPos2iARB-calls-with-glWindowPos2i.patch


file_copy recipes-graphics/wayland/wayland/fixpathinpcfiles.patch
file_copy recipes-graphics/wayland/weston/0001-make-error-portable.patch
file_copy recipes-graphics/wayland/weston/0001-weston.ini-using-argb8888-as-gbm-default-on-mscale-8.patch
file_copy recipes-graphics/wayland/weston/0001-weston-launch-Provide-a-default-version-that-doesn-t.patch
file_copy recipes-graphics/wayland/weston/0002-weston.ini-configure-desktop-shell-size-in-weston-co.patch
file_copy recipes-graphics/wayland/weston/0003-weston-touch-calibrator-Advertise-the-touchscreen-ca.patch
file_copy recipes-graphics/wayland/weston/weston.desktop
file_copy recipes-graphics/wayland/weston/weston.png 
file_copy recipes-graphics/wayland/weston/xwayland.weston-start
file_copy recipes-graphics/wayland/weston-init/init
file_copy recipes-graphics/wayland/weston-init/profile
file_copy recipes-graphics/wayland/weston-init/weston.config
file_copy recipes-graphics/wayland/weston-init/weston.service
file_copy recipes-graphics/wayland/weston-init/weston-start
file_copy recipes-graphics/wayland/weston-init/imxdrm/weston.config
file_copy recipes-graphics/wayland/weston-init/mx8mm/weston.config
file_copy recipes-graphics/wayland/wayland-ivi-extension_git.bb
file_copy recipes-graphics/wayland/wayland-protocols_1.16.imx.bb
file_copy recipes-graphics/wayland/weston_5.0.0.imx.bb \
			"s/mx6/nxp-imx6/g"
file_copy recipes-graphics/wayland/weston-init.bbappend


file_copy recipes-graphics/xinput-calibrator/xinput-calibrator_%.bbappend


file_copy recipes-graphics/xorg-driver/xf86-video-imx-vivante_6.2.4.p2.3.bb
file_copy recipes-graphics/xorg-driver/xf86-video-imx-vivante.inc \
			"s/(mx6|mx7ulp)/nxp-imx6/g"
file_copy recipes-graphics/xorg-driver/xf86-video-imx-vivante/rc.autohdmi


mkdir -p $GRAPHIC_DTS/imx6-graphic/recipes-graphics/xorg-xserver/xserver-xf86-config/nxp-imx6
mkdir -p $GRAPHIC_DTS/imx6-graphic/recipes-graphics/xorg-xserver/xserver-xorg
file_copy recipes-graphics/xorg-xserver/xserver-xf86-config_%.bbappend \
			"s/FILESEXTRAPATHS_prepend/FILESEXTRAPATHS_prepend_nxp-imx6/g"
file_copy recipes-graphics/xorg-xserver/xserver-xorg_%.bbappend \
			"s/mx8/nxp-imx6/g" \
			"/0001-glamor-Use-CFLAGS-for-EGL-and-GBM.patch/d" \
			"/0002-glamor_egl-Automatically-choose-a-GLES2-context-if-d.patch/d" \
			"/0002-configure.ac-Fix-wayland-scanner-and-protocols-locat.patch/d" \
			"4iSRC_URI_append_nxp-imx6 = \" file://0001-Remove-check-for-useSIGIO-option.patch\""

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/xorg-xserver/xserver-xf86-config/mx6sll/xorg.conf
file_copy recipes-graphics/xorg-xserver/xserver-xf86-config/mx7ulp/xorg.conf
if [ ! -f $GRAPHIC_DTS/imx6-graphic/recipes-graphics/xorg-xserver/xserver-xf86-config/nxp-imx6/xorg.conf ]; then
	cp $GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/recipes-graphics/xorg-xserver/xserver-xf86-config/imxfbdev/xorg.conf $GRAPHIC_DTS/imx6-graphic/recipes-graphics/xorg-xserver/xserver-xf86-config/nxp-imx6/
fi
if [ ! -f $GRAPHIC_DTS/imx6-graphic/recipes-graphics/xorg-xserver/xserver-xorg/0001-Remove-check-for-useSIGIO-option.patch ]; then
cat > $GRAPHIC_DTS/imx6-graphic/recipes-graphics/xorg-xserver/xserver-xorg/0001-Remove-check-for-useSIGIO-option.patch << "EOF"
From cf407b16cd65ad6e26a9c8e5984e163409a5c0f7 Mon Sep 17 00:00:00 2001
From: Prabhu Sundararaj <prabhu.sundararaj@nxp.com>
Date: Mon, 30 Jan 2017 16:32:06 -0600
Subject: [PATCH] Remove check for useSIGIO option

Commit 6a5a4e60373c1386b311b2a8bb666c32d68a9d99 removes the configure of useSIGIO
option.

As the xfree86 SIGIO support is reworked to use internal versions of OsBlockSIGIO
and OsReleaseSIGIO.

No longer the check for useSIGIO is needed

Upstream-Status: Pending

Signed-off-by: Prabhu Sundararaj <prabhu.sundararaj@nxp.com>
---
 hw/xfree86/os-support/shared/sigio.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/hw/xfree86/os-support/shared/sigio.c b/hw/xfree86/os-support/shared/sigio.c
index 884a71c..be76498 100644
--- a/hw/xfree86/os-support/shared/sigio.c
+++ b/hw/xfree86/os-support/shared/sigio.c
@@ -185,9 +185,6 @@ xf86InstallSIGIOHandler(int fd, void (*f) (int, void *), void *closure)
     int i;
     int installed = FALSE;
 
-    if (!xf86Info.useSIGIO)
-        return 0;
-
     for (i = 0; i < MAX_FUNCS; i++) {
         if (!xf86SigIOFuncs[i].f) {
             if (xf86IsPipe(fd))
@@ -256,9 +253,6 @@ xf86RemoveSIGIOHandler(int fd)
     int max;
     int ret;
 
-    if (!xf86Info.useSIGIO)
-        return 0;
-
     max = 0;
     ret = 0;
     for (i = 0; i < MAX_FUNCS; i++) {
-- 
2.7.4
EOF
fi

echo "\nGraphic layer is generated successfully!"
clean_up && return 1

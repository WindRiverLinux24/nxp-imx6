#!/bin/sh
#
# i.MX6 Graphic Layer Generation Script
#
# Copyright (C) 2020 WindRiver
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
Warning: Once customer generates imx6 graphic layer, and then build with this layer.
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
		exit 1
		;;
		*)
		echo "WARNING has not been read."
		exit 1
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
    usage && clean_up && exit 1
elif test -z "$GRAPHIC_SRC"; then
    usage && clean_up && exit 1
elif test -z "$GRAPHIC_DTS"; then
    usage && clean_up && exit 1
elif test $fsl_setup_error; then
    clean_up && exit 1
fi

mkdir -p $GRAPHIC_DTS/imx6-graphic/conf
if [ ! -f $GRAPHIC_DTS/imx6-graphic/conf/layer.conf ]; then
cat > $GRAPHIC_DTS/imx6-graphic/conf/layer.conf << "EOF"
#
# Copyright (C) 2019-2020 Wind River Systems, Inc.
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
MACHINEOVERRIDES_EXTENDER_nxp-imx6   = "imx:imxfbdev:imxipu:imxvpu:imxvpucnm:imxgpu:imxgpu2d:imxgpu3d"
MACHINE_SOCARCH = "nxp_imx6"

IMAGE_INSTALL_append += "assimp devil imx-gpu-viv xf86-video-imx-vivante imx-gpu-g2d imx-gpu-apitrace imx-gpu-sdk imx-lib imx-vpu imx-gpu-viv-demos"
BANNER[nxp-imx6_default] = "The nxp-imx6 layer includes third party components, where additional third party licenses may apply."

IMX_MIRROR ?= "https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/"
FSL_MIRROR ?= "${IMX_MIRROR}"
FSL_EULA_FILE = "${LAYERDIR}/EULA"

LAYERSERIES_COMPAT_imx6-graphic-layer = "wrl warrior zeus"
EOF
fi


if [ ! -f $GRAPHIC_DTS/imx6-graphic/conf/nxp-imx6-graphic.inc ]; then
cat > $GRAPHIC_DTS/imx6-graphic/conf/nxp-imx6-graphic.inc << EOF
PREFERRED_PROVIDER_virtual/egl_nxp-imx6 = "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libgles1_nxp-imx6 = "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libgles2_nxp-imx6 = "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libgl_nxp-imx6 = "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libg2d_nxp-imx6 = "imx-gpu-g2d"
PREFERRED_VERSION_imx-vpu = "5.4.39.1"
BBMASK += "./meta/recipes-graphics/drm/libdrm"

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
PNWHITELIST_openembedded-layer += 'rapidjson'
PNWHITELIST_imx6-graphic-layer += 'stb'
PNWHITELIST_imx6-graphic-layer += 'half'
PNWHITELIST_imx6-graphic-layer += 'gli'
PNWHITELIST_openembedded-layer += 'glm'
PNWHITELIST_openembedded-layer += 'fmt'
PNWHITELIST_openembedded-layer += 'googletest'
PNWHITELIST_imx6-graphic-layer += 'linux-imx-headers'
PNWHITELIST_imx6-graphic-layer += 'libdrm'

# Remove conflicting backends.
DISTRO_FEATURES_remove = "wayland"
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

file_copy classes/fsl-eula-unpack.bbclass

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/

file_copy classes/machine-overrides-extender.bbclass
file_copy classes/use-imx-headers.bbclass

file_copy recipes-bsp/imx-lib/imx-lib_git.bb \
			"s/mx6q/nxp-imx6/g" \
			"s/(mx6|mx7)/nxp-imx6/g" \
			"11iDEPENDS = \"virtual/kernel\"\n" \

SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/

file_copy recipes-bsp/imx-vpu/imx-vpu_5.4.39.1.bb \
			"s/imxvpucnm/nxp-imx6/g" \
			"s/{PN}-/{BPN}-/g" \
			"9iDEPENDS = \"virtual/kernel\"\n" \
			"33iPACKAGE_ARCH = \"$\{MACHINE_ARCH\}\"\n" \


file_copy recipes-core/systemd/systemd/0001-systemd-udevd.service.in-Set-PrivateMounts-to-no-to-.patch \
			"s/-25,11 +25,10/-26,13 +26,12/g" \
			"/MemoryDenyWriteExecute/d" \
			"/RestrictRealtime/d" \
			"/RestrictAddressFamilies/d" \
			"36i\ ProtectHostname=yes" \
			"37i\ MemoryDenyWriteExecute=yes" \
			"38i\ RestrictAddressFamilies=AF_UNIX AF_NETLINK AF_INET AF_INET6" \
			"39i\ RestrictRealtime=yes" \
			"40i\ RestrictSUIDSGID=yes"

file_copy recipes-core/systemd/systemd_%.bbappend \
			"/0001-Revert-udev-remove-userspace-firmware-loading-suppor.patch/d" \
			"/0007-Revert-rules-remove-firmware-loading-rules.patch/d" \
			"/EXTRA_OEMESON/d"

file_copy recipes-core/systemd/systemd-gpuconfig/gpuconfig
file_copy recipes-core/systemd/systemd-gpuconfig/gpuconfig.service
file_copy recipes-core/systemd/systemd-gpuconfig_1.0.bb

SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-sdk/

file_copy recipes-devtools/half/half_1.12.0.bb
file_copy recipes-devtools/stb/stb_git.bb

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale-distro/

file_copy recipes-graphics/devil/devil/Fix-GCC-5.2-erros.patch
file_copy recipes-graphics/devil/devil/il_manip_c.patch
file_copy recipes-graphics/devil/devil/il_manip_h.patch
file_copy recipes-graphics/devil/devil/M4Patch.patch
file_copy recipes-graphics/devil/devil_1.7.8.bb

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/

mkdir -p $GRAPHIC_DTS/imx6-graphic/recipes-graphics/drm/libdrm/nxp-imx6
if [ ! -f $GRAPHIC_DTS/imx6-graphic/recipes-graphics/drm/libdrm/nxp-imx6/drm-update-arm.patch ]; then
	cp $GRAPHIC_SRC/meta-freescale/recipes-graphics/drm/libdrm/imxgpu2d/drm-update-arm.patch $GRAPHIC_DTS/imx6-graphic/recipes-graphics/drm/libdrm/nxp-imx6/
fi
file_copy recipes-graphics/drm/libdrm_%.bbappend
file_copy recipes-graphics/drm/libdrm_2.4.91.imx.bb
file_copy recipes-graphics/drm/libdrm/0001-configure.ac-Allow-explicit-enabling-of-cunit-tests.patch
file_copy recipes-graphics/drm/libdrm/fix_O_CLOEXEC_undeclared.patch
file_copy recipes-graphics/drm/libdrm/installtests.patch

SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/

file_copy recipes-graphics/drm/libdrm_2.4.99.imx.bb

mkdir -p $GRAPHIC_DTS/imx6-graphic/recipes-graphics/freeglut
if [ ! -f $GRAPHIC_DTS/imx6-graphic/recipes-graphics/freeglut/freeglut_%.bbappend ]; then
cat > $GRAPHIC_DTS/imx6-graphic/recipes-graphics/freeglut/freeglut_%.bbappend << "EOF"
DEPENDS += "${@bb.utils.contains("DISTRO_FEATURES", "x11", "mesa", "", d)}"
EOF
fi


SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-sdk/
file_copy recipes-graphics/gli/gli_0.8.2.0.bb
file_copy recipes-graphics/gli/gli/0001-Set-C-standard-through-CMake-standard-options.patch

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/imx-gpu-apitrace/imx-gpu-apitrace_7.1.0.bb \
			"s/(imxgpu)/nxp-imx6/g"

SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/
file_copy recipes-graphics/imx-gpu-apitrace/imx-gpu-apitrace_7.1.0.bbappend

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/imx-gpu-g2d/imx-gpu-g2d_6.2.4.p1.8.bb \
			"s/imxgpu2d/nxp-imx6/g"

SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/
file_copy recipes-graphics/imx-gpu-g2d/imx-gpu-g2d_6.4.0.p1.0.bb

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
file_copy recipes-graphics/imx-gpu-sdk/imx-gpu-sdk_5.4.0.bb \
			"s/mx6q/nxp-imx6/g" \
			"s/'DISTRO_FEATURES', 'wayland'/'DISTRO_FEATURES', 'weston-demo'/g" \
			"62i\    export GIT_SSL_NO_VERIFY=true" \
			"33iSRC_URI_append_nxp-imx6 = \" file://0001-imx-gpu-sdk-open-https-link-without-ssl-certificate-.patch\"" \
			"/glslang-native rapidvulkan vulkan-headers vulkan-loader/d" \
			"16i\\\nDEPENDS_VULKAN_mx8   = \\\ " \
			"18i\    \"\${@bb.utils.contains('DISTRO_FEATURES', 'weston-demo', 'glslang-native rapidvulkan vulkan-headers vulkan-loader', \\\ " \
			"19i\        bb.utils.contains('DISTRO_FEATURES',     'x11',                      '', \\\ " \
			"20i\                                                        'glslang-native rapidvulkan vulkan-headers vulkan-loader', d), d)}\"" \
			"s/\\\ /\\\/g"


SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/
file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv/Add-dummy-libgl.patch
file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv_6.4.0.p1.0-aarch32.bb \
			"19iMACHINE_HAS_VIVANTE_KERNEL_DRIVER_SUPPORT = \"1\"" \
			"s/(mx6q|mx6dl|mx6sx|mx6sl|mx7ulp)/nxp-imx6/g"
file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv-v6.inc

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv-6.inc \
			"s/'DISTRO_FEATURES', 'wayland'/'DISTRO_FEATURES', 'weston-demo'/g" \
			"s/\"DISTRO_FEATURES\", \"wayland\"/\"DISTRO_FEATURES\", \"weston-demo\"/g" \
			"s/\${PN}-\${PV}/\${BPN}-\${PV}/g" \
			"/RPROVIDES_libwayland-viv-imx/d" \
			"361iRPROVIDES_libwayland-viv-imx += \"\${@bb.utils.contains('DISTRO_FEATURES', 'weston-demo', \\\ " \
			"362i\					bb.utils.contains('DISTRO_FEATURES', 'x11', '', \\\ " \
			"363i\					'xf86-video-imx-vivante', d), '', d)}\"" \
			"/RDEPENDS_libgal-imx/d" \
			"297iRDEPENDS_libegl-imx += \"\${@bb.utils.contains('DISTRO_FEATURES', 'weston-demo', 'libgc-wayland-protocol-imx libwayland-viv-imx libgc-wayland-protocol-imx', '', d)}\"" \
			"298iRDEPENDS_libegl-imx-dev += \"\${@bb.utils.contains('DISTRO_FEATURES', 'weston-demo', 'libwayland-egl-imx-dev', '', d)}\""


mkdir -p $GRAPHIC_DTS/imx6-graphic/recipes-graphics/matchbox-wm/matchbox-wm
if [ ! -f $GRAPHIC_DTS/imx6-graphic/recipes-graphics/matchbox-wm/matchbox-wm/fix-close-button-do-not-response-to-multitouch.patch ]; then
cat > $GRAPHIC_DTS/imx6-graphic/recipes-graphics/matchbox-wm/matchbox-wm/fix-close-button-do-not-response-to-multitouch.patch << "EOF"
matchbox-wm:  Fix to support closing windows in multi-touch panels

In many applications, the close is not recognized because the sub window class is NULL
This calculates coordinates to track close touch actions in the area to respond.

Upstream Status: Not applicable

diff --git a/src/client_common.c b/src/client_common.c
index 2b62024..30724c1 100644
--- a/src/client_common.c
+++ b/src/client_common.c
@@ -779,10 +779,24 @@ client_get_button_list_item_from_event(Client *c, XButtonEvent *e)
 {
   struct list_item *l = c->buttons;
   MBClientButton   *b = NULL;
-
+  int dx, dy;
   while (l != NULL)
     {
       b = (MBClientButton *)l->data;
+	  if (e->subwindow == 0)
+	  {
+		dx = (e->x - b->x - b->w/2) > 0 ? \
+			 (e->x - b->x - b->w/2) : \
+			 (b->x + b->w/2 - e->x);
+
+		dy = (e->y - b->y - b->h/2) > 0 ? \
+			 (e->y - b->y - b->h/2) : \
+			 (b->y + b->h/2 - e->y);
+
+		if (dx <= b->w/2 && dy <= b->h/2)
+		  return l;
+	  }
+
       if (b->win == e->subwindow)
 	{
 	  return l;
EOF
fi

if [ ! -f $GRAPHIC_DTS/imx6-graphic/recipes-graphics/matchbox-wm/matchbox-wm_%.bbappend ]; then
cat > $GRAPHIC_DTS/imx6-graphic/recipes-graphics/matchbox-wm/matchbox-wm_%.bbappend << "EOF"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " file://fix-close-button-do-not-response-to-multitouch.patch"
EOF
fi

file_copy recipes-graphics/mesa/mesa_%.bbappend \
			"s/egl gbm/egl/g" \
			"s/'DISTRO_FEATURES', 'wayland'/'DISTRO_FEATURES', 'weston-demo'/g" \
			"37i\    rm -f \${D}\${includedir}/GL/glcorearb.h"
file_copy recipes-graphics/mesa/mesa-demos_%.bbappend \
			"16iPACKAGECONFIG_remove_nxp-imx6 = \"egl\""
file_copy recipes-graphics/mesa/mesa-demos/Additional-eglSwapBuffer-calling-makes-wrong-throttl.patch \
			"18,25d" \
			"18i\    window->callback = wl_surface_frame(window->surface);" \
			"19i\    wl_callback_add_listener(window->callback, &frame_listener, window);" \
			"20i\ " \
			"21i\-   eglSwapBuffers(_eglut->dpy, win->surface);" \
			"22i\+   /*eglSwapBuffers(_eglut->dpy, win->surface);*/" \
			"23i\ }" \
			"24i\ " \
			"25i\ void"
file_copy recipes-graphics/mesa/mesa-demos/Add-OpenVG-demos-to-support-wayland.patch
file_copy recipes-graphics/mesa/mesa-demos/fix-clear-build-break.patch
file_copy recipes-graphics/mesa/mesa-demos/Replace-glWindowPos2iARB-calls-with-glWindowPos2i.patch


SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/

file_copy recipes-graphics/wayland/weston-init.bbappend \
			"18i\        if \${HAS_XWAYLAND}; then" \
			"19i\            install -Dm0755 \${WORKDIR}/weston.config \${D}\${sysconfdir}/default/weston" \
			"20i\        fi" \
			"12i\    install -Dm0755 \${WORKDIR}/profile \${D}\${sysconfdir}/profile.d/weston.sh" \
			"10i\HAS_XWAYLAND = \"\${@bb.utils.contains('DISTRO_FEATURES', 'wayland x11', 'true', 'false', d)}\"" \
			"9i\SRC_URI += \"\${@bb.utils.contains('DISTRO_FEATURES', 'systemd wayland x11', 'file://weston.config', '', d)}\"\n"
file_copy recipes-graphics/wayland/weston_6.0.1.imx.bb \
			"s/mx6/nxp-imx6/g" \
			"s/SRC_URI_append_nxp-imx6sl/SRC_URI_append_mx6sl/g"
file_copy recipes-graphics/wayland/wayland-protocols_1.17.imx.bb
file_copy recipes-graphics/wayland/wayland_1.17.0.bb

file_copy recipes-graphics/wayland/weston-init/init
file_copy recipes-graphics/wayland/weston-init/profile
file_copy recipes-graphics/wayland/weston-init/weston.service
file_copy recipes-graphics/wayland/weston-init/weston-start

file_copy recipes-graphics/wayland/weston/0001-make-error-portable.patch
file_copy recipes-graphics/wayland/weston/0001-weston-launch-Provide-a-default-version-that-doesn-t.patch
file_copy recipes-graphics/wayland/weston/0003-weston-touch-calibrator-Advertise-the-touchscreen-ca.patch
file_copy recipes-graphics/wayland/weston/weston.desktop
file_copy recipes-graphics/wayland/weston/weston.png 
file_copy recipes-graphics/wayland/weston/xwayland.weston-start
file_copy recipes-graphics/wayland/weston/mx6sl/weston.config

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/wayland/weston-init/weston.config
file_copy recipes-graphics/wayland/weston-init/imxdrm/weston.config
file_copy recipes-graphics/wayland/weston-init/mx8mm/weston.config


SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/
file_copy recipes-graphics/xinput-calibrator/xinput-calibrator_%.bbappend

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/xorg-driver/xf86-video-imx-vivante_6.2.4.p1.8.bb \
			"s/(mx6|mx7ulp)/nxp-imx6/g"
file_copy recipes-graphics/xorg-driver/xf86-video-imx-vivante/rc.autohdmi

SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/
file_copy recipes-graphics/xorg-driver/xf86-video-imx-vivante_6.4.0.p0.0.bb \
			"1d" \
			"1iFILESEXTRAPATHS_prepend := \"\${THISDIR}/\${BPN}:\""


file_copy recipes-graphics/xorg-xserver/xserver-xorg_%.bbappend \
			"1iIMX_OPENGL_PKGCONFIGS_REMOVE        = \"\"" \
			"2iIMX_OPENGL_PKGCONFIGS_REMOVE_imxgpu = \"glamor\"" \
			"3iOPENGL_PKGCONFIGS_remove_nxp-imx6        = \"\${IMX_OPENGL_PKGCONFIGS_REMOVE}\"" \
			"4iOPENGL_PKGCONFIGS_remove_mx7        = \"\${IMX_OPENGL_PKGCONFIGS_REMOVE}\"" \
			"5iOPENGL_PKGCONFIGS_remove_mx8        = \"\${IMX_OPENGL_PKGCONFIGS_REMOVE}\"\n"
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0001-glamor-Use-CFLAGS-for-EGL-and-GBM.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0003-Remove-check-for-useSIGIO-option.patch


file_copy recipes-graphics/xorg-xserver/xserver-xf86-config_%.bbappend \
			"s/FILESEXTRAPATHS_prepend/FILESEXTRAPATHS_prepend_nxp-imx6/g"
file_copy recipes-graphics/xorg-xserver/xserver-xf86-config/mx6ull/xorg.conf
SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
mkdir -p $GRAPHIC_DTS/imx6-graphic/recipes-graphics/xorg-xserver/xserver-xf86-config/nxp-imx6
file_copy recipes-graphics/xorg-xserver/xserver-xf86-config/mx6sll/xorg.conf
file_copy recipes-graphics/xorg-xserver/xserver-xf86-config/mx7ulp/xorg.conf
if [ ! -f $GRAPHIC_DTS/imx6-graphic/recipes-graphics/xorg-xserver/xserver-xf86-config/nxp-imx6/xorg.conf ]; then
	cp $GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/recipes-graphics/xorg-xserver/xserver-xf86-config/imxfbdev/xorg.conf $GRAPHIC_DTS/imx6-graphic/recipes-graphics/xorg-xserver/xserver-xf86-config/nxp-imx6/
fi


file_copy recipes-kernel/linux/linux-imx-headers_4.9.123.bb
file_copy recipes-kernel/linux/linux-imx-headers-4.9.123/0001-uapi-Install-custom-headers.patch
SOURCE_DIR=$GRAPHIC_SRC/meta-fsl-bsp-release/imx/meta-bsp/
file_copy recipes-kernel/linux/linux-imx-headers_4.19.35.bb

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy EULA

echo "\nGraphic layer is generated successfully!"
clean_up && exit 1

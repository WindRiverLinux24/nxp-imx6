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

<1>. Download SDK package(L5.10.9_1.0.0_MX6QDLSOLOX) with below command
# mkdir imx-yocto-bsp;cd imx-yocto-bsp
# repo init -u https://source.codeaurora.org/external/imx/imx-manifest -b imx-linux-hardknott -m imx-5.10.9-1.0.0.xml
# repo sync
<2>. Run script scripts/generate-graphic-layer.sh and input correct parameter
# ./generate-graphic-layer.sh -s <nxp-sdk download directory>/imx-yocto-bsp/sources -d <wrlinux project directory>/layer/nxp-imx6/
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
           echo "Graphic source directory is " $GRAPHIC_SRC
           ;;
        d) GRAPHIC_DTS="$OPTARG";
           echo "Graphic destination directory is " $GRAPHIC_DTS
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
MACHINEOVERRIDES_EXTENDER_nxp-imx6   = "imx:imxfbdev:imxipu:imxvpu:imxvpucnm:imxgpu:imxgpu2d:imxgpu3d:mx6:mx6ul:mx6ull:mx6q:mx6dl:use-nxp-bsp"
MACHINE_SOCARCH = "nxp_imx6"

IMAGE_INSTALL_append_nxp-imx6 += "assimp devil imx-gpu-viv xf86-video-imx-vivante imx-gpu-g2d imx-gpu-apitrace imx-gpu-sdk imx-lib imx-vpu imx-gpu-viv-demos"
BANNER[nxp-imx6_default] = "The nxp-imx6 layer includes third party components, where additional third party licenses may apply."

IMX_MIRROR ?= "https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/"
FSL_MIRROR ?= "${IMX_MIRROR}"
FSL_EULA_FILE_GRAPHIC = "${LAYERDIR}/EULA"

LAYERSERIES_COMPAT_imx6-graphic-layer = "wrl hardknott"
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

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
DESTINATION_DIR=$GRAPHIC_DTS/imx6-graphic/

file_copy classes/fsl-eula-unpack.bbclass \
"s/FSL_EULA_FILE/FSL_EULA_FILE_GRAPHIC/g" \
                        '30i\FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V13 = \"1b4db4b25c3a1e422c0c0ed64feb65d2\"' \
                        '31i\FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V15 = \"983e4c77621568488dd902b27e0c2143\"' \
                        '32i\FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V16 = \"e9e880185bda059c90c541d40ceca922\"' \
                        '33i\FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V17 = \"cf3f9b8d09bc3926b1004ea71f7a248a\"' \
                        '34i\FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V18 = \"231e11849a4331fcbb19d7f4aab4a659\"' \
                        '35i\FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V19 = \"a632fefd1c359980434f9389833cab3a\"' \
                        '57a\    ${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V13} \\' \
                        '58a\    ${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V15} \\' \
                        '59a\    ${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V16} \\' \
                        '60a\    ${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V17} \\' \
                        '64i\    ${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V18} \\' \
                        '65i\    ${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V19} \\' \
                        '70d' \
                        '70i\    "${FSL_EULA_FILE_GRAPHIC_MD5SUM_LA_OPT_NXP_SOFTWARE_LICENSE_V19}"'
mv $GRAPHIC_DTS/imx6-graphic/classes/fsl-eula-unpack.bbclass $GRAPHIC_DTS/imx6-graphic/classes/fsl-eula-unpack-graphic.bbclass
file_copy classes/fsl-vivante-kernel-driver-handler.bbclass

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/

file_copy classes/machine-overrides-extender.bbclass
file_copy classes/use-imx-headers.bbclass

file_copy recipes-bsp/imx-lib/imx-lib_git.bb \
			"s/mx6q/nxp-imx6/g" \
			"s/(mx6|mx7)/nxp-imx6/g" \
			"11iDEPENDS = \"virtual/kernel\"\n" \

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/

file_copy recipes-bsp/imx-vpu/imx-vpu_5.4.39.3.bb \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"

file_copy recipes-core/systemd/systemd/0001-systemd-udevd.service.in-Set-PrivateMounts-to-no-to-.patch
file_copy recipes-core/systemd/systemd/0020-logind.conf-Set-HandlePowerKey-to-ignore.patch

file_copy recipes-core/systemd/systemd_%.bbappend

file_copy recipes-core/systemd/systemd-gpuconfig/gpuconfig
file_copy recipes-core/systemd/systemd-gpuconfig/gpuconfig.service
file_copy recipes-core/systemd/systemd-gpuconfig_1.0.bb \
			"s/GPL-2.0/GPL-2.0-only/g"

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-sdk/

file_copy recipes-devtools/half/half_2.1.0.bb
file_copy recipes-devtools/stb/stb_git.bb

file_copy recipes-graphics/devil/devil_1.8.0.bb \
			"s/LGPL-2.1/LGPL-2.1-only/g"
file_copy recipes-graphics/devil/devil/0001-CMakeLists-Use-CMAKE_INSTALL_LIBDIR-for-install-libs.patch

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/

file_copy recipes-graphics/drm/libdrm_2.4.99.imx.bb
file_copy recipes-graphics/drm/libdrm/0001-meson-add-libdrm-vivante-to-the-meson-meta-data.patch
file_copy recipes-graphics/drm/libdrm/musl-ioctl.patch
SOURCE_DIR=$GRAPHIC_SRC/poky/meta/
file_copy recipes-graphics/drm/libdrm_2.4.102.bb
file_copy recipes-graphics/drm/files/0001-xf86drm.c-fix-build-failure.patch
SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/drm/libdrm_2.4.102.imx.bb
file_copy recipes-graphics/drm/files/0001-meson-add-libdrm-vivante-to-the-meson-meta-data.patch

mkdir -p $GRAPHIC_DTS/imx6-graphic/recipes-graphics/freeglut
if [ ! -f $GRAPHIC_DTS/imx6-graphic/recipes-graphics/freeglut/freeglut_%.bbappend ]; then
cat > $GRAPHIC_DTS/imx6-graphic/recipes-graphics/freeglut/freeglut_%.bbappend << "EOF"
DEPENDS += "${@bb.utils.contains("DISTRO_FEATURES", "x11", "mesa", "", d)}"
EOF
fi


SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-sdk/
file_copy recipes-graphics/gli/gli_0.8.2.0.bb
file_copy recipes-graphics/gli/gli/0001-Set-C-standard-through-CMake-standard-options.patch
file_copy recipes-graphics/glm/glm_0.9.8.5.bb
file_copy recipes-graphics/glm/glm/Fixed-GCC-7.3-compile.patch

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/imx-gpu-apitrace/imx-gpu-apitrace_9.0.0.bb

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/imx-gpu-g2d/imx-gpu-g2d_6.4.0.p2.4.bb \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/imx-gpu-g2d/imx-gpu-g2d_6.4.3.p1.2.bb \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-sdk/
file_copy recipes-graphics/imx-gpu-sdk/imx-gpu-sdk_5.6.2.bb \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv/Add-dummy-libgl.patch
file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv_6.4.3.p1.2-aarch32.bb \
			"7iMACHINE_HAS_VIVANTE_KERNEL_DRIVER_SUPPORT = \"1\""
file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv-6.inc \
			"s/fsl-eula-unpack/fsl-eula-unpack-graphic/g"

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/xorg-driver/xf86-video-imx-vivante_6.4.0.p0.0.bb
file_copy recipes-graphics/xorg-driver/xf86-video-imx-vivante/rc.autohdmi

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/xorg-driver/xf86-video-imx-vivante_6.4.0.p0.0.bb

#SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
#file_copy recipes-graphics/imx-gpu-viv/imx-gpu-viv_6.4.0.p2.4-aarch32.bb

SOURCE_DIR=$GRAPHIC_SRC/poky/meta/
file_copy recipes-graphics/matchbox-wm/matchbox-wm_1.2.2.bb
file_copy recipes-graphics/matchbox-wm/matchbox-wm/0001-Fix-build-with-gcc-10.patch
file_copy recipes-graphics/matchbox-wm/matchbox-wm/kbdconfig

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/mesa/mesa_%.bbappend
file_copy recipes-graphics/mesa/mesa-demos_%.bbappend
file_copy recipes-graphics/mesa/mesa-demos/Add-OpenVG-demos-to-support-wayland.patch
file_copy recipes-graphics/mesa/mesa-demos/fix-clear-build-break.patch
file_copy recipes-graphics/mesa/mesa-demos/Replace-glWindowPos2iARB-calls-with-glWindowPos2i.patch

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/vulkan/assimp_5.0.1.bb
file_copy recipes-graphics/vulkan/assimp/0001-closes-https-github.com-assimp-assimp-issues-2733-up.patch
file_copy recipes-graphics/vulkan/assimp/0001-Use-ASSIMP_LIB_INSTALL_DIR-to-search-library.patch

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/wayland/weston-init.bbappend \
                        "44i\    install -Dm0755 \${WORKDIR}/profile \${D}\${sysconfdir}/profile.d/weston.sh" \
                        "\$a\\\nSRC_URI += \"file://profile\""

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/wayland/weston-init/imx/weston.ini
file_copy recipes-graphics/wayland/weston-init/profile
SOURCE_DIR=$GRAPHIC_SRC/poky/meta/
file_copy recipes-graphics/wayland/weston-init.bb \
                '72i\COMPATIBLE_MACHINE_nxp-imx6 = \"nxp-imx6\"'
file_copy recipes-graphics/wayland/weston-init/weston-start
file_copy recipes-graphics/wayland/weston-init/weston@.service
echo "[Unit]
Description=Weston Wayland Compositor (on tty7)
RequiresMountsFor=/run
Conflicts=getty@tty7.service plymouth-quit.service
After=systemd-user-sessions.service getty@tty7.service plymouth-quit-wait.service

[Service]
User=%i
PermissionsStartOnly=true

# Log us in via PAM so we get our XDG & co. environment and
# are treated as logged in so we can use the tty:
PAMName=login

# Grab tty7
UtmpIdentifier=tty7
TTYPath=/dev/tty7
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes

# stderr to journal so our logging doesn't get thrown into /dev/null
StandardOutput=tty
StandardInput=tty
StandardError=journal

EnvironmentFile=-/etc/default/weston

# Weston does not successfully change VT, nor does systemd place us on
# the VT it just activated for us. Switch manually:
ExecStartPre=/usr/bin/chvt 7
ExecStart=/usr/bin/weston --log=\${XDG_RUNTIME_DIR}/weston.log \$OPTARGS

IgnoreSIGPIPE=no

#[Install]
#Alias=multi-user.target.wants/weston.service" > $GRAPHIC_DTS/imx6-graphic/recipes-graphics/wayland/weston-init/weston@.service
file_copy recipes-graphics/wayland/weston-init/weston.env
file_copy recipes-graphics/wayland/weston-init/weston@.socket
file_copy recipes-graphics/wayland/weston-init/weston-autologin
file_copy recipes-graphics/wayland/weston-init/init
file_copy recipes-graphics/wayland/weston-init/71-weston-drm.rules
SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/wayland/weston-init/mx6sl/weston.config

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/wayland/weston_9.0.0.imx.bb
sed -i "s/weston_9.0.0.bb/weston_9.0.0.sdk.bb/g" $DESTINATION_DIR/recipes-graphics/wayland/weston_9.0.0.imx.bb
SOURCE_DIR=$GRAPHIC_SRC/poky/meta/
file_copy recipes-graphics/wayland/weston_9.0.0.bb
mv $DESTINATION_DIR/recipes-graphics/wayland/weston_9.0.0.bb $DESTINATION_DIR/recipes-graphics/wayland/weston_9.0.0.sdk.bb
file_copy recipes-graphics/wayland/weston/0001-weston-launch-Provide-a-default-version-that-doesn-t.patch
file_copy recipes-graphics/wayland/weston/0001-tests-include-fcntl.h-for-open-O_RDWR-O_CLOEXEC-and-.patch
file_copy recipes-graphics/wayland/weston/weston.desktop
file_copy recipes-graphics/wayland/weston/weston.png
file_copy recipes-graphics/wayland/weston/xwayland.weston-start
echo "From a2ba4714a6872e547621d29d9ddcb0f374b88cf6 Mon Sep 17 00:00:00 2001
From: Chen Qi <Qi.Chen@windriver.com>
Date: Tue, 20 Apr 2021 20:42:18 -0700
Subject: [PATCH] meson.build: fix incorrect header

The wayland.c actually include 'xdg-shell-client-protocol.h' instead of
the server one, so fix it. Otherwise, it's possible to get build failure
due to race condition.

Upstream-Status: Pending

Signed-off-by: Chen Qi <Qi.Chen@windriver.com>
---
 libweston/backend-wayland/meson.build | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libweston/backend-wayland/meson.build b/libweston/backend-wayland/meson.build
index 7e82513..29270b5 100644
--- a/libweston/backend-wayland/meson.build
+++ b/libweston/backend-wayland/meson.build
@@ -10,7 +10,7 @@ srcs_wlwl = [
        fullscreen_shell_unstable_v1_protocol_c,
        presentation_time_protocol_c,
        presentation_time_server_protocol_h,
-       xdg_shell_server_protocol_h,
+       xdg_shell_client_protocol_h,
        xdg_shell_protocol_c,
 ]

--
2.30.2" >$GRAPHIC_DTS/imx6-graphic/recipes-graphics/wayland/weston/0001-meson.build-fix-incorrect-header.patch

file_copy recipes-graphics/wayland/wayland-protocols_1.20.bb
SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/wayland/wayland-protocols_1.20.imx.bb
SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/wayland/wayland-protocols_1.18.imx.bb

file_copy recipes-graphics/xorg-xserver/xserver-xorg_%.bbappend \
                        "\$a# Trailing space is intentional due to a bug in meta-freescale" \
                        "\$aSRC_URI += \"file://0001-glamor-Use-CFLAGS-for-EGL-and-GBM.patch \"" \
                        "8d"
SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0001-glamor-Use-CFLAGS-for-EGL-and-GBM.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg_1.20.8.bb
file_copy recipes-graphics/xorg-xserver/xserver-xorg.inc
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0001-drmmode_display.c-add-missing-mi.h-include.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0001-prefer-to-use-GLES2-for-glamor-EGL-config.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0001-glamor-Use-CFLAGS-for-EGL-and-GBM.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0002-MGS-5186-Per-Specification-EGL_NATIVE_PIXMAP_KHR-req.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0001-MGS-5186-Per-Specification-EGL_NATIVE_PIXMAP_KHR-req.patch
file_copy recipes-graphics/xorg-xserver/xserver-xorg/0003-Remove-GL-library-and-dependency-from-xwayland.patch
file_copy recipes-graphics/xorg-xserver/files/0001-test-xtest-Initialize-array-with-braces.patch
file_copy recipes-graphics/xorg-xserver/files/0001-xf86pciBus.c-use-Intel-ddx-only-for-pre-gen4-hardwar.patch
file_copy recipes-graphics/xorg-xserver/files/pkgconfig.patch
file_copy recipes-graphics/xorg-xserver/files/sdksyms-no-build-path.patch

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/xorg-xserver/xserver-xf86-config_%.bbappend
SOURCE_DIR=$GRAPHIC_SRC/meta-imx/meta-bsp/
file_copy recipes-graphics/xorg-xserver/xserver-xf86-config/imx/xorg.conf
file_copy recipes-graphics/xorg-xserver/xserver-xf86-config/imxdrm/xorg.conf

file_copy recipes-kernel/linux/linux-imx-headers_5.10.bb \
                        "9iDEPENDS += \"rsync-native\"" \
                        "11,16d" \
                        "11iSRCBRANCH = \"v5.10/standard/nxp-sdk-5.10/nxp-soc\"" \
                        "12iKERNEL_SRC ?= \"git://\${LAYER_PATH_wrlinux}/git/linux-yocto.git;protocol=file\"" \
                        "13iSRC_URI = \"\${KERNEL_SRC};branch=\${SRCBRANCH}\"" \
                        "14iSRCREV = \"\${AUTOREV}\""

SOURCE_DIR=$GRAPHIC_SRC/meta-freescale/
file_copy recipes-graphics/waffle/waffle_%.bbappend
file_copy recipes-graphics/waffle/waffle/0001-meson-Add-missing-wayland-dependency-on-EGL.patch
file_copy recipes-graphics/waffle/waffle/0002-meson-Separate-surfaceless-option-from-x11.patch

SOURCE_DIR=$GRAPHIC_SRC/meta-imx/
file_copy EULA.txt
mv $GRAPHIC_DTS/imx6-graphic/EULA.txt $GRAPHIC_DTS/imx6-graphic/EULA

echo "Graphic layer is generated successfully!"
clean_up && exit 0

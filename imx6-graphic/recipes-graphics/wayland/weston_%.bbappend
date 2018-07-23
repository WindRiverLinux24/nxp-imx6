DEPENDS_append_imxgpu2d = " virtual/libg2d"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

REQUIRED_DISTRO_FEATURES_remove_mx6sl = "opengl"
PACKAGECONFIG_IMX_TO_REMOVE_mx6sl = ""
EXTRA_OECONF_append_mx6sl = " --disable-opengl"

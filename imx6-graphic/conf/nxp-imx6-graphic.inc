PREFERRED_PROVIDER_virtual/egl_nxp-imx6 = "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libgles1_nxp-imx6 = "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libgles2_nxp-imx6 = "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libgl_nxp-imx6 = "imx-gpu-viv"
PREFERRED_PROVIDER_virtual/libg2d_nxp-imx6 = "imx-gpu-g2d"
PREFERRED_VERSION_imx-vpu = "5.4.37"

PNWHITELIST_openembedded-layer += 'freeglut'
PNWHITELIST_imx6-graphic-layer += 'imx-gpu-viv'
PNWHITELIST_imx6-graphic-layer += 'imx-gpu-g2d'
PNWHITELIST_imx6-graphic-layer += 'imx-gpu-sdk'
PNWHITELIST_imx6-graphic-layer += 'imx-vpu'
PNWHITELIST_imx6-graphic-layer += 'assimp'
PNWHITELIST_imx6-graphic-layer += 'devil'
PNWHITELIST_imx6-graphic-layer += 'imx-lib'
PNWHITELIST_imx6-graphic-layer += 'xf86-video-imxfb-vivante'
PNWHITELIST_imx6-graphic-layer += 'imx-gpu-apitrace'
PNWHITELIST_imx6-graphic-layer += 'systemd-gpuconfig'

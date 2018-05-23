MAKE_NXP_IMX6_WIC = "no"
MAKE_NXP_IMX6_WIC_nxp-imx6 = "yes"

do_make_nxp_imx6_wic() {
	if [ ${MAKE_NXP_IMX6_WIC} = "yes" ]; then
		cd ${DEPLOY_DIR_IMAGE}
		cp ${IMAGE_LINK_NAME}.wic  ${IMAGE_LINK_NAME}-imx6q.wic
		dd if=u-boot.imx-imx6qsabresd of=${IMAGE_LINK_NAME}-imx6q.wic bs=512 seek=2 conv=fsync,notrunc
		cp ${IMAGE_LINK_NAME}.wic  ${IMAGE_LINK_NAME}-imx6sx.wic
		dd if=u-boot.imx-imx6sxsabresd of=${IMAGE_LINK_NAME}-imx6sx.wic bs=512 seek=2 conv=fsync,notrunc
	fi
}

addtask make_nxp_imx6_wic after do_image_complete before do_build

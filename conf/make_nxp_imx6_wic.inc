do_image_wic[postfuncs] += "nxp_imx6_wic"

nxp_imx6_wic() {
    for config in ${UBOOT_CONFIG}; do
        cd "${DEPLOY_DIR_IMAGE}"

        cp ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.wic ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}-${config}.wic
        dd if=u-boot-nxp-imx6.imx-${config} of=${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}-${config}.wic bs=512 seek=2 conv=fsync,notrunc

        cd "${IMGDEPLOYDIR}"
        bmaptool create "${IMAGE_LINK_NAME}-${config}.wic" -o "${IMAGE_LINK_NAME}-${config}.wic.bmap"
    done

    # Remove the default wic file
    # echo  ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.wic
    rm -rf "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.wic"
    rm -rf "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.wic.bmap"
    rm -rf "${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wic"
    rm -rf "${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.wic.bmap"
}

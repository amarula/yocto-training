SUMMARY = "Training information script"
DESCRIPTION = "Prints target and image information for the training labs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://training-info.sh"

S = "${UNPACKDIR}"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/training-info.sh ${D}${bindir}/training-info
}

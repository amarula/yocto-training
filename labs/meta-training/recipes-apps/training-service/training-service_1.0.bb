SUMMARY = "Yocto training systemd service"
DESCRIPTION = "Simple systemd service and user used in the system integration lab"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://training-service.sh \
           file://training-service.service \
          "

S = "${UNPACKDIR}"

inherit systemd useradd

SYSTEMD_SERVICE:${PN} = "training-service.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} = "-r -s /bin/false -d /var/lib/training -g training training"
GROUPADD_PARAM:${PN} = "-r training"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/training-service.sh ${D}${bindir}/training-service

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/training-service.service ${D}${systemd_system_unitdir}/
}

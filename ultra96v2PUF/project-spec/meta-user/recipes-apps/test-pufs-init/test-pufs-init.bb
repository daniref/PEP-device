#
# This file is the test-pufs-init recipe.
#
SUMMARY = "Simple test-pufs-init application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM ="file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://test-pufs-init \
        "
S = "${WORKDIR}"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

inherit update-rc.d

INITSCRIPT_NAME = "test-pufs-init"
INITSCRIPT_PARAMS = "start 99 S ."

do_install() {
        install -d ${D}${sysconfdir}/init.d
        install -m 0755 ${S}/test-pufs-init ${D}${sysconfdir}/init.d/test-pufs-init
}
FILES_${PN} += "${sysconfdir}/*"
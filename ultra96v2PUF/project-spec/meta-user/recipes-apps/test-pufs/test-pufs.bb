#
# This file is the test-pufs recipe.
#

DEPENDS += "curl glibc glib-2.0 openssl"
RDEPENDS_${PN} += "curl openssl glib-2.0"

INSANE_SKIP_${PN} = "ldflags"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"
IMAGE_INSTALL_append = "static-staticdev"
TARGET_CC_ARCH += "${LDFLAGS}"

SUMMARY = "Simple test-pufs application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://."

S = "${WORKDIR}"

do_compile() {
	     oe_runmake
}

do_install() {
	     install -d ${D}${bindir}
	     install -m 0755 test-pufs ${D}${bindir}
}

#FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

#inherit update-rc.d

#INITSCRIPT_NAME = "test-pufs"
#INITSCRIPT_PARAMS = "start 99 S ."

#do_install() {
#  install -d ${D}${sysconfdir}/init.d
#  install -m 0755 ${S}/test-pufs ${D}${sysconfdir}/init.d/test-pufs
#}
#FILES_${PN} += "${sysconfdir}/*"
SUMMARY = "Yocto training package group"
DESCRIPTION = "Applications used throughout the Yocto training labs"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = "hello training-info"

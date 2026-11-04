SUMMARY = "Yocto training image"
DESCRIPTION = "Minimal image with the training applications"
LICENSE = "MIT"

require recipes-core/images/core-image-minimal.bb

IMAGE_INSTALL:append = " packagegroup-training"
IMAGE_FEATURES:append = " ssh-server-openssh"
IMAGE_FSTYPES:append = " wic"

WKS_FILE = "training.wks"

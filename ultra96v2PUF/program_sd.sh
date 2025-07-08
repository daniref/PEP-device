#!/bin/bash
set -e

# Richiedi la password sudo una sola volta
sudo -v

# Definisci le directory
MOUNT_POINT="/media/puftester"
BOOT_FOLDER_DIR="/media/puftester/BOOT"
ROOT_FOLDER_DIR="/media/puftester/root"
BOOT_BIN_DIR="images/linux"
BOOT_SCR_DIR="images/linux"
IMAGE_UB_DIR="images/linux"
ROOT_FS_DIR="images/linux"
SD_DEVICE="/dev/sdd"  # Pay attention!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Funzione per mostrare l'uso
usage() {
    echo "Usage: $0 [-b] [-p] [-z]"
    echo "  -b    Esegui solo 'petalinux-build'"
    echo "  -p    Esegui solo 'petalinux-package'"
    echo "  -z    Esegui build, package e formatta la scheda SD"
    exit 1
}

# Funzione per il build del sistema
run_build() {
    echo "Petalinux-build in esecuzione..."
    petalinux-build
    echo "Petalinux-build completato!"
}

# Funzione per il package del sistema
run_package() {
    echo "Petalinux-package in esecuzione..."
    petalinux-package --boot --fsbl $BOOT_BIN_DIR/zynqmp_fsbl.elf --fpga ~/PhD/peta_prj/ultra96v2_base_hw/bitstream.bit --pmufw $BOOT_BIN_DIR/pmufw.elf --u-boot --force
    echo "Petalinux-package completato!"

    # Creazione dei punti di montaggio
    sudo mkdir -p ${BOOT_FOLDER_DIR}
    sudo mkdir -p ${ROOT_FOLDER_DIR}

    # Montaggio delle partizioni
    sudo mount ${SD_DEVICE}1 ${BOOT_FOLDER_DIR}
    sudo mount ${SD_DEVICE}2 ${ROOT_FOLDER_DIR}

    # Rimuovi i file esistenti
    echo "Rimozione dei file nella directory BOOT..."
    sudo rm -rf ${BOOT_FOLDER_DIR:?}/*
    echo "Rimozione dei file nella directory root..."
    sudo rm -rf ${ROOT_FOLDER_DIR:?}/*

    # Copia i nuovi file
    echo "Copia dei file nella directory BOOT..."
    sudo cp $BOOT_BIN_DIR/BOOT.BIN $BOOT_FOLDER_DIR
    sudo cp $BOOT_SCR_DIR/boot.scr $BOOT_FOLDER_DIR
    sudo cp $IMAGE_UB_DIR/image.ub $BOOT_FOLDER_DIR

    # Estrazione del filesystem root
    echo "Estrazione del filesystem root..."
    sudo tar -xf $ROOT_FS_DIR/rootfs.tar.gz -C $ROOT_FOLDER_DIR

    echo "Copying ssh public key in rootfs"
    copy_ssh_pubKey
    # Smonta le directory
    echo "Smontaggio delle directory BOOT e root..."
    sudo umount $BOOT_FOLDER_DIR
    sudo umount $ROOT_FOLDER_DIR
}

# Funzione per la formattazione e la partizionamento della scheda SD
format_sd() {
    echo "Formattazione e partizionamento della scheda SD..."
    
    # Smonta le partizioni esistenti
    sudo umount ${SD_DEVICE}1 || true
    sudo umount ${SD_DEVICE}2 || true

    # Creazione delle nuove partizioni
    sudo parted $SD_DEVICE --script mklabel msdos
    sudo parted $SD_DEVICE --script mkpart primary fat32 1MiB 1025MiB
    sudo parted $SD_DEVICE --script mkpart primary ext4 1025MiB 100%

    # Formattazione delle nuove partizioni
    sudo mkfs.vfat -F 32 -n BOOT ${SD_DEVICE}1
    sudo mkfs.ext4 -F -L root ${SD_DEVICE}2

    echo "Formattazione completata!"
}

copy_ssh_pubKey()
{
    sudo mkdir $ROOT_FOLDER_DIR/home/root/.ssh
    sudo touch $ROOT_FOLDER_DIR/home/root/.ssh/authorized_keys
    sudo sh -c 'cat ssh_key.pub >> '$ROOT_FOLDER_DIR'/home/root/.ssh/authorized_keys'
}

# Processa le opzioni
while getopts ":fbpz" opt; do
    case ${opt} in
        f )
            format_sd
            ;;
        b )
            run_build
            ;;
        p )
            run_package
            ;;
        z )
            format_sd
            # run_build
            run_package
            ;;
        \? )
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Verifica che siano state fornite opzioni
if [ "$OPTIND" -eq 1 ]; then
    echo "Nessuna opzione fornita."
    usage
fi

echo "Operazione completata con successo."

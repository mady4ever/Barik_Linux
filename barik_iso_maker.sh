# Prepaire 
rm -rf kaamkaj
mkdir kaamkaj
mkdir -p source


# Get kernel

DOWNLOAD_URL=https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.18.6.tar.xz
ARCHIVE_FILE=${DOWNLOAD_URL##*/}
cd source

# Downloading kernel file
wget -c $DOWNLOAD_URL
rm -rf ../kaamkaj/kernel
mkdir ../kaamkaj/kernel

# Extract kernel to folder 'kaamkaj/kernel'
tar -xvf $ARCHIVE_FILE -C ../kaamkaj/kernel
cd ..

# Build Kernel
cd kaamkaj/kernel
# Change to the first directory ls finds, e.g. 'linux-3.18.6'
cd $(ls -d *)
make mrproper
make defconfig
sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\"CustomeNameHere\"/" .config

# Compile the kernel
make bzImage
cd ../../..


# Get BusyBox.
DOWNLOAD_URL1=http://busybox.net/downloads/busybox-1.23.1.tar.bz2
ARCHIVE_FILE1=${DOWNLOAD_URL1##*/}
cd source
wget -c $DOWNLOAD_URL1
rm -rf ../kaamkaj/busybox
mkdir ../kaamkaj/busybox
tar -xvf $ARCHIVE_FILE1 -C ../kaamkaj/busybox
cd ..
# Build Busybox
cd kaamkaj/busybox
cd $(ls -d *)
make clean
make defconfig
sed -i "s/.*CONFIG_STATIC.*/CONFIG_STATIC=y/" .config
# Compile busybox
make busybox
make install
cd ../../..
# Generate Root file system and welcome texts.
cd kaamkaj
rm -rf rootfs
cd busybox
cd $(ls -d *)
cp -R _install ../../rootfs
cd ../../rootfs
rm -f linuxrc

#create directory structure.

mkdir dev
mkdir etc
mkdir proc
mkdir root
mkdir src
mkdir sys
mkdir tmp
chmod 1777 tmp

cd etc

cat > bootscript.sh << EOF
#!/bin/sh

dmesg -n 1
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys

EOF

chmod +x bootscript.sh

cat > hi.txt << EOF

  #####################################
  #   Welcome to Sajjanpure baby!     #
  #####################################

EOF

cat > inittab << EOF
::sysinit:/etc/bootscript.sh
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::once:cat /etc/hi.txt
::respawn:/bin/cttyhack /bin/sh
tty2::once:cat /etc/hi.txt
tty2::respawn:/bin/sh
tty3::once:cat /etc/hi.txt
tty3::respawn:/bin/sh
tty4::once:cat /etc/hi.txt
tty4::respawn:/bin/sh

EOF

cd ..
cat > init << EOF
#!/bin/sh

exec /sbin/init

EOF

chmod +x init
cp ../../*.sh src
cp ../../.config src
chmod +r src/*.sh
chmod +r src/.config
cd ../..

# Pack Root File system.

cd kaamkaj

rm -f rootfs.cpio.gz

cd rootfs

find . | cpio -H newc -o | gzip > ../rootfs.cpio.gz

cd ../..

# Finally generate the iso file.

rm -f minimal_linux_live.iso

cd kaamkaj/kernel
cd $(ls -d *)

make isoimage FDINITRD=../../rootfs.cpio.gz
cp arch/x86/boot/image.iso ../../../minimal_linux_live.iso

cd ../../..

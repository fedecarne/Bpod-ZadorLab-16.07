This sound calibration software currently requires the following (very expensive) hardware:

-A USB1608G acquisition board (Measurement Computing)
-A pressure-field microphone:
http://www.bksv.com/products/transducers/acoustic/microphones/microphone-preamplifier-combinations/4138-a-15
-A conditioning amplifier:
http://www.bksv.com/Products/transducers/conditioning/charge/2692A0I1


Steps to follow to install the drivers of MC USB-1608G in Ubuntu (tested in 14.04LTS)

1) Install build-essentials
   sudo apt-get install build-essential

2) Install libedev
   sudo apt-get install libudev-dev libusb-1.0-0-dev libfox-1.6-dev

3) Install hidapi

 git clone git://github.com/signal11/hidapi.git

 sudo apt-get install autotools-dev autoconf automake libtool
 cd hidapi
 sudo ./bootstrap
 sudo ./configure
 sudo make
 sudo make install


3) Download 61-mcc.rules from ftp://lx10.tx.ncsu.edu/pub/Linux/drivers by Save link as and install
   
  sudo cp 61-mcc.rules /etc/udev/rules.d
  sudo /sbin/udevadm control --reload-rules

4) Download MCCLIBUSB.1.07.tgz from ftp://lx10.tx.ncsu.edu/pub/Linux/drivers/USB/

   tar zxvf  MCCLIBUSB.1.07.tgz
   cd mcc-libusb
   sudo make
   sudo make install
   sudo ldconfig

5) Go to Bpod/Functions/SoundCalibrator/mcc
   sudo make
   sudo make install

6) Connect the usb plug and test by doing ./read-usb1608G 1 2 10 10000
If it return 2 values then you are fine.

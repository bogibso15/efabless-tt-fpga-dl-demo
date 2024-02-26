Step to successfully flash the bootloader:

1. connect clip over top flash
2. jumper reset to gnd
3. plug usb to fpga board
4. power up Tigard
5. python3 caravelflash/flash_util.py --capacity
6. python3 caravelflash/flash_util.py --write fpgaboot/bootloader-withlock.bin
7. 
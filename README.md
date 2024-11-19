# QR-Code Generator for Commodore VIC-20,C64,C128,Mega65,X16

The name of the repo is qr128, because I mainly developed on the c128 and only ported it to the other systems later, when I found out that they should be able to manage it perfectly fine.

## Languages
This is implemented in Commodore Basic and in 6502 Assembly Language.


### Basic
Files with extension BAS are the Basic source files, written in C64 Studio. The executable Basic files for the Commodore systems are for example qrdriver.prg, qrdriver64.prg, etc.
They are stored in the directories that are named after the systems.

The system-specific folders also contain disk-images with all executables (if available).


### Assembly Language
All source files are in the [[asm]] folder. While this started on the C128, I tried to port it to the other systems as well. Mega 65 and X16 are not done (yet).
I'm counting on input from the community on these systems.


The file to start with is qr.a
It contains all the necessary includes. System-specific behavior is supposed to be handled by !IF directives.

### C
The C-Implementation mentioned in the Video can be found at CSDB: [[https://csdb.dk/release/?id=106999]]


nayuki.io also provides a C-implementation. Keep in mind though that this is not tailored towards 6502 systems and might need a bit of work when it comes to libraries and includes.
[[https://github.com/nayuki/QR-Code-generator/tree/master/c]]



If you find this useful for your projects, I'd love to hear about it.


Have fun!

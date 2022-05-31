Telephone is a VoIP program which allows you to make phone calls over
the internet. It can be used to call regular phones via any
appropriate SIP provider. If your office or home phone works via SIP,
you can use that phone number on your Mac anywhere you have decent
internet connection.

## Building

### Opus

Opus codec is optional.

Download:

    $ curl -O https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz
    $ tar xzvf opus-1.3.1.tar.gz
    $ cd opus-1.3.1

Build and install:

    $ ./configure --prefix=/path/to/Telephone/ThirdParty/Opus --disable-shared CFLAGS='-arch arm64 -arch x86_64 -Os -mmacosx-version-min=10.13'
    $ make
    $ make install

### LibreSSL

Download:

    $ curl -O https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-3.1.5.tar.gz
    $ curl -O https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-3.1.5.tar.gz.asc
    $ gpg --verify libressl-3.1.5.tar.gz.asc
    $ tar xzvf libressl-3.1.5.tar.gz
    $ cd libressl-3.1.5

Build and install:

    $ ./configure --prefix=/path/to/Telephone/ThirdParty/LibreSSL --disable-shared CFLAGS='-arch arm64 -arch x86_64 -Os -mmacosx-version-min=10.13'
    $ make
    $ make install

### PJSIP

Download:

    $ curl -o pjproject-2.10.tar.gz https://codeload.github.com/pjsip/pjproject/tar.gz/2.10
    $ tar xzvf pjproject-2.10.tar.gz
    $ cd pjproject-2.10

Create `pjlib/include/pj/config_site.h`:

    #define PJSIP_DONT_SWITCH_TO_TCP 1
    #define PJSUA_MAX_ACC 32
    #define PJMEDIA_RTP_PT_TELEPHONE_EVENTS 101
    #define PJ_DNS_MAX_IP_IN_A_REC 32
    #define PJ_DNS_SRV_MAX_ADDR 32
    #define PJSIP_MAX_RESOLVED_ADDRESSES 32
    #define PJ_HAS_IPV6 1

Patch:

    $ patch -p0 -i /path/to/Telephone/ThirdParty/PJSIP/patches/sock_qos_darwin.patch
    $ patch -p0 -i /path/to/Telephone/ThirdParty/PJSIP/patches/os_core_unix.patch
    $ patch -p0 -i /path/to/Telephone/ThirdParty/PJSIP/patches/coreaudio_dev.patch

Build and install (remove `--with-opus` option if you don’t need Opus):

    $ ./configure --prefix=/path/to/Telephone/ThirdParty/PJSIP --with-opus=/path/to/Telephone/ThirdParty/Opus --with-ssl=/path/to/Telephone/ThirdParty/LibreSSL --disable-video --disable-libyuv --disable-libwebrtc --host=arm-apple-darwin CFLAGS='-arch arm64 -arch x86_64 -Os -DNDEBUG -mmacosx-version-min=10.13' CXXFLAGS='-arch arm64 -arch x86_64 -Os -DNDEBUG -mmacosx-version-min=10.13'
    $ make lib
    $ make install

    
Build Telephone.

## Contribution

For the legal reasons, pull requests are not accepted. Please feel
free to share your thoughts and ideas by commenting on the issues.

Telephone is a VoIP program which allows you to make phone calls over
the internet. It can be used to call regular phones via any
appropriate SIP provider. If your office or home phone works via SIP,
you can use that phone number on your Mac anywhere you have decent
internet connection.

## Building

### Opus

Opus codec is optional.

Download:

    $ curl -O https://archive.mozilla.org/pub/opus/opus-1.2.1.tar.gz
    $ tar xzvf opus-1.2.1.tar.gz
    $ cd opus-1.2.1

Build and install:

    $ ./configure --prefix=/path/to/Telephone/ThirdParty/Opus --disable-shared CFLAGS='-O2 -mmacosx-version-min=10.10'
    $ make
    $ make install

### PJSIP

Download:

    $ ftp http://www.pjsip.org/release/2.5.5/pjproject-2.5.5.tar.bz2
    $ tar xzvf pjproject-2.5.5.tar.bz2
    $ cd pjproject-2.5.5

Create `pjlib/include/pj/config_site.h`:

    #define PJSIP_DONT_SWITCH_TO_TCP 1
    #define PJSUA_MAX_ACC 32
    #define PJMEDIA_RTP_PT_TELEPHONE_EVENTS 101
    #define PJMEDIA_RTP_PT_TELEPHONE_EVENTS_STR "101"
    #define PJ_DNS_MAX_IP_IN_A_REC 32
    #define PJ_DNS_SRV_MAX_ADDR 32
    #define PJSIP_MAX_RESOLVED_ADDRESSES 32
    #define PJ_GETHOSTIP_DISABLE_LOCAL_RESOLUTION 1

Build and install (remove `--with-opus` option if you don’t need Opus):

    $ ./configure --prefix=/path/to/Telephone/ThirdParty/PJSIP --with-opus=/path/to/Telephone/ThirdParty/Opus --host=x86_64-apple-darwin CFLAGS='-mmacosx-version-min=10.10'
    $ make lib
    $ make install

### LibreSSL

    $ curl -O https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.6.3.tar.gz
    $ curl -O https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.6.3.tar.gz.asc
    $ gpg --verify libressl-2.6.3.tar.gz.asc
    $ tar xzvf libressl-2.6.3.tar.gz
    $ cd libressl-2.6.3
    $ ./configure --prefix=/path/to/Telephone/ThirdParty/LibreSSL --disable-shared CFLAGS='-mmacosx-version-min=10.10'
    $ make
    $ make install

    
Build Telephone.

## Contribution

For the legal reasons, pull requests are not accepted. Please feel
free to share your thoughts and ideas by commenting on the issues.

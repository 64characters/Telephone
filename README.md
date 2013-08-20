Telephone is a VoIP program which allows you to make phone calls over
the internet. It can be used to call regular phones via any
appropriate SIP provider. If your office or home phone works via SIP,
you can use that phone number on your Mac anywhere you have decent
internet connection.

Building
--------

To quickly build pjsip so that you can then build Telephone run:

```
./build-pjsip.sh
```

This script does what is detailed here below.

Telephone's SIP user agent is based on [pjsip][]. You need to build it
before building Telephone. Name the directory _pjproject_ and place it
near Telephone, in the same parent directory.

  [pjsip]: http://www.pjsip.org/

    $ svn checkout http://svn.pjsip.org/repos/pjproject/tags/2.1 pjproject
    $ cd pjproject

Create the file `pjlib/include/pj/config_site.h` with the following
contents:

    #define PJMEDIA_AUDIO_DEV_HAS_PORTAUDIO 0
    #define PJMEDIA_AUDIO_DEV_HAS_COREAUDIO 1
    #define PJSIP_DONT_SWITCH_TO_TCP 1
    #define PJSUA_MAX_ACC 32
    #define PJMEDIA_RTP_PT_TELEPHONE_EVENTS 101
    #define PJMEDIA_RTP_PT_TELEPHONE_EVENTS_STR "101"
    #define PJ_DNS_MAX_IP_IN_A_REC 32
    #define PJ_DNS_SRV_MAX_ADDR 32
    #define PJSIP_MAX_RESOLVED_ADDRESSES 32

Include CoreAudio at the line 35 in `pjmedia/src/pjmedia-audiodev/coreaudio_dev.c`:

    Index: pjmedia/src/pjmedia-audiodev/coreaudio_dev.c
    ===================================================================
    --- pjmedia/src/pjmedia-audiodev/coreaudio_dev.c	(revision 4580)
    +++ pjmedia/src/pjmedia-audiodev/coreaudio_dev.c	(working copy)
    @@ -32,6 +32,7 @@

     #include <AudioUnit/AudioUnit.h>
     #include <AudioToolbox/AudioConverter.h>
    +#include <CoreAudio/CoreAudio.h>
     #if !COREAUDIO_MAC
        #include <AudioToolbox/AudioServices.h>

Add `static` at the line 286 in `third_party/srtp/crypto/cipher/aes_icm.c`:

    Index: third_party/srtp/crypto/cipher/aes_icm.c
    ===================================================================
    --- third_party/srtp/crypto/cipher/aes_icm.c	(revision 4580)
    +++ third_party/srtp/crypto/cipher/aes_icm.c	(working copy)
    @@ -283,7 +283,7 @@
      * this is an internal, hopefully inlined function
      */

    -inline void
    +static inline void
     aes_icm_advance_ismacryp(aes_icm_ctx_t *c, uint8_t forIsmacryp) {
       /* fill buffer with new keystream */
       v128_copy(&c->keystream_buffer, &c->counter);

Configure and build pjsip:

    $ ./configure
    $ make
    
Build Telephone.

Coding Style
------------

Telephone source code follows [Google Objective-C Style Guide][coding_style]
with the exception of maximum 120-column width and 4 spaces for indentation.

  [coding_style]: http://google-styleguide.googlecode.com/svn/trunk/objcguide.xml

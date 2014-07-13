Telephone is a VoIP program which allows you to make phone calls over
the internet. It can be used to call regular phones via any
appropriate SIP provider. If your office or home phone works via SIP,
you can use that phone number on your Mac anywhere you have decent
internet connection.

Building
--------

Telephone's SIP user agent is based on [pjsip][]. You need to build it
before building Telephone. Name the directory _pjproject_ and place it
near Telephone, in the same parent directory.

  [pjsip]: http://www.pjsip.org/

    $ svn checkout http://svn.pjsip.org/repos/pjproject/tags/2.2.1 pjproject
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

Configure and build pjsip:

    $ CFLAGS="-mmacosx-version-min=10.8" ./configure
    $ make lib
    
Build Telephone.

Coding Style
------------

Telephone source code follows [Google Objective-C Style Guide][coding_style]
with the exception of maximum 120-column width and 4 spaces for indentation.

  [coding_style]: http://google-styleguide.googlecode.com/svn/trunk/objcguide.xml

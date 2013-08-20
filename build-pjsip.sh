#!/bin/sh
cd ..
echo "[+] Checking out http://svn.pjsip.org/repos/pjproject/tags/2.1"
svn checkout http://svn.pjsip.org/repos/pjproject/tags/2.1 pjproject &&
cd pjproject &&
echo "[+] Writing pjlib/include/pj/config_site.h"
echo '#define PJMEDIA_AUDIO_DEV_HAS_PORTAUDIO 0
#define PJMEDIA_AUDIO_DEV_HAS_COREAUDIO 1
#define PJSIP_DONT_SWITCH_TO_TCP 1
#define PJSUA_MAX_ACC 32
#define PJMEDIA_RTP_PT_TELEPHONE_EVENTS 101
#define PJMEDIA_RTP_PT_TELEPHONE_EVENTS_STR "101"
#define PJ_DNS_MAX_IP_IN_A_REC 32
#define PJ_DNS_SRV_MAX_ADDR 32
#define PJSIP_MAX_RESOLVED_ADDRESSES 32
' > pjlib/include/pj/config_site.h &&

echo "[+] Patching pjmedia/src/pjmedia-audiodev/coreaudio_dev.c" &&
echo 'Index: pjmedia/src/pjmedia-audiodev/coreaudio_dev.c
===================================================================
--- pjmedia/src/pjmedia-audiodev/coreaudio_dev.c    (revision 4580)
+++ pjmedia/src/pjmedia-audiodev/coreaudio_dev.c    (working copy)
@@ -32,6 +32,7 @@

 #include <AudioUnit/AudioUnit.h>
 #include <AudioToolbox/AudioConverter.h>
+#include <CoreAudio/CoreAudio.h>
 #if !COREAUDIO_MAC
    #include <AudioToolbox/AudioServices.h>
' | patch pjmedia/src/pjmedia-audiodev/coreaudio_dev.c &&

echo "[+] Patching third_party/srtp/crypto/cipher/aes_icm.c" &&
echo '286c286
< inline void
---
> static inline void
' | patch third_party/srtp/crypto/cipher/aes_icm.c &&

echo "[+] Building pjsip" &&
./configure && make &&
echo "You are now all good to go."
echo "Telephone should build with X-Code properly."

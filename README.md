Telephone is a VoIP program which allows you to make phone calls over
the internet. It can be used to call regular phones via any
appropriate SIP provider. If your office or home phone works via SIP,
you can use that phone number on your Mac anywhere you have decent
internet connection.

Building
--------

Telephone's SIP user agent is based on [pjsip][]. You need to build it
before building Telephone. Place it to the directory named _pjproject_
in the same directory as you placed Telephone.

  [pjsip]: http://www.pjsip.org/

    $ svn checkout http://svn.pjsip.org/repos/pjproject/tags/1.8.10 pjproject
    $ cd pjproject

Create the file `pjlib/include/pj/config_site.h` with the following
contents.

    #define PJSIP_DONT_SWITCH_TO_TCP 1
    #define PJSUA_MAX_ACC 32

Configure and build Telephone    

    $ ./configure --disable-ssl
    $ make
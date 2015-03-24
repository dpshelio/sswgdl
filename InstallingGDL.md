# Introduction #
The source code for GDL can be obtained from the [GDL homepage](http://gnudatalanguage.sourceforge.net/).
This source code needs to be compiled in order to create a gdl executable.

# Mac OSX #

Unfortunately, GDL uses many libraries which are not available with a
standard installation of Mac OS X.  Some programs such as [macports](http://www.macports.org/) or [Fink](http://www.finkproject.org/index.php) can make
this process easier by automatically downloading compiled versions of the libraries GDL needs.

  1. Install Apple's [XCode](http://developer.apple.com/technologies/tools/xcode.html).  This will install many important libraries as well as install a compiler, gcc.
  1. Install [macports](http://www.macports.org/).
  1. Run the following command  ` sudo port install gnudatalanguage ` which will (by default) install the GDL executable in /opt/local/bin/
  1. Now try running GDL by simply typing `gdl` in the Terminal.

The next step is to set up GDL to recognize SSW.  The following assumes that you already have an installation of SSW in /usr/local/ssw.  If not go to the [SSW installation page](http://www.lmsal.com/solarsoft/ssw_install.html) and follow the instructions.

  * Fink - GDL 0.9rc4-3 http://pdb.finkproject.org/pdb/package.php/gdl
  * Macports - GDL  0.9rc4 http://trac.macports.org/browser/trunk/dports/gnome/gdl/Portfile

# Windows #

Compiling software is difficult under any windows therefore our solution to this problem is to install a virtual machine which itself runs some version of linux and install GDL inside this virtual machine. Our virtual machine of choice here is [VirtualBox](http://www.virtualbox.org/) and our linux distribution will be Fedora. Fedora earns our respect because GDL is included directly in its software installer.

  1. Install Virtual box which can be found here. The VirtualBox Personal Use and Evaluation License (PUEL) provides all the functionality that you will need for GDL.
  1. Next we must install Fedora 13 inside this virtual box. An easy install designed specifically for Virtual box can be found here. A small charge of $3 will give you access to an ftp download as well as the vboxguestadditions which provides seamless mode (fedora windows mingle with normal windows), and easy file sharing between your virtual box and windows.
  1. Now start virtual box and create a new system with your fedora virtual box image.
  1. Once it is install start your new fedora system. The default login and password for fedora is _user_ and _admin_.
  1. We can now easily install GDL by going to the system menu and choosing "add/remove software". You should install GDL, GDL common tools.CVS, and tcsh (our terminal of choice).

The next step is to setup GDL to recognize SSW.  The following assumes that you already have an installation of SSW in /usr/local/ssw.  If not go to the [SSW installation page](http://www.lmsal.com/solarsoft/ssw_install.html) and follow the instructions.

# Linux #
Add instructions here
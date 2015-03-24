# Introduction #

A quick introduction to using SVN to sync with a code project.  Subversion (or SVN) is a complete versioning system.  All changes to the code are documented and saved so that all previous versions are always available.  SVN should be installed automatically on Mac OS X and some flavors of linux.  If not you can find many different free versions out there.  For Windows users, we recommend http://tortoisesvn.tigris.org/ which comes with Explorer integration plugin.

The following describes how to use SVN on the command line but should be useful for those with a GUI interface as well.  For those using the command line, you may also like to install a program to facilitate merging of files which may be very tedious to do through the command line.

# Details #

First you should create a local copy (a sswgdl directory) of the code project with the following command
```
svn checkout https://sswgdl.googlecode.com/svn/trunk/ sswgdl --username yourusername
```
This will create a directory called sswgdl and download the latest (or head) version of the projects contents into it (or at least everything in trunk).  This directory will now be SVN enabled meaning that it will be keeping track of whether you make any changes to it.

You can then work with your local copy.  You can update it at any time with the command within the svn-enabled directory
```
svn update
```
If your files show conflicts with those on the google code server you will then be asked to merge the changes.  If you would like to update the project with some of your own changes first run the update and then run
```
svn commit --message 'a description of my changes'
```
This will uploaded the files you have changed to the project.  You are required to always append a message describing your changes.  In order for the messages to be worthwhile please try to run commit as often as possible.

If you would like to add files to the project it is NOT enough to create them within the directory.  You must also declare them to the SVN with the following command
```
svn add filename
```
This command also works for directories.  You can then run the commit command.

Other self-explanatory commands are also possible such as
```
svn move
svn delete
```
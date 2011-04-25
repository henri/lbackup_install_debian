# lbackup_install_debian #

LBackup is an open source (GNU GPL) backup system, aimed at systems administrators who demand reliable backups.

Use this project to build the .deb installer for LBackup. 

In order to build an .deb installer follow the steps outlined below : 
 
 - Ensure that you have checked out the version of lbackup core which you wish to build : <http://github.com/henri/lbackup_core>
 - Ensure that you have the dpkg packaging tools installed on your system.
 - Ensure you are have super user privileges on your system.
 - Ensure that the "lbackup-core" and "lbackup_install_debian" share the same parent directory. 
 - Execute the "build.bash" script and pass the script the version number for this build (eg: './build.bash 0.9.8r5')

Further information including basic and more advanced usage is available from the following URL: 
<http://www.lbackup.org>

Instructions for installing directly from source are available from the following URL : <http://www.lbackup.org/source>

Online build instructions for debian : 
http://www.lbackup.org/developer/debian_build_notes

Comments and suggestions regarding the LBackup project and also the debian package install process are very welcome.




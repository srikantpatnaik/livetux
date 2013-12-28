======
README
======

-------------------------
What is this script for ?
-------------------------

To create minimal Livecd/USB with enlightenment desktop. The initial
effort will focus on i386 based machines with Ubuntu repositories. 

Dependencies
------------

* extlinux

* kpartx

* qemu

* 5 GB of free space and internet connection


Running the script
------------------

Run the script as root ::

	bash livetux.sh


Caution
-------

This script uses `dd` command, which can wipe out your disk if not careful. 
Please read the script before executing, and if you have any doubt please raise
an issue first. It worked for me. In simple words, I don't guarantee your data. 

-------
LICENSE
-------
GNU GPLv3

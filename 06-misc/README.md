## Miscellaneous Topics

### X11 and OpenGL

You can use Singularity containers to display graphics through common protocols. To do this, you need to install the proper graphics stack within the Singularity container.  For instance if you want to display X11 graphics you must install `xorg` within your container.  In an Ubuntu container the command would look like this.  

```
$ apt-get install xorg
```

### GPU computing

In Singularity v2.3+ the experimental `--nv` option will look for NVIDIA libraries on the host system and automatically bind mount them to the container so that GPUs work seamlessly. 

### Using the network on the host system

Network ports on the host system are accessible from within the container and work seamlessly.  For example, you could install ipython within a container, start a jupyter notebook instance, and then connect to that instance using a browser running outside of the container on the host system or from another host.  

### a note on SUID programs and daemons

Some programs need root privileges to run.  These often include services or daemons that start via the `init.d` or `system.d` systems and run in the background.  For instance, `sshd` the ssh daemon that listens on port 22 and allows another user to connect to your computer requires root privileges.  You will not be able to run it in a container unless you start the container as root.

Other programs may set the SUID bit or capabilities to run as root or with elevated privileges without your knowledge. For instance, the well-known `ping` program actually runs with elevated privileges (and needs to since it sets up a raw network socket).  This program will not run in a container unless you are root in the container.

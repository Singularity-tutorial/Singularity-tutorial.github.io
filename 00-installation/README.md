### Install
Here we will install the latest tagged release from [GitHub](https://github.com/singularityware/singularity). If you prefer to install a different version or to install Singularity in a different location, see these [Singularity docs](http://singularity.lbl.gov/docs-installation).

We're going to compile Singularity from source code.  First we'll need to make sure we have some development tools installed so that we can do that.  On Ubuntu, run these commands to make sure you have all the necessary packages installed.

```
$ sudo apt-get update

$ sudo apt-get -y install python build-essential debootstrap squashfs-tools
```

On CentOS, these commmands should get you up to speed.

```
$ sudo yum update 

$ sudo yum groupinstall 'Development Tools'

$ sudo yum install wget epel-release

$ sudo yum install debootstrap.noarch squashfs-tools
```

Next we'll download a compressed archive of the source code (using the the `wget` command). Then we'll extract the source code from the archive (with the `tar` command).

```
$ wget https://github.com/singularityware/singularity/releases/download/2.4.2/singularity-2.4.2.tar.gz

$ tar -xf singularity-2.4.2.tar.gz
```

Finally it's time to build and install!

```
$ cd singularity-2.4.2

$ ./configure --prefix=/usr/local

$ make 

$ sudo make install
```

If you want support for tab completion of Singularity commands, you need to source the appropriate file and add it to the bash completion directory in `/etc` so that it will be sourced automatically when you start another shell.

```
$ . etc/bash_completion.d/singularity

$ sudo cp etc/bash_completion.d/singularity /etc/bash_completion.d/
```

If everything went according to plan, you now have a working installation of Singularity.  You can test your installation like so:

```
$ singularity run docker://godlovedc/lolcow
```

You should see something like the following.

```
Docker image path: index.docker.io/godlovedc/lolcow:latest
Cache folder set to /home/ubuntu/.singularity/docker
[6/6] |===================================| 100.0%
Creating container runtime...
 _______________________________________
/ Excellent day for putting Slinkies on \
\ an escalator.                         /
 ---------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

Your cow will likely say something different (and be more colorful), but as long as you see a cow your installation is working properly.  

This command downloads and runs a container from [Docker Hub](https://hub.docker.com/r/godlovedc/lolcow/).  During the next hour we will learn how to build a similar container from scratch.  

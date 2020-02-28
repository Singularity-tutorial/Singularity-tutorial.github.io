# Installing Singularity
Here we will install the latest tagged release from [GitHub](https://github.com/sylabs/singularity/releases). If you prefer to install a different version or to install Singularity in a different location, see these [Singularity docs](https://sylabs.io/guides/3.5/admin-guide/installation.html).

We're going to compile Singularity from source code.  First we'll need to make sure we have some development tools and libraries installed so that we can do that.  On Ubuntu, run these commands to make sure you have all the necessary packages installed.

```
$ sudo apt-get update

$ sudo apt-get install -y build-essential libssl-dev uuid-dev libgpgme11-dev \
    squashfs-tools libseccomp-dev wget pkg-config git cryptsetup debootstrap
```

On CentOS, these commmands should get you up to speed.

```
$ sudo yum -y update 

$ sudo yum -y groupinstall 'Development Tools'

$ sudo yum -y install wget epel-release

$ sudo yum -y install debootstrap.noarch squashfs-tools openssl-devel \
    libuuid-devel gpgme-devel libseccomp-devel cryptsetup-luks
```

Singularity v3.0 was completely re-written in [Go](https://golang.org/). We will need to install the Go language so that we can compile Singularity. This procedure consists of downloading Go in a compressed archive, extracting it to `/usr/local/go` and placing the appropriate directory in our `PATH`. For more details, check out the [Go Downloads page](https://golang.org/dl/).

```
$ wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz

$ sudo tar --directory=/usr/local -xzvf go1.13.linux-amd64.tar.gz

$ export PATH=/usr/local/go/bin:$PATH
```

Next we'll download a compressed archive of the source code (using the the `wget` command). Then we'll extract the source code from the archive (with the `tar` command).

```
$ wget https://github.com/singularityware/singularity/releases/download/v3.5.3/singularity-3.5.3.tar.gz

$ tar -xzvf singularity-3.5.3.tar.gz
```

Finally it's time to build and install!

```
$ cd singularity

$ ./mconfig

$ cd builddir

$ make

$ sudo make install
```

If you want support for tab completion of Singularity commands, you need to source the appropriate file and add it to the bash completion directory in `/etc` so that it will be sourced automatically when you start another shell.

```
$ . etc/bash_completion.d/singularity

$ sudo cp etc/bash_completion.d/singularity /etc/bash_completion.d/
```

If everything went according to plan, you now have a working installation of Singularity.
Simply typing `singularity` will give you a summary of all the commands you can use.
Typing `singularity help <command>` will give you more detailed information about running an individual command.

You can test your installation like so:

```
$ singularity run docker://godlovedc/lolcow
```

You should see something like the following.

```
 INFO:    Converting OCI blobs to SIF format
 INFO:    Starting build...
 Getting image source signatures
 Copying blob 9fb6c798fa41 done
 Copying blob 3b61febd4aef done
 Copying blob 9d99b9777eb0 done
 Copying blob d010c8cf75d7 done
 Copying blob 7fac07fb303e done
 Copying blob 8e860504ff1e done
 Copying config 73d5b1025f done
 Writing manifest to image destination
 Storing signatures
 2020/02/25 23:58:06  info unpack layer: sha256:9fb6c798fa41e509b58bccc5c29654c3ff4648b608f5daa67c1aab6a7d02c118
 2020/02/25 23:58:06  warn rootless{dev/agpgart} creating empty file in place of device 10:175
 [snip...]
 2020/02/25 23:58:09  info unpack layer: sha256:3b61febd4aefe982e0cb9c696d415137384d1a01052b50a85aae46439e15e49a
 2020/02/25 23:58:09  info unpack layer: sha256:9d99b9777eb02b8943c0e72d7a7baec5c782f8fd976825c9d3fb48b3101aacc2
 2020/02/25 23:58:09  info unpack layer: sha256:d010c8cf75d7eb5d2504d5ffa0d19696e8d745a457dd8d28ec6dd41d3763617e
 2020/02/25 23:58:09  info unpack layer: sha256:7fac07fb303e0589b9c23e6f49d5dc1ff9d6f3c8c88cabe768b430bdb47f03a9
 2020/02/25 23:58:09  info unpack layer: sha256:8e860504ff1ee5dc7953672d128ce1e4aa4d8e3716eb39fe710b849c64b20945
 INFO:    Creating SIF file...
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

This command downloads, converts, and runs a container from [Docker Hub](https://hub.docker.com/r/godlovedc/lolcow/). You will see a lot of warnings that have to do with the fact that you've created this container without using root privileges. Pay them no mind. 

In the next exercise, we will learn how to build a similar container from scratch.

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
$ singularity run library://godlovedc/funny/lolcow
```

You should see something like the following.

```
INFO:    Downloading library image
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

This command downloads and "runs" a container from [Singularity Container Library](https://cloud.sylabs.io/library). (We'll be talking more about what it means to "run" a container later on in the class.) 

In a following exercise, we will learn how to build a similar container from scratch. But right now, we are going to use this container to execute a bunch of basic commands and just get a feel for what it's like to use Singularity.  

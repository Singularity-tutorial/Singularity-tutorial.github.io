# Building a basic container

In this exercise, we will build a container from scratch similar to the lolcow container we used to test the installation.

We are going to use a standard development cycle (sometimes referred to as Singularity flow) to create this container. It consists of the following steps:

- create a writable container (called a `sandbox`)
- shell into the container and tinker with it interactively
- record changes that we like in our definition file
- rebuild the container from the definition file if we break it
- rinse and repeat until we are happy with the result
- rebuild the container as a read-only singularity image format (SIF) image for use in production

To build a singularity container, you must use the `build` command.  The `build` command installs an OS, sets up your container's environment and installs the apps you need.  To use the `build` command, we need a definition file. A [Singularity definition file](https://sylabs.io/guides/3.5/user-guide/definition_files.html) is a set of instructions telling Singularity what software to install in the container.

The Singularity source code contains several example definition files in the `/examples` subdirectory.  Let's make a new directory, copy the Debian example definition file, and inspect it.

```
$ mkdir ~/lolcow

$ cp ~/singularity/examples/debian/Singularity ~/lolcow/lolcow.def

$ cd ~/lolcow

$ nano lolcow.def
```

It should look like this:

```
BootStrap: debootstrap
OSVersion: stable
MirrorURL: http://ftp.us.debian.org/debian/

%runscript
    echo "This is what happens when you run the container..."

%post
    echo "Hello from inside the container"
    apt-get -y --allow-unauthenticated install vim

```

See the [Singularity docs](https://sylabs.io/guides/3.5/user-guide/definition_files.html) for an explanation of each of these sections.

Now let's use this definition file as a starting point to build our `lolcow.img` container. Note that the build command requires `sudo` privileges. (We'll discuss some ways around this restriction later in the class.)

```
$ sudo singularity build --sandbox lolcow lolcow.def
```

This is telling Singularity to build a container called `lolcow` from the `lolcow.def` definition file. The `--sandbox` option in the command above tells Singularity that we want to build a special type of container (called a sandbox) for development purposes. 

Singularity can build containers in several different file formats. The default is to build a SIF (singularity image format) container that uses [squashfs](https://en.wikipedia.org/wiki/SquashFS) for the file system. The squashfs format is compressed and immutable making it a good choice for reproducible, production-grade containers.  

But if you want to shell into a container and tinker with it (like we will do here), you should build a sandbox (which is really just a directory).  This is great when you are still developing your container and don't yet know what to include in the definition file.  

When your build finishes, you will have a basic Debian container saved in a local directory called `lolcow`.

## Using `shell` to explore and modify containers

Now let's enter our new container and look around.  

```
$ singularity shell lolcow
```

Depending on the environment on your host system you may see your prompt change. Let's look at what OS is running inside the container.

```
Singularity lolcow:~> cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 10 (buster)"
NAME="Debian GNU/Linux"
VERSION_ID="10"
VERSION="10 (buster)"
VERSION_CODENAME=buster
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```

No matter what OS is running on your host, your container is running Debian Stable!

Let's try a few more commands:

```
Singularity> whoami
dave

Singularity> hostname
hal-9000
```

This is one of the core features of Singularity that makes it so attractive from a security and usability standpoint.  The user remains the same inside and outside of the container. 

Let's try installing some software. I used the programs `fortune`, `cowsay`, and `lolcat` to produce the container that we saw in the first demo.

```
Singularity> Singularity> sudo apt-get update && apt-get -y install fortune cowsay lolcat
bash: sudo: command not found
```

Whoops!

The `sudo` command is not found. But even if we had installed `sudo` into the
container and tried to run this command with it, or change to root using `su`,
we would still find it impossible to elevate our privileges within the
container:

```
Singularity> sudo apt-get update
sudo: effective uid is not 0, is /usr/bin/sudo on a file system with the 'nosuid' option set or an NFS file system without root privileges?
```

Once again, this is an important concept in Singularity.  If you enter a container without root privileges, you are unable to obtain root privileges within the container.  This insurance against privilege escalation is the reason that you will find Singularity installed in so many HPC environments.  

Let's exit the container and re-enter as root.

```
Singularity> exit

$ sudo singularity shell --writable lolcow
```

Now we are the root user inside the container. Note also the addition of the `--writable` option.  This option allows us to modify the container.  The changes will actually be saved into the container and will persist across uses. 

Let's try installing our software again.

```
Singularity> apt-get update && apt-get -y install fortune cowsay lolcat
```

Now you should see the programs successfully installed.  Let's try running the demo in this new container.

```
Singularity> fortune | cowsay | lolcat
bash: lolcat: command not found
bash: cowsay: command not found
bash: fortune: command not found
```

Drat! 

It looks like the programs were not added to our `$PATH`.  Let's add them and try again.

```
Singularity> export PATH=$PATH:/usr/games

Singularity lolcow:~> fortune | cowsay | lolcat
 ________________________________________
/ Keep emotionally active. Cater to your \
\ favorite neurosis.                     /
 ----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

Great!  Things are working properly now.  

---
**NOTE** 

If  you receive warnings from the Perl language about the `locale` being incorrect, you can usually fix them with `export LC_ALL=C`.

---

---
**NOTE** 

We changed our path in this session, but those changes will disappear as soon as we exit the container just like they will when you exit any other shell.  To make the changes permanent we should add them to the definition file and re-bootstrap the container.  We'll do that in a minute.

## Building the final production-grade SIF file

---

Although it is fine to shell into your Singularity container and make changes while you are debugging, you ultimately want all of these changes to be reflected in your definition file.  Otherwise if you need to reproduce it from scratch you will forget all of the changes you made. You will also want to rebuild you container into something more durable and robust than a directory.  

Let's update our definition file with the changes we made to this container.

```
Singularity> exit

$ nano lolcow.def
```

Here is what our updated definition file should look like.

```
BootStrap: debootstrap
OSVersion: stable
MirrorURL: http://ftp.us.debian.org/debian/

%runscript
    echo "This is what happens when you run the container..."

%post
    echo "Hello from inside the container"
    apt-get update
    apt-get -y install fortune cowsay lolcat

%environment
    export PATH=$PATH:/usr/games
```

Let's rebuild the container with the new definition file.

```
$ sudo singularity build lolcow.sif lolcow.def
```

Note that we changed the name of the container.  By omitting the `--sandbox` option, we are building our container in the standard Singularity file format (SIF).  We are denoting the file format with the (optional) `.sif` extension.  A SIF file is compressed and immutable making it a good choice for a production environment.

Singularity stores a lot of [useful metadata](https://sylabs.io/guides/3.5/user-guide/environment_and_metadata.html#container-metadata).  For instance, if you want to see the definition file that was used to create the container you can use the `inspect` command like so:

```
$ singularity inspect --deffile  lolcow.sif
BootStrap: debootstrap
OSVersion: stable
MirrorURL: http://ftp.us.debian.org/debian/

%runscript
    echo "This is what happens when you run the container..."

%post
    echo "Hello from inside the container"
    apt-get update
    apt-get -y install fortune cowsay lolcat

%environment
    export PATH=$PATH:/usr/games
```

# Building a basic container

In this exercise, we will build a container from scratch similar to the one we used to test the installation.
To build a singularity container, you must use the `build` command.  The `build` command installs an OS, sets up your container's environment and installs the apps you need.  To use the `build` command, we need a **recipe file** (also called a definition file). A Singularity recipe file is a set of instructions telling Singularity what software to install in the container.

The Singularity source code contains several example definition files in the `/examples` subdirectory.  Let's copy the ubuntu example to our home directory and inspect it.

```
$ mkdir ../lolcow

$ cp examples/debian/Singularity ../lolcow/

$ cd ../lolcow

$ nano Singularity
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
    apt-get update
    apt-get -y install vim
    apt-get clean
```

See the [Singularity docs](http://singularity.lbl.gov/docs-recipes) for an explanation of each of these sections.

Now let's use this recipe file as a starting point to build our `lolcow.img` container. Note that the build command requires `sudo` privileges, when used in combination with a recipe file. 

```
$ sudo singularity build --sandbox lolcow Singularity
```

The `--sandbox` option in the command above tells Singularity that we want to build a special type of container for development purposes.  

Singularity can build containers in several different file formats. The default is to build a [squashfs](https://en.wikipedia.org/wiki/SquashFS) image. The squashfs format is compressed and immutable making it a good choice for reproducible, production-grade containers.  

But if you want to shell into a container and tinker with it (like we will do here), you should build a sandbox (which is really just a directory).  This is great when you are still developing your container and don't yet know what should be included in the recipe file.  

When your build finishes, you will have a basic Ubuntu container saved in a local directory called `lolcow`.

# Using `shell` to explore and modify containers

Now let's enter our new container and look around.  

```
$ singularity shell lolcow
```

Depending on the environment on your host system you may see your prompt change. Let's look at what OS is running inside the container.

```
Singularity lolcow:~> cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 9 (stretch)"
NAME="Debian GNU/Linux"
VERSION_ID="9"
VERSION="9 (stretch)"
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```

No matter what OS is running on your host, your container is running Debian Stable!

Let's try a few more commands:

```
Singularity lolcow:~> whoami
dave

Singularity lolcow:~> hostname
hal-9000
```

This is one of the core features of Singularity that makes it so attractive from a security standpoint.  The user remains the same inside and outside of the container. 

Let's try installing some software. I used the programs `fortune`, `cowsay`, and `lolcat` to produce the container that we saw in the first demo.

```
Singularity lolcow:~> sudo apt-get update && sudo apt-get -y install fortune cowsay lolcat
bash: sudo: command not found
```

Whoops!

Singularity complains that it can't find the `sudo` command.  But even if you try to install `sudo` or change to root using `su`, you will find it impossible to elevate your privileges within the container.  

Once again, this is an important concept in Singularity.  If you enter a container without root privileges, you are unable to obtain root privileges within the container.  This insurance against privilege escalation is the reason that you will find Singularity installed in so many HPC environments.  

Let's exit the container and re-enter as root.

```
Singularity lolcow:~> exit

$ sudo singularity shell --writable lolcow
```

Now we are the root user inside the container. Note also the addition of the `--writable` option.  This option allows us to modify the container.  The changes will actually be saved into the container and will persist across uses. 

Let's try installing some software again.

```
Singularity lolcow:~> apt-get update && apt-get -y install fortune cowsay lolcat
```

Now you should see the programs successfully installed.  Let's try running the demo in this new container.

```
Singularity lolcow:~> fortune | cowsay | lolcat
bash: lolcat: command not found
bash: cowsay: command not found
bash: fortune: command not found
```

Drat! It looks like the programs were not added to our `$PATH`.  Let's add them and try again.

```
Singularity lolcow:~> export PATH=/usr/games:$PATH

Singularity lolcow:~> fortune | cowsay | lolcat
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
        LANGUAGE = (unset),
        LC_ALL = (unset),
        LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
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

We're making progress, but we are now receiving a warning from perl.  However, before we tackle that, let's think some more about the `$PATH` variable.

We changed our path in this session, but those changes will disappear as soon as we exit the container just like they will when you exit any other shell.  To make the changes permanent we should add them to the definition file and re-bootstrap the container.  We'll do that in a minute.

Now back to our perl warning.  Perl is complaining that the locale is not set properly.  Basically, perl wants to know where you are and what sort of language encoding it should use.  Should you encounter this warning you can  probably fix it with the `locale-gen` command or by setting `LC_ALL=C`.  Here we'll just set the environment variable.

```
Singularity lolcow:~> export LC_ALL=C

Singularity lolcow:~> fortune | cowsay | lolcat
 _________________________________________
/ FORTUNE PROVIDES QUESTIONS FOR THE      \
| GREAT ANSWERS: #19 A: To be or not to   |
\ be. Q: What is the square root of 4b^2? /
 -----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

Great!  Things are working properly now.  

Although it is fine to shell into your Singularity container and make changes while you are debugging, you ultimately want all of these changes to be reflected in your recipe file.  Otherwise if you need to reproduce it from scratch you will forget all of the changes you made.

Let's update our definition file with the changes we made to this container.

```
Singularity lolcow:~> exit

$ nano Singularity
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
    apt-get clean

%environment
    export PATH=/usr/games:$PATH
    export LC_ALL=C
```

Let's rebuild the container with the new definition file.

```
$ sudo singularity build lolcow.simg Singularity
```

Note that we changed the name of the container.  By omitting the `--sandbox` option, we are building our container in the standard Singularity squashfs file format.  We are denoting the file format with the (optional) `.simg` extension.  A squashfs file is compressed and immutable making it a good choice for a production environment.

Singularity stores a lot of [useful metadata](http://singularity.lbl.gov/docs-environment-metadata).  For instance, if you want to see the recipe file that was used to create the container you can use the `inspect` command like so:

```
$ singularity inspect --deffile lolcow.simg
BootStrap: debootstrap
OSVersion: stable
MirrorURL: http://ftp.us.debian.org/debian/

%runscript
    echo "This is what happens when you run the container..."

%post
    echo "Hello from inside the container"
    apt-get update
    apt-get -y install fortune cowsay lolcat
    apt-get clean

%environment
    export PATH=/usr/games:$PATH
    export LC_ALL=C
```

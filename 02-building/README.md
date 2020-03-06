# Building a basic container

In this section, we will build a brand new container similar to the lolcow container we've been using in the previous examples.

To build a singularity container, you must use the `build` command.  The `build` command installs an OS, sets up your container's environment and installs the apps you need.  To use the `build` command, we need a definition file. A [Singularity definition file](https://sylabs.io/guides/3.5/user-guide/definition_files.html) is a set of instructions telling Singularity what software to install in the container.

We are going to use a standard development cycle (sometimes referred to as Singularity flow) to create this container. It consists of the following steps:

- create a writable container (called a `sandbox`)
- shell into the container with the `--writable` option and tinker with it interactively
- record changes that we like in our definition file
- rebuild the container from the definition file if we break it
- rinse and repeat until we are happy with the result
- rebuild the container from the final definition file as a read-only singularity image format (SIF) image for use in production

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

## Developing a new container

Now let's use this definition file as a starting point to build our `lolcow.img` container. Note that the build command requires `sudo` privileges. (We'll discuss some ways around this restriction later in the class.)

```
$ sudo singularity build --sandbox lolcow lolcow.def
```

This is telling Singularity to build a container called `lolcow` from the `lolcow.def` definition file. The `--sandbox` option in the command above tells Singularity that we want to build a special type of container (called a sandbox) for development purposes. 

Singularity can build containers in several different file formats. The default is to build a SIF (singularity image format) container that uses [squashfs](https://en.wikipedia.org/wiki/SquashFS) for the file system. SIF files are compressed and immutable making them the best choice for reproducible, production-grade containers.  

But if you want to shell into a container and tinker with it (like we will do here), you should build a sandbox (which is really just a directory).  This is great when you are still developing your container and don't yet know what to include in the definition file.  

When your build finishes, you will have a basic Debian container saved in a local directory called `lolcow`.

## Using `shell --writable` to explore and modify containers

Now let's enter our new container and look around.  

```
$ singularity shell lolcow
```

Depending on the environment on your host system you may see your prompt change. 

Let's try installing some software. I used the programs `fortune`, `cowsay`, and `lolcat` to produce the container that we saw in the first demo.

```
Singularity> sudo apt-get update
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
Singularity> apt-get update

Singularity> apt-get install -y fortune cowsay lolcat
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

---

## Building the final production-grade SIF file

Although it is fine to shell into your Singularity container and make changes while you are debugging, you ultimately want all of these changes to be reflected in your definition file.  Otherwise if you need to reproduce it from scratch you will forget all of the changes you made. You will also want to rebuild you container into something more durable, portable, and robust than a directory.  

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

As we saw in the previous section when we used the `inspect` command to read the `runscript`, Singularity stores a lot of [useful metadata](https://sylabs.io/guides/3.5/user-guide/environment_and_metadata.html#container-metadata). For instance, if you want to see the definition file that was used to create the container you can use the `inspect` command like so:

```
$ singularity inspect --deffile  lolcow.sif
BootStrap: debootstrap
OSVersion: stable
MirrorURL: http://ftp.us.debian.org/debian/

%runscript
    echo "This is what happens when you run the container..."

%post
    apt-get update
    apt-get -y install fortune cowsay lolcat

%environment
    export PATH=$PATH:/usr/games
```

## Building from existing containers

In the preceding section we always used the following header in our definition file to build a container:

```
BootStrap: debootstrap
OSVersion: stable
MirrorURL: http://ftp.us.debian.org/debian/
```

This uses the program [`debootstrap`](https://wiki.debian.org/Debootstrap) to build the root file system using a mirror URL. In this case, we supply a URL that is maintained by Debian. We could also use an Ubuntu URL since it is a derivative of Debian and can also be built with the `debootstrap` program. If we wanted to build a CentOS container from the distribution mirror we could use the `yum` package manager similarly. There are actually a ton of different ways to build containers. See this list of ["bootstrap agents"](https://sylabs.io/guides/3.5/user-guide/appendix.html#build-modules) in the Singularity docs.

In practice, most people do not build containers from a distribution mirror like this. Instead they tend to build containers from existing containers on the Container Library or on Docker Hub and use the `%post` section to modify those containers to suit their needs.  

For instance, to use an existing Debian container from the Container library as your starting point, your header would look like this:


```
BootStrap: library
From: debian
```

Likewise to start from a debian container on Docker Hub, your header would contain the following:

```
Bootstrap: docker
From: debian
```

You can also build a container from a base container on your local file system.  

```
Bootstrap: localimage
From: /home/student/debian.sif
```

Each of these methods can also be called _without_ providing a definition file using the following shorthand.  For an added bonus, none of these `build` commands require root privileges.  

```
$ singularity build debian1.sif library://debian

$ singularity build debian2.sif docker://debian

$ singularity build debian3.sif debian2.sif
```

Behind the scenes, Singularity creates a small definition file for each of these commands and then builds the corresponding container as you can see if you use the `inspect --deffile` command.  

```
$ singularity inspect --deffile debian1.sif
bootstrap: library
from: debian

$ singularity inspect --deffile debian2.sif
bootstrap: docker
from: debian

$ singularity inspect --deffile debian3.sif
bootstrap: localimage
from: debian2.sif
```

Note that the third command may not seem very useful because you are just copying the container called `debian2.sif` to a new container called `debian3.sif`. But you can also use `build` in this way to convert a SIF file to a sandbox and back again:

```
$ singularity build --sandbox deb-sand debian3.sif

$ singularity build deb-sif deb-sand/
```

This can be a useful trick during container development. But it can also produce a container with an uncertain build history if it is misapplied because the changes made to the sandbox will not be reflected in the containers definition file.  

## Security considerations and `--fakeroot`

In the preceding we've been executing the `build` command as root via `sudo`. In our examples, that is a reasonably safe thing to do, because we use disposable virtual machines for this class and we are building directly from mirrors hosted by same groups that create the OS distributions. (Though [mirrors can still contain malware](https://lists.archlinux.org/pipermail/aur-general/2018-July/034169.html).) 

But in general, it's a bad idea to build a container as root. In particular you should never build a container from an untrusted base image as root on a machine you care about. This is the same as downloading random code from the internet and running it as root on your machine. (See [this blog](https://medium.com/sylabs/a-note-on-cve-2019-14271-running-untrusted-containers-as-root-is-still-a-bad-idea-245d227d4e02) for a technical discussion.)

On operating systems with recent kernels (such as Ubuntu 18.04), you can invoke the `--fakeroot` option when building containers instead. (For those interested in technical details, this feature leverages the [user namespace](http://man7.org/linux/man-pages/man7/user_namespaces.7.html)).  

```
$ singularity build --fakeroot container.sif container.def
```

Doing so allows you to pretend to be the root user inside of your container without actually granting singularity elevated privileges on host system.  This is a much safer way to build and interact with your container, and it is going to become more prevalent (eventually probably even default) as more distributions ship with user namespaces enabled. For instance, this feature is enabled by default in RHEL 8.  

For more about the `--fakeroot` option, see [the Singularity documentation](https://sylabs.io/guides/3.5/user-guide/fakeroot.html?highlight=fakeroot).
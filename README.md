# <b>Creating and running software containers with Singularity</b>
### <i>How to use [Singularity](http://singularity.lbl.gov)! </i>

This is an introductory workshop on Singularity. It was originally taught by David Godlove at the [NIH HPC](https://hpc.nih.gov/), but the content has since been adapted to a general audience.  For more information about the topics covered here, see the following:

- [Singularity Home](http://singularity.lbl.gov/)
- [Singularity on GitHub](https://github.com/singularityware/singularity)
- [Singularity on Google Groups](https://groups.google.com/a/lbl.gov/forum/#!forum/singularity)
- [Singularity at the NIH HPC](https://hpc.nih.gov/apps/singularity.html)
- [Docker documentation](https://docs.docker.com/)
- [Singularity Hub](https://singularity-hub.org/)
- [Docker Hub](https://hub.docker.com/)

## Hour 1 (Introduction and Installation)

### What IS a software container anyway? (And what's it good for?)

A container allows you to stick an application and all of its dependencies into a single package.  This makes your application portable, shareable, and reproducible.

Containers foster portability and reproducibility because they package **ALL** of an applications dependencies... including its own tiny operating system!

This means your application won't break when you port it to a new environment. Your app brings its environment with it.

Here are some examples of things you can do with containers:

- Package an analysis pipeline so that it runs on your laptop, in the cloud, and in a high performance computing (HPC) environment to produce the same result.
- Publish a paper and include a link to a container with all of the data and software that you used so that others can easily reproduce your results.
- Install and run an application that requires a complicated stack of dependencies with a few keystrokes.
- Create a pipeline or complex workflow where each individual program is meant to run on a different operating system.

### How do containers differ from virtual machines (VMs)

Containers and VMs are both types of virtualization.  But it's important to understand the differences between the two and know when to use each.

**Virtual Machines** install every last bit of an operating system (OS) right down to the core software that allows the OS to control the hardware (called the _kernel_).  This means that VMs:
- Are complete in the sense that you can use a VM to interact with your computer via a different OS.
- Are extremely flexible.  For instance you an install a Windows VM on a Mac using software like [VirtualBox](https://www.virtualbox.org/wiki/VirtualBox).  
- Are slow and resource hungry.  Every time you start a VM it has to bring up an entirely new OS.

**Containers** share a kernel with the host OS.  This means that Containers:
- Are less flexible than VMs.  For example, a Linux container must be run on a Linux host OS.  (Although you can mix and match distributions.)  In practice, containers are only extensively developed on Linux.
- Are much faster and lighter weight than VMs.  A container may be just a few MB.
- Start and stop quickly and are suitable for running single apps.

Because of their differences, VMs and containers serve different purposes and should be favored under different circumstances.  
- VMs are good for long running interactive sessions where you may want to use several different applications.  (Checking email on Outlook and using Microsoft Word and Excel).
- Containers are better suited to running one or two applications non-interactively in their own custom environments.

### Docker

[Docker](https://www.docker.com/) is currently the most widely used container software.  It has several strengths and weaknesses that make it a good choice for some projects but not for others.

**philosophy**

Docker is built for running multiple containers on a single system and it allows containers to share common software features for efficiency.  It also seeks to fully isolate each container from all other containers and from the host system.  

Docker assumes that you will be a root user.  Or that it will be OK for you to elevate your privileges if you are not a root user.    

**strengths**

- Mature software with a large user community
- [Docker Hub](https://hub.docker.com/)!
    - A place to build and host your containers
    - Fully integrated into core Docker
    - Over 100,000 pre-built containers
    - Provides an ecosystem for container orchestration
- Rich feature set

**weaknesses**

- Difficult to learn
    - Hidden innards 
    - Complex container model (layers)
- Not architected with security in mind
- Not built for HPC (but good for cloud) 

Docker shines for DevOPs teams providing cloud-hosted micro-services to users.

### Singularity 

[Singularity](http://singularity.lbl.gov/) is a relatively new container software originally developed by Greg Kurtzer while at Lawrence Berkley National labs.  It was developed with security, scientific software, and HPC systems in mind.  

**philosophy**

Singularity assumes ([more or less](http://containers-ftw.org/SCI-F/)) that each application will have its own container.  It does not seek to fully isolate containers from one another or the host system. 
Singularity assumes that you will have a build system where you are the root user, but that you will also have a production system where you may or may not be the root user. 

**strengths**
- Easy to learn and use (relatively speaking)
- Approved for HPC (installed on some of the biggest HPC systems in the world)
- Can convert Docker containers to Singularity and run containers directly from Docker Hub
- [Singularity Hub](https://singularity-hub.org/)!
    - A place to build and host your containers similar to Docker Hub

<b>weaknesses</b>
- Younger and less mature than Docker
- Smaller user community (as of now)
- Under active development (must keep up with new changes) 

Singularity shines for scientific software running in an HPC environent.  We will use it for the remainder of the class.

### Install
Here we will install the latest tagged release from [GitHub](https://github.com/singularityware/singularity). If you prefer to install a different version or to install Singularity in a different location, see these [Singularity docs](http://singularity.lbl.gov/docs-installation).

We're going to compile Singularity from source code.  First we'll need to make sure we have some development tools installed so that we can do that.  On Ubuntu, run these commands to make sure you have all the necessary packages installed.

```
$ sudo apt-get update

$ sudo apt-get -y install python dh-autoreconf build-essential debootstrap
```

On CentOS, these commmands should get you up to speed.

```
$ sudo yum update 

$ sudo yum groupinstall 'Development Tools'

$ sudo yum install wget epel-release

$ sudo yum install debootstrap.noarch
```

Next we'll download a compressed archive of the source code (using the the `wget` command). Then we'll extract the source code from the archive (with the `tar` command).

```
$ wget https://github.com/singularityware/singularity/releases/download/2.4/singularity-2.4.tar.gz

$ tar xvf singularity-2.4.tar.gz
```

Finally it's time to build and install!

```
$ cd singularity-2.4

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


## Hour 2 (Building and Running Containers)

In the second hour we will build the preceding container from scratch. 

Simply typing `singularity` will give you an summary of all the commands you can use. Typing `singularity help <command>` will give you more detailed information about running an individual command.

### Building a basic container

To build a singularity container, you must use the `build` command.  The `build` command installs an OS, sets up your container's environment and installs the apps you need.  To use the `build` command, we need a **recipe file** (also called a definition file). A Singularity recipe file is a set of instructions telling Singularity what software to install in the container.

The Singularity source code contains several example definition files in the `/examples` subdirectory.  Let's copy the ubuntu example to our home directory and inspect it.

**Note:** You need to build containers on a file system where the sudo command can write files as root. This may not work in an HPC cluster setting if your home directory resides on a shared file server. If that's the case you may have to to `cd` to a local hard disk such as `/tmp`.

```
$ mkdir ../lolcow

$ cp examples/ubuntu/Singularity ../lolcow/

$ cd ../lolcow

$ nano Singularity
```

It should look something like this:

```
BootStrap: debootstrap
OSVersion: trusty
MirrorURL: http://us.archive.ubuntu.com/ubuntu/


%runscript
    echo "This is what happens when you run the container..."


%post
    echo "Hello from inside the container"
    sed -i 's/$/ universe/' /etc/apt/sources.list
    apt-get -y install vim

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

### Using `shell` to explore and modify containers

Now let's enter our new container and look around.  

```
$ singularity shell lolcow
```

Depending on the environment on your host system you may see your prompt change. Let's look at what OS is running inside the container.

```
Singularity lolcow:~> cat /etc/os-release
NAME="Ubuntu"
VERSION="14.04, Trusty Tahr"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 14.04 LTS"
VERSION_ID="14.04"
HOME_URL="http://www.ubuntu.com/"
SUPPORT_URL="http://help.ubuntu.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
```

No matter what OS is running on your host, your container is running Ubuntu 14.04!

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
OSVersion: trusty
MirrorURL: http://us.archive.ubuntu.com/ubuntu/


%runscript
    echo "This is what happens when you run the container..."


%post
    echo "Hello from inside the container"
    sed -i 's/$/ universe/' /etc/apt/sources.list
    apt-get update
    apt-get -y install vim fortune cowsay lolcat

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
OSVersion: trusty
MirrorURL: http://us.archive.ubuntu.com/ubuntu/


%runscript
    echo "This is what happens when you run the container..."


%post
    echo "Hello from inside the container"
    sed -i 's/$/ universe/' /etc/apt/sources.list
    apt-get update
    apt-get -y install vim fortune cowsay lolcat

%environment
    export PATH=/usr/games:$PATH
    export LC_ALL=C
```

### Blurring the line between the container and the host system.

Singularity does not try to isolate your container completely from the host system.  This allows you to do some interesting things.

Using the exec command, we can run commands within the container from the host system.  

```
$ singularity exec lolcow.simg cowsay 'How did you get out of the container?'
 _______________________________________
< How did you get out of the container? >
 ---------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

In this example, singularity entered the container, ran the `cowsay` command, displayed the standard output on our host system terminal, and then exited. 

You can also use pipes and redirection to blur the lines between the container and the host system.  

```
$ singularity exec lolcow.simg cowsay moo > cowsaid

$ cat cowsaid
 _____
< moo >
 -----
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

We created a file called `cowsaid` in the current working directory with the output of a command that was executed within the container. 

We can also pipe things _into_ the container.

```
$ cat cowsaid | singularity exec lolcow.simg cowsay -n
 ______________________________
/  _____                       \
| < moo >                      |
|  -----                       |
|         \   ^__^             |
|          \  (oo)\_______     |
|             (__)\       )\/\ |
|                 ||----w |    |
\                 ||     ||    /
 ------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

We've created a meta-cow (a cow that talks about cows). :stuck_out_tongue_winking_eye:

## Hour 3 (advanced Singularity usage)

### Making containerized apps behave more like normal apps

In the third hour we are going to consider an extended example describing a containerized application that takes a file as input, analyzes the data in the file, and produces another file as output.  This is obviously a very common situation.  

Let's imagine that we want to use the cowsay program in our `lolcow.simg` to "analyze data".  We should give our container an input file, it should reformat it (in the form of a cow speaking), and it should dump the output into another file.  

Here's an example.  First I'll make some "data"

```
$ echo "The grass is always greener over the septic tank" > input
```

Now I'll "analyze" the "data"

```
$ cat input | singularity exec lolcow.simg cowsay > output
```

The "analyzed data" is saved in a file called `output`. 

```
$ cat output
 ______________________________________
/ The grass is always greener over the \
\ septic tank                          /
 --------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

This _works..._ but the syntax is ugly and difficult to remember.  

Singularity supports a neat trick for making a container function as though it were an executable.  We need to create a **runscript** inside the container. It turns out that our Singularity recipe file already contains a runscript.  It causes our container to print a helpful message.  

```
$ ./lolcow.simg
This is what happens when you run the container...
```

Let's rewrite this runscript in the definition file and rebuild our container
so that it does something more useful.  

```
BootStrap: debootstrap
OSVersion: trusty
MirrorURL: http://us.archive.ubuntu.com/ubuntu/


%runscript
    #!/bin/bash
    if [ $# -ne 2 ]; then
        echo "Please provide an input and an output file."
        exit 1
    fi
    cat $1 | cowsay > $2

%post
    echo "Hello from inside the container"
    sed -i 's/$/ universe/' /etc/apt/sources.list
    apt-get update
    apt-get -y install vim fortune cowsay lolcat

%environment
    export PATH=/usr/games:$PATH
    export LC_ALL=C
```

Now we must rebuild out container to install the new runscript.  

```
$ sudo singularity build --force lolcow.simg Singularity
```

Note the `--force` option which ensures our previous container is completely overwritten.

After rebuilding our container, we can call the lolcow.simg as though it were an executable, and simply give it two arguments.  One for input and one for output.  

```
$ ./lolcow.simg
Please provide an input and an output file.

$ ./lolcow.simg input output2

$ cat output2
 ______________________________________
/ The grass is always greener over the \
\ septic tank                          /
 --------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

### Bind mounting host system directories into a container

It's possible to create and modify files on the host system from within the container. In fact, that's exactly what we did in the previous example when we created output files in our home directory.  

Let's be more explicit. Consider this example. 

```
$ singularity shell lolcow.simg

Singularity lolcow.simg:~> echo wutini > ~/jawa.sez

Singularity lolcow.simg:~> cat ~/jawa.sez
wutini

Singularity lolcow.simg:~> exit

$ cat ~/jawa.sez
wutini
```

Here we shelled into a container and created a file with some text in our home directory.  Even after we exited the container, the file still existed. How did this work?

There are several special directories that Singularity _bind mounts_ into
your container by default.  These include:

- `/home/$USER`
- `/tmp`
- `/proc`
- `/sys`
- `/dev`

You can specify other directories to bind using the `--bind` option or the environmental variable `$SINGULARITY_BINDPATH`

Let's say we want to use our `cowsay.img` container to "analyze data" and save results in a different directory.  For this example, we first need to create a new directory with some data on our host system.  

```
$ sudo mkdir /data

$ sudo chown $USER:$USER /data

$ echo 'I am your father' > /data/vader.sez
```

We also need a directory _within_ our container where we can bind mount the host system `/data` directory.  We could create another directory in the `%post` section of our recipe file and rebuild the container, but our container already has a directory called `/mnt` that we can use for this example. 

Now let's see how bind mounts work.  First, let's list the contents of `/mnt` within the container without bind mounting `/data` to it.

```
$ singularity exec lolcow.simg ls -l /mnt
total 0
```

The `/mnt` directory within the container is empty.  Now let's repeat the same command but using the `--bind` option to bind mount `/data` into the container.

```
$ singularity exec --bind /data:/mnt lolcow.simg ls -l /mnt
total 4
-rw-rw-r-- 1 ubuntu ubuntu 17 Jun  7 20:57 vader.sez
```

Now the `/mnt` directory in the container is bind mounted to the `/data` directory on the host system and we can see its contents.  

Now what about our earlier example in which we used a runscript to run a our container as though it were an executable?  The `singularity run` command  accepts the `--bind` option and can execute our runscript like so.

```
$ singularity run --bind /data:/mnt lolcow.simg /mnt/vader.sez /mnt/output3

$ cat /data/output3
 __________________
< I am your father >
 ------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

But that's a cumbersome command.  Instead, we could set the variable `$SINGULARITY_BINDPATH` and then use our container as before.

```
$ export SINGULARITY_BINDPATH=/data:/mnt

$ ./lolcow.simg /mnt/output3 /mnt/metacow2

$ ls -l /data/
total 12
-rw-rw-r-- 1 ubuntu ubuntu 809 Jun  7 21:07 metacow2
-rw-rw-r-- 1 ubuntu ubuntu 184 Jun  7 21:06 output3
-rw-rw-r-- 1 ubuntu ubuntu  17 Jun  7 20:57 vader.sez

$ cat /data/metacow2
 ________________________________________
/  __________________ < I am your father \
| >                                      |
|                                        |
| ------------------                     |
|                                        |
| \ ^__^                                 |
|                                        |
| \ (oo)\_______                         |
|                                        |
| (__)\ )\/\                             |
|                                        |
| ||----w |                              |
|                                        |
\ || ||                                  /
 ----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

For a lot more info on how to bind mount host directories to your container, check out the [NIH HPC Binding external directories](https://hpc.nih.gov/apps/singularity.html#bind) section.

### Singularity Instances

Up to now all of our examples have run Singularity containers in the foreground.  But what if you want to run a service like a web server or a database in a Singularity container in the background? 

#### lolcow (useless) example
In Singularity v2.4+, you can use the [`instance` command group](http://singularity.lbl.gov/docs-instances) to start and control container instances that run in the background.  To demonstrate, let's start an instance of our `lolcow.simg` container running in the background.

```
$ singularity instance.start lolcow.simg cow1
```

We can use the `instance.list` command to show the instances that are currently running.

```
$ singularity instance.list 
DAEMON NAME      PID      CONTAINER IMAGE
cow1             10794    /home/dave/lolcow.simg
```

We can connect to running instances using the `instance://` URI like so:

```
$ singularity shell instance://cow1
Singularity: Invoking an interactive shell within container...

Singularity lolcow.simg:~> ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
dave         1     0  0 19:05 ?        00:00:00 singularity-instance: dave [cow1]
dave         3     0  0 19:06 pts/0    00:00:00 /bin/bash --norc
dave         4     3  0 19:06 pts/0    00:00:00 ps -ef

Singularity lolcow.simg:~> exit
```

Note that we've entered a new PID namespace, so that the `singularity-instance` process has PID number 1. 

You can start multiple instances running in the background, as long as you give them unique names.

```
$ singularity instance.start lolcow.simg cow2

$ singularity instance.start lolcow.simg cow3

$ singularity instance.list
DAEMON NAME      PID      CONTAINER IMAGE
cow1             10794    /home/dave/lolcow.simg
cow2             10855    /home/dave/lolcow.simg
cow3             10885    /home/dave/lolcow.simg
```

You can stop individual instances using their unique names or stop all instances with the `--all` option.

```
$ singularity instance.stop cow1
Stopping cow1 instance of /home/dave/lolcow.simg (PID=10794)

$ singularity instance.stop --all
Stopping cow2 instance of /home/dave/lolcow.simg (PID=10855)
Stopping cow3 instance of /home/dave/lolcow.simg (PID=10885)
```

#### nginx (useful) example

These examples are not very useful because `lolcow.simg` doesn't run any services.  Let's extend the example to something useful by running a local nginx web server in the background.  This command will download the official nginx image from Docker Hub and start it in a background instance called "web".  (The commands need to be executed as root so that nginx can run with the privileges it needs.)

```
$ sudo singularity instance.start docker://nginx web
Docker image path: index.docker.io/library/nginx:latest
Cache folder set to /root/.singularity/docker
[3/3] |===================================| 100.0%
Creating container runtime...

$ sudo singularity instance.list
DAEMON NAME      PID      CONTAINER IMAGE
web              15379    /tmp/.singularity-runtime.MBzI4Hus/nginx
```

Now to start nginx running in the instance called web.

```
$ sudo singularity exec instance://web nginx
```

Now we have an nginx web server running on our localhost.  We can verify that it is running with `curl`.  

```
$ curl localhost
127.0.0.1 - - [02/Nov/2017:19:20:39 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.52.1" "-"
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

When finished, don't forget to stop all running instances like so:

```
$ sudo singularity instance.stop --all
```

### Singularity Hub and Docker Hub

We've spent a lot of time on building and using your own containers so that you understand how Singularity works. But there's an easier way! [Docker Hub](https://hub.docker.com/)
hosts over 100,000 pre-built, ready-to-use containers.  And singularity makes it easy to use them.

When we first installed Singularity we tested the installation by running a container from Docker Hub like so.

```
$ singularity run docker://godlovedc/lolcow
```

Instead of running this container from Docker Hub, we could also just copy it to our local system with the `build` command.

```
$ sudo singularity build lolcow-from-docker.simg docker://godlovedc/lolcow
```

You can build and host your own images on Docker Hub, (using Docker) or you can download and run images that others have built.

```
$ singularity shell docker://tensorflow/tensorflow

Singularity tensorflow:~> python

>>> import tensorflow as tf

>>> quit()

Singularity tensorflow:~> exit
```

You can also build, download, and run containers from [Singularity Hub](https://singularity-hub.org/)

```
$ singularity run shub://GodloveD/lolcow
```

You can even use images on Docker Hub and Singularity Hub as a starting point for your own images. Singularity recipe files allow you to specifiy a Docker Hub or Singularity Hub registry to bootstrap from
and you can use the `%post` section to modify the container to your liking.

For example, to start from a Docker Hub image of Ubuntu in your recipe, you could do something like this:

```
BootStrap: docker
From: ubuntu

%runscript
    echo "This is what happens when you run the container..."

%post
    echo "Hello from inside the container"
    echo "Install additional software here"
```

Or to start from a Singularity Hub version of BusyBox you could do something like this:

```
BootStrap: shub
From: GodloveD/busybox

%runscript
    echo "This is what happens when you run the container..."

%post
    echo "Hello from inside the container"
    echo "Install additional software here"
```

Both Docker Hub and Singularity Hub link to your GitHub account. New container builds are automatically triggered every time you push changes to a Docker file or a Singularity recipe file in a linked repository.  

## Miscellaneous Topics

### details of the Singularity security model

Disclaimer: Many of the things in this section are remarkably bad practices.  They are just here to illustrate examples.  Don't try them outside of this context.  Maybe don't actually try them inside of this context either.

Let's say that you want to run a command as root inside of a Singularity container.  

```
$ singularity exec docker://ubuntu sudo whoami
[...snip...]
/.singularity.d/actions/exec: 9: exec: sudo: not found
```

Whoops! The `sudo` program is not installed.  Let's build the container as a sandbox and install it. Obviously, we must do so as root:

```
$ sudo singularity build --sandbox backdoor.simg docker://ubuntu

$ sudo singularity shell --writable backdoor.simg

Singularity backdoor.simg:~> apt-get update && apt-get install -y sudo

Singularity backdoor.simg:~> which sudo
/usr/bin/sudo
```

And we'll also make it so that our normal user can run all commands via `sudo` without a password.  (Note this renders the container non-portable but pretty much all of this is a terrible idea anyway.)

```
Singularity backdoor.simg:~> echo "student ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers

Singularity backdoor.simg:~> exit
```

Now we _should_ be able to use `sudo` to escalate privs inside of a container as the student user. 

Right?

```
$ singularity exec backdoor.simg sudo whoami
sudo: effective uid is not 0, is /usr/bin/sudo on a file system with the 'nosuid' option set or an NFS file system without root privileges?
```

Wrong. :-(

The error should give us a hint.  But let's try a few more things before we give up.  

An easier solution might just be to create a root password.  By defualt, Ubuntu does not have a root password, but once we add one we should be able to become root with `su`.

```
$ sudo singularity shell --writable backdoor.simg

Singularity backdoor.simg:~> passwd root
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully

Singularity backdoor.simg:~> exit
```

I just set it to `password` so it would be easy to remember.  Now I'm ready to shell in and use `su` to become root.

```
$ singularity shell backdoor.simg
Singularity: Invoking an interactive shell within container...

Singularity backdoor.simg:~> su -
Password:
su: Authentication failure

Singularity backdoor.simg:~> whoami
student

Singularity backdoor.simg:~> exit
```

I entered the correct password, but I still am not root!

One more try before we give up.  Let's write our own sudo program!  (Disclaimer: This is a terrible idea.)

For this to work, we need to write a little C. 

```C
/*
If this program is compiled, chowned to root, and the set-user-id bit is set, 
it will take a single string as input and execute the string as a command with 
root privs. :-O
*/

#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {

    if ( argc == 1 || argc > 2 ) {
        printf("ERROR: %s requires exactly 1 argument\n", argv[0]);
        return 1;
    }

    if ( setuid(0) != 0 ) {
        printf("ERROR: failed to set effective user id to 0 (root)\n");
        return 1;
    }

    if ( system(argv[1]) != 0 ) {
        printf("ERROR: failed to execute command '%s'\n", argv[1]);
        return 1;
    }

    return 0;
}
```

Save this text into a file called `my_sudo.c`, and compile it like so:

Now if you compile the program, `chown` the resulting binary to `root` and add the user `SUID` bit, you will have a program that takes a single string argument, elevates the user's permissions to root, and executes it.  

Now just to state the obvious, this is a dangerous program to have around.  You probably do NOT want to actually try this just in case you make a mistake and this ugly program ends up on your system somewhere.  Just read the tutorial and take my word for it. 

I'll install this program within the container being careful to compile it within the container (even though in this case the container is just a bare directory so we will still need to remove it later).

```
$ cp my_sudo.c /tmp/

$ sudo singularity shell --writable backdoor.simg/

Singularity backdoor.simg:~> apt-get install gcc

Singularity backdoor.simg:~> mv /tmp/my_sudo.c /bin/

Singularity backdoor.simg:~> cc /bin/my_sudo.c -o /bin/my_sudo

Singularity backdoor.simg:~> chmod u+s /bin/my_sudo

Singularity backdoor.simg:~> ls -l /bin/my_sudo
-rwsr-xr-x 1 root root 8424 Jul 25 02:28 /bin/my_sudo

Singularity backdoor.simg:~> exit
```

The dirty little program is now set up and ready to go inside of the container at `/bin/my_sudo`.  I should be able use it to elevate my privs.

```
$ singularity exec backdoor.simg my_sudo whoami
ERROR: failed to set effective user id to 0 (root)
```

Nope!  Even trying explicitly to create an exploit in this way does not work.  

Note that in this case we built a sandbox, meaning `backdoor.simg` is just a bare directory.  `my_sudo` exists as an SUID program in that directory.  If we were to call it _outside_ of the context of the Singularity runtime, it would quite happily elevate our privileges.     

```
$ backdoor.simg/bin/my_sudo whoami
root
```

So in this case, the Singularity runtime actually provides an additional layer of security over and above what is provided on the host system.  

*Before proceeding any further, stop and delete this program from your host system if you actually followed this portion of the tutorial.*

```
$ sudo rm backdoor.simg/bin/my_sudo
```

These examples should serve to illustrate the guiding security principle of the Singularity runtime.  Singularity allows _untrusted_ users to run _untrusted_ containers safely.  

How does Singularity block privilege escalation inside of the container?  When Singularity runs, it mounts a directory or image containing a file system to a specific location within the root file system and then makes it appear as though this mount is the actual root file system.  Critically, when the container file system is mounted, the `MS_NOSUID` flag is passed to the `mount` program.  This prevents set-user-ID (SUID) and set-group-ID (SGID) bits or file capabilities from being honored when executing programs from the container file system.  

At this point, even if you have never heard of an SUID program you should have an idea how they work.  Setting the SUID bit allows anyone to run a program as though they were the user who owns the program.  That's how we wrote our own `my_sudo` program above.  It turns out that's how programs like `sudo` and `su` work as well.  But you may be surprised to learn that other programs can have the SUID bit set.  For instance, on many systems `ping` must have the SUID bit set because it needs to open a raw socket which is a privileged operation.  This means that `ping` will not work in a Singularity container when the container is run without privileges!  

On some newer systems, `ping` is controlled via Linux file capabilities instead.  Capabilities allow developers to give finer grained control over the privileged processes that are carried out by a program.  In the case of `ping` this allows the program to create raw sockets without granting it additional privileges.  The `MS_NOSUID` flag used by Singularity to mount containers blocks this type of escalation pathway as well.  

You may wonder how Singularity allows you to be the same user inside the container as outside of the container.  Let's continue to examine the `backdoor.simg` image we create above.  Since it's a sandbox (a bare directory) we can just look inside of it.  Let's have a look at the `/etc/passwd` file and `/etc/group` files that determine what users and groups exist on the system respectively.

```
$ cat backdoor.simg/etc/passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
_apt:x:100:65534::/nonexistent:/usr/sbin/nologin

$ cat backdoor.simg/etc/group
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
adm:x:4:
tty:x:5:
disk:x:6:
lp:x:7:
mail:x:8:
news:x:9:
uucp:x:10:
man:x:12:
proxy:x:13:
kmem:x:15:
dialout:x:20:
fax:x:21:
voice:x:22:
cdrom:x:24:
floppy:x:25:
tape:x:26:
sudo:x:27:
audio:x:29:
dip:x:30:
www-data:x:33:
backup:x:34:
operator:x:37:
list:x:38:
irc:x:39:
src:x:40:
gnats:x:41:
shadow:x:42:
utmp:x:43:
video:x:44:
sasl:x:45:
plugdev:x:46:
staff:x:50:
games:x:60:
users:x:100:
nogroup:x:65534:
```

These are all just generic user and groups that appear in any Ubuntu installation and are necessary to make things work properly.  Now let's shell into the container and look again.

```
$ singularity shell backdoor.simg

Singularity backdoor.simg:~> tail -n 3 /etc/passwd
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
_apt:x:100:65534::/nonexistent:/usr/sbin/nologin
student:x:1000:1000:,,,:/home/student:/bin/bash

Singularity backdoor.simg:~> tail -n 3 /etc/group
nogroup:x:65534:

student:x:1000:student
```

Singularity dynamically appends user and group information to these files at runtime.  That is how we are able to be the same user with the same groups seamlessly inside and outside of the container.  

These are the basic security principles of code running within a Singularity container.  But what about the security of the Singularity program itself running on the host system?

Several privileged operations need to be carried out by the Singularity runtime.  For instance, Singularity must mount the file system contained in an image or directory on behalf of the user.  Other container runtimes handle this privilege escalation by means of a root-owned daemon process that carries out operations on behalf of the user.  This strategy has advantages and disadvantages.  In particular several aspects of this design render it unattractive in an HPC environment.  Most notably, in the context of a batch scheduler such as Slurm or PBS, the root-owned daemon model allows containerized processes to escape control of the resource manager and go rogue on compute nodes.

Singularity uses a program with an SUID bit to elevate privileges for operations such as container mounting.  This method also provides advantages and disadvantages.  The actual Singularity program only runs for tens of milliseconds while it sets up new namespaces, mounts the container file system, and then uses the `exec` program to run a payload within the container.  `exec` exchanges the calling program for the program that is called in memory.  In this way, Singularity effectively execs itself out of existence, and once the containerized program begins to run, no traces of the Singularity program remain.  

SUID bit programs must be designed with great care.  Singularity minimizes the amount of code that is executed with elevated privileges by adopting a model allowing privs to be increased and dropped as needed.  Singularity's execution has been made as transparent as possible so that the code can be audited with ease.  If you execute a Singularity command with the `--debug` option, you will see exactly which operations are carried out with elevated privs.  


### pipes and redirection

As we demonstrated earlier, pipes and redirects work as expected between a container and host system.  If you need to pipe the output of one command in your container to another command in your container things may be more complicated.

```
$ singularity exec lolcow.img fortune | singularity exec lolcow.img cowsay
```

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





































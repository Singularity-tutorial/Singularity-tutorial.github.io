# <b>Creating and running software containers with Singularity</b>
### <i>How to use [Singularity](http://singularity.lbl.gov)! </i>

This is an introductory class taught by David Godlove at the 
[NIH HPC](https://hpc.nih.gov/).  For more information about the topics covered 
in this class, see the following:

- [Singularity Home](http://singularity.lbl.gov/)
- [Singularity on GitHub](https://github.com/singularityware/singularity)
- [Singularity on Google Groups](https://groups.google.com/a/lbl.gov/forum/#!forum/singularity)
- [Singularity at the NIH HPC](https://hpc.nih.gov/apps/singularity.html)
- [Docker documentation](https://docs.docker.com/)
- [Singularity Hub](https://singularity-hub.org/)
- [Docker Hub](https://hub.docker.com/)

## Hour 1 (Introduction and Installation)

### What IS a software container anyway? (And what's it good for?)

A container allows you to stick an application and all of it's dependencies 
into a single package.  This makes your package portable, shareable, and 
reproducible.

Containers foster portability and reproducibility because they package 
<b>ALL</b> of an applications dependencies... including an entire small 
operating system!

This means you're application won't break when you port it to a new computer 
because there is something different about the new environment.  It brings it's 
environment with it.

Here are some of the things you can do with containers:

- Package an analysis pipeline so that it runs on your laptop, in the cloud, 
and in a high performance computing (HPC) environment to produce the same 
result.
- Publish a paper and include a link to a container with all of the data and 
software that you used so that others can easily reproduce your results.
- Install and run an application that requires a complicated stack of 
dependencies with a few keystrokes.
- Create a pipeline of programs where each individual program is meant to run 
on a different operating system.

### How do containers differ from virtual machines (VMs)

Containers and VMs are both types of virtualization.  But it's important to 
understand the differences between the two and know when to use each.

<b>Virtual Machines</b> install every last bit of an operating system (OS) 
right down to the core software that allows the OS to control the hardware 
(called the <i>kernel</i>).  This means that VMs:
- Are complete in the sense that you can use a VM to interact with your computer
via a different OS.
- Are extremely flexible.  For instance you an install a Windows VM on a MacOS 
system using software like [VirtualBox](https://www.virtualbox.org/wiki/VirtualBox).  
- Are relatively slow and resource hungry.  Every time you start a VM it has 
to bring up an entirely new OS.

<b>Containers</b> share a kernel with the host OS.  This means that Containers:
- Are less flexible than VMs.  For example, a Linux container must be run on a 
Linux host OS.  (Although you can mix and match distributions.)  In practice, 
containers are only extensively developed on Linux.
- Are much faster and lighter weight than VMs.  A container may be just a few
hundred MB.
- Start and stop quickly and are suitable for running single apps.

Because of their differences, VMs and containers serve different purposes and 
should be favored under different circumstances.  
- VMs are good for long running interactive sessions where you may want to use
several different applications.  (Checking email on Outlook and using Microsoft
Word and Excel).
- Containers are better suited to running one or two applications 
non-interactively in their own custom environments.

### Docker

[Docker](https://www.docker.com/) is currently the most popular and widely used container software.  It 
has several strengths and weaknesses that make it a good choice for some 
projects but not for others.

<b>philosophy</b>

Docker is built for running multiple containers on a single system and it 
allows containers to share common software features for efficiency.  It also 
seeks to fully isolate each container from all other containers and from the 
host system.  Docker assumes that you will be a root user.  Or that it will be OK 
for you to elevate your privileges if you are not a root user.    

<b>strengths</b>

- Mature software with a large user community
- [Docker Hub](https://hub.docker.com/)!
    - A place to build and host your containers
    - Fully integrated into core Docker
    - Over 100,000 pre-built containers
    - Provides an ecosystem for container orchestration
- Rich feature set

<b>weaknesses</b>

- Difficult to learn
    - Hidden innards 
    - Complex container model (layers)
- Not built for HPC (but good for cloud) 

Docker shines for DevOPs teams providing cloud-hosted micro-services to users.

### Singularity 

[Singularity](http://singularity.lbl.gov/) is a relatively new container software developed by Greg Kurtzer at
Lawrence Berkley National labs.  It was developed with scientific software and
HPC systems in mind.  

<b>philosophy</b>

Singularity assumes (more or less) that each application will have it's own container.  It 
does not seek to fully isolate containers from one another or the host system.
Singularity assumes that you will have a build system where you are the root 
user, but that you will also have a production system where you may or may not
be the root user and which may or may not be separate from you build system.

<b>strengths</b>
- Easy to learn and use (relatively speaking)
- Approved for HPC (installed on Biowulf and a bunch of other HPC systems)
- Can convert Docker containers to Singularity via `pull` and `bootstrap` 
commands
- [Singularity Hub](https://singularity-hub.org/)
    - A place to build and host your containers similar to Docker Hub
- Can also use Docker Hub!

<b>weaknesses</b>
- Younger and less mature than Docker
- Smaller user community (as of now)
- Under active development (must keep up with new changes) 

Singularity shines for scientific software running in an HPC environent.  We 
will use it for the remainder of the class.

### Install
Here we will install the latest tagged release from [GitHub](https://github.com/singularityware/singularity).
If you prefer to install a different version or to install Singularity in a 
different location, see these [Singularity docs](http://singularity.lbl.gov/docs-quick-start-installation).

We're going to compile Singularity from source code.  First we'll need to make
sure we have some development tools installed so that we can do that.  On 
Ubuntu, run these commands to make sure you have all the necessary packages 
installed.

```
$ sudo apt-get update 

$ sudo apt-get install python dh-autoreconf build-essential debootstrap
```

On CentOS, these commmands should get you up to speed.

```
$ sudo yum update 

$ sudo yum groupinstall 'Development Tools'

$ sudo yum install wget epel-release

$ sudo yum install debootstrap.noarch
```

Next we'll download a compressed archive of the source code (using the the 
`wget` command). Then we'll extract the source code from the archive (with the 
`tar` command).

```
$ wget https://github.com/singularityware/singularity/releases/download/2.3/singularity-2.3.tar.gz

$ tar xvf singularity-2.3.tar.gz
```

Finally it's time to build and install!

```
$ cd singularity-2.3

$ ./configure --prefix=/usr/local

$ make 

$ sudo make install
```

If everything went according to plan, you now have a working installation of 
Singularity.  You can test your installation like so:

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

You're cow will likely say something different (and be more colorful), but as 
long as you see a cow your installation is working properly.  

This command downloads and runs a container from [Docker Hub](https://hub.docker.com/r/godlovedc/lolcow/).  During the 
next hour we will learn how to build a similar container from scratch.  


## Hour 2 (Building and Running Containers)

In the second hour we will build the preceding container from scratch. Simply
typing `singularity` will give you an summary of all the commands you can use.
Typing `singularity help <command>` will give you more detailed information 
about running an individual command.

### Building a basic container

To build a singularity container, you must issue 2 commands.  First you must 
`create` an empty container.  Then you must `bootstrap` an OS and any apps into 
the empty container.  

First, let's create an empty Singularity container.  

```
$ cd ~

$ singularity create lolcow.img
```

By default, singularity creates a container with 768MB in size.  You can change
this default with the `--size` option.

Now that we have an empty singularity container, we need to use `bootstrap` to
install an OS.  To use the bootstrap command, we need a <b>definition file</b>.
A definition file is like a set of blueprints telling Singularity what software
to install in the container.


The source code that we installed using `wget` contains several example
definition files in `singularity-2.3/examples`.  Let's copy the ubuntu example
to our home directory and inspect it.

```
$ cp singularity-2.3/examples/ubuntu/Singularity .

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
    apt-get -y --force-yes install vim

```

See the [Singularity docs](http://singularity.lbl.gov/bootstrap-image) for an 
explanation of each of these sections.

Now let's rename this file so we don't get confused and use it to bootstrap our
`lolcow.img` container. Note that the bootstrap command requires `sudo` 
privileges.

```
$ mv Singularity lolcow.def

$ sudo singularity bootstrap lolcow.img lolcow.def
```

This should take a few minutes while all of the components of an OS are
downloaded and installed.  When the bootstrap finishes you will have a basic
Ubuntu container.

### Using `shell` to explore and modify containers

Now let's enter our new container and look around.  

```
$ singularity shell lolcow.img
```

Depending on the environment on your host system you may see your prompt 
change. Let's look at what OS is running inside the container.

```
$ cat /etc/os-release
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

No matter what OS is running on your host, your container is running Ubuntu
14.04!

Let's try installing some software. I used the programs `fortune`, `cowsay`, 
and `lolcat` to produce the container that we saw in the first demo.

```
$ sudo apt-get update && sudo apt-get install fortune cowsay lolcat
bash: sudo: command not found
```

Whoops!

Singularity complains that it can't find the sudo command.  It is really 
complaining that it can't elevate your privileges within the container.  This 
is an important concept in Singularity.  If you enter a container without root
privileges, you are unable to obtain root privileges within the container.

Let's exit the container and re-enter as root.

```
$ exit

$ sudo singularity shell --writable lolcow.img
```

Now we are the root user inside the container. Note also the addition of the 
`--writable` option.  By default Singularity containers are mounted as
read-only.  Adding the `--writable` option enables us to write to our container.

Let's try installing some software again.

```
$ apt-get update && apt-get install fortune cowsay lolcat
```

Now you should see the programs successfully installed.  Let's try running the
demo in this new container.

```
$ fortune | cowsay | lolcat
bash: lolcat: command not found
bash: cowsay: command not found
bash: fortune: command not found
```

Drat! It looks like the programs were not added to our `$PATH`.  Let's add
them and try again.

```
$ export PATH=/usr/games:$PATH

$ fortune | cowsay | lolcat
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

We're making progress, but we are now receiving a warning from perl.  But 
before we tackle that, let's think some more about the `$PATH` variable.

We changed our path in this session, but those changes will disappear as soon
as we exit the container.  It Singularity 2.2 it was possible to add text to a
file called `/environment` in your container so that variable changes like this
would persist.  In Singularity 2.3 things are a bit more hidden and you would 
need to edit a file called `/.singularity.d/env/90-environment.sh` to make this
variable change persistent like so:

```
$ echo 'export PATH=/usr/games:$PATH' >> /.singularity.d/env/90-environment.sh
```

But files in the `/.singularity.d` meta data directory aren't really meant to
be edited by hand.  Instead we should make this change in the definition file
and re-bootstrap the container.  We'll do that in a minute.

Now back to our perl warning.  Perl is complaining that the locale is not set
properly.  Basically, perl wants to know where you are and what sort of
language encoding it should use.  Should you encounter this warning you can 
probably fix it with the `locale-gen` command or by setting `LC_ALL=C`.  Here
we'll use `locale-gen`.

```
$ locale-gen en_US.UTF-8
Generating locales...
  en_US.UTF-8... done
Generation complete.

$ fortune | cowsay | lolcat
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

Although it is fine to shell into your Singularity container and make changes
while you are debugging, you ultimately what all of these changes to be
reflected in your definition file.  Otherwise if you mess your container up 
and need to rebuild it from scratch you will forget all of the changes you 
made.

Let's update our definition file with the changes we made to this container.

```
$ exit

$ nano lolcow.def
```

New lines are in <b>bold</b>.

```
<b>bold</b>
```

### Blurring the line between the container and the host system.

Singularity does not try to isolate your container completely from the host 
system.  This allows you to do some interesting things.

Using the exec command, we can run commands within the container from the host
system.  

```
$ singularity exec lolcow.img cowsay 'How did you get out of the container?'
```

In this example, singularity entered the container, ran the `cowsay` command, 
and then displayed the standard output on our host system terminal. 

You can also use pipes and redirection to blur the lines between the container 
and the host system.  

```
$ singularity exec lolcow.img cowsay moo > cowsaid

$ cat cowsaid
```

We created a file called `cowsaid` in the current working directory with the
output of a command that was executed within the container. 

We can also pipe things into the container.

```
$ cat cowsaid | singularity exec lolcow.img cowsay
```

We've created a meta-cow (a cow that talks about cows). ;-P

## Hour 3 (advanced Singularity usage)

### Making containerized apps behave more like normal apps

Let's consider an extended example
to demonstrate how Singularity could be used to implement a program that takes
input and produces output. This is a very common situation.  


Let's imagine that we want to use out lolcow.img to "analyze data".  We should
give our container an input file, it should reformat it (in the form of a cow
speaking), and it should dump the text into an output file.  Although this is 
a silly example, it obviously demonstrates a very common situation.  Here is 
one way that we could make our container accept a file as input and produce
another file as output.

```
$ singularity exec lolcow.img cowsay $(cat jawa.sez) > output

$ ls

$ cat output
```

The `$(some command)` syntax above simply captures the output of the command 
and treats it as though it were a plain old text argument.  

Although this works, it is a lot to remember.  One interesting singularity
trick is to make a container function as though it were an executable.  To do 
that, we need to create a runscript inside the container. It turns out that our
lolcat.def file already builds a runscript into our container for us.

```
./lolcow.img
```

Let's rewrite this runscript so that the container runs our cowsay analysis.


```
```

Now we can call the lolcow.img as though it were an executable, and simply give 
it two arguments.  One for input and one for output.  

```
$ ./lolcow.img jawa.sez output2

$ cat output2
```

### Bind mounting host system directories into a container.

It's also possible to create and modify files on the host system from within
the container. In fact, that's exactly what we did in the previous example when
we created output files in our home directory using the `singularity exec` 
command.  

To be more concrete, consider this example. 

```
$ singularity shell lolcow.img

$ cat wutini > ~/jawa.sez

$ ls

$ cat ~/jawa.sez

$ exit

$ ls

$ cat ~/jawa.sez
```

Here we shelled into a container and created a file with some text in our home
directory.  Even after we exited the container, the file still existed.

There are several special directories that Singularity <i>bind mounts</i> into
your container by default.  These include:

- ~
- /tmp
- /proc
- /sys
- /

You can specify other directories to bind too using the `--bind` command or the 
environmental variable `$SINGULARITY_BIND_PATH`

Let's say we want to use our `conwsay.img` container to analyze data and write 
output to a different directory.  For this example, we first need to create a 
new directory with some data on our host system.  

```
$ sudo mkdir /data

$ sudo chown $USER:$USER /data

$ cat 'I am your father' > /data/vador.sez
```

We also need to make a directory within our container where we can bind mount
the system directory.

```
$ sudo singularity exec --writable lolcow.img mkdir /data
```

Now let's see how that works.  First, let's list the contents of `/data`
within the container without bind mounting.

```
$ singularity exec lolcow.img ls /data
```

The `/data` directory within the container is empty.  Now let's repeat the same
command but using the `--bind` option.

```
$ singularity exec --bind /data lolcow.img ls /data
```

Now the `/data` directory in the container is bind mounted to the `/data` 
directory on the host system and we can see it's contents.  

Now what about our earlier example in which we used a runscript to run a our
container as though it were an executable?  The `singularity run` command 
accepts the `--bind` option and can execute our runscript like so.

```
$ singularity run --bind /data lolcow.img /data/vador.sez /data/output3
```

But that's a cumbersome command.  Instead, we could set the variable 
`$SINGULARITY_BINDPATH` and then use our container as before.

```
$ export SINGULARITY_BINDPATH=/data

$ ./lolcow.img /data/output3 /data/metacow

$ cat /data/metacow
```

### Singularity Hub and Docker Hub

We've spent a lot of time on building and using your own containers to
demonstrate how Singularity works.  But there's an easier way! [Docker Hub]()
hosts over 100,000 pre-built, ready-to-use containers.  And singularity makes
it easy to use them.

When we first installed Singularity we tested the installation by running a
container from Docker Hub like so.

```
$ singularity run docker://godlovedc/lolcow
```

Instead of running this container from Docker Hub, we could also just copy it 
to our local system with the `pull` command.

```
$ singularity pull docker://godlovedc/lolcow

$ ls

$ ./lolcow
```

You can build and host your own images on Docker Hub, (using docker) or you can
download and run images that others have built.

```
$ singularity shell docker://tensorflow/tensorflow:latest-gpu

python

import tensorflow as tf

quit()

exit
```

If you don't want to learn how to write Docker files (definition files for 
Docker) you can also use [Singularity Hub]() to build and host container 
images.  

Both Docker Hub and Singularity Hub link to your GitHub account. New container
builds are automatically triggered every time you push changes to a Docker file
or a Singularity definition file in a linked repository.  

### Miscellaneous topics 

<b>pipes and redirection</b>

As we demonstrated earlier, pipes and redirects work as expected between a 
container and host system.  If you need to pipe the output of one command in 
your container to another command in your container things may be more 
complicated.

```
$ singularity exec lolcow.img fortune | singularity exec lolcow.img cowsay
```

<b>X11 and OpenGL</b>

You can use Singularity containers to display graphics through common 
protocols. To do this, you need to install the proper graphics stack within
the Singularity container.  For instance if you want to display X11 graphics
you must install `xorg` within your container.  In an Ubuntu container the
command would look like this.  

```
$ apt-get install xorg
```

<b>GPU computing</b>

In Singularity v2.2 it was necessary to install graphics card drivers into the 
container to use GPU hardware for CUDA.  (See the [gpu4singularity script]() on
GitHub for details.)  This is no longer necessary in v2.3.  In v2.3 the 
experimental --nv option will look for NVIDIA libraries on the host system and
automatically bind mount them to the container so that GPUs work seamlessly. 

<b>host system ports</b> 

Network ports on the host system are accessible from within the container and 
work seamlessly.  For example, you could install ipython within a container,
start a jupyter notebook instance, and then connect to that instance using a 
browser running outside of the container on the host system or from another
host.  

<b>a note on SUID programs and daemons</b>

Some programs need root privileges to run.  These often include services or 
daemons that start via the `init.d` or `system.d` systems and run in the
background.  For instance, `sshd` the ssh daemon that listens on port 22 and 
allows another user to connect to your computer requires root privileges.  You
will not be able to run it in a container unless you call the container as root.

Other programs may set the SUID bit and run as root without your knowledge.  
For instance, the well-known `ping` program actually runs as root (and needs to
since it sets up a raw network socket).  This program will not run in a 
container unless you are root in the container.





































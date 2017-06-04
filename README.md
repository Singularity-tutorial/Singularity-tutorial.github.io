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
understand the differences between the two to know when to use each.

<b>Virtual Machines</b> install every last bit of an operating system (OS) 
right down to the core software that allows the OS to control the hardware 
(called the <i>kernel</i>).  This means that VMs:
- Are complete in the sense that you can use a VM to interact with you computer
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
- Are suitable for starting and stopping rapidly and running single apps.

Because of their differences, VMs and containers serve different purposes and 
should be favored under different circumstances.  
- VMs are good for long running interactive sessions where you may want to use
several different applications.  (Checking email on Outlook and using Microsoft
Word and Excel).
- Containers are better suited to running one or two applications 
non-interactively in their own custom environments.

### Docker
Docker is currently the most popular and widely used container software.  It 
has several strengths and weaknesses that make it a good choice for some 
projects but not for others.

<b>philosophy</b>
Docker is built for running multiple containers on a single system and it 
allows containers to share common software features for efficiency.  It also 
seeks to fully isolate each container from all other containers and from the 
host system.Docker assumes that you will be a root user.  Or that it will be OK 
for you to elevate your privileges if you are not a root user.    

<b>strengths</b>
- Mature software with a large user community
- Docker Hub!
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
Singularity is a relatively new container software developed by Greg Kurtzer at
Lawrence Berkley National labs.  It was developed with scientific software and
HPC systems in mind.  

<b>philosophy</b>
Singularity assumes that each application will have it's own container.  It 
does not seek to fully isolate containers from one aother or the host system.
Singularity assumes that you will have a build system where you are the root 
user, but that you will also have a production system where you may or may not
be the root user and which may or may not be separate from you build system.

<b>strengths</b>
- Easy to learn and use (relatively speaking)
- Approved for HPC (installed on Biowulf)
- Can convert Docker containers to Singularity via `pull` and `bootstrap` 
commands
- Singularity Hub
    - A place to build and host your containers similar to Docker Hub
- Can also use Docker Hub!

<b>weaknesses</b>
- Younger and less mature than Docker
- Smaller user community (as of now)
- Under active development (must keep up with new changes) 

## Installation
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

```sh-session
Script started on Sun Jun  4 14:56:42 2017
]0;godlovedc@felix:~/versioned/Singularity-Tutorial[?1034h]0;~/versioned/Singularity-Tutorial
[40m[32m02:56 PM [40m]0;~/versioned/Singularity-Tutorial
[40m[33mgodlovedc[40m[32m@felix:[33m~/versioned/Singularity-Tutorial[0m
$ singularity shell      ru   run docker://godlovedc/lolcow
Docker image path: index.docker.io/godlovedc/lolcow:latest
Cache folder set to /home/godlovedc/.singularity/docker
Creating container runtime...
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = "en_US",
	LC_ALL = (unset),
	LC_TIME = "C",
	LC_CTYPE = "en_US",
	LC_COLLATE = "C",
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
[38;5;129m [0m[38;5;129m_[0m[38;5;129m_[0m[38;5;129m_[0m[38;5;93m_[0m[38;5;93m_[0m[38;5;93m_[0m[38;5;93m_[0m[38;5;93m_[0m[38;5;93m_[0m[38;5;93m_[0m[38;5;93m_[0m[38;5;93m_[0m[38;5;99m_[0m[38;5;63m_[0m[38;5;63m_[0m[38;5;63m_[0m[38;5;63m_[0m[38;5;63m_[0m[38;5;63m_[0m[38;5;63m_[0m[38;5;63m_[0m[38;5;63m_[0m[38;5;63m_[0m[38;5;63m_[0m[38;5;69m_[0m[38;5;33m_[0m[38;5;33m_[0m[38;5;33m_[0m[38;5;33m_[0m[38;5;33m_[0m[38;5;33m_[0m[38;5;33m_[0m[38;5;33m_[0m[38;5;33m_[0m[38;5;39m_[0m[38;5;39m_[0m[38;5;39m_[0m[38;5;39m_[0m
[38;5;129m/[0m[38;5;93m [0m[38;5;93mY[0m[38;5;93mo[0m[38;5;93mu[0m[38;5;93m [0m[38;5;93ma[0m[38;5;93mr[0m[38;5;93me[0m[38;5;93m [0m[38;5;99mo[0m[38;5;63mn[0m[38;5;63ml[0m[38;5;63my[0m[38;5;63m [0m[38;5;63my[0m[38;5;63mo[0m[38;5;63mu[0m[38;5;63mn[0m[38;5;63mg[0m[38;5;63m [0m[38;5;63mo[0m[38;5;69mn[0m[38;5;33mc[0m[38;5;33me[0m[38;5;33m,[0m[38;5;33m [0m[38;5;33mb[0m[38;5;33mu[0m[38;5;33mt[0m[38;5;33m [0m[38;5;33my[0m[38;5;39mo[0m[38;5;39mu[0m[38;5;39m [0m[38;5;39mc[0m[38;5;39ma[0m[38;5;39mn[0m[38;5;39m [0m[38;5;39m\[0m
[38;5;93m\[0m[38;5;93m [0m[38;5;93ms[0m[38;5;93mt[0m[38;5;93ma[0m[38;5;93my[0m[38;5;93m [0m[38;5;99mi[0m[38;5;63mm[0m[38;5;63mm[0m[38;5;63ma[0m[38;5;63mt[0m[38;5;63mu[0m[38;5;63mr[0m[38;5;63me[0m[38;5;63m [0m[38;5;63mi[0m[38;5;63mn[0m[38;5;63md[0m[38;5;69me[0m[38;5;33mf[0m[38;5;33mi[0m[38;5;33mn[0m[38;5;33mi[0m[38;5;33mt[0m[38;5;33me[0m[38;5;33ml[0m[38;5;33my[0m[38;5;33m.[0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;38m [0m[38;5;38m/[0m
[38;5;93m [0m[38;5;93m-[0m[38;5;93m-[0m[38;5;93m-[0m[38;5;99m-[0m[38;5;63m-[0m[38;5;63m-[0m[38;5;63m-[0m[38;5;63m-[0m[38;5;63m-[0m[38;5;63m-[0m[38;5;63m-[0m[38;5;63m-[0m[38;5;63m-[0m[38;5;63m-[0m[38;5;63m-[0m[38;5;69m-[0m[38;5;33m-[0m[38;5;33m-[0m[38;5;33m-[0m[38;5;33m-[0m[38;5;33m-[0m[38;5;33m-[0m[38;5;33m-[0m[38;5;33m-[0m[38;5;33m-[0m[38;5;39m-[0m[38;5;39m-[0m[38;5;39m-[0m[38;5;39m-[0m[38;5;39m-[0m[38;5;39m-[0m[38;5;39m-[0m[38;5;39m-[0m[38;5;39m-[0m[38;5;38m-[0m[38;5;38m-[0m[38;5;44m-[0m[38;5;44m-[0m
[38;5;93m [0m[38;5;99m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m\[0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m^[0m[38;5;69m_[0m[38;5;33m_[0m[38;5;33m^[0m
[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m\[0m[38;5;69m [0m[38;5;33m [0m[38;5;33m([0m[38;5;33mo[0m[38;5;33mo[0m[38;5;33m)[0m[38;5;33m\[0m[38;5;33m_[0m[38;5;33m_[0m[38;5;33m_[0m[38;5;39m_[0m[38;5;39m_[0m[38;5;39m_[0m[38;5;39m_[0m
[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;69m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m([0m[38;5;33m_[0m[38;5;33m_[0m[38;5;33m)[0m[38;5;33m\[0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m)[0m[38;5;39m\[0m[38;5;38m/[0m[38;5;38m\[0m
[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;63m [0m[38;5;69m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m|[0m[38;5;39m|[0m[38;5;39m-[0m[38;5;39m-[0m[38;5;39m-[0m[38;5;39m-[0m[38;5;39mw[0m[38;5;38m [0m[38;5;38m|[0m
[38;5;63m [0m[38;5;69m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;33m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m [0m[38;5;39m|[0m[38;5;39m|[0m[38;5;39m [0m[38;5;39m [0m[38;5;38m [0m[38;5;38m [0m[38;5;44m [0m[38;5;44m|[0m[38;5;44m|[0m
]0;godlovedc@felix:~/versioned/Singularity-Tutorial]0;~/versioned/Singularity-Tutorial
[40m[32m02:57 PM [40m]0;~/versioned/Singularity-Tutorial
[40m[33mgodlovedc[40m[32m@felix:[33m~/versioned/Singularity-Tutorial[0m
$ exit
exit

Script done on Sun Jun  4 14:57:36 2017

```








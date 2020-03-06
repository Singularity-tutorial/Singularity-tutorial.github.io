# Downloading and interacting with containers

This section will be useful for container consumers. (i.e. those who really just want to use containers somebody else built.) The next chapter will explore topics more geared toward container producers (i.e. those who want/need to build containers from scratch).  

You can find pre-built containers in lots of places. Singularity can convert and run containers in many different formats, including those built by Docker.

In this class, we'll be using containers from:

- [The Singularity Container Library](https://cloud.sylabs.io/library), developed and maintained by [Sylabs](https://sylabs.io/)
- [Docker Hub](https://hub.docker.com/), developed and maintained by [Docker](https://www.docker.com/)

There are lots of other places to find pre-build containers too. Here are some of the more popular ones:

- [Singularity Hub](https://singularity-hub.org/), an early collaboration between Stanford University and the Singularity community
- [Quay.io](https://quay.io/), developed and maintained by Red Hat
- [NGC](https://ngc.nvidia.com/catalog/all?orderBy=modifiedDESC&pageNumber=3&query=&quickFilter=&filters=), developed and maintained by NVIDIA
- [BioContainers](https://biocontainers.pro/#/registry), develped and maintained by the Bioconda group
- Cloud providers like Amazon AWS, Microsoft Azure, and Google cloud also have container registries that can work with Singularity

## Downloading containers

In the last section, we validated our Singularity installation by "running" a container from the Container Library. Let's download that container using the `pull` command.

```
$ cd ~

$ singularity pull library://godlovedc/funny/lolcow
```

You'll see a warning about running `singularity verify` to make sure that the container is trusted. We'll talk more about that later.  

For now, notice that you have a new file in your current working directory called `lolcow_latest.sif`

```
$ ls lolcow_latest.sif
lolcow_latest.sif
```

This is your container. Or more precisely, it is a Singularity Image Format (SIF) file containing an image of a root level filesystem. This image is mounted to your host filesystem (in a new "mount namespace") and then entered when you run a Singularity command.   

Note that you can download the Docker version of this same container from Docker Hub with the following command:

```
$ singularity pull docker://godlovedc/lolcow
```

Doing so may produce an error if the container already exists.  

## Entering containers with `shell`

Now let's enter our new container and look around. We can do so with the `shell` command.

```
$ singularity shell lolcow_latest.sif
```

Depending on the environment of your host system you may see your shell prompt change. Let's look at what OS is running inside the container.

```
$ cat /etc/os-release
NAME="Ubuntu"
VERSION="16.04.5 LTS (Xenial Xerus)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 16.04.5 LTS"
VERSION_ID="16.04"
HOME_URL="http://www.ubuntu.com/"
SUPPORT_URL="http://help.ubuntu.com/"
BUG_REPORT_URL="http://bugs.launchpad.net/ubuntu/"
VERSION_CODENAME=xenial
UBUNTU_CODENAME=xenial
```

No matter what OS is running on your host, your container is running Ubuntu 16.04 (Xenial Xerus)!

---
**NOTE**

In general, the Singularity action commands (like `shell`, `run`, and `exec`) are expected to work with URIs like `library://` and `docker://` the same as they would work with a local image.

---


Let's try a few more commands:

```
Singularity> whoami
dave

Singularity> hostname
hal-9000
```

This is one of the core features of Singularity that makes it so attractive from a security and usability standpoint.  The user remains the same inside and outside of the container. 

Regardless of whether or not the program `cowsay` is installed on your host system, you have access to it now because it is installed inside of the container:

```
Singularity> which cowsay
/usr/games/cowsay

Singularity> cowsay moo
 _____
< moo >
 -----
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

We'll be getting a lot of mileage out of this silly little program as we explore Linux containers.  

This is the command that is executed when the container actually "runs":

```
Singularity> fortune | cowsay | lolcat
 ____________________________________
/ A horse! A horse! My kingdom for a \
| horse!                             |
|                                    |
\ -- Wm. Shakespeare, "Richard III"  /
 ------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

More on "running" the container in a minute. For now, don't forget to `exit` the container when you are finished playing!

```
Singularity> exit
exit
```

## Executing containerized commands with `exec`

Using the `exec` command, we can run commands within the container from the host system.  

```
$ singularity exec lolcow_latest.sif cowsay 'How did you get out of the container?'
 _______________________________________
< How did you get out of the container? >
 ---------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

In this example, singularity entered the container, ran the `cowsay` command with supplied arguments, displayed the standard output on our host system terminal, and then exited. 

## "Running" a container with (and without) `run`

As mentioned several times you can "run" a container like so:

```
$ singularity run lolcow_latest.sif
 _________________________________________
/ Q: How many Bell Labs Vice Presidents   \
| does it take to change a light bulb? A: |
| That's proprietary information. Answer  |
| available from AT&T on payment of       |
\ license fee (binary only).              /
 -----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

So what actually happens when you run a container? There is a special file within the container called a `runscript` that is executed when a container is run. You can see this (and other meta-data about the container) using the inspect command.  

```
$ singularity inspect --runscript lolcow_latest.sif
#!/bin/sh

    fortune | cowsay | lolcat
```

In this case the `runscript` consists of three simple commands with the output of each command piped to the subsequent command. 

Because Singularity containers have pre-defined actions that they must carry out when run, they are actually executable. Note the default permissions when you download or build a container:

```
$ ls -l lolcow_latest.sif
-rwxr-xr-x 1 student student 93574075 Feb 28 23:02 lolcow_latest.sif
```

This allows you to run execute a container like so:

```
$ ./lolcow_latest.sif
 ________________________________________
/ It is by the fortune of God that, in   \
| this country, we have three benefits:  |
| freedom of speech, freedom of thought, |
| and the wisdom never to use either.    |
|                                        |
\ -- Mark Twain                          /
 ----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```
As we shall see later, this nifty trick can makes it easy to forget your applications are containerized and just run them like any old program.  

## Pipes and redirection

Singularity does not try to isolate your container completely from the host system.  This allows you to do some interesting things. For instance, you can use pipes and redirection to blur the lines between the container and the host system.  

```
$ singularity exec lolcow_latest.sif cowsay moo > cowsaid

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

We created a file called `cowsaid` in the current working directory with the output of a command that was executed within the container.  >_shock and awe_

We can also pipe things _into_ the container (and that is very tricky).

```
$ cat cowsaid | singularity exec lolcow_latest.sif cowsay -n
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

We've created a meta-cow (a cow that talks about cows). ;-P

So pipes and redirects work as expected between a container and the host system. If, however, you need to pipe the output of one command in your container to another command in your container, things are slightly more complicated. Pipes and redirects are shell constructs, so if you don't want your host shell to interpret them, you have to hide them from it.

```
$ singularity exec lolcow_latest.sif sh -c "fortune | cowsay | lolcat"
```

The above invokes a new shell, but inside the container, and tells it to run the single command line `fortune | cowsay | lolcat`.

That covers the basics on how to download and use pre-built containers!  In the next section we'll start learning how to build your own containers.

# Singularity Hub and Docker Hub

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

The `pull` command is equivalent and can be run without `sudo`, so this can be done directly on your cluster.


```
$ singularity pull docker://godlovedc/lolcow
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

<- [previous](/07-fake-installation) - [home](https://singularity-tutorial.github.io/)

---
# Miscellaneous Topics and FAQs

## X11 and OpenGL

You can use Singularity containers to display graphics through common protocols. To do this, you need to install the proper graphics stack within the Singularity container.  For instance if you want to display X11 graphics you must install `xorg` within your container.  In an Ubuntu container the command would look like this.  

```
$ apt-get install xorg
```

## GPU computing

In Singularity v2.3+ the experimental `--nv` option will look for NVIDIA libraries on the host system and automatically bind mount them to the container so that GPUs work seamlessly. 

## Using the network on the host system

Network ports on the host system are accessible from within the container and work seamlessly.  For example, you could install ipython within a container, start a jupyter notebook instance, and then connect to that instance using a browser running outside of the container on the host system or from another host.  

## A note on SUID programs and daemons

Some programs need root privileges to run.  These often include services or daemons that start via the `init.d` or `system.d` systems and run in the background.  For instance, `sshd` the ssh daemon that listens on port 22 and allows another user to connect to your computer requires root privileges.  You will not be able to run it in a container unless you start the container as root.

Other programs may set the SUID bit or capabilities to run as root or with elevated privileges without your knowledge. For instance, the well-known `ping` program actually runs with elevated privileges (and needs to since it sets up a raw network socket).  This program will not run in a container unless you are root in the container.


## Long-running Instances

Up to now all of our examples have run Singularity containers in the foreground.  But what if you want to run a service like a web server or a database in a Singularity container in the background? 

### lolcow (useless) example
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

### nginx (useful) example

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

---
<- [previous](/07-fake-installation) - [home](https://singularity-tutorial.github.io/)
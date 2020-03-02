# Bind mounting host system directories into a container

It's possible to create and modify files on the host system from within the container. In fact, that's exactly what we did in the previous example when we created output files in our home directory.  

Let's be more explicit. Consider this example. 

```
$ singularity shell lolcow.simg

Singularity lolcow.simg:~> echo wutini > ~/jawa.txt

Singularity lolcow.simg:~> cat ~/jawa.txt
wutini

Singularity lolcow.simg:~> exit

$ cat ~/jawa.txt
wutini
```

Here we shelled into a container and created a file with some text in our home directory.  Even after we exited the container, the file still existed. How did this work?

There are several special directories that Singularity _bind mounts_ into
your container by default.  These include:

- `$HOME`
- `/tmp`
- `/proc`
- `/sys`
- `/dev`

You can specify other directories to bind using the `--bind` option or the environmental variable `$SINGULARITY_BINDPATH`

Let's say we want to use our `cowsay.img` container to "analyze data" and save results in a different directory.  For this example, we first need to create a new directory with some data on our host system.  

```
$ sudo mkdir /data

$ sudo chown $USER:$USER /data

$ echo 'I am your father' > /data/vader.txt
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
-rw-rw-r-- 1 ubuntu ubuntu 17 Jun  7 20:57 vader.txt
```

Now the `/mnt` directory in the container is bind mounted to the `/data` directory on the host system and we can see its contents.  

Now what about our earlier example in which we used a runscript to run a our container as though it were an executable?  The `singularity run` command  accepts the `--bind` option and can execute our runscript like so.

```
$ singularity run --bind /data:/mnt lolcow.simg -i /mnt/vader.txt -o /mnt/output3

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

$ ./lolcow.simg -i /mnt/output3 -o /mnt/metacow2 -- -n

$ ls -l /data/
total 12
-rw-rw-r-- 1 ubuntu ubuntu 809 Jun  7 21:07 metacow2
-rw-rw-r-- 1 ubuntu ubuntu 184 Jun  7 21:06 output3
-rw-rw-r-- 1 ubuntu ubuntu  17 Jun  7 20:57 vader.txt

$ cat /data/metacow2
 ______________________________
/  __________________          \
| < I am your father >         |
|  ------------------          |
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

For a lot more info on how to bind mount host directories to your container, check out the [NIH HPC Binding external directories](https://hpc.nih.gov/apps/singularity.html#bind) section.

# Bind mounting host system directories into a container

It's possible to create and modify files on the host system from within the container. In fact, that's exactly what we did in the previous example when we created output files in our home directory.  

Let's be more explicit. Consider this example. 

```
$ singularity shell lolcow.sif

Singularity> echo wutini > ~/jawa.txt

Singularity> cat ~/jawa.txt
wutini

Singularity> exit

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

Let's say we want to access a directory called `/data` from within our container. For this example, we first need to create this new directory with some data on our host system.  

```
$ sudo mkdir /data

$ sudo chown $USER:$USER /data

$ echo 'I am your father' > /data/vader.txt
```

Now let's see how bind mounts work.  First, let's list the contents of `/data` within the container without bind mounting `/data` on the host system to it.

```
$ $ singularity exec lolcow.sif ls -l /data
ls: cannot access '/data': No such file or directory
```

Nothing there! Now let's repeat the same command but using the `--bind` option to bind mount `/data` into the container.

```
$ singularity exec --bind /data lolcow.sif ls -l /data
total 4
-rw-rw-r-- 1 student student 17 Mar  2 00:51 vader.txt
```

Now a `/data` directory is created in the container and it is bind mounted to the `/data` directory on the host system.  

You can bind mount a source directory of one name on the host system to a destination of another name using a `source:destination` syntax, and you can bind mount multiple directories as a comma separated string. For instance:

```
$ singularity shell --bind src1:dest1,src2:dest2,src3:dest3 some.sif
```

If no colon is present, Singularity assumes the source and destination are identical.  To do the same thing with an environment variable, you could do the following:

```
$ export SINGULARITY_BINDPATH=src1:dest1,src2:dest2,src3:dest3
```

For a lot more info on how to bind mount host directories to your container, check out the [NIH HPC Binding external directories](https://hpc.nih.gov/apps/singularity.html#bind) section.

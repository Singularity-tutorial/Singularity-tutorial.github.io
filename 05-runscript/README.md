# The Runscript: Making containerized apps behave like normal apps

Consider an application that takes one file as input, analyzes the data in the file, and produces another file as output. This is obviously a very common situation.

Let's imagine that we want to use the cowsay program in our `lolcow.sif` to "analyze data".  We should give our container an input file, it should reformat the text (in the form of a cow speaking), and it should dump the output into another file.  

Here's an example.  First I'll make some "data"

```
$ echo "The grass is always greener over the septic tank" > /data/input
```

Now I'll "analyze" the "data"

```
$ cat /data/input | singularity exec lolcow.sif cowsay >/data/output
```

The "analyzed data" is saved in a file called `/data/output`. 

```
$ cat /data/output
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

Let's rewrite this runscript in the definition file and rebuild our container so that it does something more useful. And while we're at it, we'll change the bootstrap method to `library`  

```
BootStrap: library
From: debian:9

%runscript
    if [ $# -ne 2 ]; then
        echo "Please provide an input and an output file."
        exit 1
    fi
    cat $1 | cowsay > $2

%post
    apt-get update
    apt-get -y install fortune cowsay lolcat

%environment
    export PATH=$PATH:/usr/games
```

Now we must rebuild out container to install the new runscript.  

```
$ sudo singularity build --force lolcow.sif lolcow.def
```

Note the `--force` option which ensures our previous container is completely overwritten.

After rebuilding our container, we can call the `lolcow.sif` as though it were an executable, give it input and output file names.  

```
$ ./lolcow.sif /data/input /data/output2
/.singularity.d/runscript: 7: /.singularity.d/runscript: cannot create /data/output2: Directory nonexistent
cat: /data/input: No such file or directory
```

Whoops!  

We are no longer piping redirecting standard output into and out of the container, so we need to bind mount the `/data` directory into the container.  It will be convenient to simply set the bind path as an environment variable.  

```
$ export SINGULARITY_BINDPATH=/data

$ ./lolcow.sif /data/input /data/output2

$ ./lolcow.sif /data/vader.txt /data/output3

$ cat /data/output2 /data/output3
 ______________________________________
/ The grass is always greener over the \
\ septic tank                          /
 --------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
 __________________
< I am your father >
 ------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

To summarize, we have written a runscript for our container that will do some very basic error checking and expects the location of an input file and an output file allowing it to analyze the data. This is obviously a trivial example, but the sky is the limit. If you can code it, you can make your container do it!  

---
**BONUS**

You will often see this or something similar as a containers runscript.

```
%runscript
    python "$@"
```
What does this do?

---
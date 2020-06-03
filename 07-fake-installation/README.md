<- [previous](/06-runscript) - [home](https://singularity-tutorial.github.io/) - [next](/08-misc) ->

---
# Faking a Native Installation within a Singularity Container

How would you like to install an app with one more more commands inside of a Singularity container and then just forget it's in a container and use it like any other app?  

In the last example, we took a step in that direction by creating a `runscript` to accept input and output, but we still had to set an environment variable and our container was not actually using the cowsay program as written. Not to mention, it gave us zero access to the `fortune` and `lolcat` programs.  In other words, it could only do what our `runscript` told it to do. 

In this section, we are going to look at a simple, flexible method for creating containerized app installations that you can "set and forget".  This is the same method that Biowulf staff members use to install containerized applications on the NIH HPC systems.  As of today, around 100 applications are installed like this, and most of them are used all the time by scientists who may never know or care that the app they depend on is actually running inside of a container!

First, we will `cd` back into our `~/lolcow` directory (if we are not already there) and delete everything in it.  

---
**NOTE**

This class is taught using virtual machines, but you should still _always_ be careful and double check your location, permissions, and mental state before issuing a `rm -rf` command. That goes _double_ when issuing the command as root.

---

```
$ cd ~/lolcow

$ pwd # double check
/home/student/lolcow

$ sudo rm -rf * # caution! see NOTE above!
```

Now we'll make a few new directories to keep things tidy.

```
$ mkdir libexec bin
```

Next we'll create the contents of the `libexec` directory. It will contain the container, and a rather trickly little wrapper script.

```
$ singularity pull libexec/lolcow.sif library://godlovedc/funny/lolcow

$ cat >libexec/lolcow.sh<<"EOF"
#!/bin/bash
export SINGULARITY_BINDPATH="/data"
dir="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
img="lolcow.sif"
cmd=$(basename "$0")
arg="$@"
echo running: singularity exec "${dir}/${img}" $cmd $arg
singularity exec "${dir}/${img}" $cmd $arg
EOF

$ chmod 755 libexec/lolcow.sh
```

Now for the trick.  The `lolcow.sh` wrapper script is written in such a way that whatever symlinks you create to it will run inside of the container.  We've temporarily given it an `echo` line to help clarify what it's doing.  Let's make a few symlinks in the `bin` directory.

```
$ ln -s ../libexec/lolcow.sh bin/fortune

$ ln -s ../libexec/lolcow.sh bin/cowsay

$ ln -s ../libexec/lolcow.sh bin/lolcat
```

Here's what the directory should look like:

```
lolcow/
├── bin
│   ├── cowsay -> ../libexec/lolcow.sh
│   ├── fortune -> ../libexec/lolcow.sh
│   └── lolcat -> ../libexec/lolcow.sh
└── libexec
    ├── lolcow.sh
    └── lolcow.sif
```

Now let's see how it works:

```
$ cd ~

$ export PATH=$PATH:~/lolcow/bin

$ which cowsay fortune lolcat
/home/student/lolcow/bin/cowsay
/home/student/lolcow/bin/fortune
/home/student/lolcow/bin/lolcat

$ cowsay moo
running: singularity exec /home/student/lolcow/libexec/lolcow.sif cowsay moo
 _____
< moo >
 -----
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

$ lolcat --help
running: singularity exec /home/student/lolcow/libexec/lolcow.sif lolcat --help

Usage: lolcat [OPTION]... [FILE]...

Concatenate FILE(s), or standard input, to standard output.
With no FILE, or when FILE is -, read standard input.

    --spread, -p <f>:   Rainbow spread (default: 3.0)
      --freq, -F <f>:   Rainbow frequency (default: 0.1)
      --seed, -S <i>:   Rainbow seed, 0 = random (default: 0)
       --animate, -a:   Enable psychedelics
  --duration, -d <i>:   Animation duration (default: 12)
     --speed, -s <f>:   Animation speed (default: 20.0)
         --force, -f:   Force color even when stdout is not a tty
       --version, -v:   Print version and exit
          --help, -h:   Show this message

Examples:
  lolcat f - g      Output f's contents, then stdin, then g's contents.
  lolcat            Copy standard input to standard output.
  fortune | lolcat  Display a rainbow cookie.

Report lolcat bugs to <http://www.github.org/busyloop/lolcat/issues>
lolcat home page: <http://www.github.org/busyloop/lolcat/>
Report lolcat translation bugs to <http://speaklolcat.com/>
```

Once you understand how it works, remove (or comment) the echo line in `lolcow/libexec/lolcow.sh` and even things like this should work without a hitch:

```
$ fortune | cowsay -n | lolcat
 ___________________________________________________________
< You never hesitate to tackle the most difficult problems. >
 -----------------------------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

---
**NOTE**

If you have too much time on your hands, you might try linking things like `sh`, `bash`, `ls`, or `cd` to the container wrapper script. But otherwise **don't**... because it will cause you a lot of trouble. :-)  

---
<- [previous](/06-runscript) - [home](https://singularity-tutorial.github.io/) - [next](/08-misc) ->
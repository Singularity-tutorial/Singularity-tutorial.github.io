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


So pipes and redirects work as expected between a container and the host system.
if, however, you need to pipe the output of one command in your container to another command in your container, things are slightly more complicated.
Pipes and redirects are shell constructs, so if you don't want your host shell to interpret them, you have to hide them from it.

```
$ singularity exec lolcow.img sh -c "fortune | cowsay | lolcat"
```

The above invokes a new shell, but inside the container, and tells it to run the single command line `fortune | cowsay | lolcat`.

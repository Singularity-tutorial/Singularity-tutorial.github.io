# The Singularity ecosystem

We've spent a lot of time on building and using your own containers so that you understand how Singularity works. Now let's talk more about the [Singularity Container Services](https://cloud.sylabs.io/home) and [Docker Hub](https://hub.docker.com/).  

[Docker Hub](https://hub.docker.com/) hosts over 100,000 pre-built, ready-to-use containers. And the Container Library has a large and growing number of pre-built containers. We've already talked about pulling and building containers from Docker Hub and the Container Library, but there are more details you should be aware of.  

## Tags and hashes

First, Docker Hub and the container library both have a concept of a tagged image. Tags make it convenient for developers to release several different versions of the same container. For instance, if you wanted to specify that you need Debian version 9, you could do so like this:

```
$ singularity pull library://debian:9
```

Or within a definition file:

```
Bootstrap: library
From: debian:9
```
The syntax is similar to specify a tagged container from Docker Hub.  

There is a _special_ tag in both the Singularity Library and Docker Hub called **latest**.  If you omit the `:<tag>` suffix from your `pull` or `build` command or from within your definition file you will get the container tagged with `latest` by default.  This sometimes causes confusion if the `latest` tag doesn't exist for a particular container and an error is encountered. In that case a tag must be supplied.

Tags are not immutable and may change without warning. For insance, the latest tag is automatically assigned to the latest build of a container in Docker Hub. So pulling by tag (or pulling `latest` by default) can result in your pulling 2 different images with the same command. If you are interested in pulling the same container multiple times, you should pull by the hash. Continuing with our Debian 9 example, this will ensure that you get the same one even if the developers change that tag:

```
$ singularity pull debian:sha256.b92c7fdfcc6152b983deb9fde5a2d1083183998c11fb3ff3b89c0efc7b240448
```

## Default entities and collections

Let's think about this command:

```
$ singularity pull library://debian
```

When you run that command there are several default values that are provided for you to allow Singularity to build an entire URI. This is what the full command actually looks like:

```
$ singularity pull library://library/default/debian:latest
```

This container is being pulled from the URI `library`, the entity `library`, the collection `default`, and the tag `latest`.  If you try this shorthand version of the command with the `lolcow` container, you will find that it fails:

```
$ singularity pull library://lolcow
FATAL:   While pulling library image: image lolcow:latest (amd64) does not exist in the library
```

There is no default container called `lolcow` within the `library` and `default` entity and collection.  For that container to work properly, you must supply the entity (`godlovedc`) and the collection (`funny`) like so:

```
$ singularity pull library://godlovedc/funny/lolcow
```

Similarly, when pulling from Docker Hub there are some intelligent defaults supplied. Consider the following command:

```
$ singularity pull docker://godlovedc/lolcow
```

When executed this is the command that Singularity actually acts on:

```
$ singularity pull docker://index.docker.io/godlovedc/lolcow:latest
```

In this example the registry (`index.docker.io`) and the tag (`latest`) are implied. When downloading special images like Debian and Ubuntu, the user (`godovedc` in the above command) can also be implied. These values may need to be manually supplied for some containers on Docker Hub or to download from different registries like Quay.io.  

## Using trusted containers

When you build and or run a container, you are running someone else's code on your system. Doing so comes with certain inherent security risks. The blog posts [here](https://medium.com/sylabs/cve-2019-5736-and-its-impact-on-singularity-containers-8c6272b4bce6) and [here](https://medium.com/sylabs/a-note-on-cve-2019-14271-running-untrusted-containers-as-root-is-still-a-bad-idea-245d227d4e02) provide some background on the kinds of security concerns containers can cause.

Container security is a large topic and we cannot cover all of the facets in this class, but here are a few general guidelines.  

- Don't build containers from untrusted sources or run them as root 
- Review the `runscript` before you run it
- Use the `--no-home` and `--contain-all` options when running an unfamiliar container
- Establish your level of trust with a container

The last point is particularly important and can be accomplished in a few different ways.  

### Docker Hub Official and Certified images

The Docker team works with upstream maintainers (like Canonical, CentOS, etc.) to create **Official** images. They've been reviewed by humans, scanned for vulnerabilities, and approved.  You can find more details [here](https://docs.docker.com/docker-hub/official_images/)  

There are a series of steps that upstream maintainers can perform to produce **Certified** images.  This includes a standard of best practices and some baseline testing.  You can find more details [here](https://docs.docker.com/docker-hub/publish/certify-images/)

### Signing and verifying Singularity images

Singularity gives image maintainers the ability to cryptographically sign images and downstream users can use builtin tools to verify that these images are bit-for-bit reproductions of the originals.  This removes any dependencies on web infrastructure and prevents a specific type of time-of-check to time-of-use (TOCTOU) attack.  

This model also differs from the Docker model of trust because the decision of whether or not to trust a particular image is left to the user and maintainer. Sylabs does not "vouch" for a particular set of images the way that Docker does. It's up to users to obtain fingerprints from maintainers and to judge whether or not they trust a particular maintainer's image.

## Building and hosting your containers

Docker Hub allows you to save a Docker File (Docker's version of a Singularity definition file) to a GitHub repo and then link that repo to a Docker Hub repo. Every time a new commit is pushed to the GitHub repo, a new container will be build on Docker Hub.

For instance, the [godlovedc/lolcow](https://hub.docker.com/repository/docker/godlovedc/lolcow) container is linked to the [GodloveD/lolcow](https://github.com/GodloveD/lolcow/blob/master/Dockerfile) repo on GitHub.  

The [Singularity Remote Builder](https://cloud.sylabs.io/builder) offers a few different ways to build your containers. You can compose a definition file or drag-and-drop using the web GUI.  Or you can log in and create an access token. This allows you to do nifty things like search the Cloud Library with the `search` command and build containers from the command line using `--remote` option.

Here's a quick example. First, I'll use the `remote login` command to generate a token:

```
$ singularity remote login SylabsCloud
INFO:    Authenticating with remote: SylabsCloud
Generate an API Key at https://cloud.sylabs.io/auth/tokens, and paste here:
API Key:
INFO:    API Key Verified!
```

I had to actually visit the website, create the token and copy the text into the prompt (which does not echo to the screen).

Now I can search for users, collections, and containers like so:

```
$ singularity search wine
No users found for 'wine'

No collections found for 'wine'

Found 1 containers for 'wine'
        library://godloved/base/wine
                Tags: latest
```

And I can also use the `--remote` option to build my containers. Note that this **does not require root!**

```
$ cat alpine.def
Bootstrap: library
From: alpine

%post
    echo "Install stuff here"

$ singularity build --remote alpine.sif alpine.def
INFO:    Remote "default" added.
INFO:    Authenticating with remote: default
INFO:    API Key Verified!
INFO:    Remote "default" now in use.
INFO:    Starting build...
INFO:    Downloading library image
INFO:    Running post scriptlet
Install stuff here
+ echo 'Install stuff here'
INFO:    Creating SIF file...
INFO:    Build complete: /tmp/image-302588342
WARNING: Skipping container verifying
 2.59 MiB / 2.59 MiB  100.00% 26.13 MiB/s 0s
INFO:    Build complete: alpine.sif

$ ls alpine.sif
alpine.sif

$ singularity shell alpine.sif
Singularity> cat /etc/os-release
NAME="Alpine Linux"
ID=alpine
VERSION_ID=3.9.2
PRETTY_NAME="Alpine Linux v3.9"
HOME_URL="https://alpinelinux.org/"
BUG_REPORT_URL="https://bugs.alpinelinux.org/"
Singularity> exit
student@sing-class2:~$
```

The build happens transparently. Even though we are building on the cloud, it _looks_ like the container is built right here on our system and it downloads automatically.  

## Signing and sharing containers
You can generate a new PGP key with the `key` command like so:

```
$ singularity key newpair
Enter your name (e.g., John Doe) : Class Admin
Enter your email address (e.g., john.doe@example.com) : class.admin@mymail.com
Enter optional comment (e.g., development keys) : This is an example key for a class
Enter a passphrase :
Retype your passphrase :
Would you like to push it to the keystore? [Y,n] y
Generating Entity and OpenPGP Key Pair... done
Key successfully pushed to: https://keys.sylabs.io
```

This lets you cryptographically sign the container you just created with the `sign` command:

```
$ singularity sign alpine.sif
Signing image: alpine.sif
Enter key passphrase :
Signature created and applied to alpine.sif
```

The you can push it to the library like so:

```
$ singularity push alpine.sif library://godloved/base/alpine:latest
INFO:    Container is trusted - run 'singularity key list' to list your trusted keys
 2.59 MiB / 2.59 MiB [========================================================] 100.00% 10.72 MiB/s 0s
```

Then when others `pull` the container they can use the `verify` command to make sure that it has not been tampered with.

```
$ singularity verify alpine.sif
Container is signed by 1 key(s):

Verifying partition: FS:
73B905527AB1AA3929B6A736A47CBE85B37CB086
[LOCAL]   Class Admin (This is an example key for a class) <class.admin@mymail.com>
[OK]      Data integrity verified

INFO:    Container verified: alpine.sif
```

---
**NOTE**

Anyone can sign a container. So just because a container is signed, does not mean it should be trusted. Users must obtain the fingerprint associated with a given maintainer's key and compare it with that displayed by the `verify` command to ensure that the container is authentic. After that it is up to the user to decide if they trust the maintainer.  

---
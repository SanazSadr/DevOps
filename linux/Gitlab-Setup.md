# Setup Gitlab-ce on Ubuntu

## Download gitlab-ce package

The first step is to download `.deb` file for gitlab

``` bash
wget https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bullseye/gitlab-ce_16.2.3-ce.0_amd64.deb/download.deb
```

> **Note:** This command is for gitlab-ce version 16.2.3. If you want other versions, use that versions url.

## Install gitlab-ce package

Now it's time to install `gitlab-ce_16.2.3-ce.0_amd64.deb`

```bash
dpkg -i gitlab-ce_16.2.3-ce.0_amd64.deb
```

If you saw this beautiful yellow fox, you can be sure that you've done everything right so far.

![GitLab-installed](assets/GitLab-installed.png)

## Time to make some changes

Edit `/etc/gitlab/gitlab.rb` and change `external_url` to your preferred URL.

```bash
vim /etc/gitlab/gitlab.rb

external_url "http://gitlab.sanaz.com"
```

After changing `/etc/gitlab/gitlab.rb`, you need to reconfigure gitlab:

```bash
gitlab-ctl reconfigure
```

For having access to the defined `external_url`, you need to add the URL to some files.

- `/etc/hosts` on linux

```bash
vim /etc/hosts

127.0.0.1 localhost
127.0.1.1 ubuntu-srv

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# [server ip] [URL]
192.168.211.132 gitlab.sanaz.com
```

- `/etc/hosts` on windows

Edit this file (`C:\Windows\System32\drivers\etc\hosts`) in Notepad++ and add `[server ip] [URL]` to it.

> **NOTE:** If it didn't allow you to save changes, copy the file on desktop, edit and then put it back in the `etc` folder.

For checking if you have done it right, run this command on both linux and windows

```bash
ping gitlab.sanaz.com
```

## Time to see what you have done

In your browser, either on windows or linux desktop, go to the URL that you set.

If you saw this page, be happy cause you have done a huge job :)

![Login-Page](assets/GitLab-login-page.png)

By default, a Linux package installation automatically generates a password for the initial administrator user account (`root`) and stores it to `/etc/gitlab/initial_root_password` for at least 24 hours. <br/>
For security reasons, after 24 hours, this file is automatically removed by the first `gitlab-ctl reconfigure`.

Check `root` password by this command:

```bash
cat /etc/gitlab/initial_root_password
```

To reset the `root` password, in the Preferences > Password.

![Preferences](assets/Preferences.png)

![Reset-Password](assets/Reset-Password.png)

Now everything is <span style="color: green">**Done**</span>, you can enjoy of what you have done.

## Source of content

[GitLab Docs](https://docs.gitlab.com)
---
layout: post
title: Add support for s390x and fix installation of conffiles in /etc/etc
category: BugFix

excerpt: Fix a bug in the installation of configuration files and add support for s390x

---

There was a bug in the dh install configuration file, that moved all
kernel-package conf files to /etc/etc/. This commit fixes that.
(Closes: #751751).

Jumped on a s390x porterbox, and created initial support for a s390x
architecture, based mostly on what we did for s390. (Closes: #750604).

See [detils here.](https://github.com/srivasta/kernel-package/commit/4132ee7b13441b3999c40d00bdadcd246fe78f58)

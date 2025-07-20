---
date: 2016-06-11 12:00:00 +0530
layout: post
title: "Installing Jekyll"
description: "jekyll-a blogging software"
categories: [blog]
tags: [jekyll,install]
---

### install pre-requisites

* install **curl**

	```
	sudo apt-get install curl
	```

* install **nodejs**

	>(if error - "javascript runtime error")

	```
	sudo apt-get install nodejs
	```

### install rvm & ruby
* download signatures :

	```
	curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
	```
* install **rvm** (_stable_) :

	```
	curl -sSL https://get.rvm.io | bash -s stable
	```

* set rvm environment :

	```
	source $HOME/.rvm/scripts/rvm
	```

* install required packages for Ruby :

  > _gawk, libreadline6-dev, zlib1g-dev, libssl-dev, libyaml-dev, libsqlite3-dev, sqlite3, autoconf, libgmp-dev, libgdbm-dev, libncurses5-dev, automake, libtool, bison, libffi-dev_

	```
	rvm requirements
	```

* install **ruby** (check latest version on [https://www.ruby-lang.org/en/](https://www.ruby-lang.org/en/))

	```
	rvm install 2.3.1
	```

	> if error :-

	```
	RVM is not a function, selecting rubies with 'rvm use ...' will not work.
	```

	> answer :- console is not running as a login shell so no access to rvm function.

	+ open terminal (ctrl + alt + t )
	+ _Edit_ -> _Profile Preferences_
	+ select tab: _Title and Command_
	+ check box _Run command as a login shell_
	+ restart terminal

* select rvm's default version :

	```
	rvm use 2.3.1 --default
	```

### install Jekyll

```
gem install jekyll
```

check version

```
jekyll -version
```

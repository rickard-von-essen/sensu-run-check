# Sensu Run Check

Often after just doing a change on servers you want to just be sure that they’re all going to pass a certain or all (Sensu)[http://sensuapp.org] checks. This gem exposes Sensu checks to be executed local on the command line.

_WARNING_ This is very much a hack and will break with other versions* of Sensu!

*) see the ```sensu-run-check.gemspec``` for the required version.

## Installation

Be sure to install it in the Sensu embedded ruby.

```
/opt/sensu/embedded/bin/gem install sensu-run-check
```

## Usage

Print the help

```
/opt/sensu/embedded/bin/sensu-run-check -h
```

List all checks defined on this host, you must point out your Sensu config file/dir.

```
/opt/sensu/embedded/bin/sensu-run-check -d /etc/sensu/conf.d -l
```

Run the _disk_ check.

```
/opt/sensu/embedded/bin/sensu-run-check -d /etc/sensu/conf.d -r disk
```

Run all checks defined on this host.

```
/opt/sensu/embedded/bin/sensu-run-check -d /etc/sensu/conf.d -R
```

# License

(c) 2015 - Rickard von Essen

Released under the MIT license, see LICENSE.txt

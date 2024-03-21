#!/usr/bin/env bash
set -e

rm -f /var/run/apache2/apache2.pid

APACHE_ARGUMENTS=-DFOREGROUND /usr/sbin/apachectl start

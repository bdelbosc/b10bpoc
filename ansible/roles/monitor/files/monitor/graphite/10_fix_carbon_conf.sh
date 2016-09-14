#!/bin/sh

perl -p -i -e 's/MAX_CREATES_PER_MINUTE\s*=.*/MAX_CREATES_PER_MINUTE = 1000/' /opt/graphite/conf/carbon.conf
perl -p -i -e 's/MAX_UPDATES_PER_SECOND\s*=.*/MAX_UPDATES_PER_SECOND = 1000/' /opt/graphite/conf/carbon.conf


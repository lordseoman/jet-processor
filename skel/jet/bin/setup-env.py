#!/usr/bin/env python

import os
import DNS

aws = False
fh = open("/home/jet/Jet/.env", 'w')
for name, value in os.environ.items():
    if name.startswith('SRV_') or name.startswith('JETOPT_'):
        fh.write("%s=%s\n" % (name, value))
    elif name == 'AWS_EXECUTION_ENV':
        aws = True

if aws:
    fh.write('AWS=true\n')

DNS.ParseResolvConf()
srv_req = DNS.Request(qtype = 'srv')
for name in ('filetracker',):
    key = 'JETOPT_' + name.upper() + '_IP'
    if key not in os.environ:
        srv_result = srv_req.req('%s.local.' % name)
        for result in srv_result.answers:
            if result['typename'] == 'SRV':
                fh.write('%s=%s\n' % (key, result['data'][3]))
                break

fh.flush()


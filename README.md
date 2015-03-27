About
=====

cc-cli is Command Line Interface(CLI) for [CloudConductor](https://github.com/cloudconductor/cloud_conductor).


Requirements
============

Prerequisites
-------------

- git
- ruby (>= 2.0.0)
- rubygems
- bundler

Quick Start
===========

### Clone github repository and install

```bash
git clone https://github.com/cloudconductor/cloud_conductor_cli.git
cd cloud_conductor_cli
bundle install
bundle exec rake install
export CC_AUTH_ID=[your_account_email]
export CC_AUTH_PASSWORD=[your_account_password]
```

### Show usage

```bash
cc-cli help
```

For more information, please visit [official user manual](http://cloudconductor.org/documents/user-manual/conductor-cli).

Copyright and License
=====================

Copyright 2014 TIS inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


Contact
========

For more information: <http://cloudconductor.org/>

Report issues and requests: <https://github.com/cloudconductor/cloud_conductor_cli/issues>

Send feedback to: <ccndctr@gmail.com>

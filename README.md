# ftp-deploy

Deploy your code using a list of files (diff-file)

# Options


* `destination` (required) Full FTP path to upload to. Should start with ftp:// and end with wwwroot or publib_html
* `username` (required) Username to connect to FTP server. _You must escape `\` and `$`, see example.
* `password` (required) Password to connect to FTP server
* `diff-file` A list of files (one filename in one row). Can be generated using step diff-output-in-cache (which is using command `git diff --name-status --staged | tee diff-file')

# Example

Add USERNAME and PASSWORD as deploy target or application environment variable. Use output-cache-diff step to generate diff-file

```yaml
build:
  steps:
    - duleorlovic/ftp-deploy:
        destination: ftp://waws-prod-blu-003.ftp.azurewebsites.windows.net/site/wwwroot
        username: test\\\$USERNAME
        password: $PASSWORD
        diff-file: $WERCKER_CACHE_DIR/output-cache-diff/diff-file

```

# License

The MIT License (MIT)

Copyright (c) 2013 wercker
With portions Copyright (c) 2014 duleorlovic

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Changelog


## 0.0.1

- Initial release

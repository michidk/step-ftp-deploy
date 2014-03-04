# ftp-deploy

Deploy your code using a list of files (diff-file)

# Options


* `destination` (required) Full FTP path to upload to. Should start with ftp:// and end with wwwroot or public_html
* `username` (required) Username to connect to FTP server.
* `password` (required) Password to connect to FTP server
* `diff-file` (optional, default is a @diff-file@) It is a list of files (one filename in one row) that should be uploaded or removed from `destination`. Can be generated using wercker step diff-output-in-cache. Each line should start with A, M or D for files that should be uploaded, removed and uploaded and removed, respectively. List can be genarated with `git diff --name-status`.

# Example

Add PASSWORD as environment variable.

```yaml
deploy:
  steps:
    - duleorlovic/ftp-deploy:
        destination: ftp://domain.example.com/site/public_html
        username: ftpusername
        password: $PASSWORD
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

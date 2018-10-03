# ftp-deploy

[![wercker status](https://app.wercker.com/status/060bb1a8a8d0d4f4e7d8d32482d73715/s/master "wercker status")](https://app.wercker.com/project/byKey/060bb1a8a8d0d4f4e7d8d32482d73715)

Deploy your files with FTP. It looks for list of files and their md5sum in **remote-file** and compare with local generated files. Any change of local files will be uploaded in this order:
1) Add all new files
2) Update all modified files
3) Delete all deleted files

If the order is different, active visitors of the website can see 404 pages because for example a modified file has an added menu item to a page which is not yet uploaded.
Another case is that a file is deleted before the files referring to it are updated.

# Options

* `destination` (required) Full FTP path to upload to. Should start with ftp:// and end with wwwroot or public_html
* `username` (required) Username to connect to FTP server.
* `password` (required) Password to connect to FTP server
* `remote-file` (optional, default is a *remote.txt*) It is a list of md5sum and filename (one filename in one row). It is should be kept synchronized with files. If it loses synchronization, simple remove all files from destination and they will be uploaded again and *remote.txt* regenerated.
* `timeout` (optional, default is 20) Since uploading large number of files may take a long time you can define TIMEOUT when to stop before wercker stops the script. 

# Example

Add PASSWORD as protected environment variable. Other options can be hardcoded.

```yaml
deploy:
  steps:
    - michidk/ftp-deploy:
        destination: ftp://domain.example.com/site/public_html
        username: ftpusername
        password: $PASSWORD
```

# License

The MIT License (MIT)

Copyright (c) 2013 wercker
With portions Copyright (c) 2014 duleorlovic and (c) 2018 Michael Lohr

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

# xmirror

```help
xmirror [-l mirrorlist] [-r rootdir]

Interactive script for changing XBPS mirrors

	-l	Use an alternative mirror list file. This should be a tab-separated
		value file with the columns: url, region, location, tier
		Default: /usr/share/xmirror/mirrors.lst
	-u	Use an alternative mirror list URL. This should be a url pointing
		to a mirror list file.
		Default: https://github.com/void-linux/xmirror/raw/master/mirrors.lst
	-r	Use an alternative rootdir. Acts similar to xbps's -r flag.

Copyright (c) 2023 classabbyamp, released under the BSD-2-Clause license
```

## Dependencies

**Build-time:**
- `make`
- `sed`
- `awk`
- `install`

**Runtime:**
- `bash`
- `dialog`
- `sed`
- `xbps`

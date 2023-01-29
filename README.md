# xmirror

```help
xmirror [-d] [-l mirrorlist] [-r rootdir] [-s mirrorurl] [-u listurl]

Script for changing XBPS mirrors

	-d	Reset the current mirror to the default, skipping the interactive TUI.
	-h	Show this help and exit.
	-l	Use an alternative mirror list file. This should be a tab-separated
		value file with the columns: region, url, location, tier.
		Default: /usr/share/xmirror/mirrors.lst
	-n	Don't attempt to update the mirror list.
	-r	Use an alternative rootdir. Acts similar to xbps's -r flag.
	-s	Set the current mirror to mirrorurl and exit, skipping the interactive TUI.
	-u	Use an alternative mirror list URL. This should be a url pointing
		to a mirror list file.
		Default: https://xmirror.voidlinux.org/raw/mirrors.lst
	-v	Show the version and exit.

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
- `find`
- `sed`
- `xbps`

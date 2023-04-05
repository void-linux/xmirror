complete -c xmirror -f

function __xmirror_complete_mirrors
    string match -vr '^\s*#' </usr/share/xmirror/mirrors.lst | while read -l line
        set -l values (string split \t -- $line)
        # Mirror url, location, and tier
        echo -- $values[2]\t$values[3], Tier $values[4]
    end
end

function __xmirror_no_interactive_opts
    not __fish_seen_argument -s l -l mirror-list -s n -l no-fetch
end

function __xmirror_no_noninteractive_opts
    not __fish_seen_argument -s d -l default -s s -l set
end

complete -c xmirror -s h -l help -d 'Display help and exit'
complete -c xmirror -s v -l version -d 'Display version and exit'
complete -c xmirror -s r -l rootdir -d 'Use alternative rootdir' -xa '(__fish_complete_directories)'
complete -c xmirror -n '__xmirror_no_noninteractive_opts' -s l -l mirror-list -d 'Use alternative mirror list file' -rF
complete -c xmirror -n '__xmirror_no_noninteractive_opts' -s n -l no-fetch -d "Don't update mirror list"
complete -c xmirror -n '__xmirror_no_interactive_opts' -s d -l default -d 'Reset current mirror to default'
complete -c xmirror -n '__xmirror_no_interactive_opts' -s s -l set -d 'Set current mirror' -kxa '(__xmirror_complete_mirrors)'

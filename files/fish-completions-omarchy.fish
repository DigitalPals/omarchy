# Completes `omarchy` subcommands from the omarchy-* binaries next to it.
function __omarchy_complete_subcommands
    set -l words (commandline -xpc)
    set -e words[1]

    set -l prefix omarchy
    for word in $words
        string match -q -- '-*' $word; and continue
        set prefix $prefix-$word
    end

    set -l bin_dir (path dirname (path resolve (command -s omarchy)))
    set -l binaries $bin_dir/$prefix-*
    test (count $words) -eq 0; and echo commands
    string replace -- "$bin_dir/$prefix-" '' $binaries | string replace -r -- '-.*$' '' | sort -u
end

complete -c omarchy -f -a '(__omarchy_complete_subcommands)'

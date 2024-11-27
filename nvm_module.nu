# Node Version Manager
#
# Note: <version> refers to any version-like string nvm understands. This includes:
#   - full or partial version numbers, starting with an optional "v" (0.10, v0.1.2, v1)
#   - default (built-in) aliases: node, stable, unstable, iojs, system
#   - custom aliases you define with `nvm alias foo`
#
# Example:
#   nvm install 8.0.0                     Install a specific version number
#   nvm use 8.0                           Use the latest available 8.0.x release
#   nvm run 6.10.3 app.js                 Run app.js using node 6.10.3
#   nvm exec 4.8.3 node app.js            Run `node app.js` with the PATH pointing to node 4.8.3
#   nvm alias default 8.1.0               Set default node version on a shell
#   nvm alias default node                Always default to the latest available node version on a shell
#
#   nvm install node                      Install the latest available version
#   nvm use node                          Use the latest version
#   nvm install --lts                     Install the latest LTS version
#   nvm use --lts                         Use the latest LTS version
#
# Note:
#   to remove, delete, or uninstall nvm - just remove the `$NVM_DIR` folder (usually `~/.nvm`)
#
export def nvm [
    --version (-v) # Print out the installed version of nvm
] {
    if $version {
        nvm_echo "0.39.7"
        return
    }
}

export def "nvm cache dir" [] {
    error make { msg: "Not Implemented" }
}

export def "nvm cache clear" [] {
    error make { msg: "Not Implemented" }
}

export def "nvm debug" [] {
    error make { msg: "Not Implemented" }
}

# Download and install a <version>. Uses .nvmrc if available and version is omitted.
export def "nvm install" [
    -s                                # Skip binary download, install from source only.
    -b                                # Skip source download, install from binary only.
    --reinstall-packages-from: string # When installing, reinstall packages installed in <node|iojs|node version number>
    --lts                             # When installing, only select from LTS (long-term support) versions'
    --lts: string                     # When installing, only select from versions for a specific LTS line'
    --skip-default-packages           # When installing, skip the default-packages file if it exists'
    --latest-npm                      # After installing, attempt to upgrade to the latest working npm on the given node version'
    --no-progress                     # Disable the progress bar on any downloads'
    --alias: string                   # After installing, set the alias specified to the version specified. (same as: nvm alias <name> <version>)'
    --default                         # After installing, set default alias to the version specified. (same as: nvm alias default <version>)'
] {
    error make { msg: "Not implemented" }
}

export alias i = install

# Uninstall a version
export def "nvm uninstall" [
    version: string # The version number
    --lts           # Uninstall using automatic LTS (long-term support) alias `lts/*`, if available.'
    --lts: string   # Uninstall using automatic alias for provided LTS line, if available.'
] {
    error make { msg: "Not implemented" }
}

# Undo effects of `nvm` on current shell
export def "nvm deactivate" [
    --silent # Silences stdout/stderr output
] {
    error make {msg: "Not implemented" }
}

# Modify PATH to use <version>. Uses .nvmrc if available and version is omited.
export def "nvm use" [
    ...rest: string
    --silent      # Silences stdout/stderr output
    --lts: string # Uses automatic alias for provided LTS line, if available.'
] {
    mut version = ""

    if $lts != "" {
        $version = $"lts/($lts)"
    }

    $version

    error make {msg: "Not implemented" }
}

export def "nvm run" [] {
    error make { msg: "Not implemented" }
}

export def "nvm exec" [] {
    error make { msg: "Not implemented" }
}

export def "nvm list" [
    pattern: string = ""
    --no-alias
    --no-colors
] {
    if ($pattern != "") and ($no_alias) {
        error make {
            msg: "nvm failed", 
            label: {
                text: "`--no-alias` is not supported when a pattern is provided."
                span: (metadata $no_alias).span
            }
        }
    }

    let NVM_LS_OUTPUT = (nvm_ls $pattern)
    nvm_print_versions --no-colors=$no_colors
}

export alias ls = list

export def "nvm list-remote" [] {
    error make { msg: "not implemented" }
}

export alias ls-remote = list-remote

# Display currently activated version of Node
export def "nvm current" [] {
    nvm_version current
}

export def "nvm which" [] {
    error make { msg: "Not implemented" }
}

export def "nvm alias" [] {
    error make { msg: "Not implemented" }
}

export def "nvm unalias" [] {
    error make { msg: "Not implemented" }
} 

export def "nvm install-latest-npm" [] {
    error make { msg: "Not implemented" }
}

export def "nvm reinstall-packages" [] {
    error make { msg: "Not implemented" }
}

export alias copy-packages = reinstall-packages

export def "nvm clear-cache" [] {
    error make { msg: "Not implemented" }
}

export def "nvm version" [] {
    error make { msg: "Not implemented" }
}

export def "nvm version-remote" [] {
    error make { msg: "Not implemented" }
}

export def "nvm unload" [] {
    error make { msg: "Not implemented" }
}

export def "nvm set-colors" [] {
    error make { msg: "Not implemented" }
}

export-env {
    $env.NVM_DIR = $env.FILE_PWD
}

def nvm_is_zsh [] {
    return (($env | get "ZSH_VERSION"?) != "")
}

def --env --wrapped nvm_cd [...rest: string]: string -> bool {
    ^cd ...$rest
}

def --wrapped nvm_grep [...rest: string] {
    GREP_OPTIONS='' command grep $rest
}

def nvm_has [any: string] {
    ^type $any out> /dev/null err> /dev/fd/1
}

def nvm_has_non_aliased [any: string = ""] {
    return ((nvm_has $any) and not (nvm_is_alias $any))
}

def --env nvm_has_alias [any: string = ""] {
    ^alias $any out> /dev/null err> /dev/fd/1

    return $env.LAST_EXIT_CODE
}

def nvm_command_info [command: string] {
    mut INFO = ""

    if (^type $command | nvm_grep -q hashed) {
        $INFO = (^type $command | command sed -E 's/\(|\)//g' | command awk '{print $4}')
    } else if (^type $command | nvm_grep -q aliased) {
        $INFO = ^type $command | command awk '{ $1=$2=$3=$4="" ;print }' | command sed -e 's/^\\ *//g' -Ee "s/\\`|'//g" | $"(^which $command) ($in)"
    } else if (^type $command | nvm_grep -q $"^($command) is an alias for") {
        $INFO = ^type $command | command awk '{ $1=$2=$3=$4=$5="" ;print }' | command sed -e 's/^\\ *//g' | $"(^which $command) ($in)"
    } else if (^type $command | nvm_grep -q $"^($command) is /") {
        $INFO = ^type $command | command awk '{print $3}'
    } else {
        $INFO = $"(^type $command)"
    }

    nvm_echo $"($INFO)"
}

def --env nvm_has_colors [] {
    mut NVM_NUM_COLORS = -1

    if (nvm_has tput) {
        $NVM_NUM_COLORS = $env | get --ignore-errors TERM | default 'vt100' | tput -T $in colors
    }

    return ($NVM_NUM_COLORS >= 8)
}

def --env nvm_curl_libz_support [] {
    curl -V err> /dev/null | nvm_grep "^Features:" | nvm_grep -q "libz"

    return ($env.LAST_EXIT_CODE == 0)
}

def nvm_curl_use_compression [] {
    return ((nvm_curl_libz_support) and (nvm_version_greater_than_or_equal_to $"(nvm_curl_version)" 7.21.0))
}

def nvm_get_latest [] {
    mut NVM_LATEST_URL = ""
    mut CURL_COMPRESSED_FLAG = ""

    if (nvm_has "curl") {
        if nvm_curl_use_compression {
            $CURL_COMPRESSED_FLAG = "--compressed"
        }

        $NVM_LATEST_URL = (curl $CURL_COMPRESSED_FLAG -q -w "%{url_effective}\\n" -L -s -S https://latest.nvm.sh -o /dev/null)
    } else if (nvm_has "wget") {
        $NVM_LATEST_URL = (wget -q https://latest.nvm.sh --server-response -O /dev/null err> /dev/fd/1 | command awk '/^  Location: /{DEST=$2} END{ print DEST }')
    } else {
        nvm_err 'nvm needs curl or wget to proceed.'
        return 1
    }

    if $NVM_LATEST_URL == "" {
        nvm_err "https://latest.nvm.sh did not redirect to the latest release on GitHub"
        return 2
    }

    nvm_echo $"($NVM_LATEST_URL | str substring ($in | str index-of -e "/" | $in + 1)..-1)"
}

def nvm_download [...rest: string] {

    mut CURL_COMPRESSED_FLAG = ""

    if (nvm_has "curl") {
        if nvm_curl_use_compression {
            $CURL_COMPRESSED_FLAG = "--compressed"
        }

        curl --fail $CURL_COMPRESSED_FLAG -q ...$rest
    } else if (nvm_has "wget") {
        # Emulate curl with wget
        let ARGS = nvm_echo ...$rest | command sed -e 's/--progress-bar /--progress=bar /' -e 's/--compressed //' -e 's/--fail //' -e 's/-L //' -e 's/-I /--server-response /' -e 's/-s /-q /' -e 's/-sS /-nv /' -e 's/-o /-O /' -e 's/-C - /-c /'
        # shellcheck disable=SC2086
        eval wget $ARGS
    }
}

def nvm_has_system_node [] {
    return ($"((deactivate out> /dev/null) and (command -v node))" != "")
}

def nvm_has_system_iojs [] {
    return ($"((deactivate out> /dev/null) and (command -v iojs))" != "")
}

def nvm_is_version_installed [
    version: string = ""
] {
    if $version == "" {
        return false
    }

    mut NVM_NODE_BINARY = 'node'
    if $"_(nvm_get_os)" == '_win' {
        $NVM_NODE_BINARY = 'node.exe'
    }
    if ($"(nvm_version_path $version err> /dev/null)/bin/($NVM_NODE_BINARY)" | $in == "file") {
        return true
    }

    return false
}

def nvm_print_npm_version [] {
    if (nvm_has "npm") {
        let NPM_VERSION = (npm --version err> /dev/null)

        if $NPM_VERSION != "" {
            command printf $" \(npm v($NPM_VERSION)\)"
        }
    }
}

def --env nvm_install_latest_npm [] {
    nvm_echo "Attempting to upgrade to the latest working version of npm..."
    mut NODE_VERSION = (nvm_strip_iojs_prefix $"(nvm_ls_current)")
    mut NPM_VERSION = (npm --version err> /dev/null)

    if $NPM_VERSION == "" {
        nvm_err "Unable to obtain npm version."
        return 2
    }

    if $NODE_VERSION == "system" {
        $NODE_VERSION = (node --version)
    } else if $NODE_VERSION == "none" {
        nvm_echo $"Detected node version ($NODE_VERSION), npm version v($NPM_VERSION)"
        $NODE_VERSION = ""
    }

    if $NODE_VERSION == "" {
        nvm_err "Unable to obtain node version"
        return 1
    }

    mut NVM_NPM_CMD = 'npm'

    if ($env | get --ignore-errors "NVM_DEBUG" | default 0 | $in == 1) {
        nvm_echo $"Detected node version ($NODE_VERSION), npm version v($NPM_VERSION)"
        $NVM_NPM_CMD = 'nvm_echo npm'
    }

    mut NVM_IS_0_6 = 0
    if ((nvm_version_greater_than_or_equal_to $NODE_VERSION 0.6.0) and (nvm_version_greater 0.7.0 $NODE_VERSION)) {
        $NVM_IS_0_6 = 1
    }

    mut NVM_IS_0_9 = 0
    if ((nvm_version_greater_than_or_equal_to $NODE_VERSION 0.9.0) and (nvm_version_greater 0.10.0 $NODE_VERSION)) {
        $NVM_IS_0_9 = 1
    }

    if ($NVM_IS_0_6 == 1) {
        nvm_echo "* `node` v0.6.x can only upgrade to `npm` v1.3.x"
        ^$NVM_NPM_CMD install -g npm@1.3
    } else if ($NVM_IS_0_9 == 0) {
        # node 0.9 breaks here, for some reason
        if (nvm_version_greater_than_or_equal_to $NPM_VERSION 1.0.0) and (nvm_version_greater 2.0.0 $NPM_VERSION) {
            nvm_echo '* `npm` v1.x needs to first jump to `npm` v1.4.28 to be able to upgrade further'
            ^$NVM_NPM_CMD install -g npm@1.4.28
        } else if (nvm_version_greater_than_or_equal_to $NPM_VERSION 2.0.0) and (nvm_version_greater 3.0.0 $NPM_VERSION) {
            nvm_echo '* `npm` v2.x needs to first jump to the latest v2 to be able to upgrade further'
            ^$NVM_NPM_CMD install -g npm@2
        }
    }

    if ($NVM_IS_0_9 == 1) or ($NVM_IS_0_6 == 1) {
        nvm_echo '* node v0.6 and v0.9 are unable to upgrade further'
    } else if (nvm_version_greater 1.1.0 $NODE_VERSION) {
        nvm_echo '* `npm` v4.5.x is the last version that works on `node` versions < v1.1.0'
        ^$NVM_NPM_CMD install -g npm@4.5
    } else if (nvm_version_greater 4.0.0 $NODE_VERSION) {
        nvm_echo '* `npm` v5 and higher do not work on `node` versions below v4.0.0'
        ^$NVM_NPM_CMD install -g npm@4
    } else if ($NVM_IS_0_9 == 0) and ($NVM_IS_0_6 == 0) {
        mut NVM_IS_4_4_OR_BELOW = 0
        if (nvm_version_greater 4.5.0 $NODE_VERSION) {
            $NVM_IS_4_4_OR_BELOW = 1
        }

        mut NVM_IS_5_OR_ABOVE = 0
        
        if ($NVM_IS_4_4_OR_BELOW == 0) and (nvm_version_greater_than_or_equal_to $NODE_VERSION 5.0.0) {
            $NVM_IS_5_OR_ABOVE = 1
        }

        mut NVM_IS_6_OR_ABOVE = 0
        mut NVM_IS_6_2_OR_ABOVE = 0

        if ($NVM_IS_5_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION 6.0.0) {
            $NVM_IS_6_OR_ABOVE = 1

            if (nvm_version_greater_than_or_equal_to $NODE_VERSION 6.2.0) {
                $NVM_IS_6_2_OR_ABOVE = 1
            }
        }

        mut NVM_IS_9_OR_ABOVE = 0
        mut NVM_IS_9_3_OR_ABOVE = 0
        if ($NVM_IS_6_2_OR_ABOVE == 1 ) and (nvm_version_greater_than_or_equal_to $NODE_VERSION 9.0.0) {
        	$NVM_IS_9_OR_ABOVE = 1
            if (nvm_version_greater_than_or_equal_to $NODE_VERSION 9.3.0) {
                $NVM_IS_9_3_OR_ABOVE = 1
            }
        }

        mut NVM_IS_10_OR_ABOVE = 0
        if ($NVM_IS_9_3_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_10_OR_ABOVE = 1
        }
        mut NVM_IS_12_LTS_OR_ABOVE = 0
        if ($NVM_IS_10_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_12_LTS_OR_ABOVE = 1
        }
        mut NVM_IS_13_OR_ABOVE = 0
        if ($NVM_IS_12_LTS_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_13_OR_ABOVE = 1
        }
        mut NVM_IS_14_LTS_OR_ABOVE = 0
        if ($NVM_IS_13_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_14_LTS_OR_ABOVE = 1
        }
        mut NVM_IS_14_17_OR_ABOVE = 0
        if ($NVM_IS_14_LTS_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_14_17_OR_ABOVE = 1
        }
        mut NVM_IS_15_OR_ABOVE = 0
        if ($NVM_IS_14_LTS_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_15_OR_ABOVE = 1
        }
        mut NVM_IS_16_OR_ABOVE = 0
        if ($NVM_IS_15_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_16_OR_ABOVE = 1
        }
        mut NVM_IS_16_LTS_OR_ABOVE = 0
        if ($NVM_IS_16_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_16_LTS_OR_ABOVE = 1
        }
        mut NVM_IS_17_OR_ABOVE = 0
        if ($NVM_IS_16_LTS_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_17_OR_ABOVE = 1
        }
        mut NVM_IS_18_OR_ABOVE = 0
        if ($NVM_IS_17_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_18_OR_ABOVE = 1
        }
        mut NVM_IS_18_17_OR_ABOVE = 0
        if ($NVM_IS_18_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_18_17_OR_ABOVE = 1
        }
        mut NVM_IS_19_OR_ABOVE = 0
        if ($NVM_IS_18_17_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_19_OR_ABOVE = 1
        }
        mut NVM_IS_20_5_OR_ABOVE = 0
        if ($NVM_IS_19_OR_ABOVE == 1) and (nvm_version_greater_than_or_equal_to $NODE_VERSION) {
        	$NVM_IS_20_5_OR_ABOVE = 1
        }

        if ($NVM_IS_4_4_OR_BELOW == 1) or (($NVM_IS_5_OR_ABOVE == 1) and (nvm_version_greater 5.10.0 $NODE_VERSION)) {
            nvm_echo '* `npm` `v5.3.x` is the last version that works on `node` 4.x versions below v4.4, or 5.x versions below v5.10, due to `Buffer.alloc`'
            ^$NVM_NPM_CMD install -g npm@5.3
        } else if ($NVM_IS_4_4_OR_BELOW == 0) and (nvm_version_greater 4.7.0 $NODE_VERSION) {
        nvm_echo '* `npm` `v5.4.1` is the last version that works on `node` `v4.5` and `v4.6`'
        ^$NVM_NPM_CMD install -g npm@5.4.1
        } else if ($NVM_IS_6_OR_ABOVE == 0) {
        nvm_echo '* `npm` `v5.x` is the last version that works on `node` below `v6.0.0`'
        ^$NVM_NPM_CMD install -g npm@5
        } else if (($NVM_IS_6_OR_ABOVE == 1) and ($NVM_IS_6_2_OR_ABOVE == 0)) or (($NVM_IS_9_OR_ABOVE == 1) and ($NVM_IS_9_3_OR_ABOVE == 0)) {
            nvm_echo '* `npm` `v6.9` is the last version that works on `node` `v6.0.x`, `v6.1.x`, `v9.0.x`, `v9.1.x`, or `v9.2.x`'
            ^$NVM_NPM_CMD install -g npm@6.9
        } else if ($NVM_IS_10_OR_ABOVE == 0) {
            if (nvm_version_greater 4.4.4 "${NPM_VERSION}") {
                nvm_echo '* `npm` `v4.4.4` or later is required to install npm v6.14.18'
                ^$NVM_NPM_CMD install -g npm@4
            }

            nvm_echo '* `npm` `v6.x` is the last version that works on `node` below `v10.0.0`'
            ^$NVM_NPM_CMD install -g npm@6
        } else if ($NVM_IS_12_LTS_OR_ABOVE == 0) or (($NVM_IS_13_OR_ABOVE == 1) and ($NVM_IS_14_LTS_OR_ABOVE == 0)) or (($NVM_IS_15_OR_ABOVE == 1) and ($NVM_IS_16_OR_ABOVE == 0)) {
            nvm_echo '* `npm` `v7.x` is the last version that works on `node` `v13`, `v15`, below `v12.13`, or `v14.0` - `v14.15`'
            ^$NVM_NPM_CMD install -g npm@7
        } else if (($NVM_IS_12_LTS_OR_ABOVE == 1) and ($NVM_IS_13_OR_ABOVE == 0)) or (($NVM_IS_14_LTS_OR_ABOVE == 1) and ($NVM_IS_14_17_OR_ABOVE == 0)) or (($NVM_IS_16_OR_ABOVE == 1) and ($NVM_IS_16_LTS_OR_ABOVE == 0)) or (($NVM_IS_17_OR_ABOVE == 1) and ($NVM_IS_18_OR_ABOVE == 0)) {
            nvm_echo '* `npm` `v8.x` is the last version that works on `node` `v12`, `v14.13` - `v14.16`, or `v16.0` - `v16.12`'
            ^$NVM_NPM_CMD install -g npm@8
        } else if ($NVM_IS_18_17_OR_ABOVE == 0) or (($NVM_IS_19_OR_ABOVE == 1) and ($NVM_IS_20_5_OR_ABOVE == 0)) {
            nvm_echo '* `npm` `v9.x` is the last version that works on `node` `< v18.17`, `v19`, or `v20.0` - `v20.4`'
            ^$NVM_NPM_CMD install -g npm@9
        } else {
            nvm_echo '* Installing latest `npm`; if this does not work on your node version, please report a bug!'
            ^$NVM_NPM_CMD install -g npm
        }
    }
    nvm_echo $"* npm upgraded to: v(npm --version err> /dev/null)"
}

def nvm_tree_contains_path [
    tree: string = ""
    node_path: string = ""
] {
    if ($"@($tree)@" == "@@") or ($"@($node_path)@" == "@@") {
        return 2
    }

    mut previous_pathdir = $node_path
    mut pathdir = (dirname $previous_pathdir)

    while ($pathdir != "" and $pathdir != "." and $pathdir != "/" and $pathdir != $tree and $pathdir != $previous_pathdir) {
        $previous_pathdir = $pathdir
        $pathdir = (dirname $previous_pathdir)
    }

    return ($pathdir == $tree)
}

def --env nvm_find_project_dir [] {
    mut path_ = $env.PWD

    while ($path_ != "" and $path_ != "." and not ($"($path_)/package.json" | path type | $in == "file") and not ($"($path_)/node_modules" | path type | $in == "dir")) {
        $path_ = $path_ | str substring 0..(($in | str reverse | str index-of '/' | $in * -1 - 2))
    }

    nvm_echo $path_
}

def --env nvm_find_up [file: string = ""] {
    mut path_ = $env.PWD

    while ($path_ != "" and $path_ != "." and not ($"($path_)/($file)" | path type | $in == "file")) {
        $path_ = $path_ | str substring 0..(($in | str reverse | str index-of '/' | $in * -1 - 2))
    }

    nvm_echo $path_
}

def nvm_find_nvmrc [] {
    let dir = nvm_find_up '.nvmrc'

    if ($"($dir)/.nvmrc" | (path type | $in == "file") and ($in | path exists)) {
        nvm_echo $"($dir)/.nvmrc"
    }
}

def --env nvm_rc_version [
    --silent
] {
    $env.NVM_RC_VERSION = ''

    let NVMRC_PATH = nvm_find_nvmrc

    if not ($NVMRC_PATH | path exists) {
       if not $silent {
        nvm_err "No .nvmrc file found"
       }
       return 1
    }

    $env.NVM_RC_VERSION = (command head -n 1 $NVMRC_PATH | command tr -d '\r')

    if $env.LAST_EXIT_CODE != 0 {
        $env.NVM_RC_VERSION = ''
    }

    if $env.NVM_RC_VERSION == "" {
        if not $silent {
            nvm_echo $"Found '($NVMRC_PATH)' with version <($env.NVM_RC_VERSION)>"
        }
    }
}

def nvm_clang_version [] {
    return (clang --version | command awk '{ if ($2 == "version") print $3; else if ($3 == "version") print $4 }' | command sed 's/-.*$//g')
}

def nvm_curl_version [] {
    return (curl -V | command awk '{ if ($1 == "curl") print $2 }' | command sed 's/-.*$//g')
}

def --env nvm_version_greater [
    arg1: string = ""
    arg2: string = ""
] {
    let arg1_trimmed = $arg1 | str trim --left -c "v"
    let arg2_trimmed = $arg2 | str trim --left -c "v"

    command AWK 'BEGIN {
        if (ARGV[1] == "" || ARGV[2] == "") exit(1)
        split(ARGV[1], a, /\./);
        split(ARGV[2], b, /\./);
        for (i=1; i<=3; i++) {
        if (a[i] && a[i] !~ /^[0-9]+$/) exit(2);
        if (b[i] && b[i] !~ /^[0-9]+$/) { exit(0); }
        if (a[i] < b[i]) exit(3);
        else if (a[i] > b[i]) exit(0);
        }
        exit(4)
    }' $arg1_trimmed $arg2_trimmed

    return ($env.LAST_EXIT_CODE == 0)
}

def --env nvm_version_greater_than_or_equal_to [
    arg1: string = ""
    arg2: string = ""
] {
    let arg1_trimmed = $arg1 | str trim --left -c "v"
    let arg2_trimmed = $arg2 | str trim --left -c "v"

    command AWK 'BEGIN {
        if (ARGV[1] == "" || ARGV[2] == "") exit(1)
        split(ARGV[1], a, /\./);
        split(ARGV[2], b, /\./);
        for (i=1; i<=3; i++) {
        if (a[i] && a[i] !~ /^[0-9]+$/) exit(2);
        if (a[i] < b[i]) exit(3);
        else if (a[i] > b[i]) exit(0);
        }
        exit(0)
    }' $arg1_trimmed $arg2_trimmed

    return ($env.LAST_EXIT_CODE == 0)
}

def --env nvm_version_dir [
    dir: string = ""
] {
    if ($dir == "") or ($dir == "new") {
        return $"($env.NVM_DIR)/versions/node"
    } else if ($"_($dir)" == "_iojs") {
        return $"($env.NVM_DIR)/versions/io.js"
    } else if ($"_($dir)" == "_old") {
        return $env.NVM_DIR
    } else {
        error make {
            msg: "[INTERNAL] nvm failed",
            label: {
                text: "unknown version dir",
                span: (metadata $dir).span
            }
        }
    }
}

def nvm_alias_path [] {
    return $"(nvm_version_dir old)/alias"
}

def nvm_version_path [
    version: string = ""
] {
    if $version == "" {
        nvm_err "version is required"
        return 3
    } else if (nvm_is_iojs_version $version) {
        nvm_echo $"(nvm_version_dir iojs)/(nvm_strip_iojs_prefix $version)"
    } else if (nvm_version_greater 0.12.0 $version) {
        nvm_echo $"(nvm_version_dir old)/($version)"
    } else {
        nvm_echo $"(nvm_version_dir new)/($version)"
    }
}

def --env nvm_ensure_version_installed [
    provided_version: string = ""
    is_version_from_nvmrc: bool = false
] {
    if $provided_version == "system" {
        if (nvm_has_system_iojs) or (nvm_has_system_node) {
            return 0
        }
        nvm_err "N/A: no system version of node/io.js is installed."
        return 1
    }

    let LOCAL_VERSION = (nvm_version $provided_version)
    let EXIT_CODE = $env.LAST_EXIT_CODE

    if ($EXIT_CODE != "0") or not (nvm_is_version_installed $LOCAL_VERSION) {
         nvm_resolve_alias $provided_version
    }
}

def nvm_version [
    pattern: string = ""
] {
    mut version = ""

    if $pattern == "current" {
        print (nvm_ls_current)
        return
    }

    let NVM_NODE_PREFIX = nvm_node_prefix

    let $pattern = match $pattern {
        ($"_($NVM_NODE_PREFIX)" | $"_($NVM_NODE_PREFIX)-") => "stable"
        _ => ""
    }

    $version = (nvm_ls $pattern | command tail -1)

    if ($version == "") or ($"_($version)" == "_N/A") {
        nvm_echo "N/A"
        return 3
    }

    nvm_echo $version
}

def --env nvm_ls_current [] {
    let nvm_ls_current_node_path = (which node | get --ignore-errors path.0)

    if $nvm_ls_current_node_path == "" {
        return "none"
    } else if ((nvm_tree_contains_path (nvm_version_dir iojs) $nvm_ls_current_node_path) == 0) {
        iojs --version err>| ignore | nvm_add_iojs_prefix
    } else if ((nvm_tree_contains_path $env.NVM_DIR $nvm_ls_current_node_path) == 0) {
        let VERSION = (node --version err>| ignore)
        if $VERSION == "v0.6.21-pre" {
            return "v0.6.21"
        } else {
            if $VERSION == "" {
                return "none"
            } else {
                return $VERSION
            }
        }
    } else {
        return "system"
    }
}

def nvm_resolve_alias [
    pattern: string = ""
] {
    if $pattern == "" {
        return 1
    }

    mut ALIAS = $pattern
    mut SEEN_ALIASES = $ALIAS
    mut NVM_ALIAS_INDEX = 1

    mut ALIAS_TEMP = ""

    while true {
        $ALIAS_TEMP = ((nvm_alias $ALIAS err> /dev/null | command head -n $NVM_ALIAS_INDEX | command tail -n 1) or (""))

        if $ALIAS_TEMP == "" {
            break
        }

        if (command printf $SEEN_ALIASES | nvm_grep -q -e $"^($ALIAS_TEMP)$") {
            $ALIAS = "∞"
            break
        }

        $SEEN_ALIASES = $"($SEEN_ALIASES)\\n($ALIAS_TEMP)"
        $ALIAS = $ALIAS_TEMP
    }

    if ($ALIAS != "") and ($"_($ALIAS)" != $"_($pattern)") {
        let NVM_IOJS_PREFIX = (nvm_iojs_prefix)
        let NVM_NODE_PREFIX = (nvm_node_prefix)

        if ($ALIAS == "∞") or ($ALIAS == $NVM_IOJS_PREFIX) or ($ALIAS == $NVM_NODE_PREFIX) or ($ALIAS == $"($NVM_IOJS_PREFIX)-") {
            nvm_echo $ALIAS
        } else {
            nvm_ensure_version_prefix $ALIAS
        }

        return 0
    }

    if (nvm_validate_implicit_alias $pattern err> /dev/null) {
        let IMPLICIT = (nvm_print_implicit_alias local $pattern err> /dev/null)

        if ($IMPLICIT != "") {
            nvm_ensure_version_prefix $IMPLICIT
        }
    }

    return 2
}

def --env nvm_resolve_local_alias [any: string = ""] {
    if $any == "" {
        return 1
    }

    let VERSION = (nvm_resolve_alias $any)
    let EXIT_CODE = $env.LAST_EXIT_CODE

    if $VERSION == "" {
        return $EXIT_CODE
    }

    if $"_($VERSION)" == "_∞" {
        nvm_version $VERSION
    } else {
        nvm_echo $VERSION
    }
}

def nvm_node_prefix [] {
    return "node"
}

def nvm_iojs_prefix [] {
    return "iojs"
}

def nvm_add_iojs_prefix [any: string = ""] {
    return $"(nvm_iojs_prefix)-(nvm_ensure_version_prefix $"(nvm_strip_iojs_prefix $any)")"
}

def nvm_ensure_version_prefix [any: string] {
    let nvm_version = nvm_strip_iojs_prefix $any | command sed -e 's/^\([0-9]\)/v\1/g'

    if (nvm_is_iojs_version $any) {
        return (nvm_add_iojs_prefix $nvm_version)
    } else {
        return $nvm_version
    }
}

def nvm_strip_iojs_prefix [any: string]: string -> string {
    let NVM_IOJS_PREFIX = nvm_iojs_prefix

    if $any == $NVM_IOJS_PREFIX {
        return ""
    } else {
        if ($any | str starts-with $NVM_IOJS_PREFIX) {
            return $any | str substring ($NVM_IOJS_PREFIX | str length)..-1
        } else {
            return $any
        }
    }
}

def nvm_ls [
    $pattern: string = ""
] {
    if $pattern == "current" {
        print (nvm_ls_current)
        return
    }

    let NVM_IOJS_PREFIX = nvm_iojs_prefix
    let NVM_NODE_PREFIX = nvm_node_prefix
    let NVM_VERSION_DIR_IOJS = (nvm_version_dir $NVM_IOJS_PREFIX)
    let NVM_VERSION_DIR_NEW = (nvm_version_dir new)
    let NVM_VERSION_DIR_OLD = (nvm_version_dir old)

    mut $PATTERN = ""
    if (($PATTERN == $NVM_IOJS_PREFIX) or ($PATTERN == $NVM_NODE_PREFIX)) {
        $PATTERN = $"($pattern)-"
    } else {
        if ((nvm_resolve_local_alias $pattern) != 0) {
            return
        }

        $PATTERN = (nvm_ensure_version_prefix $pattern)
    }

    if $PATTERN == "N/A" {
        return
    }

    let NVM_PATTERN_STARTS_WITH_V = $PATTERN | str starts-with "v"

    mut VERSIONS = ""
    mut NVM_ADD_SYSTEM = false

    if ($NVM_PATTERN_STARTS_WITH_V) and ( $"_(nvm_num_version_groups $PATTERN)" == "_3" ) {
        if (nvm_is_version_installed $PATTERN) {
            $VERSIONS = $PATTERN
        } else if (nvm_is_version_installed (nvm_add_iojs_prefix $PATTERN)) {
            $VERSIONS = (nvm_add_iojs_prefix $PATTERN)
        }
    } else {
        if not (($PATTERN == $"($NVM_IOJS_PREFIX)-") or ($PATTERN == $"($NVM_NODE_PREFIX)-") or ($PATTERN == "system")) {
            let NUM_VERSION_GROUPS = (nvm_num_version_groups $PATTERN)

            if ($NUM_VERSION_GROUPS == "2") or ($NUM_VERSION_GROUPS == "1") {
                $PATTERN = ($PATTERN | str trim --right --char "." | $in + ".")
            }
        }

        mut NVM_DIRS_TO_SEARCH1 = ""
        mut NVM_DIRS_TO_SEARCH2 = ""
        mut NVM_DIRS_TO_SEARCH3 = ""

        if (nvm_is_iojs_version $PATTERN) {
            $NVM_DIRS_TO_SEARCH1 = $NVM_VERSION_DIR_IOJS
            $PATTERN = (nvm_strip_iojs_prefix $PATTERN)
            if (nvm_has_system_iojs) {
                $NVM_ADD_SYSTEM = true
            }
        } else if ($PATTERN == $"($NVM_NODE_PREFIX)-") {
            $NVM_DIRS_TO_SEARCH1 = $NVM_VERSION_DIR_OLD
            $NVM_DIRS_TO_SEARCH2 = $NVM_VERSION_DIR_NEW
            $PATTERN = ""
            if nvm_has_system_node {
                $NVM_ADD_SYSTEM = true
            }
        } else {
            $NVM_DIRS_TO_SEARCH1 = $NVM_VERSION_DIR_OLD
            $NVM_DIRS_TO_SEARCH2 = $NVM_VERSION_DIR_NEW
            $NVM_DIRS_TO_SEARCH3 = $NVM_VERSION_DIR_IOJS

            if (nvm_has_system_iojs) or (nvm_has_system_node) {
                $NVM_ADD_SYSTEM = true
            }
        }

        if ($NVM_DIRS_TO_SEARCH1 | path type | $in != "dir") or not (command ls -1qA $NVM_DIRS_TO_SEARCH1 | nvm_grep -q .) {
            $NVM_DIRS_TO_SEARCH1 = ""
        }
        if ($NVM_DIRS_TO_SEARCH2 | path type | $in != "dir") or not (command ls -1qA $NVM_DIRS_TO_SEARCH2 | nvm_grep -q .) {
            $NVM_DIRS_TO_SEARCH2 = $NVM_DIRS_TO_SEARCH1
        }
        if ($NVM_DIRS_TO_SEARCH3 | path type | $in != "dir") or not (command ls -1qA $NVM_DIRS_TO_SEARCH3 | nvm_grep -q .) {
            $NVM_DIRS_TO_SEARCH3 = $NVM_DIRS_TO_SEARCH2
        }

        let SEARCH_PATTERN = match $PATTERN {
            "" => '.*'
            _ => (nvm_echo $PATTERN | command sed 's#\.#\\\.#g;')
        }

        if $PATTERN == "" {
            $PATTERN = "v"
        }

        if ($"($NVM_DIRS_TO_SEARCH1)($NVM_DIRS_TO_SEARCH2)($NVM_DIRS_TO_SEARCH3)" != "") {
            $VERSIONS = ((command find $"($NVM_DIRS_TO_SEARCH1)/*" $"($NVM_DIRS_TO_SEARCH2)/*" $"($NVM_DIRS_TO_SEARCH3)/*" -name . -o -type d -prune -o -path $"($PATTERN)*") | command sed -e "
                s#${NVM_VERSION_DIR_IOJS}/#versions/${NVM_IOJS_PREFIX}/#;
                s#^${NVM_DIR}/##;
                \\#^[^v]# d;
                \\#^versions\$# d;
                s#^versions/##;
                s#^v#${NVM_NODE_PREFIX}/v#;
                \\#${SEARCH_PATTERN}# !d;
            " -e 's#^\([^/]\{1,\}\)/\(.*\)$#\2.\1#;' |  command sort -t. -u -k 1.2,1n -k 2,2n -k 3,3n | command sed -e 's#\(.*\)\.\([^\.]\{1,\}\)$#\2-\1#;' -e "s#^${NVM_NODE_PREFIX}-##;")
        }
    }

    if $NVM_ADD_SYSTEM {
        if ($PATTERN == "") or ($PATTERN == "v") {
            $VERSIONS = $"($VERSIONS)
system"
        } else if ($PATTERN == "system") {
            $VERSIONS = "system"
        }
    }

    if $VERSIONS == "" {
        nvm_echo "N/A"
        return 3
    }

    nvm_echo $VERSIONS
}

def nvm_print_versions [
    --no-colors
] {
    print $no_colors
}

def nvm_is_iojs_version [any: string] {
    if ($any | str starts-with "iojs-") {
        return false
    }

    return true
}
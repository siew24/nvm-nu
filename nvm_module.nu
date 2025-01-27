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
export def --env "nvm deactivate" [
    --silent # Silences stdout/stderr output
] {
    let NEW_PATH = (nvm_strip_path $env.PATH "/bin")

    if $"_($env.PATH)" == $"_($NEW_PATH)" {
        if not $silent {
            error make {
                msg: $"Could not find ($env.NVM_DIR)/*/bin in $env.PATH"
            }
        }
    } else {
        $env.PATH = $NEW_PATH
        if not $silent {
            print $"($env.NVM_DIR)/*/bin removed from $env.PATH"
        }
    }

    if ($env | get --ignore-errors "MANPATH" | is-not-empty) {
    let NEW_PATH = (nvm_strip_path $env.PATH "/share/man")

        if $"_($env.MANPATH)" == $"_($NEW_PATH)" {
            if not $silent {
                error make {
                    msg: $"Could not find ($env.NVM_DIR)/*/share/man in $env.MANPATH"
                }
            }
        } else {
            $env.MANPATH = $NEW_PATH
            if not $silent {
                print $"($env.NVM_DIR)/*/share/man removed from $env.MANPATH"
            }
        }
    }

    if ($env | get --ignore-errors "NODE_PATH" | is-not-empty) {
    let NEW_PATH = (nvm_strip_path $env.PATH "/lib/node_modules")

        if $"_($env.NODE_PATH)" == $"_($NEW_PATH)" {
            if not $silent {
                error make {
                    msg: $"Could not find ($env.NVM_DIR)/*/lib/node_modules in $env.NODE_PATH"
                }
            }
        } else {
            $env.NODE_PATH = $NEW_PATH
            if not $silent {
                print $"($env.NVM_DIR)/*/lib/node_modules removed from $env.NODE_PATH"
            }
        }
    }
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

# List installed versions, matching a given <version> if provided
export def "nvm list" [
    pattern: string = ""
    --no-alias # Suppress `nvm alias` output
    --no-colors # Suppress colored output
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
    nvm_print_versions $NVM_LS_OUTPUT --no-colors=$no_colors

    if (not $no_alias) and ($pattern == "") {
        nvm alias --no-colors=$no_colors
        return
    }
}

export alias "nvm ls" = nvm list

# List remote versions available for install, matching a given <version> if provided
export def "nvm list-remote" [
    pattern: string = "" # The version number
    --lts: string # When listing, only select from LTS (long-term support) versions
    --no-colors # Suppress colored output
] {
    mut PATTERN = $pattern
    mut LTS = $lts

    if ($LTS | is-empty) {
        if ($PATTERN | str starts-with "lts/") {
            $LTS = $PATTERN | str substring 4..
            $PATTERN = ""
        }
    }

    let OUTPUT = (nvm_remote_versions $PATTERN --lts=$LTS)

    if ($OUTPUT | is-empty) {
        nvm_print_versions ["N/A"] --no-colors=$no_colors
        return
    }

    nvm_print_versions ($OUTPUT | each {|it| $"($it.version) ($it.alias)(if ($it.new) {' *'} else {''})"}) --no-colors=$no_colors
}

export alias "nvm ls-remote" = nvm list-remote

# Display currently activated version of Node
export def "nvm current" [] {
    print (nvm_version current)
}

export def "nvm which" [] {
    error make { msg: "Not implemented" }
}

export def "nvm alias" [
    alias: string = ""
    target: string = ""
    --no-colors
] {
    let NVM_ALIAS_DIR = (nvm_alias_path)
    let NVM_CURRENT = (nvm_ls_current)

    mkdir $"($NVM_ALIAS_DIR)/lts"

    mut ALIAS = "--"
    mut TARGET = "--"

    if ($alias | is-not-empty) {
        $ALIAS = $alias
    }

    if ($target | is-not-empty) {
        $TARGET = $target
    }

    if ($TARGET | is-empty) {
        nvm unalias $ALIAS
    } else if $TARGET != "--" {
        if (($ALIAS | str replace -r "^[^/]*/" "") != $ALIAS) {
            error make {
                msg: "Aliases in subdirectories are not supported."
            }
        }

        let VERSION = (nvm_version $TARGET)

        if $VERSION == 'N/A' {
            error make {
                msg: $"! WARNING: Version ($TARGET) does not exist."
            }
        }
        nvm_make_alias $ALIAS $TARGET
        print -n (nvm_format_alias $ALIAS $TARGET $VERSION --no-colors=$no_colors --current=$NVM_CURRENT)
    } else {
        if $ALIAS == "--" {
            $ALIAS = ""
        }

        nvm_list_aliases $ALIAS --no-colors=$no_colors
    }
}

export def "nvm unalias" [
    target: string
] {
    error make { msg: "Not implemented" }
} 

export def "nvm install-latest-npm" [] {
    error make { msg: "Not implemented" }
}

export def "nvm reinstall-packages" [] {
    error make { msg: "Not implemented" }
}

export alias copy-packages = reinstall-packages

# 
export def "nvm clear-cache" [] {
    error make { msg: "Not implemented" }
}

# Resolve the given description to a single local version
export def "nvm version" [] {
    error make { msg: "Not implemented" }
}

# Resolve the given description to a single remote version
export def "nvm version-remote" [] {
    error make { msg: "Not implemented" }
}

# Unload `nvm` from shell
export def "nvm unload" [] {
    error make { msg: "Not implemented" }
}

# Set five text colors using format "yMeBg". Available when supported.
export def "nvm set-colors" [
    color_codes: string
] {
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
    GREP_OPTIONS='' ^grep ...$rest
}

def nvm_has [any: string] {
    which $any | is-not-empty
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
        $NVM_NUM_COLORS = $env | get --ignore-errors TERM | default 'vt100' | tput -T $in colors | into int
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
        if (nvm_curl_use_compression) {
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

def --wrapped nvm_download [...rest: string] {

    mut CURL_COMPRESSED_FLAG = ""

    if (nvm_has "curl") {
        if (nvm_curl_use_compression) {
            $CURL_COMPRESSED_FLAG = "--compressed"
        }

        curl --fail $CURL_COMPRESSED_FLAG -q ...$rest
    } else if (nvm_has "wget") {
        # Emulate curl with wget
        let ARGS = nvm_echo ...$rest | command sed -e 's/--progress-bar /--progress=bar /' -e 's/--compressed //' -e 's/--fail //' -e 's/-L //' -e 's/-I /--server-response /' -e 's/-s /-q /' -e 's/-sS /-nv /' -e 's/-o /-O /' -e 's/-C - /-c /'
        wget $ARGS
    }
}

def nvm_has_system_node [] {
    return (try {nvm deactivate o> /dev/null} | (which node) | is-not-empty)
}

def nvm_has_system_iojs [] {
    return (try {nvm deactivate o> /dev/null} | (which iojs) | is-not-empty)
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
    if ($version | is-empty) {
        nvm_err "version is required"
        return 3
    } else if (nvm_is_iojs_version $version) {
        $"(nvm_version_dir iojs)/(nvm_strip_iojs_prefix $version)"
    } else if (nvm_version_greater 0.12.0 $version) {
        $"(nvm_version_dir old)/($version)"
    } else {
        $"(nvm_version_dir new)/($version)"
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
        return (nvm_ls_current)
    }

    let NVM_NODE_PREFIX = (nvm_node_prefix)

    let $pattern = match $pattern {
        ($"_($NVM_NODE_PREFIX)" | $"_($NVM_NODE_PREFIX)-") => "stable"
        _ => ""
    }

    $version = (nvm_ls $pattern | last)

    if ($version == "") or ($version == "N/A") {
        return "N/A"
    }

    return $version
}

def nvm_remote_version [] {
    error make { msg: "Not Implemented" }
}

def nvm_remote_versions [
    pattern: string = ""
    --lts: string = ""
]: string -> table {
    let NVM_IOJS_PREFIX = (nvm_iojs_prefix)
    let NVM_NODE_PREFIX = (nvm_node_prefix)
    mut PATTERN = $pattern

    mut FLAVOR = ""

    if ($lts | is-not-empty) {
        $FLAVOR = $NVM_NODE_PREFIX
    }

    if ($PATTERN in [$NVM_IOJS_PREFIX "io.js"]) {
        $FLAVOR = $NVM_IOJS_PREFIX
        $PATTERN = ""
    } else if ($PATTERN == $NVM_NODE_PREFIX) {
        $FLAVOR = $NVM_NODE_PREFIX
        $PATTERN = ""
    }

    if (nvm_validate_implicit_alias $PATTERN) {
        error make {
            label: {
                text: "Implicit aliases are not supported in nvm_remote_versions.",
                span: (metadata $PATTERN).span
            }
        }
    }

    mut NVM_LS_REMOTE_PRE_MERGED_OUTPUT = []
    mut NVM_LS_REMOTE_POST_MERGED_OUTPUT = []

    if ($FLAVOR | is-empty) or ($FLAVOR == $NVM_NODE_PREFIX) {
        let NVM_LS_REMOTE_OUTPUT = (nvm_ls_remote $PATTERN --lts=$lts)

        $NVM_LS_REMOTE_PRE_MERGED_OUTPUT = $NVM_LS_REMOTE_OUTPUT | take while { |it| $it.version != "v4.0.0" }
        $NVM_LS_REMOTE_POST_MERGED_OUTPUT = $NVM_LS_REMOTE_OUTPUT | skip ($NVM_LS_REMOTE_PRE_MERGED_OUTPUT | length)
    }

    mut NVM_LS_REMOTE_IOJS_OUTPUT = []

    if ($lts | is-empty) and (($FLAVOR | is-empty) or ($FLAVOR == $NVM_IOJS_PREFIX)) {
        $NVM_LS_REMOTE_IOJS_OUTPUT = (nvm_ls_remote_iojs $PATTERN)
    }

    let VERSIONS = ([
        ...$NVM_LS_REMOTE_PRE_MERGED_OUTPUT
        ...$NVM_LS_REMOTE_IOJS_OUTPUT
        ...$NVM_LS_REMOTE_POST_MERGED_OUTPUT
    ] | where { |it| $it.version != "N/A" })

    if ($VERSIONS | is-empty) {
        return [[version]; ["N/A"]]
    }

    return $VERSIONS
}

def nvm_is_valid_version [] {
    error make { msg: "Not Implemented" }
}

def nvm_normalize_version [
    version: string = ""
] -> string {
    return ($version | str trim --left -c "v" | split row "." | enumerate | each { |it| if ($it.index == 0) { $it.item } else { $it.item | fill -a right -c "0" -w 6 } } | str join "")
}

def nvm_normalize_lts [
    lts: string = ""
] {

    if ($lts | parse -r "^(lts/-)" | is-not-empty) {
        error make {
            msg: "Unhandled lts pattern.",
            label: {
                span: (metadata $lts).span
            }
        }
    }

    return $lts
}

def nvm_ensure_version_prefix [any: string] {
    mut nvm_version = nvm_strip_iojs_prefix $any | str replace -r '^([0-9])' 'v$1'

    if (nvm_is_iojs_version $any) {
        return (nvm_add_iojs_prefix $nvm_version)
    } else {
        return $nvm_version
    }

}

def nvm_format_version [] {
    error make { msg: "Not implemented" }
}

def nvm_num_version_groups [
    version: string
] {
    let VERSION = ($version | str trim --left -c "v" | str trim --right -c ".")

    if ($VERSION | is-empty) {
        return "0"
    }

    return ""
}

def --env nvm_strip_path [
    path: list<string>
    folder:  string
] {
    if ($env | get --ignore-errors "NVM_DIR" | is-empty) {
        error make {
            msg: "[INTERNAL] nvm failed",
            label: {
                text: "NVM_DIR not found in PATH!",
            }
        }
    }

    return ($path | where not ($it =~ $"\(^($env.NVM_DIR)/versions/[^/]*\)/[^/]*\(/bin\)"))
}   

def nvm_change_path [] {
    error make { msg: "Not implemented" }
}

def nvm_binary_available [] {
    error make { msg: "Not implemented" }
}

def nvm_set_colors [] {
    error make { msg: "Not implemented" }
}

def --env nvm_get_colors [
    code: int
] {
    let COLORS = $env | get --ignore-errors NVM_COLORS | default "bygre"

    let COLOR = match $code {
        1 => (nvm_print_color_code ($COLORS | str substring 0..0)),
        2 => (nvm_print_color_code ($COLORS | str substring 1..1)),
        3 => (nvm_print_color_code ($COLORS | str substring 2..2)),
        4 => (nvm_print_color_code ($COLORS | str substring 3..3)),
        5 => (nvm_print_color_code ($COLORS | str substring 4..4)),
        6 => (nvm_print_color_code ($COLORS | str substring 2..2) | str replace -a "0;" "1;")
    }

    return $COLOR
}

def nvm_wrap_with_color_code [] {
    error make { msg: "Not implemented" }
}

def nvm_print_color_code [
    code: string
] {
    return (match $code {
        '0' => 0,
        'r' => "0;31m",
        'R' => "1;31m",
        'g' => "0;32m",
        'G' => "1;32m",
        'b' => "0;34m",
        'B' => "1;34m",
        'c' => "0;36m",
        'C' => "1;36m",
        'm' => "0;35m",
        'M' => "1;35m",
        'y' => "0;33m",
        'Y' => "1;33m",
        'k' => "0;30m",
        'K' => "1;30m",
        'e' => "0;37m",
        'W' => "1;37m"
    })
}

def nvm_format_alias [
    alias: string = ""
    destination: string = ""
    version: string = ""
    --no-colors
    --default
    --current: string = ""
    --nvm-lts
] -> string {
    let VERSION = if ($version | is-empty) {
        (nvm_version $destination)
    } else {
        $version
    }

    mut version_format = "%s"
    mut alias_format = "%s"
    mut dest_format = "%s"

    let installed_color = (nvm_get_colors 1)
    let system_color = (nvm_get_colors 2) 
    let current_color = (nvm_get_colors 3)
    let not_installed_color = (nvm_get_colors 4)
    let default_color = (nvm_get_colors 5)
    let lts_color = (nvm_get_colors 6)

    mut newline = "\n"
    if $default {
        $newline = " (default)\n"
    }

    mut arrow = "->"
    if (not $no_colors) and (nvm_has_colors) {
        $arrow = "\u{001b}[0;90m->\u{001b}[0m"
        
        if $default {
            $newline = $" (ansi -e $default_color)\(default\)(ansi reset)\n"
        }

        if $VERSION == $current {
            $alias_format = $"(ansi -e $current_color)%s(ansi reset)"
            $dest_format = $"(ansi -e $current_color)%s(ansi reset)"
            $version_format = $"(ansi -e $current_color)%s(ansi reset)"
        } else if (nvm_is_version_installed $VERSION) {
            $alias_format = $"(ansi -e $installed_color)%s(ansi reset)"
            $dest_format = $"(ansi -e $installed_color)%s(ansi reset)"
            $version_format = $"(ansi -e $installed_color)%s(ansi reset)"
        } else if $VERSION == "∞" or $VERSION == "N/A" {
            $alias_format = $"(ansi -e $not_installed_color)%s(ansi reset)"
            $dest_format = $"(ansi -e $not_installed_color)%s(ansi reset)"
            $version_format = $"(ansi -e $not_installed_color)%s(ansi reset)"
        }

        if ($nvm_lts) {
            $alias_format = $"(ansi -e $lts_color)%s(ansi reset)"
        }

        if ($destination | str starts-with "lts/") {
            $dest_format = $"(ansi -e $lts_color)%s(ansi reset)"
        }
    } else if $VERSION != "∞" and $VERSION != "N/A" {
        $version_format = "%s *"
    }

    if $destination == $VERSION {
        return (($alias_format + " " + $arrow + " " + $version_format + $newline) | str replace "%s" $alias | str replace "%s" $destination)
    } else {
        return (($alias_format + " " + $arrow + " " + $dest_format + " (" + $arrow + " " + $version_format + ")" + $newline) | str replace "%s" $alias | str replace "%s" $destination | str replace "%s" $VERSION)
    }
}

def nvm_print_alias_path [
    nvm_alias_dir: string = ""
    alias_path: string = ""
    --no-colors
    --current: string
    --nvm-lts
] {

    if ($nvm_alias_dir | is-empty) {
        error make {
            msg: "An alias dir is required."
        }
    }

    if ($alias_path | is-empty) {
        error make {
            msg: "An alias path is required."
        }
    }

    let ALIAS = $alias_path | str replace -r $"^($nvm_alias_dir)/" ""
    let DEST = (nvm_alias $ALIAS)

    if ($DEST | is-not-empty) {
        return (nvm_format_alias $ALIAS $DEST --no-colors=$no_colors --default=false --nvm-lts=$nvm_lts --current=$current)
    }

    return ""
}

def nvm_print_default_alias [
    $alias: string = ""
    --no-colors
    --current: string = ""
] {

    if ($alias | is-empty) {
        error make {
            msg: "A default alias is required."
        }
    }

    let DEST = (nvm_print_implicit_alias local $alias)
    if ($DEST | is-not-empty) {
        return (nvm_format_alias $alias $DEST --no-colors=$no_colors --default --current=$current)
    }

    return ""
}

def nvm_make_alias [
    alias: string = ""
    version: string = ""
] {
    if ($alias | is-empty) {
        error make { msg: "An alias is required." }
    }

    if ($version | is-empty) {
        error make { msg: "An alias target version is required." }
    }

    $version | save -f $"(nvm_alias_path)/($alias)"
}

def nvm_list_aliases [
    alias: string = ""
    --no-colors
] {
    let NVM_CURRENT = (nvm_ls_current)
    let NVM_ALIAS_DIR = (nvm_alias_path)

    mkdir $"($NVM_ALIAS_DIR)/lts"

    if $alias != ($alias | str replace --regex "^lts/" "") {
        return (nvm_alias $alias)
    }

    mut results = (try {
        ls $"($NVM_ALIAS_DIR)/($alias)*" | get name | each { |ALIAS_PATH|
            nvm_print_alias_path $NVM_ALIAS_DIR $ALIAS_PATH --no-colors=$no_colors --current=$NVM_CURRENT
        }
    } catch { |err|
        []
    })

    # For default aliases, we should try to print them even if the alias files don't exist
    $results = $results ++ [$"(nvm_node_prefix)" stable unstable $"(nvm_iojs_prefix)"] | each { |ALIAS_NAME|
        try {
            return (nvm_print_default_alias $ALIAS_NAME --no-colors=$no_colors --current=$NVM_CURRENT)
        } catch { |err|
            # Skip aliases that don't exist yet
            []
        }
    }

    $results = $results ++ (try {
        glob $"($NVM_ALIAS_DIR)/lts/($alias)*" | each { |ALIAS_PATH|
            let LTS_ALIAS = (nvm_print_alias_path $NVM_ALIAS_DIR $ALIAS_PATH --no-colors=$no_colors --current=$NVM_CURRENT --nvm-lts)

            if ($LTS_ALIAS | is-not-empty) {
                return $LTS_ALIAS
            }
        }
    } catch { |err|
        # Skip if no LTS aliases exist yet
        null
    })

    $results | sort | each { |it| print -n $it }
}

def nvm_alias [
    alias: string = ""
] {
    if ($alias | is-empty) {
        error make {
            msg: "An alias is required."
        }
    }    
    let ALIAS = (nvm_normalize_lts $alias)

    if ($ALIAS | is-empty) {
        error make {
            msg: "An alias is required."
        }
    }

    let NVM_ALIAS_PATH = $"(nvm_alias_path)/($ALIAS)"

    if ($NVM_ALIAS_PATH | path type | $in != "file") {
        error make {
            msg: "Alias does not exist."
        }
    }

    return (open $NVM_ALIAS_PATH)
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
        return [1]
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
            return [0, $ALIAS]
        } else {
            return [0, (nvm_ensure_version_prefix $ALIAS)]
        }
    }

    if (nvm_validate_implicit_alias $pattern err> /dev/null) {
        let IMPLICIT = (nvm_print_implicit_alias local $pattern err> /dev/null)

        if ($IMPLICIT != "") {
            return [2, (nvm_ensure_version_prefix $IMPLICIT)]
        }
    }

    return [2]
}

def --env nvm_resolve_local_alias [any: string = ""] {
    if $any == "" {
        return [1]
    }

    let VERSION = (nvm_resolve_alias $any)

    if (($VERSION | length) == 1) or ($VERSION.1 == "") {
        return [$VERSION.0]
    }

    if $"_($VERSION.1)" != "_∞" {
        return [0, (nvm_version $VERSION)]
    } else {
        return [0, $VERSION]
    }
}

def nvm_iojs_prefix [] {
    return "iojs"
}

def nvm_node_prefix [] {
    return "node"
}

def nvm_is_iojs_version [any: string] {
    if ($any | str starts-with "iojs-") {
        return true 
    }

    return false
}

def nvm_add_iojs_prefix [any: string = ""] {
    return $"(nvm_iojs_prefix)-(nvm_ensure_version_prefix $"(nvm_strip_iojs_prefix $any)")"
}

def nvm_strip_iojs_prefix [any: string = ""]: string -> string {
    let NVM_IOJS_PREFIX = (nvm_iojs_prefix)

    if $any == $NVM_IOJS_PREFIX {
        return ""
    } else {
        if ($any | str starts-with $NVM_IOJS_PREFIX) {
            return ($any | str substring ($NVM_IOJS_PREFIX | str length)..-1)
        } else {
            return ($any)
        }
    }
}

def nvm_ls [
    $pattern: string = ""
] -> list<string> {


    if $pattern == "current" {
        return [(nvm_ls_current)]
    }

    let NVM_IOJS_PREFIX = (nvm_iojs_prefix)
    let NVM_NODE_PREFIX = (nvm_node_prefix)
    let NVM_VERSION_DIR_IOJS = (nvm_version_dir $NVM_IOJS_PREFIX)
    let NVM_VERSION_DIR_NEW = (nvm_version_dir new)
    let NVM_VERSION_DIR_OLD = (nvm_version_dir old)

    mut $PATTERN = ""
    if (($pattern == $NVM_IOJS_PREFIX) or ($pattern == $NVM_NODE_PREFIX)) {
        $PATTERN = $"($pattern)-"
    } else {
        let temp = (nvm_resolve_local_alias $pattern)
        if ($temp.0 == 0) {
            return [$temp.1]
        }

        $PATTERN = (nvm_ensure_version_prefix $pattern)
    }

    if $PATTERN == "N/A" {
        return []
    }

    let NVM_PATTERN_STARTS_WITH_V = $PATTERN | str starts-with "v"

    mut VERSIONS = []
    mut NVM_ADD_SYSTEM = false

    if ($NVM_PATTERN_STARTS_WITH_V) and ( $"_(nvm_num_version_groups $PATTERN)" == "_3" ) {
        if (nvm_is_version_installed $PATTERN) {
            $VERSIONS = [$PATTERN]
        } else if (nvm_is_version_installed (nvm_add_iojs_prefix $PATTERN)) {
            $VERSIONS = [(nvm_add_iojs_prefix $PATTERN)]
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
            if (nvm_has_system_node) {
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
 
        if ($NVM_DIRS_TO_SEARCH1 | path type | $in != "dir") or not (ls $NVM_DIRS_TO_SEARCH1 | where name =~ . | is-not-empty) {
            $NVM_DIRS_TO_SEARCH1 = ""
        }
        if ($NVM_DIRS_TO_SEARCH2 | is-empty) or ($NVM_DIRS_TO_SEARCH2 | path type | $in != "dir") or not (ls $NVM_DIRS_TO_SEARCH2 | where name =~ . | is-not-empty) {
            $NVM_DIRS_TO_SEARCH2 = $NVM_DIRS_TO_SEARCH1
        }
        if ($NVM_DIRS_TO_SEARCH3 | is-empty) or ($NVM_DIRS_TO_SEARCH3 | path type | $in != "dir") or not (ls $NVM_DIRS_TO_SEARCH3 | where name =~ . | is-not-empty) {
            $NVM_DIRS_TO_SEARCH3 = $NVM_DIRS_TO_SEARCH2
        }

        let SEARCH_PATTERN = match $PATTERN {
            "" => '.*'
            _ => ($PATTERN | str replace -a -r "\\." "\\\\\\.")
        }

        if $PATTERN == "" {
            $PATTERN = "v"
        }

        if ($"($NVM_DIRS_TO_SEARCH1)($NVM_DIRS_TO_SEARCH2)($NVM_DIRS_TO_SEARCH3)" != "") {
            $VERSIONS = (try {
                ls -f $"($NVM_DIRS_TO_SEARCH1)/*" $"($NVM_DIRS_TO_SEARCH2)/*" $"($NVM_DIRS_TO_SEARCH3)/*" | where name =~ . or type == "dir" or name =~ $"($PATTERN)*" | get name
            } catch {
                []
            }) | each { |item| $item
               | str replace -r $"($NVM_VERSION_DIR_IOJS)/" $"versions/($NVM_IOJS_PREFIX)/"
               | str replace -r $"^($env.NVM_DIR)" ""
               | str replace -r "^versions/" ""
               | str replace -r "^v" $"($NVM_NODE_PREFIX)/v"
               | str replace -r "^([^/]{1,})/(.*)$" "$2.$1"
               | str replace -r "(.*).([^.]{1,})$" "$2-$1"
               | str replace -r $"^($NVM_NODE_PREFIX)-" ""
            }
        }
    }

    if $NVM_ADD_SYSTEM {
        if ($PATTERN == "") or ($PATTERN == "v") {
            $VERSIONS = [$"($VERSIONS)
system"]
        } else if ($PATTERN == "system") {
            $VERSIONS = ["system"]
        }
    }

    if ($VERSIONS | is-empty) {
        return ["N/A"]
    }

    return $VERSIONS
}

export def nvm_ls_remote [
    pattern: string = ""
    --lts: string = ""
] -> table {

    mut PATTERN = $pattern

    # Handle implicit aliases like 'node', 'stable', etc
    if (nvm_validate_implicit_alias $PATTERN) {
        let IMPLICIT = (nvm_print_implicit_alias "remote" $PATTERN)
        if ($IMPLICIT | is-empty) or ($IMPLICIT == 'N/A') {
            return [[version]; ['N/A']]
        }
        $PATTERN = (NVM_LTS=$lts nvm_ls_remote $IMPLICIT | last | get version)
    } else if ($PATTERN | is-not-empty) {
        # If a pattern is provided, ensure it has version prefix
        $PATTERN = (nvm_ensure_version_prefix $PATTERN)
    } else {
        # Default pattern matches everything
        $PATTERN = ".*"
    }

    # Get versions from remote index
    let VERSIONS = (nvm_ls_remote_index_tab "node" "std" $PATTERN --lts=$lts)
    
    if ($VERSIONS | is-empty) {
        return [[version]; ['N/A']]
    }

    # Return as list
    $VERSIONS
}

def nvm_ls_remote_iojs [
    pattern: string = ""
    --lts: string = ""
] {
    return (nvm_ls_remote_index_tab "iojs" "std" $pattern --lts=$lts)
}

def nvm_ls_remote_index_tab [
    flavor: string = ""
    type: string = ""
    pattern: string = ""
    --lts: string = ""
] -> table {
    let MIRROR = (nvm_get_mirror $flavor $type)

    if ($MIRROR | is-empty) {
        return [[version]; ["N/A"]]
    }

    let PREFIX = match $"($flavor)-($type)" {
        "iojs-std" => $"(nvm_iojs_prefix)-",
        "node-std" => "",
        _ => {
            nvm_err "Unknown type of node.js or io.js release"
            return [[version]; ["N/A"]]
        }
    }

    mut PATTERN = $pattern
    if ($pattern | str ends-with ".") {
        $PATTERN = ($PATTERN | str trim --right --char ".")
    }

    if ($PATTERN | is-not-empty) and ($PATTERN != "*") {
        if $flavor == 'iojs' {
            $PATTERN = (nvm_ensure_version_prefix (nvm_strip_iojs_prefix $PATTERN))
        } else {
            $PATTERN = (nvm_ensure_version_prefix $PATTERN)
        }
    } else {
        $PATTERN = ""
    }

    let VERSION_LIST = (nvm_download -L -s $"($MIRROR)/index.tab" -o - 
        | lines 
        | skip 1  # Skip header line
        | each { |line| 
            $"($PREFIX)($line)" | split row "\t"
        }
    )

    mkdir $"(nvm_alias_path)/lts"

    # Parse version list and create aliases
    $VERSION_LIST
        | reduce -f {} { |row, acc|
            if ($row.9? | is-empty) or ($row.9 == "-") {
                return $acc
            }

            mut ACC = $acc
            let ALIAS_NAME = $"lts/($row.9? | str downcase)"

            let version = ($ACC | get version?)

            if ("alias" in $ACC) {
                $ACC = ($ACC | upsert ($ACC | get alias) { $version })
            } else {
                $ACC = ($ACC | upsert "lts/*" { $ALIAS_NAME })
            }

            $ACC = ($ACC | upsert "alias" { $ALIAS_NAME })
            $ACC = ($ACC | upsert "version" { $row.0 })
            return $ACC
        }
        | reject -i alias version
        | transpose LTS_ALIAS LTS_VERSION
        | each { |row|
            nvm_make_alias $row.LTS_ALIAS $row.LTS_VERSION
        }

    let LTS = if ($lts | is-not-empty) {
        (nvm_normalize_lts $"lts/($lts)") | str replace -r "^lts/" ""
    } else {
        ""
    }

    mut VERSIONS = $VERSION_LIST
    | reduce -f {lts: $lts} {|row, acc|
        let prev = ($acc | get prev? | default "")
        let lts = ($acc | get lts)
        if ($lts | is-not-empty) and ($row.9? == "-") {
            return $acc
        }

        if ($lts | is-not-empty) and ($lts != "*") and (($row.9? | str downcase) != ($lts | str downcase)) {
            return $acc
        }

        if ($row.9? != "-") {
            if ($row.9? | is-not-empty) and ($row.9? != $prev) {
                return ($acc | upsert $row.0 { alias: $row.9?, new: true } | upsert prev { $row.9? })
            } else {
                return ($acc | upsert $row.0 { alias: $row.9?, new: false } | upsert prev { $row.9? })
            }
        } 

        return ($acc | upsert $row.0 { alias: "", new: false } | upsert prev { $row.9? })
    }
    | reject lts prev
    | transpose version data
    | flatten

    if ($flavor == "node") {
        $VERSIONS = ($VERSIONS | sort-by -c {|a, b| 
            let a_versions = ($a.version | split row "." | each {|it| $it | str trim --left --char "v" | into int})
            let b_versions = ($b.version | split row "." | each {|it| $it | str trim --left --char "v" | into int})

            if ($a_versions | get 0) != ($b_versions | get 0) {
                return (($a_versions | get 0) < ($b_versions | get 0))
            }

            if ($a_versions | get 1) != ($b_versions | get 1) {
                return (($a_versions | get 1) < ($b_versions | get 1))
            }

                return (($a_versions | get 2) < ($b_versions | get 2))
            }
        )
    } else {
        $VERSIONS = ($VERSIONS | sort-by version)
    }

    if ($VERSIONS | is-empty) {
        return [[version]; ["N/A"]]
    }

    return $VERSIONS
}

def nvm_get_checksum_binary [] {
    error make { msg: "Not implemented" }
}

def nvm_get_checksum_alg [] {
    error make { msg: "Not implemented" }
}

def nvm_compute_checksum [] {
    error make { msg: "Not implemented" }
}

def nvm_compare_checksum [] {
    error make { msg: "Not implemented" }
}

def nvm_get_checksum [] {
    error make { msg: "Not implemented" }
}

def nvm_print_versions [
    $versions: list<string>
    --no-colors
] {
    let REMOTE_VERSIONS = $versions
    let INSTALLED_VERSIONS = (nvm_ls)
    let INSTALLED_COLOR = (nvm_get_colors 1)
    let SYSTEM_COLOR = (nvm_get_colors 2)
    let CURRENT_COLOR = (nvm_get_colors 3)
    let NOT_INSTALLED_COLOR = (nvm_get_colors 4)
    let DEFAULT_COLOR = (nvm_get_colors 5)
    let OLD_LTS_COLOR = $DEFAULT_COLOR
    let LTS_COLOR = (nvm_get_colors 6)
    mut HAS_COLORS = false

    if (not $no_colors) and (nvm_has_colors) {
        $HAS_COLORS = true
    }

    for VERSION in $REMOTE_VERSIONS {
        let fields = ($VERSION | split row " " | { "version": $in.0, "alias": $in.1?, "is_lts": ($in | get 2? | default "") } )
        mut cols = 1

        if ($fields.alias? | is-not-empty) {
            $cols += 1
        }
        if ($fields.is_lts? | is-not-empty) {
            $cols += 1
        }

        let is_installed = ($fields.version in $INSTALLED_VERSIONS)

        let padding = if ((not $HAS_COLORS) and $is_installed) { "" } else { "  " }

        mut version = if ($HAS_COLORS and ($CURRENT_COLOR | is-empty)) or (not $HAS_COLORS) {
            $fields.version | fill -w 13 -a r
        } else {
            $fields.version | fill -w 15 -a r
        }

        $version = if ($HAS_COLORS) {
            if ($fields.version == "current") {
                if ($CURRENT_COLOR | is-empty) {
                    $version
                } else {
                    $version | str replace -r "^" $"(ansi -e $CURRENT_COLOR)->" | str replace -r "$" $"(ansi reset)"
                }
            } else if ($fields.version == "system") {
                if ($SYSTEM_COLOR | is-empty) {
                    $version
                } else {
                    $version | str replace -r "^" $"(ansi -e $SYSTEM_COLOR)" | str replace -r "$" $"(ansi reset)"
                }
            } else if ($is_installed) {
                if ($INSTALLED_COLOR | is-empty) {
                    $version
                } else {
                    $version | str replace -r "^" $"(ansi -e $INSTALLED_COLOR)" | str replace -r "$" $"(ansi reset)"
                }
            } else {
                $version
            }
        } else {
            if ($fields.version == "current") {
                $version | str replace -r "^" "->" | str replace -r "$" " *"
            } else if ($fields.version == "system" or $is_installed) {
                $version | str replace -r "$" " *"
            } else {
                $version
            }
        }

        mut lts = if ($cols == 1) {
            ""
        } else if ($cols == 2) {
            if ($HAS_COLORS and ($OLD_LTS_COLOR | is-not-empty)) {
                $fields.alias | str replace -r "^" $"(ansi -e $OLD_LTS_COLOR) \(LTS: " | str replace -r "$" $")(ansi reset)"
            } else {
                $fields.alias | str replace -r "^" " (LTS: " | str replace -r "$" ")"
            }
        } else if ($cols == 3 and $fields.is_lts == "*") {
            if ($HAS_COLORS and ($CURRENT_COLOR | is-not-empty)) {
                $fields.alias | str replace -r "^" $"(ansi -e $CURRENT_COLOR) \(Latest LTS: " | str replace -r "$" $")(ansi reset)"
            } else {
                $fields.alias | str replace -r "^" " (Latest LTS: " | str replace -r "$" ")"
            }
        }

        if ($cols == 1) {
            print $version 
        } else if ($cols == 2) {
            print ($version + $padding + $lts)
        } else if ($cols == 3) and ($fields.is_lts == "*") {
            print ($version + $padding + $lts)
        }
    }
}

def nvm_validate_implicit_alias [
    alias: string = ""
    --throw
] -> bool {
    let NVM_IOJS_PREFIX = (nvm_iojs_prefix)
    let NVM_NODE_PREFIX = (nvm_node_prefix)

    if ($alias not-in ["stable" "unstable" $"($NVM_IOJS_PREFIX)" $"($NVM_NODE_PREFIX)"])  {
        if $throw {
            error make {
                msg: "Only implicit aliases 'stable', 'unstable', '($NVM_IOJS_PREFIX)' and '($NVM_NODE_PREFIX)' are supported."
                label: {
                text: $"Only implicit aliases 'stable', 'unstable', '($NVM_IOJS_PREFIX)' and '($NVM_NODE_PREFIX)' are supported."
                    span: (metadata $alias).span
                }
            }
        }
        return false
    }

    return true
}

export def nvm_print_implicit_alias [
    type: string = ""
    implicit_alias: string = ""
] -> string {
    if ($type not-in ["local" "remote"]) {
        error make {
            label: {
                text: "nvm_print_implicit_alias must be specified with local or remote as the first argument"
                span: (metadata $type).span
            }
        }
    }

    nvm_validate_implicit_alias $implicit_alias

    let NVM_IOJS_PREFIX = (nvm_iojs_prefix)
    let NVM_NODE_PREFIX = (nvm_node_prefix)
    mut LAST_TWO = []

    if $implicit_alias == $NVM_IOJS_PREFIX {
        let NVM_IOJS_VERSION = if $type == "local" {
            nvm_ls $implicit_alias
        } else {
            nvm_ls_remote_iojs
        }

        if ($NVM_IOJS_VERSION | length | $in == 1) and ($NVM_IOJS_VERSION | get 0) == "N/A" {
            return "N/A"
        }

        return (nvm_add_iojs_prefix $NVM_IOJS_VERSION)
    } else if $implicit_alias == $NVM_NODE_PREFIX {
        return "stable"
    } else {
        $LAST_TWO = if ($type == "local") {
            (nvm_ls node)
        } else {
            (nvm_ls_remote)
        }
    }

    mut STABLE = ""
    mut UNSTABLE = ""
    mut MOD = ""
    mut NORMALIZED_VERSION = ""

    for MINOR in $LAST_TWO {
        let NORMALIZED_VERSION = (nvm_normalize_version $MINOR)

        if (($NORMALIZED_VERSION | str substring 1..-1) != $NORMALIZED_VERSION) {
            $STABLE = $MINOR
        } else {
            let MOD = ($NORMALIZED_VERSION | str substring 0..-7 | into int | $in mod 2)
            if $MOD == 0 {
                $STABLE = $MINOR
            } else {
                $UNSTABLE = $MINOR
            }
        }
    }

    if ($implicit_alias == "stable") {
        return $STABLE
    } else if ($implicit_alias == "unstable") {
        if ($UNSTABLE | is-empty) {
            return "N/A"
        } else {
            return $UNSTABLE
        }
    }
}

def nvm_get_os [] {
    let NVM_UNAME = (sys host | get name)
    return (match $NVM_UNAME {
        "Linux" => "linux",
        "Darwin" => "darwin",
        "SunOS" => "sunos",
        "FreeBSD" => "freebsd",
        "OpenBSD" => "openbsd",
        "AIX" => "aix",
        "CYGWIN" => "win",
        "MSYS" => "win",
        "MINGW" => "win",
        _ => "unknown"
    })
}

def nvm_get_arch [] {
    error make { msg: "Not implemented" }
}

def nvm_get_minor_version [] {
    error make { msg: "Not implemented" }
}

def nvm_ensure_default_set [] {
    error make { msg: "Not implemented" }
}

def nvm_is_merged_node_version [
    $version: string = ""
] {
    nvm_version_greater_than_or_equal_to $version v4.0.0
}

def nvm_get_mirror [
    flavor: string
    type: string
] -> string {
    let NVM_MIRROR = match $"($flavor)-($type)" {
        "node-std" => (($env | get --ignore-errors NVM_NODEJS_ORG_MIRROR) | default "https://nodejs.org/dist"),
        "iojs-std" => (($env | get --ignore-errors NVM_IOJS_ORG_MIRROR) | default "https://iojs.org/dist"),
        _ => {
            nvm_err 'unknown type of node.js or io.js release'
            return ""
        }
    }

    # Validate mirror URL
    if ($NVM_MIRROR | str contains '`') or ($NVM_MIRROR | str contains '\\') or ($NVM_MIRROR | str contains "'") or ($NVM_MIRROR | str contains '(') or ($NVM_MIRROR | str contains ' ') {
        nvm_err '$NVM_NODEJS_ORG_MIRROR and $NVM_IOJS_ORG_MIRROR may only contain a URL'
        return ""
    }

    # Check if mirror URL matches expected format
    if not ($NVM_MIRROR | parse -r "^https?://[a-zA-Z0-9./_-]+$" | is-not-empty) {
        nvm_err '$NVM_NODEJS_ORG_MIRROR and $NVM_IOJS_ORG_MIRROR may only contain a URL'
        return ""
    }

    $NVM_MIRROR
}

def nvm_install_binary_extract [] {
    error make { msg: "Not implemented" }
}

def nvm_install_binary [] {
    error make { msg: "Not implemented" }
}

def nvm_get_download_slug [] {
    error make { msg: "Not implemented" }
}

def nvm_get_artifact_compression [] {
    error make { msg: "Not implemented" }
}

def nvm_download_artifact [] {
    error make { msg: "Not implemented" }
}

def nvm_extract_tarball [] {
    error make { msg: "Not implemented" }
}

def nvm_get_make_jobs [] {
    error make { msg: "Not implemented" }
}

def nvm_install_source [] {
    error make { msg: "Not implemented" }
}

def nvm_use_if_needed [] {
    error make { msg: "Not implemented" }
}

def nvm_install_npm_if_needed [] {
    error make { msg: "Not implemented" }
}

def nvm_match_version [] {
    error make { msg: "Not implemented" }
}

def nvm_npm_global_modules [] {
    error make { msg: "Not implemented" }
}

def nvm_npmrc_bad_news_bears [] {
    error make { msg: "Not implemented" }
}

def nvm_die_on_prefix [] {
    error make { msg: "Not implemented" }
}

def nvm_iojs_version_has_solaris_binary [] {
    error make { msg: "Not implemented" }
}

def nvm_node_version_has_solaris_binary [] {
    error make { msg: "Not implemented" }
}

def nvm_has_solaris_binary [] {
    error make { msg: "Not implemented" }
}

def nvm_sanitize_path [] {
    error make { msg: "Not implemented" }
}

def nvm_is_natural_num [] {
    error make { msg: "Not implemented" }
}

def nvm_check_file_permissions [] {
    error make { msg: "Not implemented" }
}

def --env nvm_cache_dir [] {
    return $"($env.NVM_DIR)/.cache"
}

def nvm_get_default_packages [] {
    error make { msg: "Not implemented" }
}

def nvm_install_default_packages [] {
    error make { msg: "Not implemented" }
}

def nvm_supports_xz [] {
    error make { msg: "Not implemented" }
}

def nvm_auto [] {
    error make { msg: "Not implemented" }
}

def nvm_process_parameters [] {
    error make { msg: "Not implemented" }
}

def nvm_echo [...args] {
    print ($args | str join " ")
}

def nvm_err [...args] {
    $args | str join " " | error make { msg: $in }
}
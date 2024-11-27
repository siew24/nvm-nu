# nvm-nu

A direct port of [nvm](https://github.com/nvm-sh/nvm) by converting the [nvm.sh](https://github.com/nvm-sh/nvm/blob/master/nvm.sh) file into a Nu module.

The aim of this project is to try to maintain the behavior of the original while stripping off the parts so that it only works with Nushell.

## Known Issues

Currently there's no possible way to return error codes from Nu Commands, so all errors are converted into custom error messages to fit Nu's way of working.

## Compatibility Matrix

|      Command       |       State        |
| :----------------: | :----------------: |
|      install       |        :x:         |
|     uninstall      |        :x:         |
|        use         |        :x:         |
|        exec        |        :x:         |
|        run         |        :x:         |
|      current       | :white_check_mark: |
|         ls         |        :x:         |
|     ls-remote      |        :x:         |
|      version       |        :x:         |
|   version-remote   |        :x:         |
|     deactivate     |        :x:         |
|       alias        |        :x:         |
|      unalias       |        :x:         |
| install-latest-npm |        :x:         |
| reinstall-packages |        :x:         |
|       unload       |        :x:         |
|       which        |        :x:         |
|     cache dir      |        :x:         |
|    cache clear     |        :x:         |
|     set-colors     |        :x:         |

## Getting Started

1. Download the [nvm_module.nu](nvm_module.nu) file locally
2. Run `use <folder path to nvm_module>/nvm_module.nu *`
3. (Optional) Make it always available on your terminal by appending the command above into `$nu.config-path`.

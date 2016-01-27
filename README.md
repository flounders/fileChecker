# fileChecker

fileChecker is a utility to help identify the MIME type of multiple files at once.
It can be used recursively or only on the immediate child files of the directory
you are checking. The default is non recursive checking at this time.

## Building

To build fileChecker you will need to have stack installed. You can find out how
to install stack on your platform of choice
[here.](https://github.com/commercialhaskell/stack/blob/master/doc/install_and_upgrade.md)

Here are the commands that you need to use:

```
$ stack setup
$ stack build
```

When the build command is finished it will give you the path of where the executable
is located. You can also run fileChecker using `stack exec fileChecker` if you are
in the project directory.

## Usage

To check just immediate child files: `fileChecker <path>`

To check a path recursively: `fileChecker -r <path>`

To bring up help: `fileChecker -h`

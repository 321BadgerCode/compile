<!--Badger-->
# compile

Compiles a bash script into a stand-alone executable.

## Purpose

Bash script to put local files that a bash script uses into the bash script, so that it doesn't depend on local files. It then uses `shc` to convert the bash script into c code, then it gets compiled into a stand-alone executable file to be run.

## Dependencies

Intall `shc`(sh->c) & `gcc`(c->exe) using the following command(you likely already have `gcc` if you're on Linux):

```sh
<path to compile.sh> -i2 #or you could use "--install" instead
```

## Installation

To install `compile`, run the following command:

```
git clone https://github.com/321BadgerCode/compile.git
```

> You can use `compile` to compile itself by running `<path to compile.sh> <path to compile.sh>`, then renaming it to `compile`(take out `.exe`) and appending the outputted executable to your PATH or by placing the executable into a folder that's already in your path such as `/usr/local/bin/`.

If you do add `compile` into your path, you can run it just by typing something along the lines of: `compile script_to_compile.sh`.

## Usage

To compile a bash script, use the following command:

```
<path to compile.sh> script_to_compile.sh
```

This will create an executable file named `script_to_compile.exe`.

You can also specify the output file name using the `-o` or `--out` option:

```
compile script.sh -o out.exe
```

This will create an executable file named `out.exe`.

To enable verbose output, use the `-v` option:

```
compile -v script.sh
```

This will print more information about the compilation process.

To ask the user if they want to see more options after the script is compiled, use the `-q` option:

```
compile -q script.sh
```

This will ask the user if they want to see more options, such as running the compiled script.

## Options

* `-h, --help`
    * Prints this help message.
* `-o, --out`
    * The output file name. If not specified, the output file will be named `compiled_script`.
* `-v, --verbose`
    * Enables verbose output. This will print more information about the compilation process.
* `-q, --question`
    * Asks the user if they want to see more options after the script is compiled.

## Bugs

Please report any bugs to the author of this script.

## Author

This script was written by Badger Code.

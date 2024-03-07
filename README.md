# Nbang Script Compiler

Nbang is a simple script compiler that allows you to compile and run scripts written in the Nim programming language. It provides a convenient way to manage script compilation and execution, making it easy to write and run scripts on your system.

Installation
------------

To install Nbang, you'll need to have Nim and Nimble installed on your system. Once you have Nim and Nimble installed, you can build Nbang using the following command:

```bash
nimble build -d:release
```

This will build Nbang in release mode and generate an executable file named `nbang` in the project directory.

Usage
-----

To compile and run a script using Nbang, use the following command:

```bash
nbang --compiler-args=[compiler_args] script.nim [script_args]
```

The `compiler_args` are optional arguments that will be passed to the Nim compiler. By default, Nbang will compile the script with the `-d:release --hints:off --warnings:off` flags.

The `script.nim` argument is the path to the script that you want to compile and run. This can be either an absolute path or a relative path to the script.

The `script_args` are optional arguments that will be passed to the compiled script when it is run.

Here's an example of how to use Nbang to compile and run a simple script:

```nim
#!/path/to/nbang --compiler-args="-d:danger --hints:off --warnings:off"

import os, strformat

let args = commandLineParams()
let name = if args.len > 0: args[0] else: "World"

echo fmt"Hello {name}!"
```

This script imports the `os` and `strformat` modules, retrieves the command line arguments, and prints a greeting to the console. The shebang line at the top of the script specifies the path to the Nbang executable and the compiler flags to use.

Contributing
------------

If you'd like to contribute to Nbang, please open a pull request with your proposed changes. Before submitting a pull request, please make sure that your changes are well-tested and that they do not introduce any new bugs.

License
-------

Nbang is released under the MIT License. See the [LICENSE](./LICENSE) file for more information.

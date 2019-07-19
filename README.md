QuickJS Javascript引擎
=========================

目录
-----------------

*   [1 简介](#Introduction)
    *   [1.1 主要功能](#Main-Features)
    *   [1.2 基准测试](#bench)
*   [2 用法](#Usage)
    *   [2.1 安装](#Installation)
    *   [2.2 快速入门](#Quick-start)
    *   [2.3 命令行选项](#Command-line-options)
        *   [2.3.1 `qjs` 解释器](#qjs-interpreter)
        *   [2.3.2 `qjsc` 编译器](#qjsc-compiler)
    *   [2.4 `qjscalc` 应用程序](#qjscalc-application)
    *   [2.5 内置测试](#Built_002din-tests)
    *   [2.6 Test262 (ECMAScript测试套件)](#Test262-_0028ECMAScript-Test-Suite_0029)
*   [3 技术规范](#Specifications)
    *   [3.1 语言支持](#Language-support)
        *   [3.1.1 ES2019支持](#ES2019-support)
        *   [3.1.2 JSON](#JSON)
        *   [3.1.3 ECMA402](#ECMA402)
        *   [3.1.4 扩展](#Extensions)
        *   [3.1.5 数学扩展](#Mathematical-extensions)
    *   [3.2 模块](#Modules)
    *   [3.3 标准库](#Standard-library)
        *   [3.3.1 全局对象](#Global-objects)
        *   [3.3.2 `std` 模块](#std-module)
        *   [3.3.3 `os` 模块](#os-module)
    *   [3.4 QuickJS C API](#QuickJS-C-API)
        *   [3.4.1 运行时和上下文](#Runtime-and-contexts)
        *   [3.4.2 JSValue](#JSValue)
        *   [3.4.3 C函数](#C-functions)
        *   [3.4.4 错误异常](#Exceptions)
        *   [3.4.5 Script代码执行](#Script-evaluation)
        *   [3.4.6 JS类](#JS-Classes)
        *   [3.4.7 C模块](#C-Modules)
        *   [3.4.8 内存处理](#Memory-handling)
        *   [3.4.9 执行超时和中断](#Execution-timeout-and-interrupts)
*   [4 内部实现](#Internals)
    *   [4.1 Bytecode](#Bytecode)
    *   [4.2 Executable generation](#Executable-generation)
        *   [4.2.1 `qjsc` 编译器](#qjsc-compiler-1)
        *   [4.2.2 二进制 JSON](#Binary-JSON)
    *   [4.3 运行时](#Runtime)
        *   [4.3.1 Strings](#Strings)
        *   [4.3.2 Objects](#Objects)
        *   [4.3.3 Atoms](#Atoms)
        *   [4.3.4 Numbers](#Numbers)
        *   [4.3.5 垃圾回收](#Garbage-collection)
        *   [4.3.6 JSValue](#JSValue-1)
        *   [4.3.7 Function call](#Function-call)
    *   [4.4 RegExp](#RegExp)
    *   [4.5 Unicode](#Unicode)
    *   [4.6 BigInt and BigFloat](#BigInt-and-BigFloat)
*   [5 许可协议](#License)
*   [6 相关项目](#Projects)

1 简介
--------------

QuickJS是一个小型并且可嵌入的Javascript引擎，它支持ES2019规范，包括模块，异步生成器和代理器。

它可选支持数学扩展，例如大整数 (BigInt)，大浮点数 (BigFloat) 以及运算符重载。

### 1.1 主要功能

*   轻量而且易于嵌入：只需几个C文件，没有外部依赖，一个x86下的简单的“hello world”程序只要180 KiB。
*   具有极低启动时间的快速解释器： 在一台单核的台式PC上，大约在100秒内运行ECMAScript 测试套件[1](#FOOT1) 56000次。运行时实例的完整生命周期在不到300微秒的时间内完成。
*   几乎完整实现ES2019支持，包括： 模块，异步生成器和和完整Annex B支持 (传统的Web兼容性)。
*   通过100％的ECMAScript Test Suite测试。
*   可以将Javascript源编译为没有外部依赖的可执行文件。
*   使用引用计数（以减少内存使用并具有确定性行为）的垃圾收集与循环删除。
*   数学扩展：BigInt, BigFloat, 运算符重载, bigint模式, math模式.
*   在Javascript中实现的具有上下文着色和完成的命令行解释器。
*   采用C包装库构建的内置标准库。

### 1.2 基准测试

点击查看[QuickJS基准测试](bench.md)具体内容

2 用法
-------

### 2.1 安装

提供Makefile可以在Linux或者MacOS/X上编译。通过使用MinGW工具在Linux主机上进行交叉编译，可以获得初步的Windows支持。

如果要选择特定选项，请编辑`Makefile`顶部，然后运行`make`。

使用root身份执行 `make install` 可以将编译的二进制文件和支持文件安装到 `/usr/local` (这不是使用QuickJS所必需的).

### 2.2 快速入门

`qjs` 是命令行解析器 (Read-Eval-Print Loop). 您可以将Javascript文件和/或表达式作为参数传递以执行它们：

```
./qjs examples/hello.js
```

`qjsc` 是命令行编译器:

```
./qjsc -o hello examples/hello.js
./hello
```

生成一个没有外部依赖的 `hello` 可执行文件。

`qjsbn` 和 `qjscbn` 是具有数学扩展的相应解释器和编译器：

```
./qjsbn examples/pi.js 1000
```

显示PI的1000位数字

```
./qjsbnc -o pi examples/pi.js
./pi 1000
```

编译并执行PI程序。

### 2.3 命令行选项

#### 2.3.1 `qjs` 解释器

用法: qjs \[options\] \[files\]

选项:

`-h`

`--help`

选项列表。

``-e `EXPR` ``

``--eval `EXPR` ``

执行EXPR.

`-i`

`--interactive`

转到交互模式 (在命令行上提供文件时，它不是默认模式).

`-m`

`--module`

加载为ES6模块（默认为.mjs文件扩展名）。

高级选项包括：

`-d`

`--dump`

转存内存使用情况统计信息。

`-q`

`--quit`

只是实例化解释器并退出。

#### 2.3.2 `qjsc` 编译器

用法: qjsc \[options\] \[files\]

选项:

`-c`

仅输出C文件中的字节码，默认是输出可执行文件。

`-e`

 `main()` C文件中的输出和字节码，默认是输出可执行文件。

`-o output`

设置输出文件名（默认= out.c或a.out）。

`-N cname`

设置生成数据的C名称。

`-m`

编译为Javascript模块（默认为.mjs扩展名）。

`-M module_name[,cname]`

添加外部C模块的初始化代码。查看`c_module`示例。

`-x`

字节交换输出（仅用于交叉编译）。

`-flto`

使用链接时间优化。编译速度较慢，但可执行文件更小更快。使用选项时会自动设置此选项`-fno-x`。

`-fno-[eval|string-normalize|regexp|json|proxy|map|typedarray|promise]`

禁用所选语言功能以生成较小的可执行文件。

### 2.4 `qjscalc` 应用程序

该`qjscalc`应用程序是`qjsbn`命令行解释器的超集，它实现了一个具有任意大整数和浮点数，分数，复数，多项式和矩阵的Javascript计算器。源代码在qjscalc.js中。[http://numcalc.com](http://numcalc.com/)上提供了更多文档和Web版本。

### 2.5 内置测试

运行`make test`以运行QuickJS存档中包含的一些内置测试。

### 2.6 Test262 (ECMAScript 测试套件))

QuickJS存档中包含test262运行程序。

作为参考，完整的test262测试在档案qjs-tests-yyyy-mm-dd.tar.xz中提供。您只需将其解压缩到QuickJS源代码目录中即可。

或者，test262测试可以安装：

```
git clone https://github.com/tc39/test262.git test262
cd test262
git checkout 94b1e80ab3440413df916cd56d29c5a2fa2ac451
patch -p1 < ../tests/test262.patch
cd ..
```

补丁添加了特定于实现的`harness`函数，并优化了低效的RegExp字符类和Unicode属性转义测试（测试本身不会被修改，只有慢速字符串初始化函数被优化）。

测试可以运行

```
make test2
```

有关更多信息，请运行`./run-test262`以查看test262 runner的选项。配置文件`test262.conf`并`test262bn.conf`包含运行各种测试的选项。

3 技术规范
----------------

### 3.1 语言支持

#### 3.1.1 ES2019支持

The ES2019 specification [2](#FOOT2) is almost fully supported including the Annex B (legacy web compatibility) and the Unicode related features. The following features are not supported yet:

*   Realms (althougth the C API supports different runtimes and contexts)
*   Tail calls[3](#FOOT3)

#### 3.1.2 JSON

The JSON parser is currently more tolerant than the specification.

#### 3.1.3 ECMA402

ECMA402 (Internationalization API) is not supported.

#### 3.1.4 扩展

*   The directive `"use strip"` indicates that the debug information (including the source code of the functions) should not be retained to save memory. As `"use strict"`, the directive can be global to a script or local to a function.
*   The first line of a script beginning with `#!` is ignored.

#### 3.1.5 数学扩展

The mathematical extensions are available in the `qjsbn` version and are fully backward compatible with standard Javascript. See `jsbignum.pdf` for more information.

*   The `BigInt` (big integers) TC39 proposal is supported.
*   `BigFloat` support: arbitrary large floating point numbers in base 2.
*   Operator overloading.
*   The directive `"use bigint"` enables the bigint mode where integers are `BigInt` by default.
*   The directive `"use math"` enables the math mode where the division and power operators on integers produce fractions. Floating point literals are `BigFloat` by default and integers are `BigInt` by default.

### 3.2 模块

ES6 modules are fully supported. The default name resolution is the following:

*   Module names with a leading `.` or `..` are relative to the current module path.
*   Module names without a leading `.` or `..` are system modules, such as `std` or `os`.
*   Module names ending with `.so` are native modules using the QuickJS C API.

### 3.3 标准库

The standard library is included by default in the command line interpreter. It contains the two modules `std` and `os` and a few global objects.

#### 3.3.1 全局对象

`scriptArgs`

Provides the command line arguments. The first argument is the script name.

`print(...args)`

Print the arguments separated by spaces and a trailing newline.

`console.log(...args)`

Same as print().

#### 3.3.2 `std` 模块

The `std` module provides wrappers to the libc stdlib.h and stdio.h and a few other utilities.

Available exports:

`exit(n)`

Exit the process.

`evalScript(str)`

Evaluate the string `str` as a script (global eval).

`loadScript(filename)`

Evaluate the file `filename` as a script (global eval).

`Error(errno)`

`std.Error` constructor. Error instances contain the field `errno` (error code) and `message` (result of `std.Error.strerror(errno)`).

The constructor contains the following fields:

`EINVAL`

`EIO`

`EACCES`

`EEXIST`

`ENOSPC`

`ENOSYS`

`EBUSY`

`ENOENT`

`EPERM`

`EPIPE`

Integer value of common errors (additional error codes may be defined).

`strerror(errno)`

Return a string that describes the error `errno`.

`open(filename, flags)`

Open a file (wrapper to the libc `fopen()`). Throws `std.Error` in case of I/O error.

`tmpfile()`

Open a temporary file. Throws `std.Error` in case of I/O error.

`puts(str)`

Equivalent to `std.out.puts(str)`.

`printf(fmt, ...args)`

Equivalent to `std.out.printf(fmt, ...args)`

`sprintf(fmt, ...args)`

Equivalent to the libc sprintf().

`in`

`out`

`err`

Wrappers to the libc file `stdin`, `stdout`, `stderr`.

`SEEK_SET`

`SEEK_CUR`

`SEEK_END`

Constants for seek().

`global`

Reference to the global object.

`gc()`

Manually invoke the cycle removal algorithm. The cycle removal algorithm is automatically started when needed, so this function is useful in case of specific memory constraints or for testing.

`getenv(name)`

Return the value of the environment variable `name` or `undefined` if it is not defined.

FILE prototype:

`close()`

Close the file.

`puts(str)`

Outputs the string with the UTF-8 encoding.

`printf(fmt, ...args)`

Formatted printf, same formats as the libc printf.

`flush()`

Flush the buffered file.

`seek(offset, whence)`

Seek to a give file position (whence is `std.SEEK_*`). Throws a `std.Error` in case of I/O error.

`tell()`

Return the current file position.

`eof()`

Return true if end of file.

`fileno()`

Return the associated OS handle.

`read(buffer, position, length)`

Read `length` bytes from the file to the ArrayBuffer `buffer` at byte position `position` (wrapper to the libc `fread`).

`write(buffer, position, length)`

Write `length` bytes to the file from the ArrayBuffer `buffer` at byte position `position` (wrapper to the libc `fread`).

`getline()`

Return the next line from the file, assuming UTF-8 encoding, excluding the trailing line feed.

`getByte()`

Return the next byte from the file.

`putByte(c)`

Write one byte to the file.

#### 3.3.3 `os` 模块

The `os` module provides Operating System specific functions:

*   low level file access
*   signals
*   timers
*   asynchronous I/O

The OS functions usually return 0 if OK or an OS specific negative error code.

Available exports:

`open(filename, flags, mode = 0o666)`

Open a file. Return a handle or < 0 if error.

`O_RDONLY`

`O_WRONLY`

`O_RDWR`

`O_APPEND`

`O_CREAT`

`O_EXCL`

`O_TRUNC`

POSIX open flags.

`O_TEXT`

(Windows specific). Open the file in text mode. The default is binary mode.

`close(fd)`

Close the file handle `fd`.

`seek(fd, offset, whence)`

Seek in the file. Use `std.SEEK_*` for `whence`.

`read(fd, buffer, offset, length)`

Read `length` bytes from the file handle `fd` to the ArrayBuffer `buffer` at byte position `offset`. Return the number of read bytes or < 0 if error.

`write(fd, buffer, offset, length)`

Write `length` bytes to the file handle `fd` from the ArrayBuffer `buffer` at byte position `offset`. Return the number of written bytes or < 0 if error.

`isatty(fd)`

Return `true` is `fd` is a TTY (terminal) handle.

`ttyGetWinSize(fd)`

Return the TTY size as `[width, height]` or `null` if not available.

`ttySetRaw(fd)`

Set the TTY in raw mode.

`remove(filename)`

Remove a file. Return 0 if OK or < 0 if error.

`rename(oldname, newname)`

Rename a file. Return 0 if OK or < 0 if error.

`setReadHandler(fd, func)`

Add a read handler to the file handle `fd`. `func` is called each time there is data pending for `fd`. A single read handler per file handle is supported. Use `func = null` to remove the hander.

`setWriteHandler(fd, func)`

Add a write handler to the file handle `fd`. `func` is called each time data can be written to `fd`. A single write handler per file handle is supported. Use `func = null` to remove the hander.

`signal(signal, func)`

Call the function `func` when the signal `signal` happens. Only a single handler per signal number is supported. Use `null` to set the default handler or `undefined` to ignore the signal.

`SIGINT`

`SIGABRT`

`SIGFPE`

`SIGILL`

`SIGSEGV`

`SIGTERM`

POSIX signal numbers.

`setTimeout(delay, func)`

Call the function `func` after `delay` ms. Return a handle to the timer.

`clearTimer(handle)`

Cancel a timer.

`platform`

Return a string representing the platform: `"linux"`, `"darwin"`, `"win32"` or `"js"`.

### 3.4 QuickJS C API

The C API was designed to be simple and efficient. The C API is defined in the header `quickjs.h`.

#### 3.4.1 运行时和上下文

`JSRuntime` represents a Javascript runtime corresponding to an object heap. Several runtimes can exist at the same time but they cannot exchange objects. Inside a given runtime, no multi-threading is supported.

`JSContext` represents a Javascript context (or Realm). Each JSContext has its own global objects and system objects. There can be several JSContexts per JSRuntime and they can share objects, similary to frames of the same origin sharing Javascript objects in a web browser.

#### 3.4.2 JSValue

`JSValue` represents a Javascript value which can be a primitive type or an object. Reference counting is used, so it is important to explicitely duplicate (`JS_DupValue()`, increment the reference count) or free (`JS_FreeValue()`, decrement the reference count) JSValues.

#### 3.4.3 C函数

C functions can be created with `JS_NewCFunction()`. `JS_SetPropertyFunctionList()` is a shortcut to easily add functions, setters and getters properties to a given object.

Unlike other embedded Javascript engines, there is no implicit stack, so C functions get their parameters as normal C parameters. As a general rule, C functions take constant `JSValue`s as parameters (so they don’t need to free them) and return a newly allocated (=live) `JSValue`.

#### 3.4.4 错误异常

Exceptions: most C functions can return a Javascript exception. It must be explicitely tested and handled by the C code. The specific `JSValue` `JS_EXCEPTION` indicates that an exception occured. The actual exception object is stored in the `JSContext` and can be retrieved with `JS_GetException()`.

#### 3.4.5 Script代码执行

Use `JS_Eval()` to evaluate a script or module source.

If the script or module was compiled to bytecode with `qjsc`, `JS_EvalBinary()` achieves the same result. The advantage is that no compilation is needed so it is faster and smaller because the compiler can be removed from the executable if no `eval` is required.

Note: the bytecode format is linked to a given QuickJS version. Moreover, no security check is done before its execution. Hence the bytecode should not be loaded from untrusted sources. That’s why there is no option to output the bytecode to a binary file in `qjsc`.

#### 3.4.6 JS类

C opaque data can be attached to a Javascript object. The type of the C opaque data is determined with the class ID (`JSClassID`) of the object. Hence the first step is to register a new class ID and JS class (`JS_NewClassID()`, `JS_NewClass()`). Then you can create objects of this class with `JS_NewObjectClass()` and get or set the C opaque point with `JS_GetOpaque()`/`JS_SetOpaque()`.

When defining a new JS class, it is possible to declare a finalizer which is called when the object is destroyed. A `gc_mark` method can be provided so that the cycle removal algorithm can find the other objects referenced by this object. Other methods are available to define exotic object behaviors.

The Class ID are globally allocated (i.e. for all runtimes). The JSClass are allocated per `JSRuntime`. `JS_SetClassProto()` is used to define a prototype for a given class in a given JSContext. `JS_NewObjectClass()` sets this prototype in the created object.

Examples are available in js\_libc.c.

#### 3.4.7 C模块

Native ES6 modules are supported and can be dynamically or statically linked. Look at the test\_bjson and bjson.so examples. The standard library js\_libc.c is also a good example of a native module.

#### 3.4.8 内存处理

Use `JS_SetMemoryLimit()` to set a global memory allocation limit to a given JSRuntime.

Custom memory allocation functions can be provided with `JS_NewRuntime2()`.

The maximum system stack size can be set with `JS_SetMaxStackSize()`.

#### 3.4.9 执行超时和中断

Use `JS_SetInterruptHandler()` to set a callback which is regularly called by the engine when it is executing code. This callback can be used to implement an execution timeout.

It is used by the command line interpreter to implement a `Ctrl-C` handler.

4 内部实现
-----------

### 4.1 Bytecode

The compiler generates bytecode directly with no intermediate representation such as a parse tree, hence it is very fast. Several optimizations passes are done over the generated bytecode.

A stack-based bytecode was chosen because it is simple and generates compact code.

For each function, the maximum stack size is computed at compile time so that no runtime stack overflow tests are needed.

A separate compressed line number table is maintained for the debug information.

Access to closure variables is optimized and is almost as fast as local variables.

Direct `eval` in strict mode is optimized.

### 4.2 Executable generation

#### 4.2.1 `qjsc` 编译器

The `qjsc` compiler generates C sources from Javascript files. By default the C sources are compiled with the system compiler (`gcc` or `clang`).

The generated C source contains the bytecode of the compiled functions or modules. If a full complete executable is needed, it also contains a `main()` function with the necessary C code to initialize the Javascript engine and to load and execute the compiled functions and modules.

Javascript code can be mixed with C modules.

In order to have smaller executables, specific Javascript features can be disabled, in particular `eval` or the regular expressions. The code removal relies on the Link Time Optimization of the system compiler.

#### 4.2.2 二进制 JSON

`qjsc` works by compiling scripts or modules and then serializing them to a binary format. A subset of this format (without functions or modules) can be used as binary JSON. The example test\_bjson.js shows how to use it.

Warning: the binary JSON format may change without notice, so it should not be used to store persistent data. The test\_bjson.js example is only used to test the binary object format functions.

### 4.3 运行时

#### 4.3.1 Strings

Strings are stored either as an 8 bit or a 16 bit array of characters. Hence random access to characters is always fast.

The C API provides functions to convert Javascript Strings to C UTF-8 encoded strings. The most common case where the Javascript string contains only ASCII characters involves no copying.

#### 4.3.2 Objects

The object shapes (object prototype, property names and flags) are shared between objects to save memory.

Arrays with no holes (except at the end of the array) are optimized.

TypedArray accesses are optimized.

#### 4.3.3 Atoms

Object property names and some strings are stored as Atoms (unique strings) to save memory and allow fast comparison. Atoms are represented as a 32 bit integer. Half of the atom range is reserved for immediate integer literals from _0_ to _2^{31}-1_.

#### 4.3.4 Numbers

Numbers are represented either as 32-bit signed integers or 64-bit IEEE-754 floating point values. Most operations have fast paths for the 32-bit integer case.

#### 4.3.5 垃圾回收

Reference counting is used to free objects automatically and deterministically. A separate cycle removal pass is done when the allocated memory becomes too large. The cycle removal algorithm only uses the reference counts and the object content, so no explicit garbage collection roots need to be manipulated in the C code.

#### 4.3.6 JSValue

It is a Javascript value which can be a primitive type (such as Number, String, ...) or an Object. NaN boxing is used in the 32-bit version to store 64-bit floating point numbers. The representation is optimized so that 32-bit integers and reference counted values can be efficiently tested.

In 64-bit code, JSValue are 128-bit large and no NaN boxing is used. The rationale is that in 64-bit code memory usage is less critical.

In both cases (32 or 64 bits), JSValue exactly fits two CPU registers, so it can be efficiently returned by C functions.

#### 4.3.7 Function call

The engine is optimized so that function calls are fast. The system stack holds the Javascript parameters and local variables.

### 4.4 RegExp

A specific regular expression engine was developped. It is both small and efficient and supports all the ES2019 features including the Unicode properties. As the Javascript compiler, it directly generates bytecode without a parse tree.

Backtracking with an explicit stack is used so that there is no recursion on the system stack. Simple quantizers are specifically optimized to avoid recursions.

Infinite recursions coming from quantizers with empty terms are avoided.

The full regexp library weights about 15 KiB (x86 code), excluding the Unicode library.

### 4.5 Unicode

A specific Unicode library was developped so that there is no dependency on an external large Unicode library such as ICU. All the Unicode tables are compressed while keeping a reasonnable access speed.

The library supports case conversion, Unicode normalization, Unicode script queries, Unicode general category queries and all Unicode binary properties.

The full Unicode library weights about 45 KiB (x86 code).

### 4.6 BigInt and BigFloat

BigInt and BigFloat are implemented with the `libbf` library[4](#FOOT4). It weights about 60 KiB (x86 code) and provides arbitrary precision IEEE 754 floating point operations and transcendental functions with exact rounding.

5 许可协议
---------

QuickJS is released under the MIT license.

Unless otherwise specified, the QuickJS sources are copyright Fabrice Bellard and Charlie Gordon.

* * *

#### Footnotes

### [(1)](#DOCF1)

[https://github.com/tc39/test262](https://github.com/tc39/test262)

### [(2)](#DOCF2)

[https://tc39.github.io/ecma262/](https://tc39.github.io/ecma262/)

### [(3)](#DOCF3)

We believe the current specification of tails calls is too complicated and presents limited practical interests.

### [(4)](#DOCF4)

[https://bellard.org/libbf](https://bellard.org/libbf)

* * *

6 相关项目
---------

- [QuickJS-iOS](https://github.com/siuying/QuickJS-iOS) iOS下的QuickJS库

- [quickjs-rs](https://github.com/quickjs-zh/quickjs-rs) Rust的QuickJS库

- [quickjspp](https://github.com/quickjs-zh/quickjs-rs) C++的QuickJS库

- [go-quickjs](https://github.com/wspl/go-quickjs) Go的QuickJS库


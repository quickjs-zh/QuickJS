QuickJS Javascript引擎
=========================

目录
-----------------

*   [1 简介](#1-简介)
    *   [1.1 主要功能](#11-主要功能)
    *   [1.2 基准测试](#12-基准测试)
*   [2 用法](#2-用法)
    *   [2.1 安装](#21-安装)
    *   [2.2 快速入门](#22-快速入门)
    *   [2.3 命令行选项](#23-命令行选项)
        *   [2.3.1 `qjs` 解释器](#231-qjs-解释器)
        *   [2.3.2 `qjsc` 编译器](#232-qjsc-编译器)
    *   [2.4 `qjscalc` 应用程序](#24-qjscalc-应用程序)
    *   [2.5 内置测试](#25-内置测试)
    *   [2.6 Test262 (ECMAScript测试套件)](#26-test262-ecmascript-测试套件)
*   [3 技术规范](#3-技术规范)
    *   [3.1 语言支持](#31-语言支持)
        *   [3.1.1 ES2019支持](#311-es2019支持)
        *   [3.1.2 JSON](#312-json)
        *   [3.1.3 ECMA402](#313-ecma402)
        *   [3.1.4 扩展](#314-扩展)
        *   [3.1.5 数学扩展](#315-数学扩展)
    *   [3.2 模块](#32-模块)
    *   [3.3 标准库](#33-标准库)
        *   [3.3.1 全局对象](#331-全局对象)
        *   [3.3.2 `std` 模块](#332-std-模块)
        *   [3.3.3 `os` 模块](#333-os-模块)
    *   [3.4 QuickJS C API](#34-quickjs-c-api)
        *   [3.4.1 运行时和上下文](#341-运行时和上下文)
        *   [3.4.2 JSValue](#342-jsvalue)
        *   [3.4.3 C函数](#343-c函数)
        *   [3.4.4 错误异常](#344-错误异常)
        *   [3.4.5 Script代码执行](#345-script代码执行)
        *   [3.4.6 JS类](#346-js类)
        *   [3.4.7 C模块](#347-c模块)
        *   [3.4.8 内存处理](#348-内存处理)
        *   [3.4.9 执行超时和中断](#349-执行超时和中断)
*   [4 内部实现](#4-内部实现)
    *   [4.1 Bytecode](#41-bytecode)
    *   [4.2 Executable generation](#42-executable-generation)
        *   [4.2.1 `qjsc` 编译器](#421-qjsc-编译器)
        *   [4.2.2 二进制 JSON](#422-二进制-json)
    *   [4.3 运行时](#43-运行时)
        *   [4.3.1 Strings](#431-strings)
        *   [4.3.2 Objects](#432-objects)
        *   [4.3.3 Atoms](#433-atoms)
        *   [4.3.4 Numbers](#434-numbers)
        *   [4.3.5 垃圾回收](#435-垃圾回收)
        *   [4.3.6 JSValue](#436-jsvalue)
        *   [4.3.7 函数调用](#437-函数调用)
    *   [4.4 RegExp](#44-regexp)
    *   [4.5 Unicode](#45-unicode)
    *   [4.6 BigInt and BigFloat](#46-bigint-and-bigfloat)
*   [5 许可协议](#5-许可协议)
*   [6 相关项目](#6-相关项目)

1 简介
--------------

QuickJS是一个小型并且可嵌入的Javascript引擎，它支持ES2020规范，包括模块，异步生成器和代理器。

它可选支持数学扩展，例如大整数 (BigInt)，大浮点数 (BigFloat) 以及运算符重载。

------

官方站点：https://bellard.org/quickjs/

中文站点：https://github.com/quickjs-zh/

QuickJS QQ群：**598609506**。

中文Wiki：https://github.com/quickjs-zh/QuickJS/wiki

### 1.1 主要功能

*   轻量而且易于嵌入：只需几个C文件，没有外部依赖，一个x86下的简单的“hello world”程序只要180 KiB。
*   具有极低启动时间的快速解释器： 在一台单核的台式PC上，大约在100秒内运行ECMAScript 测试套件[1](#FOOT1) 56000次。运行时实例的完整生命周期在不到300微秒的时间内完成。
*   几乎完整实现[ES2019](https://www.ecma-international.org/ecma-262/10.0)支持，包括： 模块，异步生成器和和完整Annex B支持 (传统的Web兼容性)。许多[ES2020](https://tc39.github.io/ecma262/)中带来的特性也依然会被支持。
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

**注**：可以参考QuickJS中文关于[Windows下编译安装](https://github.com/quickjs-zh/QuickJS/wiki/%E5%9C%A8Windows%E4%B8%8B%E7%BC%96%E8%AF%91QuickJS)及[Linux下编译安装](https://github.com/quickjs-zh/QuickJS/wiki/%E5%9C%A8Linux%E4%B8%8B%E7%BC%96%E8%AF%91QuickJS)相关文档。

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

包含Annex B (遗留Web兼容)和Unicode相关功能的ES2019规范 [2](#FOOT2) 已经基本支持。 目前尚未支持以下功能:

*   Realms (尽管C API支持不同的运行时和上下文)
*   Tail calls[3](#FOOT3)

#### 3.1.2 JSON

JSON解析器目前比规范支持范围更宽.

#### 3.1.3 ECMA402

ECMA402 (国际化API)尚未支持.

#### 3.1.4 扩展

*   指令 `"use strip"` 不保留调试信息 (包括函数源代码) 以节省内存。 `"use strict"`指令可以应用全局脚本，或者特定函数。
*   脚本开头第一行 `#!` 会被忽略。

#### 3.1.5 数学扩展

数学扩展在`qjsbn` 版本中可用，并且完全向后兼容标准Javascript. 查看`jsbignum.pdf`获取更多信息。

*   `BigInt` (大整数) TC39已经支持。
*   `BigFloat` 支持: 基数2中任意大浮点数。
*   运算符重载。
*   指令`"use bigint"`启用bigint模式， `BigInt`默认情况下为整数。
*   指令`"use math"`启用数学模式，其中整数上的除法和幂运算符产生分数。BigFloat默认情况下，浮点文字是默认值，整数是BigInt默认值。

### 3.2 模块

ES6模块完全支持。默认名称解析规则如下：

*   模块名称带有前导`.`或 `..`是相对于当前模块的路径。
*   模块名称没有前导`.`或`..`是系统模块，例如`std`或`os`。
*   模块名称以`.so`结尾，是使用QuickJS C API的原生模块。

### 3.3 标准库

默认情况下，标准库包含在命令行解释器中。 它包含两个模块`std`和`os`以及一些全局对象.

#### 3.3.1 全局对象

`scriptArgs`

提供命令行参数。第一个参数是脚本名称。

`print(...args)`

打印由空格和尾随换行符分隔的参数。

`console.log(...args)`

与print()相同。

#### 3.3.2 `std` 模块

该`std`模块为libc提供包装器stdlib.h和stdio.h和其他一些实用程序。

可用出口：

`exit(n)`

退出进程。

`evalScript(str)`

将字符串`str`以脚本方式运行（全局eval）。

`loadScript(filename)`

将文件`filename`以脚本方式运行（全局eval）。

`Error(errno)`

`std.Error` 构造函数。 错误实例包含字段`errno`（错误代码）和`message`（`std.Error.strerror(errno)`的结果）。

构造函数包含以下字段：

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

常见错误的整数值 （可以定义附加错误代码）。

`strerror(errno)`

返回描述错误的字符串`errno`.

`open(filename, flags)`

打开一个文件（libc的包装器`fopen()`）。在I/O错误时抛出 `std.Error` 

`tmpfile()`

打开一个临时文件。在I/O错误时抛出`std.Error` 。

`puts(str)`

相当于`std.out.puts(str)`.

`printf(fmt, ...args)`

相当于`std.out.printf(fmt, ...args)`

`sprintf(fmt, ...args)`

相当于libc的sprintf().

`in`

`out`

`err`

包装libc文件的`stdin`, `stdout`, `stderr`.

`SEEK_SET`

`SEEK_CUR`

`SEEK_END`

seek()的常量

`global`

引用全局对象。

`gc()`

手动调用循环删除算法。循环移除算法在需要时自动启动，因此该功能在特定内存限制或测试时非常有用。

`getenv(name)`

返回环境变量的值 `name` ，或未定义时返回 `undefined` .

FILE 原型：

`close()`

关闭文件。

`puts(str)`

使用UTF-8编码输出字符串。

`printf(fmt, ...args)`

格式化printf，与libc printf格式相同。

`flush()`

刷新缓冲的文件。

`seek(offset, whence)`

寻找特定文件位置 (从哪里`std.SEEK_*`)。在I/O错误时抛出 `std.Error`。

`tell()`

返回当前文件位置。

`eof()`

如果文件结束，则返回true。

`fileno()`

返回关联的OS句柄。

`read(buffer, position, length)`

Read `length` bytes from the file to the ArrayBuffer `buffer` at byte position `position` （libc的包装器`fread`）。

`write(buffer, position, length)`

Write `length` bytes to the file from the ArrayBuffer `buffer` at byte position `position` (wrapper to the libc `fread`).

`getline()`

返回文件中的下一行，假设为UTF-8编码，不包括尾随换行符。

`getByte()`

返回文件中的下一个字节。

`putByte(c)`

将一个字节写入文件。

#### 3.3.3 `os` 模块

 `os` 模块提供操作系统特定功能：

*   底层文件访问
*   信号
*   计时器
*   异步 I/O

如果是OK，OS函数通常返回0，或者OS返回特定的错误代码。

可用导出函数：

`open(filename, flags, mode = 0o666)`

打开一个文件。如果错误，返回句柄或<0。

`O_RDONLY`

`O_WRONLY`

`O_RDWR`

`O_APPEND`

`O_CREAT`

`O_EXCL`

`O_TRUNC`

POSIX打开标志。

`O_TEXT`

(Windows特定)。以文本模式打开文件。默认为二进制模式。

`close(fd)`

关闭文件句柄`fd`.

`seek(fd, offset, whence)`

寻找文件。使用 `std.SEEK_*` 或 `whence`.

`read(fd, buffer, offset, length)`

Read `length` bytes from the file handle `fd` to the ArrayBuffer `buffer` at byte position `offset`. Return the number of read bytes or < 0 if error.

`write(fd, buffer, offset, length)`

Write `length` bytes to the file handle `fd` from the ArrayBuffer `buffer` at byte position `offset`. Return the number of written bytes or < 0 if error.

`isatty(fd)`

`fd` 是一个TTY (终端)句柄返回 `true` 。

`ttyGetWinSize(fd)`

返回TTY大小 `[width, height]` 或者如果不可用返回 `null` 。

`ttySetRaw(fd)`

在原始模式下设置TTY。

`remove(filename)`

删除文件。如果正常则返回0，如果错误则返回<0

`rename(oldname, newname)`

重命名文件。如果正常则返回0，如果错误则返回<0

`setReadHandler(fd, func)`

将读处理程序添加到文件句柄`fd`。 `fd`每次有数据待增加处理时调用`func` 。支持每个文件句柄的单个读处理程序。使用 `func = null` 来删除句柄。

`setWriteHandler(fd, func)`

将写处理程序添加到文件句柄`fd`。  `fd`每次有数据待写入处理时调用`func` . 支持每个文件句柄一个写处理程序。使用 `func = null来删除句柄。

`signal(signal, func)`

当信号 `signal` 发生时调用 `func` 。 每个信号编号只支持一个处理程序。使用 `null` 设定的默认处理或 `undefined` 忽略的信号。

`SIGINT`

`SIGABRT`

`SIGFPE`

`SIGILL`

`SIGSEGV`

`SIGTERM`

POSIX 信号编号。

`setTimeout(func, delay)`

在 `delay` 毫秒之后调用函数 `func` 。返回计时器的句柄。

`clearTimer(handle)`

取消计时器。

`platform`

返回表示该平台的字符串： `"linux"`, `"darwin"`, `"win32"` or `"js"`.

### 3.4 QuickJS C API

C API的设计简单而有效。C API在`quickjs.h`标头中定义。

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

支持动态或者静态链接的原生ES6模块。查看test\_bjson和bjson.so示例。标准库js\_libc.c也是原生模块很好的一个例子。

#### 3.4.8 内存处理

使用 `JS_SetMemoryLimit()` 为给定的JSRuntime设置全局内存分配限制。

`JS_NewRuntime2()`可以提供自定义内存分配功能。

`JS_SetMaxStackSize()`可以使用设置最大系统堆栈大小

#### 3.4.9 执行超时和中断

Use `JS_SetInterruptHandler()` to set a callback which is regularly called by the engine when it is executing code. This callback can be used to implement an execution timeout.

命令行解释器使用它来实现 `Ctrl-C` 处理程序。

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

字符串存储为8位或16位字符数组。因此，随机访问字符总是很快。

C API提供将Javascript字符串转换为C UTF-8编码字符串的函数。最常见情况是 Javascript字符串仅包含ASCII 字符串不涉及复制。

#### 4.3.2 Objects

The object shapes (object prototype, property names and flags) are shared between objects to save memory.

Arrays with no holes (except at the end of the array) are optimized.

TypedArray访问已优化。

#### 4.3.3 Atoms

Object property names and some strings are stored as Atoms (unique strings) to save memory and allow fast comparison. Atoms are represented as a 32 bit integer. Half of the atom range is reserved for immediate integer literals from _0_ to _2^{31}-1_.

#### 4.3.4 Numbers

Numbers are represented either as 32-bit signed integers or 64-bit IEEE-754 floating point values. Most operations have fast paths for the 32-bit integer case.

#### 4.3.5 垃圾回收

引用计数用于自动和准确地释放对象。A separate cycle removal pass is done when the allocated memory becomes too large. The cycle removal algorithm only uses the reference counts and the object content, so no explicit garbage collection roots need to be manipulated in the C code.

#### 4.3.6 JSValue

It is a Javascript value which can be a primitive type (such as Number, String, ...) or an Object. NaN boxing is used in the 32-bit version to store 64-bit floating point numbers. The representation is optimized so that 32-bit integers and reference counted values can be efficiently tested.

In 64-bit code, JSValue are 128-bit large and no NaN boxing is used. The rationale is that in 64-bit code memory usage is less critical.

In both cases (32 or 64 bits), JSValue exactly fits two CPU registers, so it can be efficiently returned by C functions.

#### 4.3.7 函数调用

引擎已经过优化，因此函数调用很快。系统堆栈包含Javascript参数和局部变量。

### 4.4 RegExp

开发了一个特定的正则表达式引擎。它既小又高效，并支持所有ES2019功能，包括Unicode属性。作为Javascript编译器，它直接生成没有解析树的字节码。

使用显式堆栈的回溯使得系统堆栈上没有递归。简单的量化器经过专门优化，以避免递归。

来自具有空项的量化器的无限递归被避免。

完整的正则表达式文件库的权重约为15 KiB（x86代码），不包括Unicode库。

### 4.5 Unicode

开发了一个特定的Unicode库，因此不依赖于外部大型Unicode库，例如ICU。压缩所有Unicode表，同时保持合理的访问速度。

该库支持大小写转换，Unicode规范化，Unicode脚本查询，Unicode常规类别查询和所有Unicode二进制属性。

完整的Unicode库大约重量为45 KiB（x86代码）。

### 4.6 BigInt 和 BigFloat

BigInt 和 BigFloat 是用`libbf` 库 `libbf` 库实现的[4](#FOOT4)。 它大概有60 KiB (x86 代码) 并提供任意精度的IEEE 754 浮点运算和具有精确舍入的超越函数。

5 许可协议
---------

QuickJS 在MIT协议下发布。

除非另有说明，否则QuickJS来源的版权归Fabrice Bellard和Charlie Gordon所有。

* * *

#### 脚注

### [(1)](#DOCF1)

[https://github.com/tc39/test262](https://github.com/tc39/test262)

### [(2)](#DOCF2)

[https://tc39.github.io/ecma262/](https://tc39.github.io/ecma262/)

### [(3)](#DOCF3)

我们认为目前的尾部调用规范过于复杂，并且实际利益有限。

### [(4)](#DOCF4)

[https://bellard.org/libbf](https://bellard.org/libbf)

* * *

6 相关项目
---------

- [QuickJS-iOS](https://github.com/siuying/QuickJS-iOS) iOS下的QuickJS库

- [quickjs-rs](https://github.com/quickjs-zh/quickjs-rs) Rust的QuickJS库

- [quickjspp](https://github.com/quickjs-zh/quickjspp) C++的QuickJS库

- [go-quickjs](https://github.com/wspl/go-quickjs) Go的QuickJS库

- [qjsuv](https://github.com/saghul/qjsuv) QuickJS ❤️ libuv

- [QuickJS-Pascal](https://github.com/Coldzer0/QuickJS-Pascal) Quickjs FreePascal / Delphi Bindings

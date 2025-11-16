QuickJS JavaScript 引擎
=========================

目录
-----------------

- [QuickJS JavaScript 引擎](#quickjs-javascript-引擎)
  - [目录](#目录)
  - [1 简介](#1-简介)
    - [1.1 主要功能](#11-主要功能)
  - [2 用法](#2-用法)
    - [2.1 安装](#21-安装)
    - [2.2 快速入门](#22-快速入门)
    - [2.3 命令行选项](#23-命令行选项)
      - [2.3.1 `qjs` 解释器](#231-qjs-解释器)
      - [2.3.2 `qjsc` 编译器](#232-qjsc-编译器)
    - [2.4 内置测试](#24-内置测试)
    - [2.5 Test262 (ECMAScript 测试套件)](#25-test262-ecmascript-测试套件)
  - [3 技术规范](#3-技术规范)
    - [3.1 语言支持](#31-语言支持)
      - [3.1.1 ES2023 支持](#311-es2023-支持)
      - [3.1.2 ECMA402](#312-ecma402)
    - [3.2 模块](#32-模块)
    - [3.3 标准库](#33-标准库)
      - [3.3.1 全局对象](#331-全局对象)
      - [3.3.2 `std` 模块](#332-std-模块)
      - [3.3.3 `os` 模块](#333-os-模块)
    - [3.4 QuickJS C API](#34-quickjs-c-api)
      - [3.4.1 运行时与上下文](#341-运行时与上下文)
      - [3.4.2 JSValue](#342-jsvalue)
      - [3.4.3 C 函数](#343-c-函数)
      - [3.4.4 异常](#344-异常)
      - [3.4.5 脚本评估](#345-脚本评估)
      - [3.4.6 JS 类](#346-js-类)
      - [3.4.7 C 模块](#347-c-模块)
      - [3.4.8 内存处理](#348-内存处理)
      - [3.4.9 执行超时与中断](#349-执行超时与中断)
  - [4 内部实现](#4-内部实现)
    - [4.1 字节码](#41-字节码)
    - [4.2 可执行文件生成](#42-可执行文件生成)
      - [4.2.1 `qjsc` 编译器](#421-qjsc-编译器)
      - [4.2.2 二进制 JSON](#422-二进制-json)
    - [4.3 运行时](#43-运行时)
      - [4.3.1 字符串](#431-字符串)
      - [4.3.2 对象](#432-对象)
      - [4.3.3 原子](#433-原子)
      - [4.3.4 数值](#434-数值)
      - [4.3.5 垃圾回收](#435-垃圾回收)
      - [4.3.6 JSValue](#436-jsvalue)
      - [4.3.7 函数调用](#437-函数调用)
    - [4.4 正则表达式](#44-正则表达式)
    - [4.5 Unicode](#45-unicode)
    - [4.6 BigInt](#46-bigint)
  - [5 许可](#5-许可)
  - [脚注](#脚注)
  - [6 相关项目](#6-相关项目)

1 简介
--------------

QuickJS是一个小型并且可嵌入的Javascript引擎，它支持ES2020规范，包括模块，异步生成器和代理器。

它可选支持数学扩展，例如大整数 (BigInt)，大浮点数 (BigFloat) 以及运算符重载。

------

官方站点：https://bellard.org/quickjs/

中文站点：https://github.com/quickjs-zh/

QuickJS QQ群1：**598609506**。

中文Wiki：https://github.com/quickjs-zh/QuickJS/wiki

### 1.1 主要功能

* 小巧且易于嵌入：仅需少量 C 文件，无外部依赖；在 x86 上，一个简易 “hello world” 程序约 210 KiB。
* 启动极快的解释器：在台式机的单核上，运行 ECMAScript 测试套件[2] 的 77000 个测试用例用时不到 2 分钟。运行时实例的完整生命周期在不到 300 微秒内完成。
* 几乎完整的 ES2023 支持，包括模块、异步生成器以及完整的 Annex B（传统 Web 兼容性）。部分 ES2024[3] 的特性也已支持。
* 在选择 ES2023 特性时，几乎通过 100% 的 ECMAScript 测试套件用例。
* 可将 JavaScript 源代码编译为无外部依赖的可执行文件。
* 采用引用计数并结合循环删除的垃圾回收（降低内存占用并具备确定性行为）。
* 以 JavaScript 实现的带上下文着色与补全的命令行解释器。
* 内置体积小的标准库，提供 C 标准库封装。

2 用法
-------

### 2.1 安装

提供 `Makefile`，可在 Linux 或 MacOS/X 上编译。通过在 Linux 主机上使用 MingGW 工具进行交叉编译，可获得初步的 Windows 支持。

如需选择特定编译选项，请编辑 `Makefile` 顶部，然后运行 `make`。

若希望将二进制和支持文件安装到 `/usr/local`（使用 QuickJS 并非必需），可使用 `root` 身份执行：

```
make install
```

注意：在某些操作系统上，原子操作不可用或需要特定库。如果遇到相关错误，可以在 `Makefile` 的 `LIBS` 变量中添加 `-latomics`，或在 `quickjs.c` 中禁用 `CONFIG_ATOMICS`。

### 2.2 快速入门

`qjs` 是命令行解释器（REPL）。可以将 JavaScript 文件和/或表达式作为参数传入以执行：

```
./qjs examples/hello.js
```

`qjsc` 是命令行编译器：

```
./qjsc -o hello examples/hello.js
./hello
```

生成一个不依赖外部库的 `hello` 可执行文件。

### 2.3 命令行选项

#### 2.3.1 `qjs` 解释器

```
usage: qjs [options] [file [args]]
```

选项：

`-h`, `--help`

列出选项。

``-e `EXPR` ``, ``--eval `EXPR` ``

执行表达式 EXPR。

`-i`, `--interactive`

进入交互模式（当命令行上提供了文件时，默认不为交互模式）。

`-m`, `--module`

作为 ES6 模块加载（默认=自动检测）。当文件扩展名为 `.mjs` 或源码的第一个关键词为 `import` 时自动检测为模块。

`--script`

作为 ES6 脚本加载（默认=自动检测）。

`-I file`, `--include file`

包含一个额外的文件。

高级选项：

`--std`

即使加载的不是模块，也让 `std` 与 `os` 模块可用。

`-d`, `--dump`

转储内存使用统计信息。

`-q`, `--quit`

仅实例化解释器后立即退出。

#### 2.3.2 `qjsc` 编译器

```
usage: qjsc [options] [files]
```

选项：

`-c`

仅将字节码输出到 C 文件。默认输出为可执行文件。

`-e`

在 C 文件中输出 `main()` 和字节码。默认输出为可执行文件。

`-o output`

设置输出文件名（默认=`out.c` 或 `a.out`）。

`-N cname`

设置生成数据的 C 名称。

`-m`

编译为 JavaScript 模块（默认=自动检测）。

`-D module_name`

编译一个动态加载的模块及其依赖。当代码使用 `import` 关键字或构造 `os.Worker` 时需要该选项，因为编译器无法静态发现动态加载模块的名称。

`-M module_name[,cname]`

为外部 C 模块添加初始化代码。参见 `c_module` 示例。

`-x`

字节序交换输出（仅用于交叉编译）。

`-flto`

使用链接时优化（LTO）。编译更慢，但可执行文件更小更快。当使用 `-fno-x` 类选项时自动启用。

`-fno-[eval|string-normalize|regexp|json|proxy|map|typedarray|promise|bigint]`

禁用所选语言特性，以生成更小的可执行文件。

### 2.4 内置测试

运行 `make test` 以执行 QuickJS 存档中包含的少量内置测试。

### 2.5 Test262 (ECMAScript 测试套件)

QuickJS 存档中包含 test262 运行器。可以将 test262 测试安装到 QuickJS 源码目录：

```
git clone https://github.com/tc39/test262.git test262
cd test262
patch -p1 < ../tests/test262.patch
cd ..
```

该补丁添加了特定实现的 `harness` 函数，并优化了低效的正则字符类和 Unicode 属性转义测试（测试本身未修改，仅优化了一个慢速字符串初始化函数）。

运行测试：

```
make test2
```

配置文件 `test262.conf`（旧 ES5.1 测试使用 `test262o.conf`[4]）包含运行各种测试的选项。可根据特性或文件名排除测试。

文件 `test262_errors.txt` 包含当前错误列表。运行器在出现新错误或纠正/修改现有错误时显示消息。使用 `-u` 选项更新当前错误列表（或执行 `make test2-update`）。

文件 `test262_report.txt` 包含所有测试的日志，便于更清晰地分析特定错误。在发生崩溃时，最后一行对应失败的测试。

使用语法 `./run-test262 -c test262.conf -f filename.js` 运行单个测试；使用 `./run-test262 -c test262.conf N` 从第 `N` 个测试开始执行。

更多信息可运行 `./run-test262` 查看 test262 运行器的命令行选项。

通过 `eshost` 从 `test262-harness`[5] 调用时，`run-test262` 接受 `-N` 选项。除非需要在相同条件下比较 QuickJS 与其它引擎，否则不建议使用这种方式运行测试，速度会慢很多（通常半小时，而直接方式约 100 秒）。

3 技术规范
----------------

### 3.1 语言支持

#### 3.1.1 ES2023 支持

几乎完整支持 ES2023 规范，包括 Annex B（遗留 Web 兼容性）及与 Unicode 相关的特性。

目前尚未支持的特性：

* 尾调用[6]

#### 3.1.2 ECMA402

ECMA402（国际化 API）未支持。

### 3.2 模块

完全支持 ES6 模块。默认名称解析规则如下：

* 以 `.` 或 `..` 开头的模块名相对当前模块路径。
* 不以 `.` 或 `..` 开头的模块名为系统模块，例如 `std` 或 `os`。
* 以 `.so` 结尾的模块为使用 QuickJS C API 的原生模块。

### 3.3 标准库

标准库默认包含在命令行解释器中。它包含两个模块 `std` 与 `os`，以及少量全局对象。

#### 3.3.1 全局对象

`scriptArgs`

提供命令行参数。第一个参数是脚本名称。

`print(...args)`

打印参数，参数之间以空格分隔，并在末尾追加换行。

`console.log(...args)`

与 `print()` 相同。

#### 3.3.2 `std` 模块

`std` 模块为 libc 的 `stdlib.h`、`stdio.h` 提供封装，并包含一些其它实用功能。

可用导出：

`exit(n)`：退出进程。

`evalScript(str, options = undefined)`：将字符串 `str` 作为脚本（全局 eval）执行。`options` 为可选对象，支持：

- `backtrace_barrier`（布尔，默认 false）：为 true 时，错误回溯不展示 `evalScript` 之下的堆栈帧。
- `async`（布尔，默认 false）：为 true 时，脚本可使用 `await`，并返回一个 Promise；该 Promise 解析为一个包含 `value` 字段的对象，`value` 为脚本返回的值。

`loadScript(filename)`：将文件 `filename` 作为脚本（全局 eval）执行。

`loadFile(filename)`：按 UTF-8 编码读取文件 `filename` 并以字符串返回；I/O 错误返回 `null`。

`open(filename, flags, errorObj = undefined)`：打开文件（libc `fopen()` 的封装）。返回 FILE 对象，或在 I/O 错误时返回 `null`。若提供 `errorObj`，其 `errno` 属性会设置为错误码（或为 0 表示无错）。

`popen(command, flags, errorObj = undefined)`：通过创建管道打开进程（libc `popen()` 封装）。返回 FILE 对象或 `null`；`errorObj.errno` 同上。

`fdopen(fd, flags, errorObj = undefined)`：从文件句柄打开文件（libc `fdopen()` 封装）。返回 FILE 对象或 `null`；`errorObj.errno` 同上。

`tmpfile(errorObj = undefined)`：打开临时文件。返回 FILE 对象或 `null`；`errorObj.errno` 同上。

`puts(str)`：等价于 `std.out.puts(str)`。

`printf(fmt, ...args)`：等价于 `std.out.printf(fmt, ...args)`。

`sprintf(fmt, ...args)`：等价于 libc 的 `sprintf()`。

`in`、`out`、`err`：libc 文件 `stdin`、`stdout`、`stderr` 的封装。

`SEEK_SET`、`SEEK_CUR`、`SEEK_END`：`seek()` 的常量。

`Error`：枚举对象，包含常见错误的整数值（可定义附加错误码）：`EINVAL`、`EIO`、`EACCES`、`EEXIST`、`ENOSPC`、`ENOSYS`、`EBUSY`、`ENOENT`、`EPERM`、`EPIPE`。

`strerror(errno)`：返回描述错误码 `errno` 的字符串。

`gc()`：手动触发循环删除算法。循环删除在需要时自动启动；该函数在特定内存限制或测试时有用。

`getenv(name)`：返回环境变量 `name` 的值；未定义返回 `undefined`。

`setenv(name, value)`：将环境变量 `name` 设置为字符串 `value`。

`unsetenv(name)`：删除环境变量 `name`。

`getenviron()`：以键值对对象形式返回所有环境变量。

`urlGet(url, options = undefined)`：使用命令行工具 `curl` 下载 `url`。`options` 可包含：

- `binary`（布尔，默认 false）：为 true 时响应为 `ArrayBuffer`；否则为字符串（假定 UTF-8）。
- `full`（布尔，默认 false）：为 true 时返回对象，包含 `response`（响应内容）、`responseHeaders`（以 CRLF 分隔的响应头）、`status`（状态码）。当发生协议或网络错误时 `response` 为 `null`。若 `full` 为 false，且状态码范围为 200–299，直接返回响应；否则返回 `null`。

`parseExtJSON(str)`：以 `JSON.parse` 的超集解析 `str`，与 JSON5 非常接近。支持：单行/多行注释、未加引号的属性（ASCII 仅标识符）、数组/对象末尾多余逗号、单引号字符串、`\v` 转义与以反斜杠续行的多行字符串、将 `\f`/`\v` 视为空白字符、数字前导加号或仅小数点、十六进制（`0x`）、八进制（`0o`）、二进制（`0b`）整数、接受 `NaN` 与 `Infinity` 为数字。

FILE 原型：

`close()`：关闭文件；成功返回 0，I/O 错误返回 `-errno`。

`puts(str)`：按 UTF-8 输出字符串。

`printf(fmt, ...args)`：格式化输出。支持与标准 C `printf` 相同的格式。整数类型（如 `%d`）会将 Number 或 BigInt 截断为 32 位；使用 `l` 修饰符（如 `%ld`）截断为 64 位。

`flush()`：刷新缓冲文件。

`seek(offset, whence)`：定位到指定文件位置（`whence` 使用 `std.SEEK_*`）。`offset` 可为 Number 或 BigInt；成功返回 0，I/O 错误返回 `-errno`。

`tell()`：返回当前文件位置。

`tello()`：以 BigInt 返回当前文件位置。

`eof()`：到达文件末尾返回 true。

`fileno()`：返回关联的 OS 句柄。

`error()`：如发生错误返回 true。

`clearerr()`：清除错误标志。

`read(buffer, position, length)`：将文件中从字节位置 `position` 开始的 `length` 字节读入 `ArrayBuffer buffer`（libc `fread` 封装）。

`write(buffer, position, length)`：将 `ArrayBuffer buffer` 中从字节位置 `position` 开始的 `length` 字节写入文件（libc `fwrite` 封装）。

`getline()`：返回文件的下一行（假定 UTF-8 编码），不包含尾随换行符。

`readAsString(max_size = undefined)`：读取 `max_size` 字节并按 UTF-8 返回字符串；未指定时读取至文件结束。

`getByte()`：返回文件的下一个字节；到达末尾返回 -1。

`putByte(c)`：写入一个字节。

#### 3.3.3 `os` 模块

`os` 模块提供操作系统相关功能：底层文件访问、信号、计时器、异步 I/O、工作线程（线程）。

OS 函数通常在成功时返回 0，或返回 OS 特定的负错误码。

可用导出（节选）：

`open(filename, flags, mode = 0o666)`：打开文件。返回句柄，或错误时返回小于 0 的值。

`O_RDONLY`、`O_WRONLY`、`O_RDWR`、`O_APPEND`、`O_CREAT`、`O_EXCL`、`O_TRUNC`：POSIX 打开标志。

`O_TEXT`（Windows 特有）：以文本模式打开文件；默认为二进制模式。

`close(fd)`：关闭文件句柄 `fd`。

`seek(fd, offset, whence)`：在文件中定位。`whence` 使用 `std.SEEK_*`；`offset` 可为 Number 或 BigInt；若为 BigInt，返回值也为 BigInt。

`read(fd, buffer, offset, length)`：从句柄 `fd` 的字节位置 `offset` 开始，读取 `length` 字节到 `ArrayBuffer buffer`。返回读取字节数，错误时返回小于 0。

`write(fd, buffer, offset, length)`：将 `ArrayBuffer buffer` 的 `length` 字节从字节位置 `offset` 写入句柄 `fd`。返回写入字节数，错误时返回小于 0。

`isatty(fd)`：若 `fd` 是 TTY（终端）句柄返回 `true`。

`ttyGetWinSize(fd)`：返回 TTY 大小 `[width, height]` 或不可用时返回 `null`。

`ttySetRaw(fd)`：将 TTY 设置为原始模式。

`remove(filename)`：删除文件。成功返回 0，或返回 `-errno`。

`rename(oldname, newname)`：重命名文件。成功返回 0，或返回 `-errno`。

`realpath(path)`：返回 `[str, err]`，其中 `str` 为 `path` 的规范化绝对路径，`err` 为错误码。

`getcwd()`：返回 `[str, err]`，其中 `str` 为当前工作目录，`err` 为错误码。

`chdir(path)`：切换当前目录。成功返回 0，或返回 `-errno`。

`mkdir(path, mode = 0o777)`：在 `path` 创建目录。成功返回 0，或返回 `-errno`。

`stat(path)` / `lstat(path)`：返回 `[obj, err]`，`obj` 为文件状态对象（字段：`dev, ino, mode, nlink, uid, gid, rdev, size, blocks, atime, mtime, ctime`，时间以毫秒为单位）；`lstat()` 与 `stat()` 相同，但返回链接本身的信息。

`S_IFMT`、`S_IFIFO`、`S_IFCHR`、`S_IFDIR`、`S_IFBLK`、`S_IFREG`、`S_IFSOCK`、`S_IFLNK`、`S_ISGID`、`S_ISUID`：用于解释 `stat()` 返回的 `mode` 属性的常量，取值与 C 系统头文件 `sys/stat.h` 相同。

`utimes(path, atime, mtime)`：修改文件 `path` 的访问/修改时间（毫秒为单位）。成功返回 0，或返回 `-errno`。

`symlink(target, linkpath)`：在 `linkpath` 创建指向字符串 `target` 的链接。成功返回 0，或返回 `-errno`。

`readlink(path)`：返回 `[str, err]`，其中 `str` 为链接目标，`err` 为错误码。

`readdir(path)`：返回 `[array, err]`，其中 `array` 为目录 `path` 下的文件名数组，`err` 为错误码。

`setReadHandler(fd, func)`：为文件句柄 `fd` 添加读处理器；每次 `fd` 有待处理数据时调用。每个句柄只支持一个读处理器；传 `func = null` 删除处理器。

`setWriteHandler(fd, func)`：为文件句柄 `fd` 添加写处理器；每次 `fd` 可写时调用。每个句柄只支持一个写处理器；传 `func = null` 删除处理器。

`signal(signal, func)`：在信号 `signal` 发生时调用函数 `func`。每个信号编号只支持一个处理器；传 `null` 设置默认处理器，传 `undefined` 忽略信号。信号处理器仅可在主线程定义。

`SIGINT`、`SIGABRT`、`SIGFPE`、`SIGILL`、`SIGSEGV`、`SIGTERM`：POSIX 信号编号。

`kill(pid, sig)`：向进程 `pid` 发送信号 `sig`。

`exec(args[, options])`：以参数 `args` 执行子进程。`options` 为可选对象，支持：

- `block`（布尔，默认 true）：为 true 时阻塞等待进程结束；返回正数退出码，或若被信号中断则返回负的信号编号。为 false 时不阻塞，返回子进程 pid。
- `usePath`（布尔，默认 true）：为 true 时在 `PATH` 环境变量中搜索执行文件。
- `file`（字符串，默认 `args[0]`）：设置要执行的文件。
- `cwd`（字符串）：设置子进程工作目录。
- `stdin` / `stdout` / `stderr`：设置子进程的标准流句柄。
- `env`（对象）：以键值对设置子进程环境；未提供时沿用当前进程环境。
- `uid`（整数）：若提供则使用 `setuid` 设置子进程 uid。
- `gid`（整数）：若提供则使用 `setgid` 设置子进程 gid。

`getpid()`：返回当前进程 ID。

`waitpid(pid, options)`：Unix 系统调用 `waitpid`。返回 `[ret, status]`；错误时 `ret` 为 `-errno`。

`WNOHANG`：`waitpid` 的 `options` 参数常量。

`dup(fd)`、`dup2(oldfd, newfd)`：Unix 系统调用。

`pipe()`：Unix 系统调用。成功返回两个句柄 `[read_fd, write_fd]`，错误时返回 `null`。

`sleep(delay_ms)`：睡眠 `delay_ms` 毫秒。

`sleepAsync(delay_ms)`：异步睡眠 `delay_ms` 毫秒，返回 Promise。例如：

```
await os.sleepAsync(500);
```

`now()`：返回以毫秒为单位的时间戳，精度高于 `Date.now()`；起始时间未定义，通常不受系统时钟调整影响。

`setTimeout(func, delay)`：在 `delay` 毫秒后调用函数 `func`；返回计时器句柄。

`clearTimeout(handle)`：取消计时器。

`platform`：返回表示平台的字符串：`"linux"`、`"darwin"`、`"win32"` 或 `"js"`。

`Worker(module_filename)`：构造函数，用于创建新线程（worker），API 接近 `WebWorkers`。`module_filename` 为在线程中执行的模块文件名；与动态导入模块一样，路径相对当前脚本或模块。线程默认不共享数据，通过消息通信。不支持嵌套 worker。示例见 `tests/test_worker.js`。

Worker 类的静态属性：

`parent`：在创建的 worker 中，`Worker.parent` 表示父 worker，用于发送/接收消息。

Worker 实例的属性：

`postMessage(msg)`：向对应 worker 发送消息。`msg` 使用与 `HTML` 结构化克隆算法相似的方式在目标 worker 中克隆；`SharedArrayBuffer` 在 worker 间共享。当前限制：暂不支持 `Map` 与 `Set`。

`onmessage`（getter/setter）：设置在接收消息时调用的函数。该函数接收一个参数，为包含 `data` 属性的对象，`data` 即收到的消息。只要存在至少一个非 `null` 的 `onmessage` 处理器，线程不会被终止。

### 3.4 QuickJS C API

C API 设计简洁高效。C API 定义在头文件 `quickjs.h` 中。

#### 3.4.1 运行时与上下文

`JSRuntime` 表示与对象堆对应的 JavaScript 运行时。可同时存在多个运行时，但它们不能交换对象；在同一运行时内不支持多线程。

`JSContext` 表示 JavaScript 上下文（或 Realm）。每个 JSContext 都有自己的全局对象和系统对象。每个 JSRuntime 中可存在多个 JSContext，并且它们可以共享对象，类似于浏览器中同源的多个框架共享 JavaScript 对象。

#### 3.4.2 JSValue

`JSValue` 表示一个 JavaScript 值，可为原始类型或对象。采用引用计数，因此需要显式复制（`JS_DupValue()`，增加引用计数）或释放（`JS_FreeValue()`，减少引用计数）JSValue。

#### 3.4.3 C 函数

可使用 `JS_NewCFunction()` 创建 C 函数。`JS_SetPropertyFunctionList()` 可便捷地将函数、setter 与 getter 属性添加到给定对象。

与其他嵌入式 JavaScript 引擎不同，QuickJS 没有隐式栈，因此 C 函数以普通的 C 参数接收其入参。一般规则是：C 函数以常量 `JSValue` 作为参数（无需释放），并返回一个新分配（活跃）的 `JSValue`。

#### 3.4.4 异常

异常：多数 C 函数可能返回 JavaScript 异常。必须由 C 代码显式测试并处理它。特定 `JSValue` 值 `JS_EXCEPTION` 表示发生了异常。实际的异常对象存储在 `JSContext` 中，可通过 `JS_GetException()` 获取。

#### 3.4.5 脚本评估

使用 `JS_Eval()` 评估脚本或模块源码。

若脚本或模块已由 `qjsc` 编译为字节码，则可通过调用 `js_std_eval_binary()` 进行评估。优势是无需编译，因而更快且更小；如果不需要 `eval`，可将编译器从可执行文件中移除。

注意：字节码格式与具体的 QuickJS 版本绑定，且在执行前不会进行安全检查。因此不应从不受信任的来源加载字节码。这也是 `qjsc` 中没有将字节码输出到二进制文件的选项的原因。

#### 3.4.6 JS 类

可以将 C 的不透明数据附加到 JavaScript 对象上。不透明数据的类型由对象的类 ID（`JSClassID`）确定。因此，第一步是注册新的类 ID 与 JS 类（`JS_NewClassID()`、`JS_NewClass()`）。然后可使用 `JS_NewObjectClass()` 创建该类的对象，并通过 `JS_GetOpaque()` / `JS_SetOpaque()` 获取或设置不透明指针。

在定义新的 JS 类时，可以声明析构函数，在对象销毁时调用；它应用于释放 C 资源，但不应在其中执行 JS 代码。可提供 `gc_mark` 方法，以便循环删除算法找出被该对象引用的其它对象。还可提供其它方法来定义异类对象行为。

类 ID 在全局范围分配（适用于所有运行时）。JSClass 在每个 `JSRuntime` 中分配。使用 `JS_SetClassProto()` 可在给定 `JSContext` 中为特定类定义原型；`JS_NewObjectClass()` 在创建的对象中设置该原型。

示例见 `quickjs-libc.c`。

#### 3.4.7 C 模块

支持动态或静态链接的原生 ES6 模块。参见示例 `test_bjson` 与 `bjson.so`。标准库 `quickjs-libc.c` 也是原生模块的良好示例。

#### 3.4.8 内存处理

使用 `JS_SetMemoryLimit()` 为给定的 JSRuntime 设置全局内存分配限制。

可通过 `JS_NewRuntime2()` 提供自定义内存分配函数。

可通过 `JS_SetMaxStackSize()` 设置最大系统栈大小。

#### 3.4.9 执行超时与中断

使用 `JS_SetInterruptHandler()` 设置一个回调，该回调在引擎执行代码时被定期调用。可用它来实现执行超时。

命令行解释器使用它来实现 `Ctrl-C` 处理器。

4 内部实现
-----------

### 4.1 字节码

编译器直接生成字节码而不使用解析树等中间表示，因此非常快速。生成的字节码上会执行多轮优化。

选择基于栈的字节码，因为它简单且能生成紧凑代码。

对每个函数，最大栈大小在编译期计算，因此无需在运行时执行栈溢出检查。

调试信息维护了单独的压缩行号表。

对闭包变量的访问进行了优化，几乎与局部变量一样快。

严格模式下的直接 `eval` 得到优化。

### 4.2 可执行文件生成

#### 4.2.1 `qjsc` 编译器

`qjsc` 编译器从 JavaScript 文件生成 C 源代码。默认情况下，C 源代码由系统编译器（`gcc` 或 `clang`）编译。

生成的 C 源包含已编译函数或模块的字节码。若需要完整的可执行文件，它还包含一个 `main()` 函数，其中含有必要的 C 代码来初始化 JavaScript 引擎，并加载与执行已编译的函数和模块。

JavaScript 代码可与 C 模块混合使用。

为生成更小的可执行文件，可禁用特定的 JavaScript 特性，尤其是 `eval` 或正则表达式。代码移除依赖系统编译器的链接时优化（LTO）。

#### 4.2.2 二进制 JSON

`qjsc` 通过编译脚本或模块，然后序列化为二进制格式工作。该格式的一个子集（不包含函数或模块）可用作二进制 JSON。示例 `test_bjson.js` 展示了其用法。

警告：二进制 JSON 格式可能在不通知的情况下更改，因此不应用于存储持久数据。`test_bjson.js` 示例仅用于测试二进制对象格式的函数。

### 4.3 运行时

#### 4.3.1 字符串

字符串存储为 8 位或 16 位字符数组。因此，随机访问字符始终很快。

C API 提供将 JavaScript 字符串转换为 C UTF-8 字符串的函数。最常见的情况是 JavaScript 字符串仅包含 ASCII 字符，此时不涉及复制。

#### 4.3.2 对象

对象形状（对象原型、属性名与标志）在对象间共享以节省内存。

无洞（除数组结尾外）的数组得到优化。

`TypedArray` 访问得到优化。

#### 4.3.3 原子

对象属性名和部分字符串作为原子（唯一字符串）存储，以节省内存并便于快速比较。原子以 32 位整数表示；原子范围的一半保留用于从 `0` 到 `2^{31}-1` 的立即整数文本。

#### 4.3.4 数值

数值以 32 位有符号整数或 64 位 IEEE-754 浮点表示。多数运算在 32 位整数情况下有快速路径。

#### 4.3.5 垃圾回收

使用引用计数自动且确定性地释放对象；当已分配内存过大时执行单独的循环删除过程。循环删除仅依赖引用计数与对象内容，因此无需在 C 代码中操作显式垃圾回收根。

#### 4.3.6 JSValue

JSValue 是可表示原始类型（如 Number、String 等）或对象的 JavaScript 值。32 位版本使用 NaN boxing 存储 64 位浮点数；表示方式经过优化，以便高效测试 32 位整数和引用计数值。

在 64 位代码中，JSValue 为 128 位宽，不使用 NaN boxing；其理由是 64 位环境下内存占用不那么关键。

两种情况下（32 位或 64 位），JSValue 恰好占用两个 CPU 寄存器，因此可被 C 函数高效返回。

#### 4.3.7 函数调用

引擎对函数调用进行了优化以保证速度。系统栈持有 JavaScript 的参数与局部变量。

### 4.4 正则表达式

实现了一个专用正则表达式引擎：体积小、效率高，支持所有 ES2023 特性，包括 Unicode 属性。与 JavaScript 编译器类似，直接生成字节码而不使用解析树。

使用具有显式栈的回溯实现，避免系统栈上的递归。对简单量词做了专门优化以避免递归。

完整的正则库（不含 Unicode 库）在 x86 上约 15 KiB。

### 4.5 Unicode

实现了一个专用 Unicode 库，以避免依赖 ICU 等大型外部库。所有 Unicode 表在保持合理访问速度的同时采用压缩存储。

该库支持大小写转换、Unicode 规范化、Unicode 脚本查询、Unicode 通用类别查询以及所有 Unicode 二值属性。

完整的 Unicode 库在 x86 上约 45 KiB。

### 4.6 BigInt

BigInt 采用二进制补码表示。额外使用一个短 BigInt 值以优化小 BigInt 的性能。

5 许可
-------

QuickJS 以 MIT 许可证发布。

除非另有说明，QuickJS 源码版权归 Fabrice Bellard 和 Charlie Gordon 所有。

脚注
----

1. https://tc39.es/ecma262/2023
2. https://github.com/tc39/test262
3. https://tc39.es/ecma262/
4. 旧 ES5.1 测试可通过 `git clone --single-branch --branch es5-tests https://github.com/tc39/test262.git test262o` 获取
5. https://github.com/bterlson/test262-harness
目录

* * *

6 相关项目
---------

- [QuickJS-iOS](https://github.com/siuying/QuickJS-iOS) iOS下的QuickJS库

- [QuickJS-Android](https://github.com/HarlonWang/quickjs-android-wrapper) Android下的QuickJS库

- [quickjs-rs](https://github.com/quickjs-zh/quickjs-rs) Rust的QuickJS库

- [quickjspp](https://github.com/quickjs-zh/quickjspp) C++的QuickJS库

- [go-quickjs](https://github.com/wspl/go-quickjs) Go的QuickJS库

- [txiki.js](https://github.com/saghul/txiki.js) The tiny JavaScript runtime built with QuickJS, libuv and ❤️

- [QuickJS-Pascal](https://github.com/Coldzer0/QuickJS-Pascal) Quickjs FreePascal / Delphi Bindings

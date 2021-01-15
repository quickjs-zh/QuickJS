# QuickJS基准测试

结果
-------

这里是 [bench-v8 version 7 benchmark](https://github.com/v8/v8/tree/master/benchmarks)的测试结果

| 引擎                         | QuickJS | DukTape | XS   | MuJS | JerryScript | **Hermes** | **V8 --jitless** | V8 (JIT) |
| ---------------------------- | ------- | ------- | ---- | ---- | ----------- | ---------- | ---------------- | -------- |
| 可执行文件尺寸               | 620K    | 331K    | 1.2M | 244K | 211K        | 27M        | 28M              | 28M      |
| Richards                     | 777     | 218     | 444  | 187  | 238         | 818        | 1036             | 29745    |
| DeltaBlue                    | 761     | 266     | 553  | 245  | 209         | 651        | 1143             | 65173    |
| Crypto                       | 1061    | 202     | 408  | 113  | 255         | 1090       | 884              | 34215    |
| RayTrace                     | 915     | 484     | 1156 | 392  | 286         | 937        | 2989             | 69781    |
| EarleyBoyer                  | 1417    | 620     | 1175 | 315  | -           | 1728       | 4583             | 48254    |
| RegExp                       | 251     | 156     | -    | -    | -           | 335        | 2142             | 7637     |
| Splay                        | 1641    | 1389    | 1048 | 36.7 | -           | 1602       | 4303             | 26150    |
| NavierStokes                 | 1856    | 1003    | 836  | 109  | 394         | 1522       | 1377             | 36766    |
| **Total score**              | 942     | 408     | -    | 158  | -           | 968        | 1916             | 33640    |
| Total score<br/>(w/o RegExp) | 1138    | 468     | 738  | 159  | -           | 1127       | 1886             | 41576    |

(分数越高越好).

测试细节
------------

所有经过测试的JS引擎都是解释器，并且运行资源有限。

bench-v8源代码在QuickJS测试档案（`tests/bench-v8`目录）中提供。

在Fedora 21上使用gcc 4.9.2编译所有程序。它们在3.2 GHz的Core i5 4570 CPU上运行。

**可执行文件尺寸**是指运行引擎所需的所有资源(除了系统C库)的大小。

*   [QuickJS](https://bellard.org/quickjs): version 2019-07-09, qjs executable, x86, 64 bits, compiled with -O2.
*   [DukTape](https://duktape.org/): version 2.3.0, duk executable, x86, 64 bits, compiled with -O2.
*   [XS](https://github.com/Moddable-OpenSource/moddable): version 8.8.0, xst executable, x86, 64 bits, compiled with -O3. The engine cannot correctly run the RegExp test, so it was disabled.
*   [MuJS](https://mujs.com/): version 1.0.6, mujs executable, x86, 64 bits, compiled with -O2. The engine cannot correctly run the RegExp test so it was disabled. JS\_STACKSIZE and JS\_ENVLIMIT were increased to 32768 to run EarleyBoyer.
*   [JerryScript](http://jerryscript.net/): git version 2b8c4286, jerry executable, x86, 64 bits. The engine could not run EarleyBoyer, RegExp and Splay.
*   [Hermes](https://hermesengine.dev/): version 0.1.0, 64 bit Linux binary downloaded from [here](https://github.com/facebook/hermes/releases). The benchmark was run with the -O option (=enable expensive optimizations).
*   [V8](https://v8.dev/): version 7.7.289, Linux 64 bit executable downloaded from [here](https://storage.googleapis.com/chromium-v8/official/canary/v8-linux64-rel-7.7.289.zip).

运行基准测试，可以按需添加其他Javascript引擎。

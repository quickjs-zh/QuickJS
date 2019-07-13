# QuickJS基准测试

结果
-------

这里是 [bench-v8 version 7 benchmark](https://github.com/v8/v8/tree/master/benchmarks)的测试结果

| 引擎                         | QuickJS<br/>2019-06-23 | DukTape<br/>2.3.0 | XS<br/>8.8.0 | MuJS<br/>1.0.6 | JerryScript |
| ---------------------------- | ---------------------- | ----------------- | ------------ | -------------- | ----------- |
| Richards                     | 777                    | 218               | 444          | 187            | 238         |
| DeltaBlue                    | 761                    | 266               | 553          | 245            | 209         |
| Crypto                       | 1061                   | 202               | 408          | 113            | 255         |
| RayTrace                     | 915                    | 484               | 1156         | 392            | 286         |
| EarleyBoyer                  | 1417                   | 620               | 1175         | 315            | -           |
| RegExp                       | 251                    | 156               | -            | -              | -           |
| Splay                        | 1641                   | 1389              | 1048         | 36.7           | -           |
| NavierStokes                 | 1856                   | 1003              | 836          | 109            | 394         |
| **Total score**              | 942                    | 408               | -            | -              | -           |
| Total score<br/>(w/o RegExp) | 1138                   | 468               | 738          | 159            | -           |

(分数越高越好).

测试细节
------------

所有经过测试的JS引擎都是解释器，并且运行资源有限。

bench-v8源代码在QuickJS测试档案（`tests/bench-v8`目录）中提供。

在Fedora 21上使用gcc 4.9.2编译所有程序。它们在3.2 GHz的Core i5 4570 CPU上运行。

*   [QuickJS](https://bellard.org/quickjs): version 2019-07-09, qjs executable, x86, 64 bits, compiled with -O2.
*   [DukTape](https://duktape.org/): version 2.3.0, duk executable, x86, 64 bits, compiled with -O2.
*   [XS](https://github.com/Moddable-OpenSource/moddable): version 8.8.0, xst executable, x86, 64 bits, compiled with -O3. The engine cannot correctly run the RegExp test, so it was disabled.
*   [MuJS](https://mujs.com/): version 1.0.6, mujs executable, x86, 64 bits, compiled with -O2. The engine cannot correctly run the RegExp test so it was disabled. JS\_STACKSIZE and JS\_ENVLIMIT were increased to 32768 to run EarleyBoyer.
*   [JerryScript](http://jerryscript.net/): git version 2b8c4286, jerry executable, x86, 64 bits. The engine could not run EarleyBoyer, RegExp and Splay.

运行基准测试，可以按需添加其他Javascript引擎。

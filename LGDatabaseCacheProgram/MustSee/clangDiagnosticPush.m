//
//  clangDiagnosticPush.m
//  LGDatabaseCacheProgram
//
//  Created by carnet on 2018/12/4.
//  Copyright © 2018年 TP. All rights reserved.
//

////https://www.cnblogs.com/lurenq/p/7709731.html

/**
 首先#pragma在本质上是声明，常用的功能就是注释，尤其是给Code分段注释；而且它还有另一个强大的功能是处理编译器警告，但却没有上一个功能用的那么多。
 
 clang diagnostic 是#pragma 第一个常用命令：
 
 #pragma clang diagnostic push
 #pragma clang diagnostic ignored "-相关命令"
 // 你自己的代码
 #pragma clang diagnostic pop
 */

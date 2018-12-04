#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double FMDBVersionNumber;
FOUNDATION_EXPORT const unsigned char FMDBVersionString[];

#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"
#import "FMDatabasePool.h"

/**
     头文件很干净，引入项目的5个文件
 
     常量三巨头：1，FOUNDATION_EXPORT(foundation_export) 2，#define 3，extern
 
     {FOUNDATION_EXPORT
         //.h文件
         FOUNDATION_EXPORT NSString * const kMyConstantString;
         //.m文件是这样定义的
         NSString * const kMyConstantString = @"Hello";
     }
 
     {#define
        #define kMyConstantString @"Hello"
     }
 
     区别:
         使用第一种方法在检测字符串的值是否相等的时候更快.
         对于第一种你可以直接使用(stringInstance == MyFirstConstant)来比较,
         而define则使用的是这种.([stringInstance isEqualToString:MyFirstConstant])
 
         第一种直接比较的是指针地址,
         而第二个则是一一比较字符串的每一个字符是否相等.
 
     {extern
         ///.h
         extern NSString * const TTGClassWorkBeginNotification;
         //.m
         NSString * const TTGClassWorkBeginNotification = @"TTGClassWorkBeginNotification";
     }
 
 */

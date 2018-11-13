//
//  LGDatabaseCacheProgramDBHelper.h
//  LGDatabaseCacheProgram
//
//  Created by carnet on 2018/11/7.
//  Copyright © 2018年 TP. All rights reserved.
//

#import <Foundation/Foundation.h>

///数据库名字
extern NSString * const CACHEUSER;
///缓存当前APP版本号，用于数据库表的升级
extern NSString * const CACHE_APPVERSION;

@interface LGDatabaseCacheProgramDBHelper : NSObject

- (void)setMaxCacheNumber:(NSInteger)maxCacheNumber;

///插入新数据
+ (void)lgDB_InsertDataWithModelName:(NSString *)modelName
                          sourceData:(NSArray *)arrayForData
                                 suc:(void (^)(void))suc
                                 fai:(void (^)(void))fai;



@end

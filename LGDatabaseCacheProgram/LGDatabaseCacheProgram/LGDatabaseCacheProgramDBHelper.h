//
//  LGDatabaseCacheProgramDBHelper.h
//  LGDatabaseCacheProgram
//
//  Created by carnet on 2018/11/7.
//  Copyright © 2018年 TP. All rights reserved.
//

#import <Foundation/Foundation.h>

///缓存当前APP版本号，用于数据库表的升级
extern NSString * const CACHE_APPVERSION;

typedef NS_ENUM(NSInteger,SortWay)
{
    ///0:升序
    SortWay_Asc          = 0,
    ///1:降序
    SortWay_Desc         = 1,
    ///2:==
    SortWay_Equal        = 2,
};


@interface LGDatabaseCacheProgramDBHelper : NSObject

+ (LGDatabaseCacheProgramDBHelper *)sharedDatabaseCacheProgramDBHelper;

/**
    设置最大缓存数量，默认300条。
 */
- (void)setMaxCacheNumber:(NSInteger)maxCacheNumber;
/**
    是否使用调试模式（调试模式日志打印较为详细）
 */
- (void)setDebugMode:(BOOL)isOpenDebugMode;
/**
    切换数据库路径，存在则切换，不存在则创建并切换
 */
- (void)setDBWayWithName:(NSString *)dbName;


#pragma mark - --插入新数据--
///插入新数据
+ (void)lgDB_InsertDataWithModelName:(NSString *)modelName
                          sourceData:(NSArray *)arrayForData
                              result:(void (^)(BOOL isSuc))result;

#pragma mark - --根据条件获取缓存数据--
///根据条件获取缓存数据
+ (void)lgDB_SelectDataWithModelName:(NSString *)modelName///名字
                       searchKeyword:(NSString *)searchKeyword///检索关键字,为空时默认用RetrievalId检索
                         searchValue:(NSInteger)searchValue///检索关键字值，为0默认最大或者最小值。
                           ascOrDesc:(SortWay)sortWay///排序方式
                              number:(NSInteger)number///条数
                                 suc:(void (^)(BOOL haveCache,NSArray *array))suc;
#pragma mark - --根据条件删除数据--
///根据条件删除数据
+ (void)lgDB_DeleteDataWithModelName:(NSString *)modelName///名字
                       searchKeyword:(NSString *)searchKeyword///检索关键字,为空时默认用RetrievalId检索
                         searchValue:(NSInteger)searchValue///检索关键字值，为0默认最大或者最小值。
                           ascOrDesc:(SortWay)sortWay///排序方式
                              number:(NSInteger)number///条数
                              result:(void (^)(BOOL isSuc))result;
#pragma mark - --根据条件更改数据--
///根据条件更改数据
+ (void)lgDB_UpdateDataWithModelName:(NSString *)modelName
                    accordingKeyword:(NSString *)accordingKeyword///定位key
                      accordingValue:(NSObject *)accordingValue///定位Value
                       updateKeyword:(NSString *)updateKeyword///待更新值的key
                         updateValue:(NSObject *)updateValue///待更新的值
                              result:(void (^)(BOOL isSuc))result;

@end

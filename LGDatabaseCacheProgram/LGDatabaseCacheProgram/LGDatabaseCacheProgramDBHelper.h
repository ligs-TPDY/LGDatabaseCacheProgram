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
/**
    设置最大缓存数量，默认300条。
 */
- (void)setMaxCacheNumber:(NSInteger)maxCacheNumber;

///插入新数据
+ (void)lgDB_InsertDataWithModelName:(NSString *)modelName
                          sourceData:(NSArray *)arrayForData
                                 suc:(void (^)(void))suc
                                 fai:(void (^)(void))fai;

#pragma mark - --根据条件获取缓存数据--
+ (void)lgDB_SelectDataWithModelName:(NSString *)modelName///名字
                       searchKeyword:(NSString *)searchKeyword///检索关键字,为空时默认用RetrievalId检索
                         searchValue:(NSInteger)searchValue///检索关键字值，为0默认最大或者最小值。
                           ascOrDesc:(SortWay)sortWay///排序方式
                              number:(NSInteger)number///条数
                                 suc:(void (^)(BOOL haveCache,NSArray *array))suc;
#pragma mark - --根据条件删除数据--
+ (void)lgDB_DeleteDataWithModelName:(NSString *)modelName///名字
                       searchKeyword:(NSString *)searchKeyword///检索关键字,为空时默认用RetrievalId检索
                         searchValue:(NSInteger)searchValue///检索关键字值，为0默认最大或者最小值。
                           ascOrDesc:(SortWay)sortWay///排序方式
                              number:(NSInteger)number///条数
                                 suc:(void (^)(void))suc;
#pragma mark - --根据条件更改数据--
- (void)updateDataWithModelName:(NSString *)modelName
               accordingKeyword:(NSString *)searchKeyword///定位key
                 accordingValue:(NSInteger)searchValue///定位Value
                  updateKeyword:(NSString *)searchKeyword///待更新值的key
                    updateValue:(NSInteger)searchValue///待更新的值
                            suc:(void (^)(void))suc;



@end

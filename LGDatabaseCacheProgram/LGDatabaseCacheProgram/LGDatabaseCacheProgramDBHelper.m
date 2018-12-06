//
//  LGDatabaseCacheProgramDBHelper.m
//  LGDatabaseCacheProgram
//
//  Created by carnet on 2018/11/7.
//  Copyright © 2018年 TP. All rights reserved.
//

#import "LGDatabaseCacheProgramDBHelper.h"
#import "FMDB.h"
#import <objc/runtime.h> ///包含对类、成员变量、属性、方法的操作
//#import <objc/message.h> ///包含消息机制

NSString * const CACHEUSER = @"Cache_User.db";
///缓存当前APP版本号，用于数据库表的升级
NSString * const CACHE_APPVERSION = @"LG_Cache_AppVersion";

@interface LGDatabaseCacheProgramDBHelper ()
@property (nonatomic,strong) FMDatabaseQueue *queue;
@property (nonatomic,assign) NSInteger max_CacheNunber;
@property (nonatomic,assign) BOOL isOpenDebugMode;
@end

@implementation LGDatabaseCacheProgramDBHelper

+ (LGDatabaseCacheProgramDBHelper *)sharedDatabaseCacheProgramDBHelper
{
    static LGDatabaseCacheProgramDBHelper *sharedDatabaseCacheProgram = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDatabaseCacheProgram = [[self alloc] init];
    });
    return sharedDatabaseCacheProgram;
}
/**
    设置最大缓存数量，默认300条。
 */
- (void)setMaxCacheNumber:(NSInteger)maxCacheNumber
{
    _max_CacheNunber = maxCacheNumber;
}
/**
    是否使用调试模式（调试模式日志打印较为详细）
 */
- (void)setDebugMode:(BOOL)isOpenDebugMode;
{
    _isOpenDebugMode = isOpenDebugMode;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        ///在沙盒的Library/Caches目录下创建用户数据库。
        NSArray*paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
        NSString*path=[paths objectAtIndex:0];
        NSString *db = [path stringByAppendingPathComponent:CACHEUSER];
        _queue = [FMDatabaseQueue databaseQueueWithPath:db];
        _max_CacheNunber = 300;
    }
    return self;
}
/**
    modelName:model名字
    suc:回调
 */
+ (void)upDBTableModelName:(NSString *)modelName
                       suc:(void (^)(void))suc
                       fai:(void (^)(void))fai;
{
    LGDatabaseCacheProgramDBHelper *databaseCache = [LGDatabaseCacheProgramDBHelper sharedDatabaseCacheProgramDBHelper];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [databaseCache.queue inDatabase:^(FMDatabase *db) {
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            //当前app版本号
            NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString * app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            //缓存app版本号
            NSString *cache_App_Version = [userDefaults objectForKey:CACHE_APPVERSION];
            
            if (cache_App_Version == nil) {///安装APP
                ///新建表格
                [self creatTableWithModelName:modelName suc:^{
                    [userDefaults setObject:app_Version forKey:CACHE_APPVERSION];
                    [userDefaults synchronize];
                    suc();
                } fai:^{fai();}];
            }else if (![app_Version isEqualToString:cache_App_Version]){//升级APP
                {
                    //表名
                    NSString *tableName = [NSString stringWithFormat:@"%@",modelName];
                    NSArray *arrayForPropertyNames = [databaseCache getAllPropertyNames:modelName];
                    NSArray *arrayForDBPropertyType = [databaseCache getModelPropertyTypeForDB:modelName];
                    BOOL ADD_SUC = YES;
                    {//增加新增字段
                        for (int i=0; i<arrayForPropertyNames.count; i++) {
                            NSString *pro = arrayForPropertyNames[i];
                            if (![db columnExists:pro inTableWithName:tableName]){///判读字段是否存在
                                NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@",tableName,pro, arrayForDBPropertyType[i]];
                                BOOL result = [db executeUpdate:alertStr];
                                if (result) {NSLog(@"插入字段%@成功",pro);}
                                else{ADD_SUC = NO;NSLog(@"插入字段%@失败",pro);}
                            }
                        }
                    }
                    BOOL DROP_SUC = YES;
                    {///删除多余字段
                        /**
                         sqlite> create table D_BrandService(id int);
                         sqlite> alter table D_BrandService add column a int default 0;
                         sqlite> create table tmp as select id from D_BrandService;
                         sqlite> drop table D_BrandService;
                         sqlite> alter table tmp rename to D_BrandService;
                         目前SQLITE版本中ALTER TABLE不支持DROP COLUMN，只有RENAME 和ADD
                         */
                        NSMutableString *copySQL = [NSMutableString stringWithFormat:@"create table tmp as select RetrievalId"];
                        for (int i=0; i<arrayForPropertyNames.count; i++) {
                            NSString *pro = arrayForPropertyNames[i];
                            [copySQL appendFormat:@",%@",pro];
                        }
                        [copySQL appendFormat:@" from %@",modelName];
                        BOOL copyResult = [db executeUpdate:copySQL];
                        if (copyResult) {
                            NSLog(@"copy%@成功",modelName);
                        }else{DROP_SUC = NO;NSLog(@"copy%@失败",modelName);}
                        
                        NSMutableString *dropSQL = [NSMutableString stringWithFormat:@"drop table %@",modelName];
                        BOOL dropResult = [db executeUpdate:dropSQL];
                        if (dropResult) {
                            NSLog(@"drop%@成功",modelName);
                            dispatch_async(dispatch_get_main_queue(), ^{suc();});
                        }else{DROP_SUC = NO;NSLog(@"drop%@失败",modelName);}
                        
                        NSMutableString *renameSQL = [NSMutableString stringWithFormat:@"alter table tmp rename to %@",modelName];
                        BOOL renameResult = [db executeUpdate:renameSQL];
                        if (renameResult) {
                            NSLog(@"rename%@成功",modelName);
                            dispatch_async(dispatch_get_main_queue(), ^{suc();});
                        }else{DROP_SUC = NO;NSLog(@"rename%@失败",modelName);}
                    }
                    if (ADD_SUC && DROP_SUC) {
                        [userDefaults setObject:app_Version forKey:CACHE_APPVERSION];
                        [userDefaults synchronize];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            suc();
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{fai();});
                    }
                }
            }else{//正常使用中
                dispatch_async(dispatch_get_main_queue(), ^{suc();});
            }
        }];
    });
}
///创建当前用户对应的表格
+ (void)creatTableWithModelName:(NSString *)modelName
                            suc:(void (^)(void))suc
                            fai:(void (^)(void))fai;
{
    LGDatabaseCacheProgramDBHelper *databaseCache = [LGDatabaseCacheProgramDBHelper sharedDatabaseCacheProgramDBHelper];
    NSArray *arrayForPropertyNames = [databaseCache getAllPropertyNames:modelName];
    NSArray *arrayForDBPropertyType = [databaseCache getModelPropertyTypeForDB:modelName];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [databaseCache.queue inDatabase:^(FMDatabase *db) {
            NSMutableString *createSQL = [NSMutableString stringWithFormat:@"create table if not exists %@ (RetrievalId integer primary key autoincrement", modelName];
            if (arrayForPropertyNames.count == arrayForDBPropertyType.count) {
                for (int i=0; i<arrayForPropertyNames.count; i++) {
                    if (i == arrayForPropertyNames.count-1) {
                        [createSQL appendFormat:@",%@ %@)",arrayForPropertyNames[i],arrayForDBPropertyType[i]];
                    }else{
                        [createSQL appendFormat:@",%@ %@",arrayForPropertyNames[i],arrayForDBPropertyType[i]];
                    }
                }
            }
            BOOL result = [db executeUpdate:createSQL];
            if (result) {NSLog(@"create table==%@ success",modelName);dispatch_async(dispatch_get_main_queue(), ^{suc();});}
            else{NSLog(@"create table failure");dispatch_async(dispatch_get_main_queue(), ^{fai();});};
        }];
    });
}
///插入数据（增加数据）
+ (void)lgDB_InsertDataWithModelName:(NSString *)modelName
                          sourceData:(NSArray *)arrayForData
                              result:(void (^)(BOOL isSuc))result;
{
    LGDatabaseCacheProgramDBHelper *databaseCache = [LGDatabaseCacheProgramDBHelper sharedDatabaseCacheProgramDBHelper];
    ///参数有效性检测
    if (arrayForData != nil && arrayForData.count != 0 && modelName!= nil && modelName.length != 0) {
        [LGDatabaseCacheProgramDBHelper upDBTableModelName:modelName  suc:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [databaseCache.queue inDatabase:^(FMDatabase *db) {
                    NSInteger arrayForDataCount = arrayForData.count;
                    NSArray *arrayForDBPropertyType = [databaseCache getModelPropertyTypeForDB:modelName];
                    NSArray *arrayForPropertyName = [databaseCache getAllPropertyNames:modelName];
                    int count = 0;
                    NSMutableArray *markBlobIndex = [[NSMutableArray alloc]init];
                    
                    for (NSInteger i = arrayForDataCount-1; i>=0; i--) {
                        
                        [markBlobIndex removeAllObjects];
                        
                        NSObject *model = arrayForData[i];
                        NSArray *arrayForPropertyValues = [databaseCache useModelPropertyNameGetValues:model];
                        
                        NSMutableString *insertSQL = [NSMutableString stringWithFormat:@"insert into %@ ",modelName];
                        if (arrayForPropertyName.count == arrayForPropertyValues.count && arrayForPropertyName.count == arrayForDBPropertyType.count)
                        {
                            for (int i=0; i<arrayForPropertyName.count; i++) {
                                if (i==arrayForPropertyName.count-1) {
                                    [insertSQL appendFormat:@",%@)",arrayForPropertyName[i]];
                                }else if(i==0){
                                    [insertSQL appendFormat:@"(%@",arrayForPropertyName[i]];
                                }else{
                                    [insertSQL appendFormat:@",%@",arrayForPropertyName[i]];
                                }
                            }
                            
                            [insertSQL appendFormat:@" values "];
                            for (int j=0; j<arrayForPropertyValues.count; j++) {
                                if (j==arrayForPropertyValues.count-1) {///最后一个
                                    if ([arrayForDBPropertyType[j] isEqualToString:@"text"]) {
                                        [insertSQL appendFormat:@",'%@')",arrayForPropertyValues[j]];
                                    }else if ([arrayForDBPropertyType[j] isEqualToString:@"blob"]){
                                        [insertSQL appendFormat:@",?)"];
                                        [markBlobIndex addObject:@(j)];
                                    }else{
                                        [insertSQL appendFormat:@",%@)",arrayForPropertyValues[j]];
                                    }
                                }else if(j==0){///第一个
                                    if ([arrayForDBPropertyType[j] isEqualToString:@"text"]) {
                                        [insertSQL appendFormat:@"('%@'",arrayForPropertyValues[j]];
                                    }else if ([arrayForDBPropertyType[j] isEqualToString:@"blob"]){
                                        [insertSQL appendFormat:@"(?"];
                                        [markBlobIndex addObject:@(j)];
                                    }else{
                                        [insertSQL appendFormat:@"(%@",arrayForPropertyValues[j]];
                                    }
                                }else{///中间的
                                    if ([arrayForDBPropertyType[j] isEqualToString:@"text"]) {
                                        [insertSQL appendFormat:@",'%@'",arrayForPropertyValues[j]];
                                    }else if ([arrayForDBPropertyType[j] isEqualToString:@"blob"]){
                                        [insertSQL appendFormat:@",?"];
                                        [markBlobIndex addObject:@(j)];
                                    }else{
                                        [insertSQL appendFormat:@",%@",arrayForPropertyValues[j]];
                                    }
                                }
                            }
                        }
                        NSMutableString *mutStrBlob = [[NSMutableString alloc]init];
                        for (int n = 0; n<markBlobIndex.count; n++) {
                            NSInteger index = [[markBlobIndex objectAtIndex:n] integerValue];
                            if (index < arrayForPropertyValues.count) {
                                if (n!=markBlobIndex.count-1) {
                                    [mutStrBlob appendFormat:@"%@,",arrayForPropertyValues[index]];
                                }else{
                                    [mutStrBlob appendFormat:@"%@",arrayForPropertyValues[index]];
                                }
                            }
                        }
                        BOOL result = NO;
                        if (markBlobIndex.count == 1) {
                            NSInteger index = [[markBlobIndex objectAtIndex:0] integerValue];
                            result = [db executeUpdate:insertSQL,arrayForPropertyValues[index]];
                        }
                        if (markBlobIndex.count == 2) {
                            NSInteger index0 = [[markBlobIndex objectAtIndex:0] integerValue];
                            NSInteger index1 = [[markBlobIndex objectAtIndex:1] integerValue];
                            result = [db executeUpdate:insertSQL,arrayForPropertyValues[index0],arrayForPropertyValues[index1]];
                        }
                        if (result) {
                            count ++;
                        }
                    }
                    if (count == arrayForDataCount) {
                        NSLog(@"lgDB_InsertData == success == [%@]",modelName);
                        FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",modelName]];
                        int totalCount = 0;
                        if ([results next]) {
                            totalCount = [results intForColumnIndex:0];
                        }
                        [results close];
                        if (totalCount >= databaseCache.max_CacheNunber) {
                            ///关键调试信息
                            if (databaseCache.isOpenDebugMode) {
                                NSLog(@"lgDB_SelectData == totalCount&&max_CacheNunber == [数据总量超过上限][%d%ld]",
                                      totalCount,
                                      databaseCache.max_CacheNunber);
                            }
                            [self deleteDataWithModelName:modelName count:totalCount-databaseCache.max_CacheNunber];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{if(result){result(YES);}});
                    }else{
                        NSLog(@"lgDB_InsertData == failure == [%@]",modelName);
                        dispatch_async(dispatch_get_main_queue(), ^{if(result){result(NO);}});
                    };
                }];
            });
        } fai:^{dispatch_async(dispatch_get_main_queue(), ^{if(result){result(NO);}});}];
    }
}
///当数据总量超过上限时，删除多余的数据
+ (void)deleteDataWithModelName:(NSString *)modelName
                          count:(NSInteger)count;
{
    LGDatabaseCacheProgramDBHelper *databaseCache = [LGDatabaseCacheProgramDBHelper sharedDatabaseCacheProgramDBHelper];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [databaseCache.queue inDatabase:^(FMDatabase *db) {
            ///获取到最小的RetrievalId
            NSString *selectTotalCountSQL = [NSString stringWithFormat:@"select min(RetrievalId) from %@",modelName];
            NSInteger totalCount = [db intForQuery:selectTotalCountSQL];
            ///删除与新数据等长的数据
            NSString *deleteContentSQL = [NSString stringWithFormat:@"delete from %@ where RetrievalId>=%ld ORDER BY RetrievalId asc limit %ld",modelName,totalCount,count];
            BOOL result = [db executeUpdate:deleteContentSQL];
            if (result) {NSLog(@"数据总量超过上限：deleteData==%@==success",modelName);
            }else{NSLog(@"数据总量超过上限：deleteData==%@==failure",modelName);}
        }];
    });
}
#pragma mark - --根据条件获取缓存数据--
+ (void)lgDB_SelectDataWithModelName:(NSString *)modelName///名字
                       searchKeyword:(NSString *)searchKeyword///检索关键字,为空时默认用RetrievalId检索
                         searchValue:(NSInteger)searchValue///检索关键字值，为0默认最大或者最小值。
                           ascOrDesc:(SortWay)sortWay///排序方式
                              number:(NSInteger)number///条数
                                 suc:(void (^)(BOOL haveCache,NSArray *array))suc;
{
    LGDatabaseCacheProgramDBHelper *databaseCache = [LGDatabaseCacheProgramDBHelper sharedDatabaseCacheProgramDBHelper];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [databaseCache.queue inDatabase:^(FMDatabase *db) {
            NSString *keyword = nil;
            if (searchKeyword == nil || searchKeyword.length == 0) {
                keyword = @"RetrievalId";
            }else{
                keyword = searchKeyword;
            }
            
            ///关键调试信息
            if (databaseCache.isOpenDebugMode) {
                NSLog(@"lgDB_SelectData == searchKeyword == %@",searchKeyword);
            }
            
            NSInteger finallySearchValue = 0;
            {///获取到最大最小值
                NSString *maxOrMin = nil;
                if (sortWay == SortWay_Asc) {//升序
                    maxOrMin = @"min";
                }
                if (sortWay == SortWay_Desc) {//降序
                    maxOrMin = @"max";
                }
                NSString *SQL = [NSString stringWithFormat:@"select %@(%@) from %@",maxOrMin,keyword,modelName];
                finallySearchValue = [db intForQuery:SQL];
            }
            
            if (searchValue != 0) {///如果设置了值，则以设置值为准
                finallySearchValue = searchValue;
            }
            
            ///关键调试信息
            if (databaseCache.isOpenDebugMode) {
                NSLog(@"lgDB_SelectData == finallySearchValue == %ld",finallySearchValue);
            }
            
            NSString *ascOrDesc = nil;
            NSString *mark = nil;
            if (sortWay == SortWay_Asc) {//升序
                ascOrDesc = @"asc";
                mark = @">=";
            }
            if (sortWay == SortWay_Desc) {//降序
                ascOrDesc = @"desc";
                mark = @"<=";
            }
            if (sortWay == SortWay_Equal) {//==
                ascOrDesc = @"desc";
                mark = @"==";
            }
            
            NSInteger finallyNumber = 0;
            if (number <= 0) {//为0时，获取全部
                FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",modelName]];
                int totalCount = 0;
                if ([results next]) {
                    totalCount = [results intForColumnIndex:0];
                }
                [results close];
                finallyNumber = totalCount;
            }else{
                finallyNumber = number;
            }
            
            NSString *selectSQL = [NSString stringWithFormat:@"select * from %@ where %@%@%ld ORDER BY %@ %@ limit %ld",
                                   modelName,
                                   keyword,
                                   mark,
                                   finallySearchValue,
                                   keyword,
                                   ascOrDesc,
                                   finallyNumber];
            ///关键调试信息
            if (databaseCache.isOpenDebugMode) {
                NSLog(@"lgDB_SelectData == selectSQL == %@",selectSQL);
            }
            FMResultSet *result = [db executeQuery:selectSQL];
            NSArray *arrayForModel = [databaseCache changeFMResultSetForModel:result Model:modelName];
            if (arrayForModel.count != 0) {
                NSLog(@"lgDB_SelectData == success ==> [%@]",modelName);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (suc) {suc(YES,arrayForModel);}
                });
            }else{
                NSLog(@"lgDB_SelectData == failure ==> [%@]",modelName);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (suc) {suc(NO,nil);}
                });
            }
        }];
    });
}
#pragma mark - --根据条件删除数据--
+ (void)lgDB_DeleteDataWithModelName:(NSString *)modelName///名字
                       searchKeyword:(NSString *)searchKeyword///检索关键字,为空时默认用RetrievalId检索
                         searchValue:(NSInteger)searchValue///检索关键字值，为0默认最大或者最小值。
                           ascOrDesc:(SortWay)sortWay///排序方式
                              number:(NSInteger)number///条数
                              result:(void (^)(BOOL isSuc))result;
{
    LGDatabaseCacheProgramDBHelper *databaseCache = [LGDatabaseCacheProgramDBHelper sharedDatabaseCacheProgramDBHelper];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [databaseCache.queue inDatabase:^(FMDatabase *db) {
            NSString *keyword = nil;
            if (searchKeyword == nil || searchKeyword.length == 0) {
                keyword = @"RetrievalId";
            }else{
                keyword = searchKeyword;
            }
            
            ///关键调试信息
            if (databaseCache.isOpenDebugMode) {
                NSLog(@"lgDB_DeleteData == searchKeyword == %@",searchKeyword);
            }
            
            NSInteger finallySearchValue = 0;
            {///获取到最大最小值
                NSString *maxOrMin = nil;
                if (sortWay == SortWay_Asc) {//升序
                    maxOrMin = @"min";
                }
                if (sortWay == SortWay_Desc) {//降序
                    maxOrMin = @"max";
                }
                NSString *SQL = [NSString stringWithFormat:@"select %@(%@) from %@",maxOrMin,keyword,modelName];
                finallySearchValue = [db intForQuery:SQL];
            }
            
            if (searchValue != 0) {///如果设置了值，则以设置值为准
                finallySearchValue = searchValue;
            }
            
            ///关键调试信息
            if (databaseCache.isOpenDebugMode) {
                NSLog(@"lgDB_DeleteData == finallySearchValue == %ld",finallySearchValue);
            }
            
            NSString *ascOrDesc = nil;
            NSString *mark = nil;
            if (sortWay == SortWay_Asc) {//升序
                ascOrDesc = @"asc";
                mark = @">=";
            }
            if (sortWay == SortWay_Desc) {//降序
                ascOrDesc = @"desc";
                mark = @"<=";
            }
            if (sortWay == SortWay_Equal) {//==
                ascOrDesc = @"desc";
                mark = @"==";
            }
            
            NSString *deleteContentSQL = nil;
            if (number <= 0) {//为0时，删除所有数据。删除表格。
                deleteContentSQL = [NSString stringWithFormat:@"DROP TABLE %@",modelName];
            }else{
                deleteContentSQL = [NSString stringWithFormat:@"delete from %@ where %@%@%ld ORDER BY %@ %@ limit %ld",modelName,keyword,mark,finallySearchValue,keyword,ascOrDesc,number];
            }
            ///关键调试信息
            if (databaseCache.isOpenDebugMode) {
                NSLog(@"lgDB_DeleteData == deleteContentSQL == %ld",deleteContentSQL);
            }
            BOOL deleteResult = [db executeUpdate:deleteContentSQL];
            dispatch_async(dispatch_get_main_queue(), ^{if (result) {result(deleteResult);}});
            if (deleteResult) {NSLog(@"lgDB_DeleteData == success ==> [%@]",modelName);
                if (number <= 0) {///清空缓存版本号
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults removeObjectForKey:CACHE_APPVERSION];
                }
            }else{NSLog(@"lgDB_DeleteData == failure ==> [%@]",modelName);}
        }];
    });
}
#pragma mark - --根据条件更改数据--
///根据条件更改数据
+ (void)lgDB_UpdateDataWithModelName:(NSString *)modelName
                    accordingKeyword:(NSString *)accordingKeyword///定位key
                      accordingValue:(NSObject *)accordingValue///定位Value
                       updateKeyword:(NSString *)updateKeyword///待更新值的key
                         updateValue:(NSObject *)updateValue///待更新的值
                              result:(void (^)(BOOL isSuc))result;
{
    LGDatabaseCacheProgramDBHelper *databaseCache = [LGDatabaseCacheProgramDBHelper sharedDatabaseCacheProgramDBHelper];
    ///所有属性名
    NSArray *allPropertyNames = [databaseCache getAllPropertyNames:modelName];
    ///属性对应的数据库类型
    NSArray *allDBPropertyType = [databaseCache getModelPropertyTypeForDB:modelName];
    ///属性类型
    NSArray *allPropertyType = [databaseCache getModelPropertyType:modelName];
    
    ///属性位置
    NSInteger indexAccording = [allPropertyNames indexOfObject:accordingKeyword];
    NSInteger indexUpdate = [allPropertyNames indexOfObject:updateKeyword];
    
    ///key类型
    NSString *typeAccordingProperty = nil;
    NSString *typeUpdateProperty = nil;
    if (indexAccording < allPropertyType.count) {
        typeAccordingProperty = allPropertyType[indexAccording];
    }
    if (indexUpdate < allPropertyType.count) {
        typeUpdateProperty = allPropertyType[indexUpdate];
    }
    
    ///Value类型
    NSString *typeAccordingValue = nil;
    NSString *typeUpdateValue = nil;
    {
        typeAccordingValue = [NSString stringWithUTF8String:object_getClassName(accordingValue)];
        typeUpdateValue = [NSString stringWithUTF8String:object_getClassName(updateValue)];
    }
    
    ///关键调试信息
    if (databaseCache.isOpenDebugMode) {
        NSLog(@"lgDB_UpdateData == typeAccordingProperty == %@",typeAccordingProperty);
        NSLog(@"lgDB_UpdateData == typeUpdateProperty == %@",typeUpdateProperty);
        NSLog(@"lgDB_UpdateData == typeAccordingValue == %@",typeAccordingValue);
        NSLog(@"lgDB_UpdateData == typeUpdateValue == %@",typeUpdateValue);
    }
    
    ///key类型与Value类型必须要一一对应
    if (![typeAccordingProperty containsString:typeAccordingValue]) {
        NSLog(@"lgDB_UpdateData == failure ==> [typeAccordingProperty != typeAccordingValue]");return;
    }
    if (![typeUpdateProperty containsString:typeUpdateValue]) {
        NSLog(@"lgDB_UpdateData == failure ==> [typeUpdateProperty != typeUpdateValue]");return;
    }
    
    ///key对应数据库类型
    NSString *DBTypeAccording = nil;
    NSString *DBTypeUpdate = nil;
    if (indexAccording < allDBPropertyType.count) {
        DBTypeAccording = allDBPropertyType[indexAccording];
    }
    if (indexUpdate < allDBPropertyType.count) {
        DBTypeUpdate = allDBPropertyType[indexUpdate];
    }
    
    ///根据类型确定拼接占位符
    NSString *DBTypeAccordingMark = [databaseCache getMarkWithDBType:DBTypeAccording];
    NSString *DBTypeUpdateMark = [databaseCache getMarkWithDBType:DBTypeUpdate];
    
    ///处理values
    NSObject *accordingVal = nil;
    NSObject *updateVal = nil;
    {
        if ([typeAccordingProperty isEqualToString:@"@\"NSArray\""] || [typeAccordingProperty isEqualToString:@"@\"NSDictionary\""]) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:accordingValue
                                                               options:NSJSONWritingPrettyPrinted error:nil];
            accordingVal = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
        }else{
            accordingVal = accordingValue;
        }
        if ([typeUpdateProperty isEqualToString:@"@\"NSArray\""] || [typeUpdateProperty isEqualToString:@"@\"NSDictionary\""]) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:updateValue
                                                               options:NSJSONWritingPrettyPrinted error:nil];
            updateVal = [[NSString alloc] initWithData:jsonData
                                              encoding:NSUTF8StringEncoding];
        }else{
            updateVal = updateValue;
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [databaseCache.queue inDatabase:^(FMDatabase *db) {
            
            NSMutableString *update = [[NSMutableString alloc]init];
            [update appendString:@"update %@ set %@ = "];
            [update appendString:DBTypeUpdateMark];
            [update appendString:@" where %@ = "];
            [update appendString:DBTypeAccordingMark];
            NSString *updateSQL = [NSString stringWithFormat:update,
                                   modelName,
                                   updateKeyword,
                                   updateVal,
                                   accordingKeyword,
                                   accordingVal];
            ///关键调试信息
            if (databaseCache.isOpenDebugMode) {
                NSLog(@"lgDB_UpdateData == updateSQL == %@",updateSQL);
            }
            BOOL updateResult = [db executeUpdate:updateSQL];
            dispatch_async(dispatch_get_main_queue(), ^{if (result) {result(updateResult);}});
            ///打印结果！！！！！！！！！
            if (result) {NSLog(@"lgDB_UpdateData == success ==> [%@]",modelName);
            }else{NSLog(@"lgDB_UpdateData == failure ==> [%@]",modelName);};
        }];
    });
}
- (NSString *)getMarkWithDBType:(NSString *)DBType
{
    NSString *DBTypeMark = nil;
    if ([DBType isEqualToString:@"text"]) {
        DBTypeMark = @"'%@'";
    }
    if ([DBType isEqualToString:@"integer"]) {
        DBTypeMark = @"%@";
    }
    return DBTypeMark;
}

#pragma mark - --利用runtime完成属性的遍历和取值--
///通过运行时获取当前字符串映射的对象的所有属性的名称，以数组的形式返回
///参考示例：@[@"userName",@"userAge",@"userGrade",@"userOtherInformmation",@"specialUI",@"dbVersion"]
- (NSArray *)getAllPropertyNames:(NSString *)modelName;
{
    ///存储所有的属性名称
    NSMutableArray *allNames = [[NSMutableArray alloc] init];
    //由字符串得到类
    Class cls = NSClassFromString(modelName);
    //创建类对象
    NSObject *object = [[cls alloc] init];
    ///存储属性的个数
    unsigned int propertyCount = 0;
    ///通过运行时获取当前类的属性
    objc_property_t *propertys = class_copyPropertyList([object class], &propertyCount);
    //把属性放到数组中
    for (int i = 0; i < propertyCount; i ++) {
        ///取出每一个属性
        objc_property_t property = propertys[i];
        const char * propertyName = property_getName(property);
        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    ///释放
    free(propertys);
    return allNames;
}
///通过运行时获取当前字符串映射的对象的所有属性的类型名称，以数组的形式返回
///参考示例：@[@\"NSString\",@"@"NSNumber"",@"@\"NSArray\"",@"@\"NSDictionary\"",@"UserUISpecial",@"@"NSNumber""]
- (NSArray *)getModelPropertyType:(NSString *)modelName
{
    NSMutableArray *mutArrForPropertyType = [[NSMutableArray alloc]init];
    //由字符串得到类
    Class cls = NSClassFromString(modelName);
    //创建类对象
    NSObject *object = [[cls alloc] init];
    unsigned int count = 0;
    //获取成员变量列表
    Ivar *members = class_copyIvarList([object class], &count);
    //遍历成员变量列表
    for (int i = 0 ; i < count; i++) {
        Ivar var = members[i];
        //获取成员变量类型
        const char *memberType = ivar_getTypeEncoding(var);
        NSString *typeStr = [NSString stringWithCString:memberType encoding:NSUTF8StringEncoding];
        [mutArrForPropertyType addObject:typeStr];
    }
    return mutArrForPropertyType;
}
///通过运行时获取当前字符串映射的对象的所有属性的值，以数组的形式返回
///参考示例：@[@"小强",@(18),@[@"100",@"98"],@{@"add":@"新西兰"},对象地址,@(100)];
- (NSArray *)useModelPropertyNameGetValues:(NSObject *)model
{
    NSString *modelName = NSStringFromClass([model class]);
    NSArray *array = [self getAllPropertyNames:modelName];///属性名字
    NSArray *arrayForType= [self getModelPropertyType:modelName];///属性类型
    NSMutableArray *mutArr = [[NSMutableArray alloc]init];
    for (int i=0; i<array.count; i++) {
        NSString *property = array[i];
        NSString *propertyType = arrayForType[i];
        if([propertyType isEqualToString:@"@\"NSArray\""] || [propertyType isEqualToString:@"@\"NSDictionary\""]){
            ///字典类型的值，转换为字符串///数组类型的值，转换为字符串
            if ([model valueForKey:property]) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[model valueForKey:property]
                                                                   options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                             encoding:NSUTF8StringEncoding];
                [mutArr addObject:jsonString];
            }else{
                [mutArr addObject:@""];
            }
        }else if ([propertyType isEqualToString:@"@\"NSString\""]) {///字符串类型的值
            if ([model valueForKey:property]) {
                [mutArr addObject:[model valueForKey:property]];
            }else{
                [mutArr addObject:@""];
            }
        }else if([propertyType isEqualToString:@"@\"NSNumber\""]){///基本数据类型的值
            if ([model valueForKey:property]) {
                [mutArr addObject:[model valueForKey:property]];
            }else{
                [mutArr addObject:@(0)];
            }
        }else{///自定义对象
            if ([model valueForKey:property]) {
                //使用归档
                NSData *petsData = [NSKeyedArchiver archivedDataWithRootObject:[model valueForKey:property]];
                [mutArr addObject:petsData];
            }else{
                [mutArr addObject:[[NSObject alloc] init]];
            }
        }
    }
    return mutArr;
}
///通过运行时获取当前字符串映射的对象的所有属性的类型名称对应的数据库的类型名称，以数组的形式返回
///参考示例：@[@"text",@"integer",@"text",@"text",@"blob",@"integer"];
- (NSArray *)getModelPropertyTypeForDB:(NSString *)modelName
{
    NSMutableArray *mutArrForPropertyType = [[NSMutableArray alloc]init];
    //由字符串得到类
    Class cls = NSClassFromString(modelName);
    //创建类对象
    NSObject *object = [[cls alloc] init];
    unsigned int count = 0;
    //获取属性列表
    Ivar *members = class_copyIvarList([object class], &count);
    //遍历属性列表
    for (int i = 0 ; i < count; i++) {
        Ivar var = members[i];
        //获取变量类型
        const char *memberType = ivar_getTypeEncoding(var);
        NSString *typeStr = [NSString stringWithCString:memberType encoding:NSUTF8StringEncoding];
        //判断类型
        if([typeStr isEqualToString:@"@\"NSArray\""]
           || [typeStr isEqualToString:@"@\"NSDictionary\""]
           || [typeStr isEqualToString:@"@\"NSString\""])
        {
            [mutArrForPropertyType addObject:@"text"];
        }else if ([typeStr isEqualToString:@"@\"NSNumber\""]){
             [mutArrForPropertyType addObject:@"integer"];
        }else{
            [mutArrForPropertyType addObject:@"blob"];
        }
    }
    return mutArrForPropertyType;
}
///通过运行时通过从数据库取出的数据来获取当前字符串映射的对象的所有属性的值，以数组的形式返回
- (NSArray *)changeFMResultSetForModel:(FMResultSet *)result Model:(NSString *)model
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    while ([result next]) {
        //由字符串得到类
        Class cls = NSClassFromString(model);
        //创建类对象
        NSObject *object = [[cls alloc] init];
        unsigned int count = 0;
        //获取属性列表
        Ivar *members = class_copyIvarList([object class], &count);
        //遍历属性列表
        for (int i = 0 ; i < count; i++) {
            Ivar var = members[i];
            //获取变量名称
            const char *memberName = ivar_getName(var);
            //获取变量类型
            const char *memberType = ivar_getTypeEncoding(var);
            NSString *typeStr = [NSString stringWithCString:memberType encoding:NSUTF8StringEncoding];
            NSString *nameStr = [NSString stringWithCString:memberName encoding:NSUTF8StringEncoding];
            NSArray *nameArray = [nameStr componentsSeparatedByString:@"_"];
            //判断类型
            if ([typeStr isEqualToString:@"@\"NSString\""]) {
                //修改值
                NSString *str33 = [result stringForColumn:nameArray.lastObject];
                object_setIvar(object, var, str33);
            }else if ([typeStr isEqualToString:@"@\"NSArray\""]){
                //修改值
                NSString *str33 = [result stringForColumn:nameArray.lastObject];
                NSArray *array = [self arrayWithJsonString:str33];
                object_setIvar(object, var, array);
            }else if ([typeStr isEqualToString:@"@\"NSDictionary\""]){
                //修改值
                NSString *str33 = [result stringForColumn:nameArray.lastObject];
                NSDictionary *dic = [self dictionaryWithJsonString:str33];
                object_setIvar(object, var, dic);
            }else if ([typeStr isEqualToString:@"@\"NSNumber\""]){
                //修改值
                long ddd = [result longForColumn:nameArray.lastObject];
                object_setIvar(object, var, [NSNumber numberWithLong:ddd]);
            }else{
                //修改值
                NSData *str33 = [result dataForColumn:nameArray.lastObject];
                NSObject *car = [NSKeyedUnarchiver unarchiveObjectWithData:str33];
                object_setIvar(object, var, car);
            }
        }
        [arr addObject:object];
    }
    return arr;
}
#pragma ----JsonUtil----
- (NSArray *)arrayWithJsonString:(NSString *)jsonStr
{
    if (jsonStr) {
        id tmp = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers error:nil];
        if (tmp) {
            if ([tmp isKindOfClass:[NSArray class]]) {
                return tmp;
            } else if([tmp isKindOfClass:[NSString class]] || [tmp isKindOfClass:[NSDictionary class]]) {
                return [NSArray arrayWithObject:tmp];
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        if(err) {
            return nil;
        }
        return dic;
    }
    return nil;
}

@end

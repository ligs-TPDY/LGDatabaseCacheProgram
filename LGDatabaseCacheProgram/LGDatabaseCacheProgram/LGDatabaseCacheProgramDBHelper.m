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
@property(nonatomic,strong)FMDatabaseQueue *queue;
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
- (instancetype)init
{
    self = [super init];
    if (self) {
        ///在沙盒的Library/Caches目录下创建用户数据库。
        NSArray*paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
        NSString*path=[paths objectAtIndex:0];
        NSString *db = [path stringByAppendingPathComponent:CACHEUSER];
        self.queue = [FMDatabaseQueue databaseQueueWithPath:db];
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
                [self creatTableForNewsClassificationModelName:modelName suc:^{
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
+ (void)creatTableForNewsClassificationModelName:(NSString *)modelName
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
+ (void)insertDataForNewsClassificationModelName:(NSString *)modelName
                                      sourceData:(NSArray *)arrayForData
                                             suc:(void (^)(void))suc
                                             fai:(void (^)(void))fai;
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
                    int markBlobIndex = 0;
                    for (NSInteger i = arrayForDataCount-1; i>=0; i--) {
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
                                        markBlobIndex = j;
                                    }else{
                                        [insertSQL appendFormat:@",%@)",arrayForPropertyValues[j]];
                                    }
                                }else if(j==0){///第一个
                                    if ([arrayForDBPropertyType[j] isEqualToString:@"text"]) {
                                        [insertSQL appendFormat:@"('%@'",arrayForPropertyValues[j]];
                                    }else if ([arrayForDBPropertyType[j] isEqualToString:@"blob"]){
                                        [insertSQL appendFormat:@"(?"];
                                        markBlobIndex = j;
                                    }else{
                                        [insertSQL appendFormat:@"(%@",arrayForPropertyValues[j]];
                                    }
                                }else{///中间的
                                    if ([arrayForDBPropertyType[j] isEqualToString:@"text"]) {
                                        [insertSQL appendFormat:@",'%@'",arrayForPropertyValues[j]];
                                    }else if ([arrayForDBPropertyType[j] isEqualToString:@"blob"]){
                                        [insertSQL appendFormat:@",?"];
                                        markBlobIndex = j;
                                    }else{
                                        [insertSQL appendFormat:@",%@",arrayForPropertyValues[j]];
                                    }
                                }
                            }
                        }
                        BOOL result = [db executeUpdate:insertSQL,arrayForPropertyValues[markBlobIndex]];
                        if (result) {
                            count ++;
                        }
                    }
                    if (count == arrayForDataCount) {NSLog(@"insert Data ==%@== success",modelName);
                        FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",modelName]];
                        int totalCount = 0;
                        if ([results next]) {
                            totalCount = [results intForColumnIndex:0];
                        }
                        [results close];
                        if (totalCount >= 300) {
                            [self deleteDataForNewsClassificationModelName:modelName WhenDataMore300Count:totalCount-300];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{suc();});}
                    else{NSLog(@"insert Data failure"); dispatch_async(dispatch_get_main_queue(), ^{fai();});};
                }];
            });
        } fai:^{dispatch_async(dispatch_get_main_queue(), ^{fai();});}];
    }
}
///当数据总量超过300时，删除多余的数据
+ (void)deleteDataForNewsClassificationModelName:(NSString *)modelName
                            WhenDataMore300Count:(NSInteger)count;
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
            if (result) {NSLog(@"deleteDataFor==%@==WhenDataMore300CountSuc",modelName);
            }else{NSLog(@"deleteDataFor==%@==WhenDataMore300Countfai",modelName);}
        }];
    });
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

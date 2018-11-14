//
//  LGDatabaseCacheProgramModel.h
//  LGDatabaseCacheProgram
//
//  Created by carnet on 2018/11/7.
//  Copyright © 2018年 TP. All rights reserved.
//

#import <Foundation/Foundation.h>

///（利用FMDB使用SQLite进行缓存时，可以将一些数据封装在对象中，然后将该对象归档存储在数据库中，取出时利用解档恢复对象）
@interface UserUISpecial: NSObject <NSCoding>
@property (nonatomic,strong) NSMutableAttributedString *attributedStringForUserName;
@end

@interface LGDatabaseCacheProgramModel : NSObject
///用户名字
@property (nonatomic,strong) NSString *userName;
///用户年龄
@property (nonatomic,strong) NSNumber *userAge;
///用户过往成绩
@property (nonatomic,strong) NSArray *userGrade;
///用户其他信息
@property (nonatomic,strong) NSDictionary *userOtherInformmation;
///自定义对象缓存
@property (nonatomic,strong) UserUISpecial *specialUI;
@end

/**
    1...基本类型最好用number包裹，因为数据库操作中。
        利用runtime获取属性类型时，int==i，long==q，nsinteger==q,NSNumber==NSNumber。
        可以看出使用NSNumber更好操作。
 */




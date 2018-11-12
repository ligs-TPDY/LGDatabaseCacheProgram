//
//  LGDatabaseCacheProgramModel.m
//  LGDatabaseCacheProgram
//
//  Created by carnet on 2018/11/7.
//  Copyright © 2018年 TP. All rights reserved.
//

#import "LGDatabaseCacheProgramModel.h"

@implementation UserUISpecial
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.attributedStringForUserName forKey:@"attributedStringForUserName"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self!=nil) {
        self.attributedStringForUserName = [decoder decodeObjectForKey:@"attributedStringForUserName"];
    }
    return self;
}
@end

@implementation LGDatabaseCacheProgramModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _specialUI = [[UserUISpecial alloc]init];
    }
    return self;
}
@end

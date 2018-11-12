//
//  ViewController.m
//  LGDatabaseCacheProgram
//
//  Created by carnet on 2018/11/7.
//  Copyright © 2018年 TP. All rights reserved.
//

#import "ViewController.h"
#import "LGDatabaseCacheProgramDBHelper.h"
#import "LGDatabaseCacheProgramModel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *arr = @[[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel]];
    
    [LGDatabaseCacheProgramDBHelper insertDataForNewsClassificationModelName:@"LGDatabaseCacheProgramModel" sourceData:arr suc:^{
        
    } fai:^{
        
    }];
}

- (LGDatabaseCacheProgramModel *)getModel{
    LGDatabaseCacheProgramModel *model = [[LGDatabaseCacheProgramModel alloc]init];
    model.userName2 = @"小明";
    model.userAge = @(20);
    model.userGrade = @[@"100",@"200"];
    model.userOtherInformmation = @{@"add":@"中国长白山密林屯松崽子"};
    NSMutableAttributedString *mutStr = [[NSMutableAttributedString alloc]initWithString:@"豹子明"];
    [mutStr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0, 3)];
    model.specialUI.attributedStringForUserName = [[NSMutableAttributedString alloc]initWithString:@"豹子明"];
    return model;
}

@end

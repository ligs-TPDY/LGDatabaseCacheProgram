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
    
    NSArray *arr = @[[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel],[self getModel]];
    
    [LGDatabaseCacheProgramDBHelper lgDB_InsertDataWithModelName:@"LGDatabaseCacheProgramModel" sourceData:arr result:^(BOOL isSuc) {
//                [LGDatabaseCacheProgramDBHelper lgDB_DeleteDataWithModelName:@"LGDatabaseCacheProgramModel"
//                                                               searchKeyword:@"userAge"
//                                                                 searchValue:100
//                                                                   ascOrDesc:SortWay_Equal
//                                                                      number:0
//                                                                      result:^(BOOL isSuc) {
//
//                                                                      }];
        //        [LGDatabaseCacheProgramDBHelper lgDB_UpdateDataWithModelName:@"LGDatabaseCacheProgramModel"
        //                                                    accordingKeyword:@"userName"
        //                                                      accordingValue:@"小明"
        //                                                       updateKeyword:@"userOtherInformmation"
        //                                                         updateValue:@{@"key":@"values",@"key2":@"values2"}
        //                                                                 suc:^{
        //
        //                                                                 }];
        //
        //        [LGDatabaseCacheProgramDBHelper lgDB_UpdateDataWithModelName:@"LGDatabaseCacheProgramModel"
        //                                                    accordingKeyword:@"userName"
        //                                                      accordingValue:@"小明"
        //                                                       updateKeyword:@"userGrade"
        //                                                         updateValue:@[@"300",@"400"]
        //                                                                 suc:^{
        //
        //                                                                 }];
        
//        [LGDatabaseCacheProgramDBHelper lgDB_UpdateDataWithModelName:@"LGDatabaseCacheProgramModel"
//                                                    accordingKeyword:@"userName"
//                                                      accordingValue:@"小明"
//                                                       updateKeyword:@"userAge"
//                                                         updateValue:@[@"222"]
//                                                              result:^(BOOL isSuc) {
//                                                                  NSLog(@"123");
//                                                                }];
        
//        [LGDatabaseCacheProgramDBHelper lgDB_SelectDataWithModelName:@"LGDatabaseCacheProgramModel"
//                                                       searchKeyword:nil
//                                                         searchValue:0
//                                                           ascOrDesc:SortWay_Desc
//                                                              number:100
//                                                                 suc:^(BOOL haveCache, NSArray *array) {
//                                                                     NSLog(@"456");
//                                                                 }];
    }];
}

- (LGDatabaseCacheProgramModel *)getModel{
    LGDatabaseCacheProgramModel *model = [[LGDatabaseCacheProgramModel alloc]init];
    model.userName = @"小明";
    NSInteger count = 100 ;
    model.userAge = @(count);
    model.userGrade = @[@"100",@"200"];
    model.userOtherInformmation = @{@"add":@"中国长白山密林屯松崽子"};
    model.specialUI.attributedStringForUserName = [[NSMutableAttributedString alloc]initWithString:@"豹子明"];
    model.specialUI2.attributedStringForUserName = [[NSMutableAttributedString alloc]initWithString:@"豹子明"];
    return model;
}

@end

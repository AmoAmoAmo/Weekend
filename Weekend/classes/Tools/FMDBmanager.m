//
//  FMDBmanager.m
//  Weekend
//
//  Created by Jane on 16/4/15.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "FMDBmanager.h"

@implementation FMDBmanager

+(instancetype)shareInstance
{
    static FMDBmanager *manager;    // manager 为单例对象本身
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[FMDBmanager alloc] init];
    });
    return manager;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // 数据库的沙盒路径
        NSString *dbPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/myData.db"];
        NSLog(@"%@",dbPath);
        
        // 创建数据库对象
        self.dataBase = [FMDatabase databaseWithPath:dbPath];
        
        // 打开数据库
        if (![self.dataBase open]) {
            NSLog(@"数据库打开失败...");
        }
        
        
        
        // 创建表  1 - 收藏列表
        NSString *sqlCreateCollectionStr = @"create table if not exists Like (id integer primary key autoincrement,idStr text,type text,imgUrlStr text,titleStr text,subTitleStr text,farStr text,timeInfoStr text,collectedNum text)";
        if(![self.dataBase executeUpdate:sqlCreateCollectionStr])
        {
            NSLog(@"创建表格失败");
        }
    }
    return self;
}

@end

//
//  FMDBmanager.h
//  Weekend
//
//  Created by Jane on 16/4/15.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface FMDBmanager : NSObject

/** 数据库对象 */
@property (nonatomic,strong) FMDatabase *dataBase;

/** 数据库 单例（便利构造法） */
+(instancetype)shareInstance;

@end

//
//  CellModel.m
//  Weekend
//
//  Created by Jane on 16/4/1.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "CellModel.h"

@implementation CellModel

+(instancetype)createCellModelWithDic:(NSDictionary *)dic
{
    CellModel *model = [[self alloc] init];
    model.content = dic[@"content"];
    model.type = dic[@"type"];
    model.size = dic[@"size"];
    
    return model;
}

@end

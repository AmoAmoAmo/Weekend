//
//  CellModel.h
//  Weekend
//
//  Created by Jane on 16/4/1.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellModel : NSObject

@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,strong) NSArray *size;

/** 记录 cell高度*/
@property (nonatomic,assign) CGFloat cellHeight;

+(instancetype)createCellModelWithDic:(NSDictionary *)dic;

@end

//
//  HomeModel.h
//  Weekend
//
//  Created by Jane on 16/4/14.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HomeModel : NSObject
@property (nonatomic, assign) BOOL isCollectioned;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, copy) NSString *collectedNum;
@property (nonatomic, copy) NSString *farStr;
@property (nonatomic, copy) NSString *imgUrlStr;
@property (nonatomic, copy) NSString *subTitleStr;
@property (nonatomic, copy) NSString *timeInfoStr;
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *idStr;
/**
 NSString *type = nil;
 NSURL *imgUrl = nil;
 NSString *titleStr = nil;
 NSString *subTitleStr = nil;
 NSString *farStr = nil;
 NSString *timeInfoStr = nil;
 NSString *collectedNum = 0;
 BOOL isCollectioned;
 */

@end

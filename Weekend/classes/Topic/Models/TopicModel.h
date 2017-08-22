//
//  TopicModel.h
//  Weekend
//
//  Created by Jane on 16/4/5.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicModel : NSObject

@property (nonatomic,strong) NSURL *imgUrl;

@property (nonatomic,strong) NSString *titleStr;

@property (nonatomic,strong) NSString *idStr;

/** type只有week、qk两种 */
@property (nonatomic,copy) NSString *idType;

@end

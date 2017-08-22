//
//  MyPin.m
//  Weekend
//
//  Created by Jane on 16/5/15.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "MyPin.h"

@implementation MyPin


- (instancetype)initWithCoordinate:(CLLocationCoordinate2D )coordinate AndTitle:(NSString *)title AndSubTitle:(NSString *)subTitle AndImage:(NSString *)imgStr
{
    self = [super init];
    if (self)
    {
        self.coordinate = coordinate;
        self.title = title;
        self.subtitle = subTitle;
        self.imgStr = imgStr;
    }
    return self;
}

@end

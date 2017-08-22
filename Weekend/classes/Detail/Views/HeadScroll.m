//
//  HeadScroll.m
//  Weekend
//
//  Created by Jane on 16/4/19.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "HeadScroll.h"

@implementation HeadScroll

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor yellowColor];
        
        // 背景下拉放大的图片
        self.bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 200)];
//        [self.bgImgView setImage:[UIImage imageNamed:@"4"]];
        self.bgImgView.contentMode = UIViewContentModeScaleToFill;
        self.bgImgView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.bgImgView];
        
    }
    return self;
}

@end

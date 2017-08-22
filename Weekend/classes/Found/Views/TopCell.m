//
//  TopCell.m
//  Weekend
//
//  Created by Jane on 16/4/5.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "TopCell.h"

@implementation TopCell

- (void)awakeFromNib {
    // Initialization code
    
    self.leftImgView.clipsToBounds = YES;
    self.leftImgView.layer.cornerRadius = 10;
    
}

@end

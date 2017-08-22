//
//  TopicCell.m
//  Weekend
//
//  Created by Jane on 16/3/31.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "TopicCell.h"

@implementation TopicCell

- (void)awakeFromNib {
    // Initialization code
    self.frame = CGRectMake(0, 0, SCREENWIDTH, 210);
    
    self.tagLabel.layer.cornerRadius = 5;
    self.tagLabel.clipsToBounds = YES;
    self.tagLabel.layer.borderWidth = 0.6;
    self.tagLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

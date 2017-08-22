//
//  TextCell.m
//  Weekend
//
//  Created by Jane on 16/3/31.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "TextCell.h"
#import "CellModel.h"

@implementation TextCell

- (void)awakeFromNib {
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

+(instancetype)cellWithTableView:(UITableView *)tableView andCellModel:(CellModel *)cellModel
{
    static NSString *idString = @"textCell";
    
    TextCell *cell = [tableView dequeueReusableCellWithIdentifier:idString];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
    }
    
    cell.model = cellModel;
    return cell;
}

-(void)setModel:(CellModel *)model
{
    _model = model;
    self.lable.text = model.content;
    [self layoutIfNeeded];
    model.cellHeight = CGRectGetMaxY(self.lable.frame) + 20;
}


@end

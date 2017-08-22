//
//  PicCell.m
//  Weekend
//
//  Created by Jane on 16/4/1.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "PicCell.h"
#import "CellModel.h"

@implementation PicCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


+(instancetype)cellWithTableView:(UITableView *)tableView andCellModel:(CellModel *)model
{
    static NSString *idString = @"picCell";
    
    PicCell *cell = [tableView dequeueReusableCellWithIdentifier:idString];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
    }
    
    cell.cellModel = model;
    return cell;
}


-(void)setCellModel:(CellModel *)cellModel
{
    _cellModel = cellModel;
    [self.imgView sd_setImageWithURL:UrlWithString(_cellModel.content) placeholderImage:PLACEIMAGE];
    
    NSArray *sizeArr =  _cellModel.size;
    // 图片原宽、原高
    CGFloat width = [sizeArr[0] floatValue];
    CGFloat heigh = [sizeArr[1] floatValue];
    // 图片宽度压缩比例
    CGFloat scale = width / SCREENWIDTH ;
    // so 图片的高度应为...
    CGFloat h = heigh / scale;
    cellModel.cellHeight = h;
}

@end

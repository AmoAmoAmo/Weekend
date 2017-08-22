//
//  PicCell.h
//  Weekend
//
//  Created by Jane on 16/4/1.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CellModel;

@interface PicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (nonatomic, strong) CellModel *cellModel;

+(instancetype)cellWithTableView:(UITableView *)tableView andCellModel:(CellModel *)model;

@end

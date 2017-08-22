//
//  TextCell.h
//  Weekend
//
//  Created by Jane on 16/3/31.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CellModel;

@interface TextCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lable;

@property (nonatomic,strong) CellModel *model;

+(instancetype)cellWithTableView:(UITableView *)tableView andCellModel:(CellModel *)cellModel;
@end

//
//  HomeCell.h
//  Weekend
//
//  Created by Jane on 16/3/30.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeModel;

//@protocol HomeCellDelegate <NSObject>
//
//-(void)updateDBValueTag:(BOOL)isCollect WithIdStr:(NSString*)idStr;
//
//@end

@interface HomeCell : UITableViewCell

//@property (nonatomic,assign) id<HomeCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *farLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeInfoLabel;

@property (nonatomic, strong) HomeModel * model;

@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *iconV0;


+(instancetype)cellWithTable:(UITableView*)table andModel:(HomeModel*)homeModel;

@end

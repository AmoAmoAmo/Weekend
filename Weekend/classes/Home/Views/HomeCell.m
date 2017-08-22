//
//  HomeCell.m
//  Weekend
//
//  Created by Jane on 16/3/30.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "HomeCell.h"
#import "HomeModel.h"
#import "LikeView.h"


@interface HomeCell()

@property (nonatomic,strong) LikeView *likeView;

@end

@implementation HomeCell

- (void)awakeFromNib {
    
    self.imgView.frame = CGRectMake(0, 0, SCREENWIDTH, 210);
    
    // ***** likeBtn ****
    _likeView = [LikeView createLikeViewWithIsLike:0 andNum:0];
    _likeView.frame = CGRectMake(SCREENWIDTH-65, CGRectGetMaxY(self.imgView.frame)-65, 45, 45);
    _likeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLikeBtn)];
    [_likeView addGestureRecognizer:tap];
    [self addSubview:_likeView];
}


+(instancetype)cellWithTable:(UITableView *)table andModel:(HomeModel *)homeModel
{
    static NSString *idStr = @"homeCell";
    
    HomeCell *cell = [table dequeueReusableCellWithIdentifier:idStr];
    
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = homeModel;
    cell.likeView.model = homeModel;
    cell.likeView.numLabel.text = homeModel.collectedNum;
    
    
    // **** 从数据库读取 设置likeBtn的选中状态 ****
    FMDBmanager *manager = [FMDBmanager shareInstance];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from Like where idStr = '%@'",homeModel.idStr];
    //    NSLog(@"sqlStr ==== %@",sqlStr);
    FMResultSet *rs = [manager.dataBase executeQuery:sqlStr];
    while ([rs next]) {
        cell.likeView.likeBtn.selected = YES;
        cell.likeView.numLabel.text = [NSString stringWithFormat:@"%ld",[[rs stringForColumn:@"collectedNum"] integerValue]];
    }
    
    
    return cell;
}


-(void)setModel:(HomeModel *)model
{
    _model = model;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.imgUrlStr] placeholderImage:PLACEIMAGE];
    
    self.titleLabel.text = model.titleStr;
    self.subTitleLabel.text = model.subTitleStr;
    self.farLabel.text = model.farStr;
    self.timeInfoLabel.text = model.timeInfoStr;
    
    
    //*****************************
    [self.farLabel sizeToFit];
    [self.timeInfoLabel sizeToFit];
    [self.titleLabel sizeToFit];
    
    CGFloat titleHeight = self.titleLabel.frame.size.height;
    model.cellHeight = 270 + titleHeight;

}




#pragma mark - 点击like按钮
-(void)clickLikeBtn
{
    if (_likeView.likeBtn.selected) { // 点击前是selected状态
        [_likeView canselLike];
    }else{              // 点击前是未选中状态
        [_likeView isLike];
    }
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

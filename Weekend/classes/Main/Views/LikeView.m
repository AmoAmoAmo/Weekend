//
//  LikeView.m
//  Weekend
//
//  Created by Jane on 16/5/12.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "LikeView.h"
#import "HomeModel.h"

@implementation LikeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, 45, 45)];
    if (self) {
        
        //        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 120, 20);
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 45*0.5;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
        
        [self addSubview:self.likeBtn];
        [self addSubview:self.numLabel];
    }
    return self;
}

+(instancetype)createLikeViewWithIsLike:(BOOL)isLike andNum:(NSInteger)num
{
    LikeView *view = [[LikeView alloc] init];
    view.likeBtn.selected = isLike;
    view.numLabel.text = [NSString stringWithFormat:@"%ld",num];
    
    return view;
}


-(void)isLike
{
    [self animationForLikeBtnClick];
    NSString *numStr =  self.numLabel.text;
    self.numLabel.text = [NSString stringWithFormat:@"%d",[numStr intValue]+1];
    // 更新为选中状态
    //    NSLog(@"%@",self.numLabel.text);//self.dataDic[@"newFavo"]//self.model.collectedNum
    self.likeBtn.selected = YES;
    
    // **** 插入数据库 ****
    FMDBmanager *manager = [FMDBmanager shareInstance];
    NSString *sqlStr = nil;
    
//    if (self.dataDic) {
//        sqlStr = [NSString stringWithFormat:@"insert into Like (idStr ,type ,imgUrlStr ,titleStr ,subTitleStr ,farStr ,timeInfoStr ,collectedNum ) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",self.dataDic[@"id"],self.dataDic[@"author"][@"headImg"],self.dataDic[@"author"][@"userName"],self.dataDic[@"author"][@"identity"],[NSString stringWithFormat:@"%@",self.dataDic[@"newRead"]],self.dataDic[@"smallIcon"],self.dataDic[@"title"],self.dataDic[@"category"][@"name"],self.dataDic[@"fnCommentNum"],self.dataDic[@"desc"],[NSString stringWithFormat:@"%@",self.numLabel.text],self.dataDic[@"createDate"]];
//    }else{
        sqlStr = [NSString stringWithFormat:@"insert into Like (idStr ,type ,imgUrlStr ,titleStr ,subTitleStr ,farStr ,timeInfoStr ,collectedNum ) values ('%@','%@','%@','%@','%@','%@','%@','%@')",self.model.idStr, self.model.type, self.model.imgUrlStr, self.model.titleStr, self.model.subTitleStr, self.model.farStr, self.model.timeInfoStr, self.numLabel.text];
//    }
//        NSLog(@"sqlStr ***** %@",sqlStr);
    if(![manager.dataBase executeUpdate:sqlStr])
    {
        NSLog(@"插入失败....");
    }
    
//     发送从数据库更新的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeTableDidChanged" object:self];
    
}



-(void)canselLike
{
//    [self animationForLikeBtnClick];
    NSString *numStr =  self.numLabel.text;
    //    NSLog(@"%@",numStr);
    if ([numStr intValue] > 0) {
        self.numLabel.text = [NSString stringWithFormat:@"%d",[numStr intValue]-1];
    }
    // 更新为未选中状态
    self.likeBtn.selected = NO;
    
    
//     **** 从数据库删除 ****
    FMDBmanager *manager = [FMDBmanager shareInstance];
    NSString *sqlStr = nil;
    
//    if (self.dataDic) {
//        sqlStr = [NSString stringWithFormat:@"delete from Like where idStr = '%@'", self.dataDic[@"id"]];
//    }else{
        sqlStr = [NSString stringWithFormat:@"delete from Like where idStr = '%@'", self.model.idStr];
//    }
    
//        NSLog(@"sqlStr ******* %@",sqlStr);
    if(![manager.dataBase executeUpdate:sqlStr])
    {
        NSLog(@"删除失败....");
    }
    
        // 发送从数据库更新的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeTableDidChanged" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeTableNeedToReload" object:self];
}

-(void)animationForLikeBtnClick
{
    [UIView animateWithDuration:0.3 animations:^{
        //        NSLog(@"1111111111");
        self.likeBtn.transform = CGAffineTransformMakeScale(1.4, 1.4);
        
    } completion:^(BOOL finished) {
        //        NSLog(@"2222222222");
        [UIView animateWithDuration:0.3 animations:^{
            self.likeBtn.transform = CGAffineTransformMakeScale(0.7, 0.7);
            //            NSLog(@"33333333333");
        } completion:^(BOOL finished) {
            //            NSLog(@"4444444444444");
            [UIView animateWithDuration:0.2 animations:^{
                //                NSLog(@"5555555555");
                self.likeBtn.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}






#pragma mark - 懒加载
-(UIButton *)likeBtn
{
    if (!_likeBtn) {
        
        _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeBtn.frame = CGRectMake((45-30)*0.5, 1, 30, 30);
        _likeBtn.userInteractionEnabled = NO;
        
        [_likeBtn setBackgroundImage:[UIImage imageNamed:@"ic_nav_black_heart_off"] forState:UIControlStateNormal];
        [_likeBtn setBackgroundImage:[UIImage imageNamed:@"ic_nav_black_heart_on"] forState:UIControlStateSelected];
    }
    return _likeBtn;
}

-(UILabel *)numLabel
{
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 45, 15)];
        _numLabel.font = [UIFont systemFontOfSize:12];
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _numLabel;
}

@end

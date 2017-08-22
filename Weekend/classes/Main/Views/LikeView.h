//
//  LikeView.h
//  Weekend
//
//  Created by Jane on 16/5/12.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeModel;

@interface LikeView : UIView

@property (nonatomic,strong) UIButton *likeBtn;
@property (nonatomic,strong) UILabel *numLabel;
//@property (nonatomic,strong) UIButton *bigBtn;


/** 把dataDic 传过来 */
@property (nonatomic,strong) NSDictionary *dataDic;
/** 把数据库的model传过来 */
@property (nonatomic,strong) HomeModel *model;

+(instancetype)createLikeViewWithIsLike:(BOOL)isLike andNum:(NSInteger)num;

-(void)isLike;
-(void)canselLike;

@end

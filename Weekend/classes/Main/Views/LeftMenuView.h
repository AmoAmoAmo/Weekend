//
//  LeftMenuView.h
//  Weekend
//
//  Created by Jane on 16/3/28.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeftMenuViewDelegate <NSObject>

-(void)LeftMenuViewBtnClickFromBtnTag:(NSInteger)fromTag ToBtnTag:(NSInteger)toTag;

@end

@interface LeftMenuView : UIView

@property (nonatomic, assign) id <LeftMenuViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *userHeadImgView;
@end

//
//  TopCell.h
//  Weekend
//
//  Created by Jane on 16/4/5.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *leftImgView;

@property (weak, nonatomic) IBOutlet UILabel *hotnessLab;//hotnessLab 服务器传过来的不是一个字符串
@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@end

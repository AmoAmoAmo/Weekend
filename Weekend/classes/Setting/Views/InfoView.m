//
//  InfoView.m
//  Weekend
//
//  Created by Jane on 16/4/2.
//  Copyright © 2016年 Jane. All rights reserved.
//
//  headInfoView

#import "InfoView.h"
#import "AppDelegate.h"

@interface InfoView()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userHeadImgView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
/** 缓存弹出提示框 */   // 要改成 iOS 8.3 的
@property (nonatomic,strong) UIAlertView *alertView;

@end

@implementation InfoView

-(void)awakeFromNib
{
    self.userHeadImgView.clipsToBounds = YES;
    self.userHeadImgView.layer.cornerRadius = self.userHeadImgView.frame.size.width/2;
    self.userHeadImgView.layer.borderWidth = 5;
    self.userHeadImgView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // ******************
    NSArray *iconsArr = @[@"ic_setting_share_app",@"ic_trash",@"ic_star",@"ic_tel",@"ic_feedback",@"ic_logout"];
    NSArray *titleArr = @[@"分享给好友",@"清除缓存",@"给我们一个评价",@"拨打客服电话",@"用户反馈",@"退出登录"];
    CGFloat iconX = 30;
    CGFloat iconW = 20;
    CGFloat margin = 12;
    
    for (int i = 0; i < 6; i++)
    {
        UIImageView *iconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconsArr[i]]];
        iconImgView.frame = CGRectMake(iconX, margin, iconW, iconW);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImgView.frame) + margin, margin, SCREENWIDTH-100, iconW)];
        [label setText:titleArr[i]];
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:14];
        
        UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(label.frame), CGRectGetMaxY(label.frame)+margin, SCREENWIDTH - 20 - CGRectGetMinX(label.frame) , 0.5)];
        lineV.backgroundColor = [UIColor lightGrayColor];
        lineV.alpha = 0.6;
        
        UIView *bigView = [[UIView alloc] initWithFrame:CGRectMake(0, i*(margin*2 + iconW), SCREENWIDTH, margin*2 + iconW)];
        bigView.tag = 100 + i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        [bigView addGestureRecognizer:tap];
        [self.bgView addSubview:bigView];
        [bigView addSubview:iconImgView];
        [bigView addSubview:label];
        [bigView addSubview:lineV];
    }
    
    
    
}


+(instancetype)createInfoView
{
    InfoView *view = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil][0];
    view.frame = CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT-64);//frame 是子控件在父控件中的位置
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}


#pragma mark - tap
-(void)tapView:(UITapGestureRecognizer *)tap
{
    //判断点击了哪个view
    switch (tap.view.tag) {
        case 100://分享给好友
        {
                    }
            break;
        case 101://清除缓存
        {
            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSLog(@"%@",cachesPath);
            NSFileManager *manager = [NSFileManager defaultManager];
            CGFloat folderSize = 0;
            if ([manager fileExistsAtPath:cachesPath])  // 如果存在文件
            {
                // 拿到所有子文件路径的数组
                NSArray *filesArr = [manager subpathsAtPath:cachesPath];
                //  拿到每个子文件的路径,如有有不想清除的文件就在这里判断
                for (NSString *childFilePath in filesArr) {
                    
                    // 拼接成完整路径
                    NSString *fullPath = [cachesPath stringByAppendingString:[NSString stringWithFormat:@"/%@",childFilePath]];
//                    NSLog(@"* %@",fullPath);
                    folderSize += [self fileSizeAtPath:fullPath]; // 方法.计算单个文件夹的大小
//                    NSLog(@"size===%f",folderSize);
                }
//                NSLog(@"size-all===%f",folderSize);
                // alertView
                self.alertView = [[UIAlertView alloc] initWithTitle:@"清除缓存" message:[NSString stringWithFormat:@"缓存大小为%.2fM,确定要清理缓存吗?",folderSize] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [self.alertView show];
            }
        }
            break;
        case 102://评价
        {
            UIApplication *app = [UIApplication sharedApplication];
            NSURL *pathURL = [NSURL URLWithString:@"http://www.baidu.com"];
            [app openURL:pathURL];
        }
            break;
        case 103://拨打客服电话
        {
            
        }
            break;
        case 104://用户反馈
            
            break;
        case 105://退出登录
            
            break;
            
        default:
            break;
    }
}

//计算单个文件夹的大小
-(float)fileSizeAtPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
//    NSLog(@"path === %@",path);
    if ([manager fileExistsAtPath:path]) {
        
        long long size = [manager attributesOfItemAtPath:path error:nil].fileSize;
//        NSLog(@"%lld",size);
        return size/1024.0/1024.0;
    }
    return 0;
}

#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex)    // buttonIndex == 1 点击了确定,
    {
        // 遍历整个caches文件,将里面的缓存清空
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:cachesPath])  // 如果存在文件
        {
            // 拿到所有子文件路径的数组
            NSArray *filesArr = [manager subpathsAtPath:cachesPath];
            //  拿到每个子文件的路径,如有有不想清除的文件就在这里判断
            for (NSString *childFilePath in filesArr) {
                
                // 拼接成完整路径
                NSString *fullPath = [cachesPath stringByAppendingString:[NSString stringWithFormat:@"/%@",childFilePath]];
                
                [manager removeItemAtPath:fullPath error:nil]; // remove
            }
        }
    }
    self.alertView = nil;
}

@end

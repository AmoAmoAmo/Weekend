//
//  MyAnnotation.m
//  Weekend
//
//  Created by Jane on 16/5/15.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        
        self.image = [UIImage imageNamed:@"ic_location_basketball"];
        
        self.canShowCallout = YES;
        
    }
    return self;
}


+(instancetype)createAnnotationViewWithMapView:(MKMapView *)mapView andAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *idStr = @"id";
    
    MyAnnotation *myView = (MyAnnotation *)[mapView dequeueReusableAnnotationViewWithIdentifier:idStr];
    if (myView == nil) {
        myView = [[MyAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:idStr];
    }
    
    //气泡左侧视图
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    view.backgroundColor = [UIColor redColor];
    myView.leftCalloutAccessoryView = view;
    
    return myView;
}



-(void)clickView
{
    [UIView animateWithDuration:1 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            self.transform = CGAffineTransformMakeScale(0.9, 0.9);
            
        } completion:^(BOOL finished) {
            self.transform = CGAffineTransformIdentity;
        }];
    }];
}


@end

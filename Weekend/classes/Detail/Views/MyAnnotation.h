//
//  MyAnnotation.h
//  Weekend
//
//  Created by Jane on 16/5/15.
//  Copyright © 2016年 Jane. All rights reserved.
//
//  大头针的样式（图片），复用的时候在代理中用

#import <MapKit/MapKit.h>

@interface MyAnnotation : MKAnnotationView

+(instancetype)createAnnotationViewWithMapView:(MKMapView *)mapView andAnnotation:(id<MKAnnotation>)annotation;

@end

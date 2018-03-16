//
//  LocationManagerTool.m
//  HiDate
//
//  Created by qidangsong on 16/10/8.
//  Copyright © 2016年 HiDate. All rights reserved.
//

#import "LocationManagerTool.h"

#import <CoreLocation/CoreLocation.h>
#import "HiDate-Swift.h"

@interface LocationManagerTool () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;


@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger timeoutPeriod;


@end

@implementation LocationManagerTool

- (void)tryLocationWithAccuracy:(BOOL)enableHighAccuracy andTimeout:(NSInteger)timeInterval
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        // 定位可用
        [HDSendLocalNotificationTool sendSystemAutotizeAlertWithTitle:NSLocalizedString(@"AuthorizeAlertWithLocationTitle", @"") body:NSLocalizedString(@"AuthorizeAlertWithLocationBody", @"")];
        
        if (self.resultCallBack) {
            self.resultCallBack(@{@"error": @{@"code": @"2"}});
        }
        
    } else {
        
        if (timeInterval > 0) {
            
            self.timeoutPeriod = timeInterval;

            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerProgress) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
        
        [self startGetLocation:enableHighAccuracy];
    }
}

- (void)startGetLocation:(BOOL)enableHighAccuracy
{
    // 检查定位是否授权
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if (enableHighAccuracy) {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    } else {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)updateTimerProgress
{
    if (self.timeoutPeriod == -1) {
        [self.locationManager stopUpdatingHeading];
        [self.timer invalidate];
        
        // 超时
        if (self.resultCallBack) {
            self.resultCallBack(@{@"error": @{@"code": @"3"}});
        }
    } else {
        self.timeoutPeriod -= 1;
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // 停止位置更新
    [self.locationManager stopUpdatingLocation];
    
    [self.timer invalidate];
    
    // 获取经纬度
    if (self.resultCallBack) {
        
        NSDictionary *locationInfo = @{
                                       @"coords": @{
                                               @"latitude": [NSNumber numberWithDouble:newLocation.coordinate.latitude],
                                               @"longitude": [NSNumber numberWithDouble:newLocation.coordinate.longitude],
                                               @"direction": [NSNumber numberWithDouble:newLocation.course],
                                               @"speed": [NSNumber numberWithDouble:newLocation.speed],
                                               @"altitude": [NSNumber numberWithDouble:newLocation.altitude]
                                               },
                                       @"timestamp": [NSNumber numberWithDouble:[newLocation.timestamp timeIntervalSince1970]]
                                       };
        self.resultCallBack(locationInfo);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
    [self.timer invalidate];
    if (self.resultCallBack) {
        self.resultCallBack(@{@"error": @{@"code": @"0"}});
    }
}

@end

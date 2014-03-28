//
//  MapViewController.h
//  SISMAPP
//
//  Created by Axel on 07/01/14.
//  Copyright (c) 2014 axelardoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController
@property NSArray *positionNameDistance;
@property CLLocation *selfPosition;
@end

//
//  BrowserViewController.h
//  SISMAPP
//
//  Created by Axel on 07/01/14.
//  Copyright (c) 2014 axelardoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <CoreLocation/CoreLocation.h>

@interface BrowserViewController : UITableViewController

@property (nonatomic,strong) MCPeerID *browserPeerID;
@property (nonatomic,strong) CLLocation *position;
@property CLLocation *selfLocation;

@end

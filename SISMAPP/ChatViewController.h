//
//  ChatViewController.h
//  SISMAPP
//
//  Created by Axel on 12/01/14.
//  Copyright (c) 2014 axelardoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ChatViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,MCSessionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UITableView *tableMessages;
@property MCSession *sessionToSend;
@property MCPeerID *peerSender;
-(void)addMessage:(NSString*) message fromPeer:(MCPeerID*) peer;
@end

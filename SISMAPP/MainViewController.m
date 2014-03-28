//
//  ViewController.m
//  SISMAPP
//
//  Created by Axel on 06/01/14.
//  Copyright (c) 2014 axelardoin. All rights reserved.
//

#import "MainViewController.h"
#import "BrowserViewController.h"
#import "ChatViewController.h"
#import "MapViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <AVFoundation/AVFoundation.h>

@interface MainViewController () <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (nonatomic,strong) MCPeerID *peerID;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic,strong) MCNearbyServiceAdvertiser *advertiser;
@property (weak, nonatomic) IBOutlet UITextField *utfPseudo;
@property (nonatomic,strong) MCSession *advertiserSession;
@property AVAudioPlayer* audioPlayer;
@property CLLocation *position;
@property ChatViewController *chatView;

@end

@implementation MainViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title= @"GPS: position inconnue";
    [self initLocator];
    [self initAlert];
    [self initChatReceiver];
    [self initAdvertiser];
}
-(void)initChatReceiver
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"bundle:nil];
    _chatView=[storyboard instantiateViewControllerWithIdentifier:@"chatView"];
}
-(void)initLocator
{
    _locationManager = [[CLLocationManager alloc]init];
    _position = [[CLLocation alloc]init];
    _locationManager.delegate=self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    //we have to fix a location for the simulator
    #if TARGET_IPHONE_SIMULATOR
        _position=[[CLLocation alloc] initWithLatitude:43.617634 longitude:7.065697];
        self.title= [NSString stringWithFormat:@"GPS: %g;%g",_position.coordinate.latitude,_position.coordinate.longitude];;
    #else
        [self restartTimer];
    #endif
}
-(void)initAlert
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"alarm" ofType:@"mp3" inDirectory:@"sounds"];
    NSURL* file = [NSURL URLWithString:path];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
}

-(void)playAlarm{
    [_audioPlayer play];
}
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    if(state==MCSessionStateConnected){}
}

#pragma mark - Advertising

-(void)initAdvertiser
{
    NSString *deviceName=[UIDevice currentDevice].name;
    [_utfPseudo setText:deviceName];
    _peerID = [[MCPeerID alloc]initWithDisplayName:deviceName];
    
    NSDictionary *infos = [[NSDictionary alloc] initWithObjectsAndKeys:@"position inconnue",@"position", nil];
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:infos serviceType:@"alerte"];
    _advertiser.delegate=self;
    [_advertiser startAdvertisingPeer];
    _advertiserSession = [[MCSession alloc]initWithPeer:_peerID];
    _advertiserSession.delegate = _chatView;
    NSLog(@"%@ is advertising...",deviceName);
}
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler{
    @try {
        [_audioPlayer prepareToPlay];
        invitationHandler(YES,_advertiserSession);
        [self playAlarm];
        UIAlertView *connexionAsked = [[UIAlertView alloc] initWithTitle: @"RISQUE SISMIQUE CONFIRMÉ" message:@"" delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [connexionAsked show];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Erreur lors de l'invitation" message:[exception description] delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
    }
    _chatView.sessionToSend = _advertiserSession;
    _chatView.peerSender=_peerID;
    if(![self.navigationController.topViewController isKindOfClass:[ChatViewController class]]){
        [self.navigationController pushViewController:_chatView animated:YES];
    }

}

//Reload the advertising with the last position known wich is updated by a NSTimer interval
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(_position!=nil && locations.lastObject != _position){
        [_locationManager stopUpdatingLocation];
        _position=locations.lastObject;
        //NSLog(@"New position: %@",_position.description);
        [_advertiser stopAdvertisingPeer];
        NSString *latLong= [NSString stringWithFormat:@"%g;%g",_position.coordinate.latitude,_position.coordinate.longitude];
        self.title= [NSString stringWithFormat: @"GPS: %@",latLong];
        NSDictionary *infos = [[NSDictionary alloc] initWithObjectsAndKeys:latLong,@"position", nil];
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:infos serviceType:@"alerte"];
        _advertiser.delegate=self;
        [_advertiser startAdvertisingPeer];
        [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(restartTimer) userInfo:nil repeats:NO];
        //NSLog(@"Next position update in 60s");
    }
}
-(void)restartTimer{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),^{
        [_locationManager startUpdatingLocation];
    });
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"P2PSegue"])
    {
        BrowserViewController *bvc = [segue destinationViewController];
        bvc.position=_position;
        bvc.browserPeerID=_peerID;
        bvc.selfLocation=_position;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [_advertiser stopAdvertisingPeer];
    }
}

@end

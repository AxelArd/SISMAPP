//
//  BrowserViewController.m
//  SISMAPP
//
//  Created by Axel on 07/01/14.
//  Copyright (c) 2014 axelardoin. All rights reserved.
//

#import "BrowserViewController.h"
#import "ChatViewController.h"
#import "MapViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface BrowserViewController() <MCNearbyServiceBrowserDelegate, MCSessionDelegate, UITableViewDelegate>

@property (nonatomic,strong) MCNearbyServiceBrowser *browser;
@property (nonatomic,strong) MCSession *browserSession;
@property (nonatomic,strong) NSMutableArray *peerList;
@property ChatViewController *chatView;

@end

@implementation BrowserViewController
@synthesize browserSession,browserPeerID,selfLocation;

#pragma mark - Peer browsing

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"bundle:nil];
    _peerList = [[NSMutableArray alloc]init];
    browserSession = [[MCSession alloc]initWithPeer:browserPeerID];
    _chatView=[storyboard instantiateViewControllerWithIdentifier:@"chatView"];
    _chatView.sessionToSend = browserSession;
    _chatView.peerSender=browserPeerID;
    browserSession.delegate = _chatView;
    NSLog(@"%@ browserSession ok",[UIDevice currentDevice].name);
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:browserPeerID serviceType:@"alerte"];
    _browser.delegate=self;
    [_browser startBrowsingForPeers];
    NSLog(@"%@ is browsing",[UIDevice currentDevice].name);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Carte"
                                                                              style:UIBarButtonItemStylePlain target:self action:@selector(showMap)];;
}

//add new peers to tableview
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"peer found, with info: %@",info.description);
    NSArray *peerInfos = [[NSArray alloc] initWithObjects:peerID, info, nil];
    NSDictionary *keyValue = [[NSDictionary alloc] initWithObjectsAndKeys:peerInfos,peerID.displayName, nil];
    if(![_peerList containsObject:keyValue]){
        [_peerList addObject:keyValue];
        [browser invitePeer:peerID toSession:browserSession withContext:nil timeout:0];
        [self.tableView reloadData];
    }
}

//remove lost peers from tableview
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"peer lost: %@",peerID.displayName);
    int removeIndex;
    for(NSDictionary *dict in _peerList){
        if([[dict objectForKey:[dict.allKeys objectAtIndex:0]] objectAtIndex:0] == peerID){
            NSLog(@"peer removed from list");
            removeIndex=[_peerList indexOfObject:dict];
            [self.tableView reloadData];
        }
    }
    [_peerList removeObjectAtIndex:removeIndex];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
}
- (void)viewWillDisappear:(BOOL)animated {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([viewControllers indexOfObject:self] == NSNotFound) {
        [_browser stopBrowsingForPeers];
        _peerList = [[NSMutableArray alloc]init];
        [self.tableView reloadData];
    }
}
#pragma mark - tableview management

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _peerList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"peerCell" forIndexPath:indexPath];
    NSArray *values=[self getPositionNameDistanceForPeerAt:indexPath];
    cell.textLabel.text= [values objectAtIndex:1];
    cell.detailTextLabel.text=[values objectAtIndex:2];
    return cell;
}
-(NSArray*)getPositionNameDistanceForPeerAt:(NSIndexPath *)indexPath {
    NSDictionary *keyValue = [_peerList objectAtIndex:indexPath.row];
    return [self getPositionNameDistanceForPeerFromDictionary:keyValue];
}
-(NSArray*)getAllPositionNameDistance{
    NSMutableArray *all=[[NSMutableArray alloc]init];
    for(NSDictionary *dict in _peerList){
        [all addObject: [self getPositionNameDistanceForPeerFromDictionary:dict]];
    }
    return all;
}
-(NSArray*)getPositionNameDistanceForPeerFromDictionary:(NSDictionary *)dict {
    id nameKey = [[dict allKeys]objectAtIndex:0];
    NSString *peerName = nameKey;
    NSString *stringPeerPosition = [[[dict objectForKey:nameKey] objectAtIndex:1] objectForKey:@"position"];
    NSArray *listCoord = [stringPeerPosition componentsSeparatedByString:@";"];
    NSString *distance=@"";
    CLLocation *peerPosition=nil;
    if(listCoord!=nil && listCoord.count>1){
        peerPosition = [[CLLocation alloc]initWithLatitude:[[listCoord objectAtIndex:0] doubleValue]
                                                 longitude:[[listCoord objectAtIndex:1] doubleValue]];
        CLLocationDistance meters = [peerPosition distanceFromLocation:_position];
        distance = [NSString stringWithFormat:@"%f m", meters];
        
    }
    NSString *name = [peerName length]==0 ?@"Inconnu":peerName;
    NSString *peerDistance = [distance length]==0 ?@"position inconnue":distance;
    return [NSArray arrayWithObjects:peerPosition,name,peerDistance, nil];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController pushViewController:_chatView animated:YES];
}

#pragma mark - Map preload
-(void)showMap{
    MapViewController *map = [[MapViewController alloc]init];
    [map setPositionNameDistance:[self getAllPositionNameDistance]];
    [map setSelfPosition:selfLocation];
    [self.navigationController pushViewController:map animated:YES];
}

@end

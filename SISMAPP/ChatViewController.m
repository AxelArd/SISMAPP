//
//  ChatViewController.m
//  SISMAPP
//
//  Created by Axel on 12/01/14.
//  Copyright (c) 2014 axelardoin. All rights reserved.
//

#import "ChatViewController.h"


@interface ChatViewController()

@property NSMutableArray *messageList;

@end

@implementation ChatViewController
@synthesize peerSender,sessionToSend;

-(void) viewDidLoad
{
    _tableMessages.dataSource=self;
    _tableMessages.delegate=self;
    _messageList = [[NSMutableArray alloc]init];
}
-(void)addMessage:(NSString*) message fromPeer:(MCPeerID*) peer
{
    NSLog(@"preparing chat message: %@ from %@",message,peer.displayName);
    NSLog(@"thread: %@", [NSThread currentThread]);
    NSDictionary *peerMessage = [[NSDictionary alloc]initWithObjectsAndKeys:message,peer.displayName, nil];
    [_messageList addObject:peerMessage];
    [self performSelectorOnMainThread:@selector(refreshTableView) withObject:nil waitUntilDone:YES];
    
}
- (IBAction)sendMessage:(id)sender {
    [_txtMessage endEditing:YES];
    NSString *textToSend=_txtMessage.text;
    if(textToSend.length>0){
        NSData* data = [textToSend dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSLog(@"sending message to:");NSLog(sessionToSend.description);
        [sessionToSend sendData:data toPeers:[sessionToSend connectedPeers] withMode:MCSessionSendDataReliable error:&error];
        [self addMessage:textToSend fromPeer:peerSender];
        [_txtMessage setText:@""];
    }
}

#pragma mark - tableview management

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messageList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
    NSDictionary *peerMessage = [_messageList objectAtIndex:indexPath.row];
    NSString *nameKey = [[peerMessage allKeys] objectAtIndex:0];
    cell.textLabel.text = nameKey;
    cell.detailTextLabel.text = [peerMessage objectForKey:nameKey];
    return cell;
}
-(void)refreshTableView
{
    [_tableMessages reloadData];
    long lastRowNumber = [_tableMessages numberOfRowsInSection:0] - 1;
    if(lastRowNumber>0){
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [_tableMessages scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark - chat management

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"message received: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [self addMessage:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] fromPeer:peerID];
}
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{

}

@end

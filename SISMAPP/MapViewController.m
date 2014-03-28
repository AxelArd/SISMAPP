//
//  MapViewController.m
//  SISMAPP
//
//  Created by Axel on 07/01/14.
//  Copyright (c) 2014 axelardoin. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation MapViewController{
    GMSMapView *mapView_;
}
@synthesize positionNameDistance,selfPosition;
- (void)viewDidLoad {
    if (selfPosition!=nil) {
        //configure the map centered on the user's position
        CLLocationDegrees lati,longi;
        lati=selfPosition.coordinate.latitude;
        longi=selfPosition.coordinate.longitude;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lati
                                                                longitude:longi
                                                                     zoom:17];
        mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        mapView_.myLocationEnabled = YES;
        self.view = mapView_;
        //create the user icon
        CLLocationCoordinate2D userPosition = selfPosition.coordinate;
        GMSMarker *user = [GMSMarker markerWithPosition:userPosition];
        user.title = @"Moi";
        user.icon = [UIImage imageNamed:@"user"];
        user.map = mapView_;
        //create an icon on the map for all peer
        NSLog(@"List of peers to show on map: %@",positionNameDistance);
        if (positionNameDistance.count>0) {
            for(NSArray *peer in positionNameDistance){
                CLLocation *loc=[peer objectAtIndex:0];
                NSString *peerName=[peer objectAtIndex:1];
                NSString *peerPos=[peer objectAtIndex:2];
                CLLocationCoordinate2D peerPosition = loc.coordinate;
                GMSMarker *peer = [GMSMarker markerWithPosition:peerPosition];
                peer.title = peerName;
                peer.snippet=peerPos;
                peer.icon = [UIImage imageNamed:@"peer"];
                peer.map = mapView_;
                
                GMSMutablePath *lineUserToPeer = [GMSMutablePath path];
                [lineUserToPeer addCoordinate:selfPosition.coordinate];
                [lineUserToPeer addCoordinate:peerPosition];
                
                GMSPolyline *pathUserToPeer = [GMSPolyline polylineWithPath:lineUserToPeer];
                pathUserToPeer.map = mapView_;
                
            }
            
        }
        
    }
    
}
@end

//
//  MapViewController.m
//  Dingo
//
//  Created by Asatur Galstyan on 9/11/14.
//  Copyright (c) 2014 Dingo. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "WebServiceManager.h"
#import "DataManager.h"

@interface MapViewController () {
    
    __weak IBOutlet MKMapView *mapView;
}

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [WebServiceManager addressToLocation:[DataManager eventLocation:self.event] completion:^(id response, NSError *error) {
        
        if ([response[@"status"] isEqualToString:@"OK"]) {
            NSArray *results = response[@"results"];
            if (results.count > 0) {
                NSDictionary *result = results[0];
                
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([result[@"geometry"][@"location"][@"lat"] doubleValue], [result[@"geometry"][@"location"][@"lng"] doubleValue]);
                MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
                MKCoordinateRegion region = {coord, span};
                [mapView setRegion:region];
                
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = coord;
                [mapView addAnnotation:annotation];
            }
            
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

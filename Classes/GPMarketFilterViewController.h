//
//  GPMarketFilterViewController.h
//  goPlay
//
//  Created by Spenser Flugum on 1/28/15.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapViewAnnotation.h"
#import "GPGameMapViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface GPMarketFilterViewController : UIViewController <MKMapViewDelegate> {

	IBOutlet UIView *mapContainer;
	IBOutlet MKMapView *filterMap;
	IBOutlet UIButton *buttonMarket;
	IBOutlet UIButton *buttonFeatured;
	IBOutlet UIButton *buttonProducts;
	IBOutlet UIButton *buttonNearby;
	IBOutlet UIButton *buttonServices;
	IBOutlet UILabel *userLocationLabel;

	IBOutlet UIImageView *arrow01;
	IBOutlet UIImageView *arrow02;
	IBOutlet UIImageView *arrow03;
	IBOutlet UIImageView *arrow04;
	IBOutlet UIImageView *arrow05;

	IBOutlet UIImageView *iconStar;
	IBOutlet UIImageView *iconTag;
	IBOutlet UIImageView *iconPin;
	IBOutlet UIImageView *iconGears;

	NSArray* buttonArray;
	NSArray* arrowArray;

	GPGameMapViewController* gameMapController;
	UIActivityIndicatorView  *av;

}

- (IBAction)filterDown:(id)sender;

- (IBAction)marketSelect:(id)sender;
- (IBAction)featureSelect:(id)sender;
- (IBAction)productsSelect:(id)sender;
- (IBAction)nearbySelect:(id)sender;
- (IBAction)servicesSelect:(id)sender;



@end

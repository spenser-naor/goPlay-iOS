//
//  GPFindGameViewController.h
//  goPlay
//
//  Created by Spenser Flugum on 7/27/14.
//
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>
#import "MapViewAnnotation.h"
#import "GPGameMapViewController.h"

@interface GPFindGameViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>{
	IBOutlet UIImageView *navBack;
	NSMutableArray *contentList;
	NSMutableArray *filteredContentList;
	BOOL isSearching;
	@public
	BOOL fromStart;
	BOOL fromSugg;
	NSString* startLocation;
	MKAnnotationView* startAnnotationView;
	IBOutlet UIButton *useLocationButton;
	IBOutlet UIButton *centerLocationButton;
	NSArray *gamesArray;
	double startLat;
	double startLon;
	NSMutableArray* hashArray;
	IBOutlet UIButton *searchStart;
	MapViewAnnotation* searchedAnnotation;
	IBOutlet UIImageView *logoNav;
	IBOutlet UIImageView *logoHex;
	IBOutlet UIView *mapContainer;

	UIView* filtersView;

	gameMapViewController* gameMapController;

	MKMapItem* gameMapItem;

	NSMutableArray* buttonArray;
	NSMutableArray* arrowArray;
	UIScrollView* filterScroll;
	int buttonHeight;

	IBOutlet UIView *searchView;
	IBOutlet UIView *slideView;
}
@property (nonatomic, strong) NSArray *places;
@property (strong, nonatomic) IBOutlet UITableView *tblContentList;
@property (strong, nonatomic) IBOutlet UISearchBar *GPsearchBar;
@property (strong, nonatomic) IBOutlet UISearchController *searchBarController;
- (IBAction)useLocation:(id)sender;
- (IBAction)centerLocation:(id)sender;
- (IBAction)backPushed:(id)sender;

@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D userLocation;
- (IBAction)filtersPressed:(id)sender;

@property (nonatomic, strong) NSArray *mapItemList;

@end

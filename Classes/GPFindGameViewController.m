//
//  GPFindGameViewController.m
//  goPlay
//
//  Created by Spenser Flugum on 7/27/14.
//
//

#import "GPFindGameViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>
#import "GPPlayGameViewController.h"

static NSString *kCellIdentifier = @"cellIdentifier";

@interface GPFindGameViewController ()


@end

@implementation GPFindGameViewController

@synthesize GPsearchBar;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		NSLog(@"init");
		if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
			[self.locationManager requestWhenInUseAuthorization];
		}
		[self setLocationAccuracyBestDistanceFilterNone];

		buttonArray = [[NSMutableArray alloc] init];

	}

	return self;
}

- (void)setLocationAccuracyBestDistanceFilterNone
{
	[self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[self.locationManager setDistanceFilter:kCLDistanceFilterNone];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];

	//set up navigation bar
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"buttonFilters.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(filtersPressed:)];

	if (fromStart == YES) {
		self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar_findlocation.png"]];
		useLocationButton.hidden = false;
	}
	else if (fromStart != YES) {
		self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar_findlocation.png"]];
		centerLocationButton.hidden = false;
	}

	GPGameMapController = [[gameMapViewController alloc] init];
	GPGameMapController->fromStart = fromStart;
	GPGameMapController->fromSugg = fromSugg;

	GPGameMapController.view.frame = CGRectMake(0, 0, mapContainer.frame.size.width, mapContainer.frame.size.height);
	[self addChildViewController:GPGameMapController];
	[mapContainer addSubview:GPGameMapController.view];
	[GPGameMapController didMoveToParentViewController:self];

	[slideView.layer setMasksToBounds:NO];
	[slideView.layer setShadowColor:[UIColor blackColor].CGColor];
	[slideView.layer setShadowOpacity:.40f];
	[slideView.layer setShadowRadius:5.0f];
	[slideView.layer setShadowOffset:CGSizeMake(3, 0)];


	GPGameMapController.mapView.alpha = 0.0f;
	UIActivityIndicatorView  *av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	av.center = mapContainer.center;
	av.tag  = 1;
	[self.view addSubview:av];
	[av startAnimating];


	//placing here for memory management
	[self.locationManager startUpdatingLocation];

}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];


	CLGeocoder* gc = [[CLGeocoder alloc] init];
	CLLocation *loc = [[CLLocation alloc]initWithLatitude:GPGameMapController.mapView.userLocation.coordinate.latitude longitude:GPGameMapController.mapView.userLocation.coordinate.longitude]; //insert your coordinates


	[gc reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
		CLPlacemark *placemark = [placemarks objectAtIndex:0];
		if (placemark.locality != NULL) {
			//remove indicator and show map
			UIActivityIndicatorView *tmpimg = (UIActivityIndicatorView *)[self.view viewWithTag:1];
			[tmpimg removeFromSuperview];

			[UIView animateWithDuration:1.0f animations:^{
				GPGameMapController.mapView.alpha = 1.0f;
			} completion:nil];
		}

		else{
			[GPGameMapController viewDidLoad];
			[self viewDidAppear:NO];
			[GPGameMapController viewDidAppear:NO];
			NSLog(@"location null");
		}
	}];

}

-(void) viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:NO];
	//grabs location info from map just before startGameViewController requests it from finGameViewController
	startLocation = GPGameMapController->startLocation;
	startLat = GPGameMapController->startLat;
	startLon = GPGameMapController->startLon;
	gameMapItem = GPGameMapController->gameMapItem;

	//removing here for memory management
	[self.locationManager stopUpdatingLocation];
	[self closeFilters];
}



- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return UIInterfaceOrientationMaskAll;
	else
		return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)playHere{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)goToGame:(id)sender{
	UIButton *clicked = (UIButton *) sender;

	for (int i=0; i<gamesArray.count; i++) {
		//NSLog(@"%@", hashArray[i]);
		if ([hashArray[i] isEqualToString:[NSString stringWithFormat:@"%li", (long)clicked.tag]]) {
			GPPlayGameViewController *gameViewController = [[GPPlayGameViewController alloc] initWithGame:gamesArray[i]];
			[self.navigationController pushViewController:gameViewController animated:NO];
		}
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
	}

	MKMapItem *mapItem = [self.places objectAtIndex:indexPath.row];
	cell.textLabel.text = mapItem.name;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath *selectedItem = [self.tblContentList indexPathForSelectedRow];
	self.mapItemList = [NSArray arrayWithObject:[self.places objectAtIndex:selectedItem.row]];

	MKMapItem *mapItem = [self.mapItemList objectAtIndex:0];

	GPGameMapController.mapView.centerCoordinate = mapItem.placemark.coordinate;

	//it would be nice to have a pin drop on a newly search area, but this pin would have to have different art than the normal pin.
	MapViewAnnotation *annotation = [[MapViewAnnotation alloc] initWithMapItem:mapItem];
	if (fromStart == true) {
		[GPGameMapController.mapView removeAnnotations:GPGameMapController.mapView.annotations];
	}
	else if (fromStart != true && searchedAnnotation != nil) {
		[GPGameMapController.mapView removeAnnotations:[NSArray arrayWithObject:searchedAnnotation]];
	}
	annotation.mapItem = mapItem;
	searchedAnnotation = annotation;
	GPGameMapController.searchedAnnotation = annotation;
	[GPGameMapController.mapView addAnnotation:annotation];

	[self searchBarCancelButtonClicked:GPsearchBar];

}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{

	[self.GPsearchBar resignFirstResponder];

	self.tblContentList.hidden = true;

	[self closeFilters];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[self.GPsearchBar setShowsCancelButton:YES animated:YES];

	if (fromStart == true) {
		self.tblContentList.hidden = false;
	}

	[self closeFilters];
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	[self.GPsearchBar setShowsCancelButton:NO animated:YES];

	[self closeFilters];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	if (fromStart == true) { //look for facilities
		if (self.localSearch.searching)
		{
			[self.localSearch cancel];
		}
		// confine the map search area to the user's current location
		MKCoordinateRegion newRegion;
		newRegion.center = GPGameMapController.mapView.centerCoordinate;

		// setup the area spanned by the map region:
		// we use the delta values to indicate the desired zoom level of the map,
		//      (smaller delta values corresponding to a higher zoom level)
		//
		MKMapRect mRect = GPGameMapController.mapView.visibleMapRect;

		newRegion = MKCoordinateRegionForMapRect(mRect);

		MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];

		request.naturalLanguageQuery = searchText;
		request.region = newRegion;


		MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error)
		{
			if (error != nil)
			{
			}
			else
			{

				self.places = [response mapItems];

				// used for later when setting the map's region in "prepareForSegue"
				self.boundingRegion = response.boundingRegion;

				[self.tblContentList reloadData];
			}
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		};

		if (self.localSearch != nil)
		{
			self.localSearch = nil;
		}
		self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];

		[self.localSearch startWithCompletionHandler:completionHandler];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}

	[self closeFilters];
}

- (void)startSearch:(NSString *)searchString
{
	if (fromStart == true) {
		if (self.localSearch.searching)
		{
			[self.localSearch cancel];
		}

		// confine the map search area to the user's current location
		MKCoordinateRegion newRegion;
		newRegion.center = GPGameMapController.mapView.centerCoordinate;

		// setup the area spanned by the map region:
		// we use the delta values to indicate the desired zoom level of the map,
		//      (smaller delta values corresponding to a higher zoom level)
		//
		MKMapRect mRect = GPGameMapController.mapView.visibleMapRect;

		newRegion = MKCoordinateRegionForMapRect(mRect);

		//newRegion.span.latitudeDelta = 0.112872;
		//newRegion.span.longitudeDelta = 0.109863;


		MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];

		request.naturalLanguageQuery = searchString;
		request.region = newRegion;

		MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error)
		{
			if (error != nil)
			{
				NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
					message:errorStr
					delegate:nil
					cancelButtonTitle:@"OK"
					otherButtonTitles:nil];
				[alert show];
			}
			else
			{
				NSLog(@"noErrors");

				self.places = [response mapItems];

				// used for later when setting the map's region in "prepareForSegue"
				self.boundingRegion = response.boundingRegion;

				[self.tblContentList reloadData];
			}
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		};

		if (self.localSearch != nil)
		{
			self.localSearch = nil;
		}
		self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];

		[self.localSearch startWithCompletionHandler:completionHandler];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}

	else{
		[GPGameMapController loadGames:searchString];
	}

	[self closeFilters];

	NSDictionary *searchParams = [NSDictionary dictionaryWithObjectsAndKeys: searchString, @"Search_Query",nil];
	[Flurry logEvent:kFlurryMapSearchQuery withParameters:searchParams];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{

	[self.GPsearchBar resignFirstResponder];

	// check to see if Location Services is enabled, there are two state possibilities:
	// 1) disabled for entire device, 2) disabled just for this app
	//	
	NSString *causeStr = nil;

	// check whether location services are enabled on the device
	if ([CLLocationManager locationServicesEnabled] == NO)
	{
		causeStr = @"device";
	}
	// check the application’s explicit authorization status:
	else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
	{
		causeStr = @"app";
	}
	else
	{
		// we are good to go, start the search
		[self startSearch:self.GPsearchBar.text];
	}

	if (causeStr != nil)
	{
		NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];

		UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
			message:alertMessage
			delegate:nil
			cancelButtonTitle:@"OK"
			otherButtonTitles:nil];
		[servicesDisabledAlert show];
	}

	[GPGameMapController.mapView removeAnnotations:GPGameMapController.mapView.annotations];

	for (MKMapItem* mapItem in self.places) {

		//it would be nice to have a pin drop on a newly search area, but this pin would have to have different art than the normal pin.

		MapViewAnnotation *annotation = [[MapViewAnnotation alloc] initWithMapItem:mapItem];

		[GPGameMapController.mapView addAnnotation:annotation];


		[self searchBarCancelButtonClicked:GPsearchBar];
	}

	[self closeFilters];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	//NSLog(@"Location");
	// remember for later the user's current location
	self.userLocation = newLocation.coordinate;

	[manager stopUpdatingLocation]; // we only want one update

	manager.delegate = nil;         // we might be called again here, even though we
	// called "stopUpdatingLocation", remove us as the delegate to be sure
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
// report any errors returned back from Location Services
}

- (IBAction)useLocation:(id)sender {
	GPGameMapController.mapView.centerCoordinate = self.userLocation;
	CLLocationCoordinate2D coord = self.userLocation;

	//This produces a pin for the nearest address to the user. It's identical to the long press gesture
	CLGeocoder *ceo = [[CLGeocoder alloc]init];
	CLLocation *loc = [[CLLocation alloc]initWithLatitude:coord.latitude longitude:coord.longitude];

	[ceo reverseGeocodeLocation:loc
		completionHandler:^(NSArray *placemarks, NSError *error) {
			if (!error) {

				CLPlacemark *placemark = [placemarks objectAtIndex:0];

				MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:placemark.location.coordinate addressDictionary:[placemark addressDictionary]];
				MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:place];
				[mapItem setName:placemark.name];
				MapViewAnnotation *annotation = [[MapViewAnnotation alloc] initWithMapItem:mapItem];
				[GPGameMapController.mapView removeAnnotations:GPGameMapController.mapView.annotations];
				[GPGameMapController.mapView addAnnotation:annotation];

			}
			else {
				NSLog(@"Could not locate");
				//This code produces "custom location" at user location. It has merits so I'll keep the code around
				MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
				MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:place];

				[mapItem setName:@"Custom Location"];

				MapViewAnnotation *annotation = [[MapViewAnnotation alloc] initWithMapItem:mapItem];

				[GPGameMapController.mapView removeAnnotations:GPGameMapController.mapView.annotations];

				[GPGameMapController.mapView addAnnotation:annotation];

				[self searchBarCancelButtonClicked:GPsearchBar];
			}
		}];

}

- (IBAction)centerLocation:(id)sender {
	[GPGameMapController.mapView setCenterCoordinate:GPGameMapController.mapView.userLocation.location.coordinate animated:YES];
}

- (IBAction)backPushed:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)filtersPressed:(id)sender {

	if (!filterScroll) {

		filterScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.frame.size.width,0, 2*self.view.frame.size.width/3,self.view.frame.size.height)];
		[self.view addSubview:filterScroll];
		[self.view sendSubviewToBack:filterScroll];
		[filterScroll setBackgroundColor:[UIColor whiteColor]];
		[filterScroll setShowsVerticalScrollIndicator:NO];

		NSMutableArray* buttonNamesArray;
		NSMutableArray* badgeNamesArray;

		if (fromStart==true) {
			buttonNamesArray = [[NSMutableArray alloc] initWithObjects:@"Favorites", @"Park", @"Basketball Court", @"Golf Course", @"Climbing Gym", @"Trail", @"Yoga", @"Tennis Court",nil];
			badgeNamesArray = [[NSMutableArray alloc] initWithObjects:@"Favorites", @"Hiking", @"Basketball", @"Golf", @"Climbing", @"Hiking", @"Yoga", @"Tennis", nil]; //badge names are the activities associated with the search queries if fromstart

		}
		else{
			NSString *filepath = [[NSBundle mainBundle] pathForResource:@"ActivityPickerData" ofType:@"txt"];
			NSString *content =  [NSString stringWithContentsOfFile:filepath  encoding:NSUTF8StringEncoding error:nil];
			NSArray* activitiesArray = [content componentsSeparatedByString:@"\n"];
			buttonNamesArray = [[NSMutableArray alloc] initWithArray:activitiesArray];
		badgeNamesArray = [[NSMutableArray alloc] initWithArray:activitiesArray]; //badge nams are the same as the activity names if from find

		}


		buttonHeight = 35;
		int badgeMargin = 5;

		for (int i=0; i<buttonNamesArray.count; i++) {
			UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, buttonHeight*i, filterScroll.frame.size.width, buttonHeight)];
			[button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
			[button setTitle:buttonNamesArray[i] forState:UIControlStateNormal];
			[button addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			[buttonArray addObject:button];
			[filterScroll addSubview:button];

			//Add badge image
			UIImageView *badgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(badgeMargin, button.frame.origin.y+badgeMargin, buttonHeight-(badgeMargin*2), buttonHeight-(badgeMargin*2))];
			[badgeImageView setContentMode:UIViewContentModeScaleAspectFit];
			[filterScroll addSubview:badgeImageView];

			//Find badge for button
			if ([buttonNamesArray[i] isEqualToString:@"Favorites"]) {
				badgeImageView.image = [UIImage imageNamed:@"buttonFav.png"];
			}
			else{
				PFQuery* badgeQuery = [PFQuery queryWithClassName:@"Badges"];
				[badgeQuery whereKey:@"badgeName" equalTo:badgeNamesArray[i]];
				[badgeQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
					if (!error) {
						if (objects.count>0){
							PFObject* badge = [objects objectAtIndex:0];
							PFFile *imageFile = [badge objectForKey:@"thumbnail"];
							[imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
								if (!error) {
									badgeImageView.image = [UIImage imageWithData:imageData];
								} else {
								}
							}];
						}}
						else{
							NSLog(@"could not load badge icon");
						}
					}];
			}

			UIView* spacer = [[UIView alloc] initWithFrame:CGRectMake(0,button.frame.origin.y+button.frame.size.height, filterScroll.frame.size.width, 1)];
			[spacer setBackgroundColor:[UIColor lightGrayColor]];
			[filterScroll addSubview:spacer];
			[filterScroll sizeToFit];
		}

		[filterScroll setContentSize:CGSizeMake(filterScroll.frame.size.width, buttonHeight*buttonArray.count)];
	}

	if (filterScroll.center.x<mapContainer.frame.size.width) {
		[self closeFilters];
	}
	else{
		[self openFilters];
	}

}

-(void)openFilters{
	[mapContainer bringSubviewToFront:GPGameMapController.view];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:.15];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	slideView.center = CGPointMake(self.view.center.x-filterScroll.frame.size.width, slideView.center.y);
	filterScroll.center = CGPointMake(self.view.frame.size.width-(filterScroll.frame.size.width/2), filterScroll.center.y);
	[UIView commitAnimations];

}

-(void)closeFilters{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:.15];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	slideView.center = CGPointMake(self.view.center.x, slideView.center.y);
	filterScroll.center = CGPointMake(self.view.frame.size.width+(filterScroll.frame.size.width/2), filterScroll.center.y);
	[UIView commitAnimations];
}

-(void)filterButtonPressed:(UIButton*)sender{

	[self closeFilters];

	[self highlight:sender];

	self.GPsearchBar.text = [sender currentTitle];

	if (fromStart == true) {
		[self searchWithFilter:[sender currentTitle]];
	}
	else{
		[self.GPsearchBar setText:[sender currentTitle]];
		[self searchBarSearchButtonClicked:self.GPsearchBar];
	}


	NSDictionary *findParams = [NSDictionary dictionaryWithObjectsAndKeys: [sender currentTitle], @"Filter_Title",nil];
	[Flurry logEvent:kFlurryMapFilter withParameters:findParams];

}

-(void)highlight:(id)sender{
	for (UIButton* button in buttonArray) {
		[button setBackgroundColor:[UIColor clearColor]];
		[button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	}

	[sender setBackgroundColor:kGPOrange];
	[sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void)searchWithFilter:(NSString*)filter{

	if ([filter isEqualToString:@"Favorites"]) {

		NSMutableArray* mapItems = [[NSMutableArray alloc] init];
		NSArray* favoritesArray = [[PFUser currentUser] objectForKey:@"favorites"];
		for (PFObject* object in favoritesArray) {
			[object fetchIfNeeded];
			PFGeoPoint* geoPoint = [object objectForKey:@"coords"];
			MKPlacemark* placemark = [GPAnnotationView placeMarkFromObject:object withLat:geoPoint.latitude andLon:geoPoint.longitude];
			MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
			[mapItems addObject:mapItem];
		}

		self.places = mapItems;

		[self.tblContentList reloadData];

		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[self searchBarSearchButtonClicked:self.GPsearchBar];
	}
	else{
		if (self.localSearch.searching)
		{
			[self.localSearch cancel];
		}
		// confine the map search area to the user's current location
		MKCoordinateRegion newRegion;
		newRegion.center = GPGameMapController.mapView.centerCoordinate;

		// setup the area spanned by the map region:
		// we use the delta values to indicate the desired zoom level of the map,
		//      (smaller delta values corresponding to a higher zoom level)
		//
		MKMapRect mRect = GPGameMapController.mapView.visibleMapRect;

		newRegion = MKCoordinateRegionForMapRect(mRect);

		MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];

		request.naturalLanguageQuery = filter;
		request.region = newRegion;


		MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error)
		{
			if (error != nil)
			{
			}
			else
			{

				self.places = [response mapItems];
				self.boundingRegion = response.boundingRegion;

				[self.tblContentList reloadData];
			}
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			[self searchBarSearchButtonClicked:self.GPsearchBar];
		};

		if (self.localSearch != nil)
		{
			self.localSearch = nil;
		}
		self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];

		[self.localSearch startWithCompletionHandler:completionHandler];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

@end

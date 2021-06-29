//
//  GPMarketFilterViewController.m
//  goPlay
//
//  Created by Spenser Flugum on 1/28/15.
//
//

#import "GPMarketFilterViewController.h"
#import "GPUtility.h"

@interface GPMarketFilterViewController ()

@end

@implementation GPMarketFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[mapContainer layer] setMasksToBounds:NO];
    [[mapContainer layer] setShadowColor:[UIColor blackColor].CGColor];
    [[mapContainer layer] setShadowOpacity:.1f];
    [[mapContainer layer] setShadowRadius:1.0f];
    [[mapContainer layer] setShadowOffset:CGSizeMake(3, 3)];

    [[buttonMarket layer] setBorderWidth:.5f];
    [[buttonMarket layer] setBorderColor:[UIColor grayColor].CGColor];

    [[buttonProducts layer] setBorderWidth:.5f];
    [[buttonProducts layer] setBorderColor:[UIColor grayColor].CGColor];

    [[buttonServices layer] setBorderWidth:.5f];
    [[buttonServices layer] setBorderColor:[UIColor grayColor].CGColor];


    buttonArray = [NSArray arrayWithObjects:buttonFeatured,buttonMarket,buttonNearby,buttonProducts,buttonServices, nil];
    arrowArray = [NSArray arrayWithObjects:arrow01,arrow02,arrow03,arrow04,arrow05, nil];

    gameMapController = [[GPGameMapViewController alloc] init];
    filterMap.hidden = true;
    gameMapController->fromMarket = YES;
    [self addChildViewController:gameMapController];
    [mapContainer addSubview:gameMapController.view];
    gameMapController.view.frame = CGRectMake(0, 0, mapContainer.frame.size.width, mapContainer.frame.size.height);

    gameMapController.mapView.alpha = 0.0f;

    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    av.center = mapContainer.center;
    av.tag  = 1;
    [self.view addSubview:av];
    [av startAnimating];

    [self setExtendedLayoutIncludesOpaqueBars:YES];

}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    CLGeocoder* gc = [[CLGeocoder alloc] init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:gameMapController.mapView.userLocation.coordinate.latitude longitude:gameMapController.mapView.userLocation.coordinate.longitude];

    [gc reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
    CLPlacemark *placemark = [placemarks objectAtIndex:0];
    if (placemark.locality != NULL) {
        userLocationLabel.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
        //NSLog(@"placemark %@",placemark.subAdministrativeArea);
        //remove indicator and show map
        UIActivityIndicatorView *tmpimg = (UIActivityIndicatorView *)[self.view viewWithTag:1];
        [tmpimg removeFromSuperview];

        [UIView animateWithDuration:1.0f animations:^{
            gameMapController.mapView.alpha = 1.0f;
        } completion:nil];
    }

    else{
        [gameMapController viewDidLoad];
        [self viewDidAppear:NO];
        [gameMapController viewDidAppear:NO];
        NSLog(@"location null");
    }
}];

self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar_filters.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)filterDown:(id)sender {
    if ([sender tintColor] != [UIColor whiteColor]) {
        gameMapController.mapView.alpha = .25f;
        av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        av.center = mapContainer.center;
        av.tag  = 1;
        [self.view addSubview:av];
        [av startAnimating];
    }
}

- (IBAction)marketSelect:(id)sender {
    if ([sender tintColor] == [UIColor whiteColor]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self highlight:sender];
        [arrow01 setImage:[UIImage imageNamed:@"rightButton_white.png"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"filterNone" object:nil];
    }
}

- (IBAction)featureSelect:(id)sender {
    if ([sender tintColor] == [UIColor whiteColor]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self highlight:sender];
        [arrow02 setImage:[UIImage imageNamed:@"rightButton_white.png"]];
        [iconStar setImage:[UIImage imageNamed:@"filterIcon_starWhite.png"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"filterFeature" object:nil];
    }
}

- (IBAction)productsSelect:(id)sender {
    if ([sender tintColor] == [UIColor whiteColor]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self highlight:sender];
        [arrow03 setImage:[UIImage imageNamed:@"rightButton_white.png"]];
        [iconTag setImage:[UIImage imageNamed:@"filterIcon_tagWhite.png"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"filterProduct" object:nil];
    }
}

- (IBAction)nearbySelect:(id)sender {
    if ([sender tintColor] == [UIColor whiteColor]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self highlight:sender];
        [arrow04 setImage:[UIImage imageNamed:@"rightButton_white.png"]];
        [iconPin setImage:[UIImage imageNamed:@"filterIcon_pinWhite.png"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"filterNearby" object:nil];
    }
}

- (IBAction)servicesSelect:(id)sender {
    if ([sender tintColor] == [UIColor whiteColor]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self highlight:sender];
        [arrow05 setImage:[UIImage imageNamed:@"rightButton_white.png"]];
        [iconGears setImage:[UIImage imageNamed:@"filterIcon_gearsWhite.png"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"filterService" object:nil];
    }
}

-(void)highlight:(id)sender{
    for (UIButton* button in buttonArray) {
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTintColor:[UIColor grayColor]];
    }

    for (UIImageView* view in arrowArray) {
        [view setImage:[UIImage imageNamed:@"rightButton_orange.png"]];
    }


    [iconStar setImage:[UIImage imageNamed:@"filterIcon_starGrey.png"]];
    [iconTag setImage:[UIImage imageNamed:@"filterIcon_tagGrey.png"]];
    [iconPin setImage:[UIImage imageNamed:@"filterIcon_pinGrey.png"]];
    [iconGears setImage:[UIImage imageNamed:@"filterIcon_gearsGrey.png"]];

    [sender setBackgroundColor:kGPOrange];
    [sender setTintColor:[UIColor whiteColor]];

    [av removeFromSuperview];
    [UIView animateWithDuration:1.0f animations:^{
        gameMapController.mapView.alpha = 1.0f;
    } completion:nil];
}

@end

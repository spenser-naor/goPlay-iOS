//
//  GPBadgePopUpView.m
//  goPlay
//
//  Created by Spenser Flugum on 4/6/15.
//
//

#import "GPBadgePopUpView.h"
#import "Branch.h"

@implementation GPBadgePopUpView

-(id) initWithBadge:(PFObject *)badge andUser:(PFUser *)user{
	self = [super init];
	if (self) {

		self.user = user;
		self.badge = badge;
		self.view.backgroundColor = [UIColor whiteColor];
		[self.badge fetchIfNeeded];

		//NSLog(@"badge init");

		self.scrollView.delegate = self;

		bigFrame = CGRectMake(0, 0, 148, 168);
		smallFrame = CGRectMake(0, 0, 74, 84);

		if (user == [PFUser currentUser]) {
			//Heroku Cloud Code Test
			[GPCloud updateBadgesForUser:user];
		}

		[user fetch];


		//Analytics
		NSString* userType;
		if (self.user == [PFUser currentUser]) {userType = @"User_Self";}
		else{userType = @"User_Other";}
		NSDictionary *badgeParams = [NSDictionary dictionaryWithObjectsAndKeys: userType, @"User_Type", [self.badge objectForKey:@"badgeName"], @"Category",nil];
		[Flurry logEvent:kFlurryBadgePushed withParameters:badgeParams];

	}
	return self;
}

-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];

	UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
	[titleLabel setText:[self.badge objectForKey:@"badgeName"]];
	[titleLabel setFont:[UIFont fontWithName:@"Bimini-Extended" size:24.0f]];
	[titleLabel setTextColor:kGPOrange];

	self.navigationItem.titleView = titleLabel;

	self.badgeImageArray = [[NSMutableArray alloc] init];
	int levels = [[self.badge objectForKey:@"levels"] intValue];
	self.scrollView.contentSize = CGSizeMake(levels*(self.scrollView.frame.size.width), self.scrollView.frame.size.height);
	pageControl.numberOfPages = levels;
	pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
	pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
	//find the level which the badge is set to
	badgeName = [self.badge objectForKey:@"badgeName"];
	NSMutableDictionary* badgeDict = [NSMutableDictionary dictionaryWithDictionary:[self.user objectForKey:@"badges"]];
	int badgePercent = [[badgeDict objectForKey:badgeName] intValue];
	remPercent = fmod(badgePercent, 100);
	level=((badgePercent-remPercent)/100);
	NSLog(@"Level: %i", level);
	int levelIndex;
	int displayLevel;
	if (level>0) {
		levelIndex = level-1;
		displayLevel = level;
	}
	else{
		levelIndex = level;
		displayLevel = level+1;
	}


	//set up remaining
	if (![[self.badge objectForKey:@"category"] isEqualToString:@"Award"]){ //Awards have no displayed  requirements
		if (self.user == [PFUser currentUser]) {
			remainingView.hidden = NO;
		}
		[self.user fetch];
		NSString* badgeKey = [self.badge objectForKey:@"badgeName"];
		if ([badgeKey isEqualToString:@"Leadership"]) {
			PFQuery* leadQuery = [PFQuery queryWithClassName:kGPGameClassKey];
			[leadQuery whereKey:kGPGameLeaderKey equalTo:self.user];
			[leadQuery whereKeyExists:kGPPhotoKey];

			[leadQuery findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error){
				if (!error) {
					int completed = (int)objects.count;
					remainingView.selectable = YES; //this seems to fix an error where .font gets reset after setText
					[remainingView setText:[NSString stringWithFormat:@"%i",completed]];
					remainingView.selectable = NO; //this seems to fix an error where .font gets reset after setText

					//achievements
					achieveView.text = [NSString stringWithFormat:@"• Completed %i",completed];

				}
			}];

		}
		else{

			NSArray* idArray = [NSArray arrayWithObject:self.user.objectId];

			PFQuery* playQuery = [PFQuery queryWithClassName:kGPGameClassKey];
			[playQuery whereKey:@"players" containsAllObjectsInArray:idArray];
			[playQuery whereKey:kGPActivityNameKey equalTo:badgeKey];
			[playQuery whereKeyExists:kGPPhotoKey];

			[playQuery findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError* error){
				if (!error) {
					NSLog(@"objects:%i", (int)objects.count);
					int completed = (int)objects.count + [[[self.user objectForKey:@"startBadgesIG"] objectForKey:badgeKey] intValue] + [[[self.user objectForKey:@"startBadgesFB"] objectForKey:badgeKey] intValue];

					remainingView.selectable = YES; //this seems to fix an error where .font gets reset after setText
					[remainingView setText:[NSString stringWithFormat:@"%i",completed]];
					remainingView.selectable = NO; //this seems to fix an error where .font gets reset after setText



					PFQuery* leadQuery = [PFQuery queryWithClassName:kGPGameClassKey];
					[leadQuery whereKey:kGPGameLeaderKey equalTo:self.user];
					[leadQuery whereKey:kGPActivityNameKey equalTo:badgeKey];

					[leadQuery findObjectsInBackgroundWithBlock:^(NSArray* objects2, NSError* error2){
						if (!error2) {
							int lead = (int)objects2.count;
					//achievements
							achieveView.text = [NSString stringWithFormat:@"• Completed %i \n• Lead %i",completed, lead];
						}
					}];

				}
			}];
		}

	}

	//setup description
	NSString* descriptionString = [NSString stringWithFormat:@"description_0%i",displayLevel];
	descriptionView.selectable = YES; //this seems to fix an error where .font gets reset after setText
	[descriptionView setText:[self.badge objectForKey:descriptionString]];
	descriptionView.selectable = NO; //this seems to fix an error where .font gets reset after setText
	NSString* beenText;
	NSString* becauseText;

	if (badgePercent>=100) {
		becauseText = @"because you";
		beenText = @"You've been ";
	}
	else{
		becauseText = @"when you've";
		beenText = @"You will be ";
	}

	if ([self.badge objectForKey:@"requirements"]) {
		NSArray* descriptionArray = [[self.badge objectForKey:descriptionString] componentsSeparatedByString:@"*"];
		NSArray* reqCount = [[[self.badge objectForKey:@"requirements"] allObjects][0] componentsSeparatedByString:@","];
		descriptionView.text = [NSString stringWithFormat:@"%@%@%@%@%@%@",beenText,descriptionArray[0],becauseText, descriptionArray[1], reqCount[levelIndex], descriptionArray[2]];
	}
	else{
		[completedView setHidden:YES];
		descriptionView.text = [NSString stringWithFormat:@"%@",[self.badge objectForKey:descriptionString]]
		;
		[descriptionView setCenter:CGPointMake(descriptionView.center.x, descriptionView.center.y+30)];
		[levelView setCenter:CGPointMake(levelView.center.x, levelView.center.y+10)];
	}

	NSString* levelString = [NSString stringWithFormat:@"Level %i %@",displayLevel, badgeName];
	levelView.text = levelString;


	UITextView *tv = descriptionView;
	CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
	topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
	tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};

	//laying out badges
	for (int i = 0; i < levels; i++) {
		CGRect frame;
		frame.origin.x = 0;
		frame.origin.y = 0;
		frame.size = CGSizeMake(74, 84);
		if (i==0) {
			frame.size = CGSizeMake(148, 168);
		}

		UIImageView* subview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
		[subview setFrame:frame];
		subview.center = CGPointMake((self.scrollView.contentSize.width/levels)*i+(self.scrollView.frame.size.width/2), (self.scrollView.frame.size.height/2));
		subview.tag = i;
		int num = i+1;
		NSString* keyString = [NSString stringWithFormat:@"icon_0%i",num];
		PFFile *imageFile = [self.badge objectForKey:keyString];

		[imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
			if (!error) {
				subview.image = [UIImage imageWithData:imageData];
			} else {
				// There was an error
			}
		}];

		[self.badgeImageArray addObject:subview];
		[self.scrollView addSubview:subview];
		//NSLog(@"array:%@",self.badgeImageArray);

		//layout title
		UILabel *badgeTitle = [[UILabel alloc] init];
		[badgeTitle setFrame:CGRectMake(frame.origin.x, 0, frame.size.width, 20)];
		badgeTitle.text = [NSString stringWithFormat:@"Level %i",i+1];
		badgeTitle.textColor = [UIColor darkGrayColor];
		badgeTitle.tag = i;
		badgeTitle.textAlignment = NSTextAlignmentCenter;
		badgeTitle.center = CGPointMake((self.scrollView.contentSize.width/levels)*i+(self.scrollView.frame.size.width/2), 40);
		[self.scrollView addSubview:badgeTitle];

		//layout loadingview
		UILabel *badgeLoading = [[UILabel alloc] init];
		[badgeLoading setFrame:CGRectMake(frame.origin.x, 0, frame.size.width, 20)];
		badgeLoading.text = [NSString stringWithFormat:@"%i%%",remPercent];
		UIImageView* loadingFrame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badgeLoadingFrame.png"]];
		loadingFrame.frame = CGRectMake(0, 0, loadingFrame.frame.size.width/2, loadingFrame.frame.size.height/2);
		badgeLoading.tag = i+10;
		badgeLoading.textColor = [UIColor grayColor];
		badgeLoading.textAlignment = NSTextAlignmentCenter;
		badgeLoading.center = CGPointMake((self.scrollView.contentSize.width/levels)*i+(self.scrollView.frame.size.width/2), (self.scrollView.frame.size.height-40));
		loadingFrame.center = badgeLoading.center;
		if (i<level){
			badgeLoading.text = [NSString stringWithFormat:@"Complete"];
			CGPoint point = badgeLoading.center;
			[badgeLoading sizeToFit];
			badgeLoading.center = point;
		}
		else if(i==level){
			badgeLoading.center = CGPointMake(badgeLoading.center.x+(loadingFrame.frame.size.width/2)+20, badgeLoading.center.y);

			//loading bar
			UIImageView* dotFirst = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badgeLoadingDot.png"]];
			UIImageView* dotSecond = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badgeLoadingDot.png"]];
			dotFirst.frame = CGRectMake(loadingFrame.frame.origin.x, loadingFrame.frame.origin.y, dotFirst.frame.size.width/2, dotFirst.frame.size.height/2);
			float finalPos = loadingFrame.frame.size.width-dotFirst.frame.size.width;
			float currentPos = finalPos*(((float)remPercent)/100);
			//NSLog(@"%f %i %f",finalPos,remPercent,currentPos);
			dotSecond.frame = CGRectMake(loadingFrame.frame.origin.x+ currentPos, loadingFrame.frame.origin.y, dotSecond.frame.size.width/2, dotSecond.frame.size.height/2);
			UIImageView* fillView = [[UIImageView alloc] initWithFrame:CGRectMake(dotFirst.center.x, dotFirst.frame.origin.y, dotSecond.center.x-dotFirst.center.x, dotFirst.frame.size.height*.7f)];
			fillView.backgroundColor = kGPOrange;
			fillView.center = CGPointMake(fillView.center.x, loadingFrame.center.y);
			[self.scrollView addSubview:fillView];
			[self.scrollView addSubview:dotFirst];
			[self.scrollView addSubview:dotSecond];
			[self.scrollView addSubview:loadingFrame];
			subview.alpha = 0.35f;
		}
		else if(i>level){
			badgeLoading.text = [NSString stringWithFormat:@"0%%"];
			subview.alpha = 0.35f;
		}
		[self.scrollView addSubview:badgeLoading];
	}

	//move to correct level
	[self.scrollView setContentOffset:CGPointMake((self.scrollView.frame.size.width*(levelIndex))+1.0f, 0.0f) animated:YES];
	[pageControl setCurrentPage:levelIndex];



	// ----- share button

	if (self.user==[PFUser currentUser]) {
		//can only share badge if you are the owner
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showShareSheet)];

		[self.navigationItem.rightBarButtonItem setTintColor:[UIColor grayColor]];
	}
}


-(void) viewDidLoad{
	[super viewDidLoad];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

	for (UIImageView* view in self.badgeImageArray) {

		float leftDiff = scrollView.contentOffset.x-(view.tag*scrollView.frame.size.width);
		float leftScale = 148-leftDiff;
		float rightDiff = ((view.tag)*scrollView.frame.size.width)-scrollView.contentOffset.x;
		float rightScale = 148-rightDiff;
		//NSLog(@"%f %f",rightDiff,rightScale);

		if (leftScale<148) {
			if (leftScale>74) {
				view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y,leftScale,leftScale*(smallFrame.size.height/smallFrame.size.width));
			}
			view.center = CGPointMake((scrollView.frame.size.width*view.tag)+(scrollView.frame.size.width/2)+(81*leftDiff/128),scrollView.frame.size.height/2);
		}
		if (rightScale<148) {
			if (rightScale>74) {
				view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y,rightScale,rightScale*(smallFrame.size.height/smallFrame.size.width));
			}
			view.center = CGPointMake((scrollView.frame.size.width*view.tag)+(scrollView.frame.size.width/2)-(81*rightDiff/128),scrollView.frame.size.height/2);
		}
		if (rightScale<74 || leftScale<74){
			CGPoint center = view.center;
			[UIView animateWithDuration:0.5f animations:^{
				view.frame = smallFrame;
				view.center = center;
			}];
		}

	}

}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	[UIView animateWithDuration:0.25f animations:^{
		descriptionView.alpha = 0.0f;
	}];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	int page = (scrollView.contentOffset.x/(scrollView.frame.size.width)) +.5f;
	//NSLog(@"%i",page);
	[pageControl setCurrentPage:page];

	NSString* descriptionString = [NSString stringWithFormat:@"description_0%i",page+1];
	NSArray* descriptionArray = [[self.badge objectForKey:descriptionString] componentsSeparatedByString:@"*"];

	NSString* beenText;
	NSString* becauseText;

	if (level>=page+1) {
		beenText = @"You've been ";
		becauseText = @"because you";
	}

	else {
		beenText = @"You will be ";
		becauseText = @"when you've";
	}

	levelView.text = [NSString stringWithFormat:@"Level %i %@",page+1, badgeName];

	if ([self.badge objectForKey:@"requirements"]) {
		NSArray* reqCount = [[[self.badge objectForKey:@"requirements"] allObjects][0] componentsSeparatedByString:@","];
		descriptionView.text = [NSString stringWithFormat:@"%@%@%@%@%@%@",beenText,descriptionArray[0],becauseText,descriptionArray[1], reqCount[page], descriptionArray[2]];
	}
	else{
		descriptionView.text = [NSString stringWithFormat:@"%@",[self.badge objectForKey:descriptionString]]
		;
	}


	[descriptionView setNeedsDisplay];

	[UIView animateWithDuration:0.25f animations:^{
		descriptionView.alpha = 1.0f;
	}];
}

-(void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:NO];
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)showShareSheet {

	NSString* titleString;
	PFFile *photoFile;

	if (level>0) {
		titleString = [NSString stringWithFormat:@"I'm level %i in %@.\nWhat level are you?",level, badgeName];
		NSString* keyString = [NSString stringWithFormat:@"icon_0%i",level];
		photoFile = [self.badge objectForKey:keyString];
	}

	else {
		titleString = [NSString stringWithFormat:@"I'm working on my %@ badge,\nHelp me out!",badgeName];
		NSString* keyString = [NSString stringWithFormat:@"icon_01"];
		photoFile = [self.badge objectForKey:keyString];

	}

	NSLog(@"showShare");

	NSString* linkId = [NSString stringWithFormat:@"badge/%@/%@", self.badge.objectId, self.user.objectId];

	BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:linkId];
	branchUniversalObject.title = titleString;
	branchUniversalObject.contentDescription = @"goPlay";
	branchUniversalObject.imageUrl = photoFile.url;

	BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];

	[linkProperties addControlParam:@"$og_image_height" withValue:@"650"];
	[linkProperties addControlParam:@"$og_image_width" withValue:@"650"];


	BranchShareLink *branchLink = [[BranchShareLink alloc] initWithUniversalObject:branchUniversalObject linkProperties:linkProperties];

	[branchLink presentActivityViewControllerFromViewController:self anchor:nil];

	NSDictionary *shareParams = [[NSDictionary alloc] initWithObjectsAndKeys:badgeName, @"Badge_Name", [NSString stringWithFormat:@"%i", level],@"Level", nil];
	[Flurry logEvent:kFlurryBadgeShared withParameters:shareParams];

}

@end

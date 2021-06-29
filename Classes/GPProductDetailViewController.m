//
//  GPProductDetailViewController.m
//  goPlay
//
//  Created by Spenser Flugum on 2/3/15.
//
//

#import "GPProductDetailViewController.h"

@interface GPProductDetailViewController ()
@property (nonatomic, strong) PFObject *item;
@end


@implementation GPProductDetailViewController

@synthesize item;


-(id) initWithItem:(PFObject *)Item{
    if (self = [super init]) {
        self.item = Item;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"Helvetica" size:16];
        label.textAlignment = NSTextAlignmentCenter;
        // ^-Use UITextAlignmentCenter for older SDKs.
        label.textColor = kGPOrange;
        self.navigationItem.titleView = label;
        label.text = [NSString stringWithFormat:@"%@",[self.item objectForKey:@"seller"]];
        [label sizeToFit];

        self.navigationItem.leftBarButtonItem = nil;

        commentsViewController = [[GPProductCommentsViewController alloc] initWithPhoto:self.item andGame:nil];

    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    //Image
    PFFile *imageFile = [self.item objectForKey:@"image"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            itemImage.image = [UIImage imageWithData:imageData];
            [itemImage.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            [itemImage.layer setBorderWidth:.5f];
        } else {
            // There was an error saving the gameScore.
        }
    }];

    //Description

    NSString* descriptionText = [[[self.item objectForKey:@"detailDescription"] stringByReplacingOccurrencesOfString:@"(R)" withString:@"®"] stringByReplacingOccurrencesOfString:@"(TM)" withString:@"™"];

    NSString *moreString = @"More Info...";
    NSString *message = [NSString stringWithFormat:@"%@ %@", descriptionText, moreString];
    NSString *localizedString = NSLocalizedString(message, nil);

    NSRange miRange = [localizedString rangeOfString:NSLocalizedString(moreString, nil) options:NSCaseInsensitiveSearch];

    NSMutableAttributedString *finalMessage = [[NSMutableAttributedString alloc] initWithString:localizedString];
    [finalMessage beginEditing];
    [finalMessage addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor],@"tappable":@(YES)} range:miRange];
    [finalMessage endEditing];

    descriptionView.attributedText = finalMessage;

    [descriptionView sizeToFit];

    //Make attributed text clickable
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreInfoTapped:)];
    [descriptionView addGestureRecognizer:tapGesture];

    //Title
    titleLabel.text = [self.item objectForKey:@"detailTitle"];

    //Price
    NSString* price = [NSString stringWithFormat:@"%.02f",[[self.item objectForKey:@"price"] floatValue]];
    NSString* priceOrig = [NSString stringWithFormat:@"%.02f",[[self.item objectForKey:@"priceOrig"] floatValue]];

    NSMutableArray* priceArray = [[NSMutableArray alloc] initWithArray:[price componentsSeparatedByString:@"."]];
    NSMutableArray* priceOrigArray = [[NSMutableArray alloc] initWithArray:[priceOrig componentsSeparatedByString:@"."]];


    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"$%@",priceOrigArray[0]]];
    [attString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0,[attString length])];

    priceLabel.text = [NSString stringWithFormat:@"$%@",priceArray[0]];
    priceCentsLabel.text = [NSString stringWithFormat:@".%@",priceArray[1]];

    priceOrigLabel.attributedText = attString;
    priceOrigCentsLabel.text = [NSString stringWithFormat:@".%@",priceOrigArray[1]];

    //Location
    locationLabel.text = [self.item objectForKey:@"location"];

    //Remaining
    savingsLabel.text = [NSString stringWithFormat:@"%li%%",lroundf([[self.item objectForKey:@"savePercent"] floatValue])];

    //Purchased
    purchasedLabel.text = [[self.item objectForKey:@"quantitySold"] stringValue];

    //Available
    remainingLabel.text = [[self.item objectForKey:@"quantityAvailable"] stringValue];

    //buyButton
    [buyButton.layer setCornerRadius:7];

    //query for badge image
    PFQuery* badgeQuery = [PFQuery queryWithClassName:@"Badges"];
    [badgeQuery whereKey:@"badgeName" equalTo:self.item[@"category"]];
    [badgeQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error){
        if (!error) {
            if (objects) {
                //NSLog(@"badge: %@", objects);
                PFFile *imageFile = [objects[0] objectForKey:@"icon_01"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        CGPoint center = badgeIcon.center;
                        badgeIcon.image = [UIImage imageWithData:imageData];
                        UIImage* badgeImage = [UIImage imageWithData:imageData];
                        double ratio = badgeImage.size.width/badgeImage.size.height;
                        //recent frame so the ratio matches the images
                        [badgeIcon setFrame:CGRectMake(0, 0, badgeIcon.frame.size.height*ratio, badgeIcon.frame.size.height)];
                        [badgeIcon setCenter:center];

                    }
                }];
            }
        }
    }];

    //set badge name
    [badgeLabel setText:self.item[@"category"]];
    [badgeLabel sizeToFit];
    [badgeLabel setCenter:CGPointMake(badgeContainerView.frame.size.width/2, badgeLabel.center.y)];

    //set brand name
    [brandNameLabel setText:self.item[@"seller"]];

    // Do any additional setup after loading the view from its nib.

    if (barHeight<=0) {
        barHeight = self.tabBarController.view.frame.size.height;
    }

    [descriptionContainerView setFrame:CGRectMake(descriptionContainerView.frame.origin.x, descriptionContainerView.frame.origin.y, descriptionContainerView.frame.size.width, descriptionView.frame.origin.y+descriptionView.frame.size.height+10)];

    //Comments
    //reposition view before creating and adding comments init
    [commentsContainerView setFrame:CGRectMake(commentsContainerView.frame.origin.x, descriptionContainerView.frame.origin.y+descriptionContainerView.frame.size.height+5, commentsContainerView.frame.size.width, commentsTableContainerView.frame.size.height+32)];

    CGFloat height = commentsViewController.tableView.contentSize.height * commentsViewController.scaleValue;

    commentsViewController.view.frame = CGRectMake([commentsTableContainerView.superview convertPoint:commentsTableContainerView.frame.origin toView:scrollView].x, [commentsTableContainerView.superview convertPoint:commentsTableContainerView.frame.origin toView:scrollView].y+5, commentsTableContainerView.frame.size.width, height);

    [self addChildViewController:commentsViewController];


    [commentsTableContainerView setFrame:CGRectMake(commentsTableContainerView.frame.origin.x, commentsTableContainerView.frame.origin.y, commentsTableContainerView.frame.size.width, commentsViewController.view.frame.size.height)];

    [commentsContainerView setFrame:CGRectMake(commentsContainerView.frame.origin.x, descriptionContainerView.frame.origin.y+descriptionContainerView.frame.size.height+5, commentsContainerView.frame.size.width, commentsTableContainerView.frame.origin.y+commentsTableContainerView.frame.size.height+5)];

    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, commentsContainerView.frame.origin.y+commentsContainerView.frame.size.height+(scrollView.frame.size.height-buyContainerView.frame.origin.y))];
    // scrollview won't scroll unless content size explicitly set
    [scrollView addSubview:contentView];//if the contentView is not already inside your scrollview in your xib/StoryBoard doc
    scrollView.contentSize = contentView.frame.size;
    [scrollView addSubview:commentsViewController.view];
}

- (IBAction)buyDown:(id)sender {
    NSLog(@"down");
    //This seems to be delayed if the button occupes the same space as the tabbar
    [buyButton setBackgroundColor:[UIColor grayColor]];
}

- (IBAction)buyButton:(id)sender {
    [sender setBackgroundColor:kGPOrange];

    //purchasing update
    GPConfirmPurchaseViewController *confirmController = [[GPConfirmPurchaseViewController alloc] initWithItem:self.item];
    [self.navigationController pushViewController:confirmController animated:YES];

}

- (void)moreInfoTapped:(UITapGestureRecognizer *)recognizer
{
    UITextView *textView = (UITextView *)recognizer.view;

    // Location of the tap in text-container coordinates

    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [recognizer locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;

    //NSLog(@"location: %@", NSStringFromCGPoint(location));

    // Find the character that's been tapped on

    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
      inTextContainer:textView.textContainer
      fractionOfDistanceBetweenInsertionPoints:NULL];

    if (characterIndex < textView.textStorage.length) {

        NSRange range;
        NSDictionary *attributes = [textView.textStorage attributesAtIndex:characterIndex effectiveRange:&range];
        //NSLog(@"%@, %@", attributes, NSStringFromRange(range));

        if ([attributes[@"tappable"] intValue]==1) {
            NSURL *url = [NSURL URLWithString:[self.item objectForKey:@"buyURL"]];
            [[UIApplication sharedApplication] openURL:url];

            NSDictionary *itemParams = [NSDictionary dictionaryWithObjectsAndKeys: [self.item objectForKey:@"category"], @"Category", [self.item objectForKey:@"description"], @"Product", [self.item objectForKey:@"seller"], @"Seller", [self.item objectForKey:@"price"], @"Price", [self.item objectForKey:@"priceOrig"], @"Original Price", [self.item objectForKey:@"savePercent"], @"Savings_Percentage", nil];
            [Flurry logEvent:kFlurryItemInfoPushed withParameters:itemParams];
        }

    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideTabBar:self.tabBarController];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self showTabBar:self.tabBarController];
}

- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];

    UIView* view = tabbarcontroller.view;

    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, barHeight+50)];

    [UIView commitAnimations];
}

- (void)showTabBar:(UITabBarController *) tabbarcontroller
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];

    UIView* view = tabbarcontroller.view;

    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, barHeight)];

    //[view setAlpha:1.0f];

    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  GPBadgePopUpView.h
//  goPlay
//
//  Created by Spenser Flugum on 4/6/15.
//
//

#import <UIKit/UIKit.h>
#import "GPPopupViewCell.h"
#import "GPCloud.h"
#import "Flurry.h"

@interface GPBadgePopUpView : UIViewController <UIScrollViewDelegate>{
	CGRect bigFrame;
	CGRect smallFrame;
	IBOutlet UIPageControl *pageControl;
	IBOutlet UITextView *descriptionView;
	IBOutlet UITextView *remainingView;
	IBOutlet UILabel *levelView;
	IBOutlet UITextView *achieveView;
	int remPercent;
	int level;
	NSString* badgeName;
	IBOutlet UIView *completedView;
}

@property (nonatomic, strong) PFObject* badge;
@property (nonatomic, strong) PFUser* user;
@property (nonatomic, strong) NSMutableArray* badgeImageArray;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

-(id) initWithBadge:(PFObject*)badge andUser:(PFUser*)user;

@end

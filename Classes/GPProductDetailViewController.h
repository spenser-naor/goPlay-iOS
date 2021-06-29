//
//  GPProductDetailViewController.h
//  goPlay
//
//  Created by Spenser Flugum on 2/3/15.
//
//

#import <UIKit/UIKit.h>
#import "GPConfirmPurchaseViewController.h"
#import "Flurry.h"
#import "GPProductCommentsViewController.h"

@interface GPProductDetailViewController : UIViewController<UIGestureRecognizerDelegate>{

	IBOutlet UIImageView *itemImage;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *priceLabel;
	IBOutlet UILabel *priceCentsLabel;
	IBOutlet UILabel *priceOrigLabel;
	IBOutlet UILabel *priceOrigCentsLabel;
	IBOutlet UILabel *locationLabel;

	IBOutlet UILabel *savingsLabel;
	IBOutlet UILabel *purchasedLabel;
	IBOutlet UILabel *remainingLabel;

	IBOutlet UITextView *descriptionView;
	IBOutlet UIButton *buyButton;
	IBOutlet UIScrollView *scrollView;

	IBOutlet UIView *productContainerView;
	IBOutlet UIView *menuContainerView;
	IBOutlet UIView *descriptionContainerView;
	IBOutlet UIView *commentsContainerView;
	IBOutlet UIView *commentsTableContainerView;
	IBOutlet UILabel *brandNameLabel;


	IBOutlet UIView *buyContainerView;
	IBOutlet UIView *discountContainerView;
	IBOutlet UIView *badgeContainerView;
	IBOutlet UIImageView *badgeIcon;
	IBOutlet UILabel *badgeLabel;

	float barHeight;

	GPProductCommentsViewController* commentsViewController;

}

- (IBAction)buyDown:(id)sender;
- (IBAction)buyButton:(id)sender;

- (id)initWithItem:(PFObject *)Item;

@end

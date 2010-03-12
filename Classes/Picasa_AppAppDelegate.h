//
//  Picasa_AppAppDelegate.h
//  Picasa App
//
//  Created by John Wang on 6/15/09.
//  Copyright Fresh Blocks 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *kItemTitleKey;		// dictionary key for obtaining the item's title to display in each cell
extern NSString *kChildrenKey;		// dictionary key for obtaining the item's children
extern NSString *kCellIdentifier;	// the table view's cell identifier

@class SwitchViewController;//, KeychainItemWrapper;

@interface Picasa_AppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet SwitchViewController *switchViewController;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	//KeychainItemWrapper *passwordItem;
	NSMutableArray *saveLocation;
	NSDictionary *outlineData;
	NSNumber *selectedAlbum;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SwitchViewController *switchViewController;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
//@property (nonatomic, retain) KeychainItemWrapper *passwordItem;
@property (nonatomic, retain) NSDictionary *outlineData;
@property (nonatomic, retain) NSMutableArray *saveLocation;
@property (nonatomic, retain) NSNumber *selectedAlbum;

- (void) startAnimation;
- (void) stopAnimation;
@end


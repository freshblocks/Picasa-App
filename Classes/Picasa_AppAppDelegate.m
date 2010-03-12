//
//  Picasa_AppAppDelegate.m
//  Picasa App
//
//  Created by John Wang on 6/15/09.
//  Copyright Fresh Blocks 2009. All rights reserved.
//

#import "Picasa_AppAppDelegate.h"
#import "SwitchViewController.h"
#import "Three20/Three20.h"
//#import "KeychainItemWrapper.h"
#import "GData.h"

NSString *kItemTitleKey		= @"itemTitle";		// dictionary key for obtaining the item's title to display in each cell
NSString *kChildrenKey		= @"itemChildren";	// dictionary key for obtaining the item's children
NSString *kCellIdentifier	= @"MyIdentifier";	// the table view's cell identifier

NSString *kRestoreLocationKey = @"RestoreLocation";	// preference key to obtain our restore location

@implementation Picasa_AppAppDelegate

@synthesize window;
@synthesize switchViewController;//,passwordItem;
@synthesize activityIndicator, outlineData, saveLocation;
@synthesize selectedAlbum;

- (id)init
{
	self = [super init];
	if (self)
	{
		// load the drill-down list content from the plist filem
		// this plist contains the outline mapping each level of the list hierarchy
		//
		[GDataHTTPFetcher setIsLoggingEnabled:YES];
		NSString *path = [[NSBundle mainBundle] bundlePath];
		NSString *finalPath = [path stringByAppendingPathComponent:@"outline.plist"];
		outlineData = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
		selectedAlbum = [NSNumber numberWithInteger:-1];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	//[self startAnimation];
    // Override point for customization after application launch
	TTNavigator* navigator = [TTNavigator navigator];
	navigator.persistenceMode = TTNavigatorPersistenceModeAll;
	[[TTURLRequestQueue mainQueue] setMaxContentLength:300000];
    //KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
	//self.passwordItem = wrapper;
	// username = (id)kSecAttrAccount
	//NSLog(@"%@", [wrapper objectForKey:(id)kSecValueData]);
    //detailViewController.passwordItem = wrapper;
    //[wrapper release];
	// load the stored preference of the user's last location from a previous launch
	NSMutableArray *tempMutableCopy = [[[NSUserDefaults standardUserDefaults] objectForKey:kRestoreLocationKey] mutableCopy];
	self.saveLocation = tempMutableCopy;
	[tempMutableCopy release];
	if (saveLocation == nil)
	{
		// user has not launched this app nor navigated to a particular level yet, start at level 1, with no selection
		/*saveLocation = [[NSMutableArray arrayWithObjects:
						  [NSNumber numberWithInteger:-1],	// item selection at 1st level (-1 = no selection)
						  [NSNumber numberWithInteger:-1],	// .. 2nd level
						  [NSNumber numberWithInteger:-1],	// .. 3rd level
						  nil] retain];
		 */
		NSLog(@"user has not yet launched app or chosen to save login info");
	}
	else
	{
		/*NSInteger selection = [[savedLocation objectAtIndex:0] integerValue];	// read the saved selection at level 1
		if (selection != -1)
		{
			// user was last at level 2 or deeper
			//
			// note: this starts a chain reaction down each level (2nd, 3rd, etc.)
			// so that each level restores itself and pushes further down until there's no further stored selections.
			//
			[(Level1ViewController*)navigationController.topViewController restoreLevel:topLevel1Content withSelectionArray:savedLocation];
		}
		else
		{
			// no saved selection, so user was at level 1 the last time
		}*/
	}
	
	
	[window addSubview:switchViewController.view];
    [window makeKeyAndVisible];

	// register our preference selection data to be archived
	//NSDictionary *savedLocationDict = [NSDictionary dictionaryWithObject:saveLocation forKey:kRestoreLocationKey];
	//[[NSUserDefaults standardUserDefaults] registerDefaults:savedLocationDict];
	//[[NSUserDefaults standardUserDefaults] synchronize];
}

/* show the user that loading activity has started */
- (void) startAnimation
{
	//	Picasa_AppAppDelegate *delegate = (Picasa_AppAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.activityIndicator startAnimating];
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
}


/* show the user that loading activity has stopped */
- (void) stopAnimation
{
    [self.activityIndicator stopAnimating];
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	NSLog(@"user is quitting at: %d", [switchViewController.rootController selectedIndex] );
	// save the drill-down hierarchy of selections to preferences
	//[[NSUserDefaults standardUserDefaults] setObject:savedLocation forKey:kRestoreLocationKey];
}


- (void)dealloc {
	//[passwordItem release];
    [window release];
	[selectedAlbum release];
	[outlineData release];
	[saveLocation release];
	[activityIndicator release];
	[switchViewController release];
    [super dealloc];
}


@end

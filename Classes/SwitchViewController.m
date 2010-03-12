//
//  SwitchViewController.m
//  Picasa App
//
//  Created by John Wang on 6/15/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import "SwitchViewController.h"
#import "AlbumViewController.h"
#import "LogonViewController.h"
#import "Picasa_AppAppDelegate.h"

@implementation SwitchViewController
@synthesize logonViewController, albumViewController;
@synthesize rootController;

-(IBAction)switchViews:(id)sender {

	[logonViewController.view removeFromSuperview];

	Picasa_AppAppDelegate *delegate = (Picasa_AppAppDelegate *)[[UIApplication sharedApplication] delegate];
	[delegate.window addSubview:rootController.view];

}

// show an alert error Message
- (void)alertError {
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Error"
						  message:@"Error logging in."
						  delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	
	[alert show];
	[alert release];
}

// get an album service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGooglePhotos *)googlePhotosService {
	
	static GDataServiceGooglePhotos* service = nil;
	
	if (!service) {
		service = [[GDataServiceGooglePhotos alloc] init];
		
		[service setUserAgent:@"FreshBlocks-PicasaApp-1.0"]; // set this to yourName-appName-appVersion
		[service setShouldCacheDatedData:YES];
		[service setServiceShouldFollowNextLinks:YES];
	}
	
	
	// update the username/password each time the service is requested
	NSString *userID = @"jwang392@gmail.com"; //[username text];
	NSString *pass = @"freestyle"; //[password text];
	if ([userID length] && [pass length]) {
		[service setUserCredentialsWithUsername:userID
									   password:pass];
	} else {
		[service setUserCredentialsWithUsername:nil
									   password:nil];
	}
	
	return service;
}

// begin retrieving the list of the user's albums
- (void)fetchAllAlbums {
	
	//[self setAlbumFeed:nil];
	//[self setAlbumFetchError:nil];
	//[self setAlbumFetchTicket:nil];
	
	//[self setPhotoFeed:nil];
	//[self setPhotoFetchError:nil];
	//	[self setPhotoFetchTicket:nil];
	
	NSString *userID = @"jwang392@gmail.com"; //[username text];
	
	GDataServiceGooglePhotos *service = [self googlePhotosService];
	GDataServiceTicket *ticket;
	
	NSURL *feedURL = [GDataServiceGooglePhotos photoFeedURLForUserID:userID
															 albumID:nil
														   albumName:nil
															 photoID:nil
																kind:nil
															  access:nil];
	ticket = [service fetchFeedWithURL:feedURL
									delegate:self
									didFinishSelector:@selector(albumListFetchTicket:finishedWithFeed:error:)];
	//[self setAlbumFetchTicket:ticket];
	
	//[self updateUI];
}

//
// album list fetch callbacks
//

// finished album list successfully
- (void)albumListFetchTicket:(GDataServiceTicket *)ticket
            finishedWithFeed:(GDataFeedPhotoUser *)feed error:(NSError *)error{
	
	if (error == nil){
		
	}
	else {
		[self alertError];
	}
	//[self setAlbumFeed:feed];
	//[self setAlbumFetchError:nil];    
	//[self setAlbumFetchTicket:nil];
	
	// load the Change Album pop-up button with the
	// album entries
	//[self updateChangeAlbumList];
	//testInfo.text = @"success";
	//[self updateUI];
} 


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	LogonViewController *logonController =[[LogonViewController alloc] initWithNibName:@"LogonView" bundle:nil];
	self.logonViewController = logonController;
	
	[self.view insertSubview:logonViewController.view atIndex:0];	
	[logonController release];
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[albumViewController release];
	[logonViewController release];
	[rootController release];
    [super dealloc];
}


@end

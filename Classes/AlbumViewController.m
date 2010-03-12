//
//  AlbumViewController.m
//  Picasa App
//
//  Created by John Wang on 6/15/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//
#import "AlbumViewController.h"
#import "GDataFeedPhotoAlbum.h"
#import "Picasa_AppAppDelegate.h"
#import "PhotoTest2Controller.h"
#import "SwitchViewController.h"
#import "MockPhotoSource.h"
#import "AddAlbumViewController.h"

@implementation AlbumViewController
@synthesize listData;
@synthesize label;
@synthesize tableViewController;
@synthesize mUserAlbumFeed;
@synthesize pictures, albumFeed;
@synthesize photosViewController;
@synthesize hideAccessoryView;

// function to resize the thumbnails
- (UIImage *)scale:(UIImage *)inImage toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [inImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.listData count];
}

- (void)createAlbum:(id)sender
{
	NSLog(@"create an Album");
	
	AddAlbumViewController *createAlbumView = [[AddAlbumViewController alloc] initWithNibName:@"AddAlbumView" bundle:nil];
	
	createAlbumView.mUserAlbumFeed = mUserAlbumFeed;
	createAlbumView.googlePhotosService = [self googlePhotosService];
	createAlbumView.selectedPhotoAlbum = nil;  // set to NULL for creating new album
	
	[[self navigationController] pushViewController:createAlbumView animated:YES];
	[createAlbumView release];
}



// listing the picasa albums in the table
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:SimpleTableIdentifier] autorelease];
	}
	
	NSUInteger row = [indexPath row];
	GDataTextConstruct *titleTextConstruct = [(GDataFeedPhotoAlbum *)[listData objectAtIndex:row] title];
	//GDataTextConstruct *dateTextConstruct = [(GDataFeedPhotoAlbum *)[listData objectAtIndex:row] ];
	NSArray *thumbnails = [[(GDataFeedPhotoAlbum *)[listData objectAtIndex:row] mediaGroup] mediaThumbnails];
	NSString *imageURLString = [[thumbnails objectAtIndex:0] URLString];
	UIImage *thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
	// need to resize the thumbnail
	CGSize itemSize = CGSizeMake(32.0,32.0);
	NSString *title = [titleTextConstruct stringValue];
	cell.textLabel.text = title;
	NSDate *gDate = [(GDataPhotoTimestamp *)[(GDataFeedPhotoAlbum *)[listData objectAtIndex:row] timestamp ]dateValue];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MMM dd, yyyy"];

	cell.detailTextLabel.text = [dateFormat stringFromDate:gDate];
	cell.imageView.image = [self scale:thumbnail toSize:itemSize];
	if (!self.hideAccessoryView)
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	[dateFormat release];
	[thumbnail release];
	return cell;//[cell autorelease];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// create a view controller with the title as its navigation title and push it
	NSUInteger row = indexPath.row;
	//NSLog(@"selected row: %d", row);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (row != NSNotFound) {
		//add code from page 42
		NSArray *albums = [mUserAlbumFeed entries];
		//if ([albums count] > 0 && row > -1) {  // this isn't working for some reason
		GDataEntryPhotoAlbum *albumEntry = [albums objectAtIndex:row];
		//NSLog(@"set albumEntry");
		//}
		[self fetchSelectedAlbum:albumEntry];
		photosViewController = [[PhotoTest2Controller alloc] init];
		photosViewController.albumEntry = albumEntry;
		photosViewController.albums = albums;
		photosViewController.selectedAlbumID = [NSNumber numberWithInteger:indexPath.row];
		//photosViewController.albumFeed = (GDataFeedPhotoAlbum *)[listData objectAtIndex:row];
		photosViewController.googlePhotosService = [self googlePhotosService];
	}

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSLog(@"disclosure button for %d",row);
	if (row != NSNotFound) {
		NSArray *albums = [mUserAlbumFeed entries];
		GDataEntryPhotoAlbum *albumEntry = [albums objectAtIndex:row];
		
		AddAlbumViewController *editAlbum = [[AddAlbumViewController alloc] initWithNibName:@"AddAlbumView" bundle:nil];
		editAlbum.selectedPhotoAlbum = albumEntry;
		editAlbum.mUserAlbumFeed = mUserAlbumFeed;
		editAlbum.googlePhotosService = [self googlePhotosService];
		editAlbum.row = [NSNumber numberWithInteger:row];
		[[self navigationController] pushViewController:editAlbum animated:YES];
		[editAlbum release];
	}
}

// setting up for deleting an album
- (void) deleteAlbum:(id)sender {
	[tableViewController.tableView setEditing:!tableViewController.tableView.editing animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSLog(@"deleting row: %d", row);
	NSArray *albums = [mUserAlbumFeed entries];
	GDataEntryPhotoAlbum *albumEntry = [albums objectAtIndex:row];
	GDataServiceGooglePhotos *service = [self googlePhotosService];
	GDataServiceTicket *ticket;
	ticket = [service deleteEntry:albumEntry delegate:self didFinishSelector:@selector(deleteTicket:nilObject:error:)];
	// need to move these down somehow - TODO
	[listData removeObjectAtIndex:row];  // removing from array
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)deleteTicket:(GDataServiceTicket *)ticket nilObject:(GDataFeedPhoto *)object error:(NSError *)error{
	if (error == nil) {
		NSLog(@"delete success");
		[self fetchAllAlbums];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UIAlertView" message:@"Error deleting the album."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
		
	}
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
}
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		if (self) {
			self.title = @"Albums";
			self.hideAccessoryView = NO;
			//self.navigationItem.title = "@albums";
		}
    }
    return self;
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
}

//
// album list fetch callbacks
//

// finished album list successfully
- (void)albumListFetchTicket:(GDataServiceTicket *)ticket
            finishedWithFeed:(GDataFeedPhotoUser *)feed
                       error:(NSError *)error {
	
		self.mUserAlbumFeed = feed;
		Picasa_AppAppDelegate *delegate = (Picasa_AppAppDelegate *)[[UIApplication sharedApplication] delegate];

	//[delegate startAnimation];
	
	if (error == nil) {
		NSMutableArray *marray = [[NSMutableArray alloc] init];
		for (int i = 0 ; i < [[feed entries] count] ; i++) {
			GDataEntryPhotoAlbum *firstAlbum = [[feed entries] objectAtIndex:i];
			[marray addObject:firstAlbum];
		}
		self.listData = marray;
		[marray release];
		[tableViewController.tableView reloadData];
	}
	else {
		[self alertError];
	}
	
	[delegate stopAnimation];
} 


// for the album selected in the top list, begin retrieving the list of
// photos
- (void)fetchSelectedAlbum:(GDataEntryPhotoAlbum *) albumEntry {
	//NSLog(@"starting");
	GDataEntryPhotoAlbum *album = albumEntry;
	if (album) {
		//NSLog(@"album");
		// fetch the photos feed
		NSURL *feedURL = [[album feedLink] URL];
		//NSLog(@"feed url: %@",feedURL);
		if (feedURL) {
			GDataServiceGooglePhotos *service = [self googlePhotosService];
			GDataServiceTicket *ticket;
			ticket = [service fetchFeedWithURL:feedURL
											delegate:self
											didFinishSelector:@selector(photosTicket:finishedWithFeed:error:)];
		}
	}
}
//
// entries list fetch callbacks
//

// fetched photo list successfully
- (void)photosTicket:(GDataServiceTicket *)ticket
    finishedWithFeed:(GDataFeedPhotoAlbum *)feed error:(NSError *)error{
	
	//albumFeed = feed;
	NSArray *photos = [feed entries];
	
	//[self setPhotoFeed:feed];
	//[self setPhotoFetchError:nil];
	//[self setPhotoFetchTicket:nil];
	//NSLog(@"count: %d", [photos count]);
	//NSString *imageURLString = [[thumbnails objectAtIndex:0] URLString];
	pictures = [[NSMutableArray alloc] init];
	for (int i = 0 ; i < [photos count]; i ++ ) {
		GDataEntryPhoto *photo = [photos objectAtIndex:i];
		NSArray *thumbnails = [[photo mediaGroup] mediaThumbnails];
		NSArray *images = [[photo mediaGroup] mediaContents];
		//NSLog(@"%d %d",[images objectAtIndex:1], [images objectAtIndex:2]);
		[pictures addObject:[[[MockPhoto alloc]
							  initWithURL:[[images objectAtIndex:0] URLString]
							  smallURL:[[thumbnails objectAtIndex:0] URLString]
							  size:CGSizeMake([[photo width] floatValue], [[photo height] floatValue])] autorelease]];
	}
	//NSLog(@"done");
	//[self updateUI];
	photosViewController.pictures = pictures;
	photosViewController.albumFeed = feed;
	//NSLog(@"%d", [photosViewController.pictures count]);
	//photosViewController.navigationController.toolbarHidden = NO;
	[pictures release];
	// only push after finished - TODO
	[[self navigationController] pushViewController:self.photosViewController animated:YES];
	[photosViewController release];
} 



/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

//- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
//	label.text = item.title;
	
//}
- (void)viewDidAppear:(BOOL)animated {
	//[tableViewController.tableView reloadData];
	[self fetchAllAlbums];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								   target:self action:@selector(deleteAlbum:)];
	self.navigationItem.leftBarButtonItem = deleteItem;	
	
    UIBarButtonItem *systemItem = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								   target:self action:@selector(createAlbum:)];
	self.navigationItem.rightBarButtonItem = systemItem;
	
	[deleteItem release];
	[systemItem release];
	
	UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
	//Picasa_AppAppDelegate *delegate = (Picasa_AppAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[delegate startAnimation];

	[self fetchAllAlbums];
	
	
	//[super viewDidLoad];
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
	[photosViewController release];
	[pictures release];
	[albumFeed release];
	[mUserAlbumFeed release];
	[listData release];
	[tableViewController release];
	[label release];
    [super dealloc];
}


@end

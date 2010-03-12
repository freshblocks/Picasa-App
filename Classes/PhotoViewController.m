//
//  PhotoViewController.m
//  Picasa App
//
//  Created by John Wang on 7/8/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import "PhotoViewController.h"
#import "GDataEntryPhotoAlbum.h"
#import "GData.h"
#import "GDataFeedPhotoAlbum.h"
#import "MockPhotoSource.h"
#import "PhotoInfoViewController.h"
#import "MessageAddressbookTestController.h"
#import "AlbumViewController.h"
#import "AlbumsNavController.h"

@implementation PhotoViewController
@synthesize googlePhotosService;
@synthesize photo;
@synthesize pictures;
@synthesize albumEntry;
@synthesize albumFeed;
@synthesize currentAlbum, albums;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)updateChrome {
	[super updateChrome];
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(info) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *iButton = [[UIBarButtonItem alloc] initWithCustomView: infoButton];
	
	//UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(info)];
	self.navigationItem.rightBarButtonItem = iButton;
	
}
- (id)init {
	[super init];
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
/*	NSLog(@"%@", albumFeed);
	NSLog(@"%@",albumEntry);
	NSArray *photos = [albumFeed entries];
	NSLog(@"count %d", [photos count]);
*/	
	//NSLog(@"index of photo: %d",_centerPhotoIndex);
	//_photoSource.numberOfPhotos
	UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
	
	
	UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete)];
	
	_toolbar.items = [NSArray arrayWithObjects:
					  share,space,_previousButton,space, _nextButton, space,trash, nil]; // add toolbar items here


}

- (void)share {
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:@"Photo Options"
								  delegate:self
								  cancelButtonTitle:@"Cancel"
								  destructiveButtonTitle:nil
								  otherButtonTitles:@"Share Photo",@"Move Photo",nil]; //,@"Add Tag",@"Add Comment",nil]; Next Version?
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)delete {
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:@"Are you sure?"
								  delegate:self
								  cancelButtonTitle:@"No"
								  destructiveButtonTitle:@"Yes, I'm sure."
								  otherButtonTitles:nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}



- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
	
	NSLog(@"index: %d", buttonIndex);
	
	if ( buttonIndex == [actionSheet cancelButtonIndex] ) {
	}

	// delete photo
	else if (buttonIndex == [actionSheet destructiveButtonIndex] ) {
		//NSLog(@"here? %d", _centerPhotoIndex);
		GDataServiceTicket * ticket;
		NSArray *photos = [albumFeed entries];
		//NSLog(@"count: %d index: %d", [photos count], _centerPhotoIndex);
		photo = [photos objectAtIndex:_centerPhotoIndex];
		if ([photo canEdit]) {
			GDataServiceGooglePhotos *service = [self googlePhotosService];
			//NSLog(@"deleting %@",service);
			ticket = [service deleteEntry:photo
						delegate:self
			   didFinishSelector:@selector(deleteTicket:nilObject:error:)];
		}
	}
	// Share
	else if (buttonIndex == 0) { // also matches delete
		MessageAddressbookTestController *shareView = [[MessageAddressbookTestController alloc] init];
		//TTNavigator* navigator = [TTNavigator navigator];
		//navigator.persistenceMode = TTNavigatorPersistenceModeNone;
		//[navigator openURL:@"tt://compose?to" animated:YES];
		//shareView.navigationController = self.navigationController;
		NSArray *photos = [albumFeed entries];
		//NSLog(@"count: %d index: %d", [photos count], _centerPhotoIndex);
		photo = [photos objectAtIndex:_centerPhotoIndex];
		shareView.photo = photo;
		shareView.albumEntry = albumEntry;
		
		[self.navigationController pushViewController:shareView	animated:NO];
		//[shareView release];
	}
	// TODO Move
	else if (buttonIndex == 1) { // also matches cancel]
		NSLog(@"photo currently in album: %d", [currentAlbum intValue]);
		AlbumsNavController *albumsNavList = [[[AlbumsNavController alloc] initWithNibName:@"AlbumsNav" bundle:nil] autorelease];
		AlbumViewController *albumsList = [[[AlbumViewController alloc] initWithNibName:@"AlbumView" bundle:nil] autorelease];
		albumsList.tableView.delegate = self;
		albumsList.hideAccessoryView = YES; // TODO add to nav so can "CANCEL"
		//albums.listData;
		UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
									   target:self action:@selector(cancel:)];
		albumsList.navigationItem.leftBarButtonItem = deleteItem;	

		albumsList.navigationItem.rightBarButtonItem = nil;
			// TODO scrolling loses the status bar. no wants full screen
		[deleteItem release];

		[albumsNavList pushViewController:albumsList animated:NO];  // need to override and add a cancel button
		[self presentModalViewController:albumsNavList animated:YES];		
	}
}

-(void)cancel {
	NSLog(@"canceling");
	[self dismissModalViewControllerAnimated:YES];
}

// selected album to move photo to
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"testing");
	//dismissModalViewControllerAnimated
	NSUInteger row = indexPath.row;
	NSLog(@"want to move it to: %d", row);
	[self dismissModalViewControllerAnimated:YES];
	
	// what's the selected album?
	
	// is it the same as the one it's already in?
	if (row == [currentAlbum intValue]) {
		// yes - do nothing
		NSLog(@"same album");
	}
	else {	// no - move the photo
		GDataEntryPhotoAlbum *toAlbumEntry = [albums objectAtIndex:row];
		[self moveSelectedPhotoToAlbum:toAlbumEntry];
		NSLog(@"different album");
	}
}

// photo delete callback
- (void)deleteTicket:(GDataServiceTicket *)ticket nilObject:(GDataFeedPhoto *)object error:(NSError *)error {
	if (error == nil) {
		NSLog(@"photo deleted");
		// TODO subtract 1 from array
		[pictures removeObjectAtIndex:_centerPhotoIndex];
		//[_photoSource removePhotoAtIndex:_centerPhotoIndex];
		
		[self.navigationController popViewControllerAnimated:YES];
		
	} else {
		//NSLog(@"error deleting photo");

		// TODO show an alert view that there was an error
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UIAlertView" message:@"Error deleting the photo."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}
#pragma mark Move a photo to another album
static NSString* const kDestAlbumKey = @"DestAlbum";

-(void)moveSelectedPhotoToAlbum:(GDataEntryPhotoAlbum *)albumToEntry {
	GDataServiceTicket * ticket;
	NSArray *photos = [albumFeed entries];
	//NSLog(@"count: %d index: %d", [photos count], _centerPhotoIndex);
	photo = [photos objectAtIndex:_centerPhotoIndex]; 
 GDataEntryPhoto *photoToMove = [self photo];
 //if (photoToMove) {

	 NSString *destAlbumID = [albumToEntry GPhotoID];
	 NSLog(@"moving starting to %@",destAlbumID); 
 // let the photo entry retain its target album ID as a property
 // (since the contextInfo isn't retained)
	 [photoToMove setProperty:destAlbumID forKey:kDestAlbumKey];
 
 // make the user confirm that the selected photo should be moved
/* NSBeginAlertSheet(@"Move Photo", @"Move", @"Cancel", nil,
 [self window], self,
 @selector(moveSheetDidEnd:returnCode:contextInfo:),
 nil, nil,
 @"Move the item \"%@\" to the album \"%@\"?",
 [[photo title] stringValue],
 [[albumEntry title] stringValue]);
*/
 
	 // set the album to move to as the photo's new album ID
	 NSString *albumID = [photoToMove propertyForKey:kDestAlbumKey];
	 [photoToMove setAlbumID:albumID];
	NSLog(@"albumId %@",albumID);
	//self.viewState = TTViewLoading;
	 GDataServiceGooglePhotos *service = [self googlePhotosService];
	 ticket = [service fetchEntryByUpdatingEntry:photoToMove
									 forEntryURL:[[photoToMove editLink] URL]
										delegate:self
							   didFinishSelector:@selector(moveTicket:finishedWithEntry:error:)];
 
//	}
}

// photo move callback
- (void)moveTicket:(GDataServiceTicket *)ticket
 finishedWithEntry:(GDataEntryPhoto *)entry
             error:(NSError *)error {
	//self.viewState = TTViewLoaded; // TODO moving screen
	if (error == nil) {
		NSLog(@"moved photo ok");
		[pictures removeObjectAtIndex:_centerPhotoIndex]; // remove the photo from the array 
		[self.navigationController popViewControllerAnimated:YES]; // and pop to the thumbnail view

	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UIAlertView" message:@"Error moving the photo."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
		NSLog(@"move error");
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
}

- (void)info {
	PhotoInfoViewController *photoInfo = [[PhotoInfoViewController alloc] init];
	NSArray *photos = [albumFeed entries];
	photo = [photos objectAtIndex:_centerPhotoIndex];
	photoInfo.photo = photo;
	//NSLog(@"Photo Entry: %@",photo);
	photoInfo.googlePhotosService = googlePhotosService;
	[[self navigationController] pushViewController:photoInfo animated:YES];
	[photoInfo release];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
	[super viewDidUnload];
}


- (void)dealloc {
	//[albumEntry release];
	//[albumFeed release];
	//[pictures release];
	//[googlePhotosService release];
	//[photo release];
    [super dealloc];
}


@end

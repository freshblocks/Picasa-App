//
//  AddAlbumViewController.m
//  Picasa App
//
//  Created by John Wang on 7/4/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import "AddAlbumViewController.h"
#import "AlbumViewController.h"

@implementation AddAlbumViewController
@synthesize albumName, albumDescription;
@synthesize googlePhotosService;
@synthesize mUserAlbumFeed;
@synthesize selectedPhotoAlbum;
@synthesize row;

// hide the keyboard on a background click
- (IBAction)cancelClick:(id)sender {
	[albumName resignFirstResponder];
	[albumDescription resignFirstResponder];
}

- (void)createAlbum:(id)sender
{
	GDataServiceGooglePhotos* service = [self googlePhotosService];
	NSURL *postLinkV = [[mUserAlbumFeed postLink] URL];
	GDataServiceTicket *ticket;
	if (selectedPhotoAlbum == nil) {
		//NSLog(@"create an Album");

		GDataEntryPhotoAlbum* newAlbum = [GDataEntryPhotoAlbum albumEntry];
		[newAlbum setTitleWithString:[albumName text]];
		[newAlbum setPhotoDescriptionWithString:[albumDescription text]];
		[newAlbum setAccess:kGDataPhotoAccessPublic];

		ticket = [service fetchEntryByInsertingEntry:newAlbum
											forFeedURL:postLinkV
											delegate:self
											didFinishSelector:@selector(addAlbumTicket:finishedWithEntry:error:)];
		//NSLog(@"description: %@", [ticket description]); 
	}
	else {
		//NSLog(@"updating an album row %d", [row intValue]);
		NSArray *albums = [mUserAlbumFeed entries];
		GDataEntryPhotoAlbum *albumEntry = [albums objectAtIndex:[row intValue]];
		service = [self googlePhotosService];
		NSLog(@"%@",[[albumEntry editLink] URL] );
		[albumEntry setTitleWithString:[albumName text]];
		[albumEntry setPhotoDescriptionWithString:[albumDescription text]];
		
		ticket = [service fetchEntryByUpdatingEntry:albumEntry
											 forEntryURL:[[albumEntry editLink] URL] 
												delegate:self
												didFinishSelector:@selector(moveTicket:finishedWithEntry:error:)];
		//NSLog(@"%@", [ticket description]); 
		//NSLog(@"done updating");
	}
	
}

// photo add callback
- (void)addAlbumTicket:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryPhotoAlbum *)photoEntry error:(NSError *)error{
	NSLog(@"create success!");
	// TODO add the album entry to the array of albums
	
	[[self navigationController] popViewControllerAnimated:YES];
	//if (error == nil) {
	// tell the user that the add worked
	/*NSBeginAlertSheet(@"Added Photo", nil, nil, nil,
	 [self window], nil, nil,
	 nil, nil, @"Photo added: %@",
	 [[photoEntry title] stringValue]);
	 
	 // refetch the current album's photos
	 [self fetchSelectedAlbum];
	 [self updateUI];*/
	//} else {
	// upload failed
	/*NSBeginAlertSheet(@"Add failed", nil, nil, nil,
	 [self window], nil, nil,
	 nil, nil, @"Photo add failed: %@", error);
	 */
	//}
	//[tableViewController.tableView reloadData];
	//[mUploadProgressIndicator setDoubleValue:0.0];
	
}

// photo moved successfully
- (void)moveTicket:(GDataServiceTicket *)ticket
 finishedWithEntry:(GDataEntryPhotoAlbum *)entry error:(NSError *)error {
	NSLog(@"yay");
	[[self navigationController] popViewControllerAnimated:YES];
} 


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	if (selectedPhotoAlbum == nil)
		self.title = @"Create Album";
	else {
		self.title = @"Edit Album";
		GDataTextConstruct *titleTextConstruct = [selectedPhotoAlbum title];
		albumName.text = [titleTextConstruct stringValue];
		titleTextConstruct = [selectedPhotoAlbum photoDescription];
		albumDescription.text = [titleTextConstruct stringValue];
	}
    UIBarButtonItem *systemItem = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
								   target:self action:@selector(createAlbum:)];
	self.navigationItem.rightBarButtonItem = systemItem;
	
    [super viewDidLoad];
	[systemItem release];
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
- (void)viewWillDisappear:(BOOL)animated {
	//NSLog(@"bye bye");
	//AlbumViewController *parent = (AlbumViewController *) self.parentViewController;
	//[parent.tableViewController.tableView reloadData];
}
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

}


- (void)dealloc {
	[row release];
	[mUserAlbumFeed release];
	[selectedPhotoAlbum release];
	[googlePhotosService release];
	[albumName release];
	[albumDescription release];
    [super dealloc];
}


@end

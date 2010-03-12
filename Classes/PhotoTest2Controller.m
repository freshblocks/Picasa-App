#import "PhotoTest2Controller.h"
#import "MockPhotoSource.h"
#import "ImagePickerController.h"
#import "Picasa_AppAppDelegate.h"
#import "GDataServiceBase.h"
#import "GData.h";

@implementation PhotoTest2Controller
@synthesize albumFeed, albumEntry, photos;
@synthesize pictures;
@synthesize selectedAlbumID;
@synthesize googlePhotosService;
@synthesize albums;
@synthesize toolbar;

- (void)action:(id)sender
{
    //NSLog(@"UIBarButtonItem clicked");
	//NSLog(@"selectedAlbum: %d", [selectedAlbumID intValue]);
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:nil
								  delegate:self
								  cancelButtonTitle:@"Cancel"
								  destructiveButtonTitle:nil
								  otherButtonTitles:@"Take New Photo",@"Use Saved Photo",nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
	
	//NSLog(@"index: %d", buttonIndex);
	//ImagePickerController *uploadImagePicker = [[ImagePickerController alloc] initWithNibName:@"ImagePickerView" bundle:nil];
	//uploadImagePicker.hidesBottomBarWhenPushed = YES;
	// Yes, save the login data
	if (buttonIndex == 1) {
		//NSLog(@"index = 1");
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
			picker.delegate = self;
			picker.allowsImageEditing = YES;
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentModalViewController:picker animated:YES];
			[picker release];
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing photo library" message:@"Device does not support a photo library" delegate:nil cancelButtonTitle:@"Drat!" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	else if (buttonIndex == 0 ) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		picker.allowsImageEditing = YES;
		[self presentModalViewController:picker animated:YES];
		[picker release];
	}
	//if (!buttonIndex == [actionSheet cancelButtonIndex])
	//{
	//}
	//else if (buttonIndex == [actionSheet destructiveButtonIndex] ) {
	
	//[[self navigationController] pushViewController:uploadImagePicker animated:YES];
	
	//}
	else {
		//[rememberMe setOn:NO];
	}
	//[uploadImagePicker release];
}

// changed for new 3.0 OS with Video
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// NSString *const UIImagePickerControllerOriginalImage;
	// NSString *const UIImagePickerControllerEditedImage;
	//imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
	//NSLog(@"selected a picture to upload");
	// if user wants to also save the image locally to the iPhone's Caemera Roll
	//	UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum: didFinishSavingWithError: contextInfo:), context);
	CGFloat compression = 1.0;
	NSData *photoData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerEditedImage], compression);
	//[NSData dataWithContentsOfFile:[info objectForKey:UIImagePickerControllerOriginalImage]];
	if (photoData) {
		
		// make a new entry for the photo
		GDataEntryPhoto *newEntry = [GDataEntryPhoto photoEntry];
		
		// set a title, description, and timestamp
		[newEntry setTitleWithString:@"Google"];
		[newEntry setPhotoDescriptionWithString:@"desc"];
		[newEntry setTimestamp:[GDataPhotoTimestamp timestampWithDate:[NSDate date]]];
		
		// attach the NSData and set the MIME type for the photo
		[newEntry setPhotoData:photoData];
		
		NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:@"/"
												   defaultMIMEType:@"image/jpeg"];
		[newEntry setPhotoMIMEType:mimeType];
		
		// get the feed URL for the album we're inserting the photo into
		GDataEntryPhotoAlbum *album = albumEntry;
		NSURL *feedURL = [[album feedLink] URL];
		
		// make service tickets call back into our upload progress selector
		GDataServiceGooglePhotos *service = [self googlePhotosService];
		
		
		//SEL progressSel = @selector(inputStream:hasDeliveredByteCount:ofTotalByteCount:);
		//[service setServiceUploadProgressSelector:progressSel];
		
		// insert the entry into the album feed
		GDataServiceTicket *ticket;
		ticket = [service fetchEntryByInsertingEntry:newEntry
										  forFeedURL:feedURL
											delegate:self
								   didFinishSelector:@selector(addPhotoTicket:finishedWithEntry:error:)];
		
		// no need for future tickets to monitor progress
		//[service setServiceUploadProgressSelector:nil];
		
	} else {
		// nil data from photo file
		/*NSBeginAlertSheet(@"Cannot get photo file data", nil, nil, nil,
						  [self window], nil, nil,
						  nil, nil, @"Could not read photo file: %@", photoName);*/
		NSLog(@"error occured");
		// TODO add alert view
	}
	
	[picker dismissModalViewControllerAnimated:YES];
	
}
// photo add callback
- (void)addPhotoTicket:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryPhoto *)photoEntry error:(NSError *)error{
	//NSLog(@"success!");
	if (error == nil) {
		// TODO refresh the data on screen
		NSArray *thumbnails = [[photoEntry mediaGroup] mediaThumbnails];
		NSArray *images = [[photoEntry mediaGroup] mediaContents];
		[pictures addObject:[[[MockPhoto alloc]
							  initWithURL:[[images objectAtIndex:0] URLString]
							  smallURL:[[thumbnails objectAtIndex:0] URLString]
							  size:CGSizeMake([[photoEntry width] floatValue], [[photoEntry height] floatValue])] autorelease]];
		// if from camera, then also save to phone library

	} else {
		// upload failed
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UIAlertView" message:@"Error adding the photo."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
		
	}
	//NSLog(@"pictures: %d  photoSource: %d", [pictures count], [self.photoSource numberOfPhotos] );
	[self updateUI];
	[self reloadContent];
	// TODO need to get updated albumFeed and albumEntry?

	//[mUploadProgressIndicator setDoubleValue:0.0];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	[picker dismissModalViewControllerAnimated:YES];
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {  
	NSString *message;  
	NSString *title;  
	if (!error) {  
		title = NSLocalizedString(@"SaveSuccessTitle", @"");  
		message = NSLocalizedString(@"SaveSuccessMessage", @"");  
	} else {  
		title = NSLocalizedString(@"SaveFailedTitle", @"");  
		message = [error description];  
	}  
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title  
													message:message  
												   delegate:nil  
										  cancelButtonTitle:NSLocalizedString(@"ButtonOK", @"")  
										  otherButtonTitles:nil];  
	[alert show];  
	[alert release];  
}  

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
}
//- (void) uploadMedia:(UIImage *)image {
	
//}

// for the album selected in the top list, begin retrieving the list of
// photos
- (void)fetchSelectedAlbum:(GDataEntryPhotoAlbum *) PhotoAlbumEntry {
	//NSLog(@"starting");
	GDataEntryPhotoAlbum *album = PhotoAlbumEntry;
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
	//NSLog(@"feed: %@",feed);
	if (error == nil) {
		albumFeed = [feed retain];
	}		
	else {
		NSLog(@"error getting feed");
	}
}


- (void)updateUI {
	[self fetchSelectedAlbum:albumEntry];
	//NSLog(@"albumEntry: %@",albumEntry);
	//NSLog(@"albumFeed: %@",albumFeed);
	NSLog(@"html: %@", [albumEntry HTMLLink]);
	NSLog(@"alternate: %@", [albumEntry alternateLink]);
	GDataTextConstruct *titleTextConstruct = [albumFeed title];
	NSString *albumTitle = [titleTextConstruct stringValue];
	[self.photoSource release];
	//NSLog(@"%d",[photos count]);
	self.photoSource = [[MockPhotoSource alloc]
						initWithType:MockPhotoSourceNormal
						//initWithType:MockPhotoSourceDelayed
						// initWithType:MockPhotoSourceLoadError
						// initWithType:MockPhotoSourceDelayed|MockPhotoSourceLoadError
						title:albumTitle
						photos:pictures
						photos2:nil
						//  photos2:[[NSArray alloc] initWithObjects:
						//    [[[MockPhoto alloc]
						//      initWithURL:@"http://farm4.static.flickr.com/3280/2949707060_e639b539c5_o.jpg"
						//      smallURL:@"http://farm4.static.flickr.com/3280/2949707060_8139284ba5_t.jpg"
						//      size:CGSizeMake(800, 533)] autorelease],
						//    nil]
						];
	//[self fetchSelectedAlbum:albumEntry];
	
	//NSLog(@"updateUI pictures: %d  photoSource: %d", [pictures count], [self.photoSource numberOfPhotos] );
}
- (void)createToolbarItems
{	
	// match each of the toolbar item's style match the selection in the "UIBarButtonItemStyle" segmented control
	//UIBarButtonItemStyle style = [self.buttonItemStyleSegControl selectedSegmentIndex];
	
	// create the system-defined "OK or Done" button
    UIBarButtonItem *systemItem = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
								   target:self action:@selector(action:)]; //TODO fix this selector
	//systemItem.style = style;
	
	// flex item used to separate the left groups items and right grouped items
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];
	
	// create a special tab bar item with a custom image and title
	UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction // TODO switch this to info icon
																target:self
																action:@selector(action:)]; // TODO fix this selector
	
	// create a bordered style button with custom title
	/*UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithTitle:@"Item"
																   style:style	// note you can use "UIBarButtonItemStyleDone" to make it blue
																  target:self
																  action:@selector(action:)];
	*/
	NSArray *items = [NSArray arrayWithObjects: systemItem, flexItem, infoItem, nil];
	[self.toolbar setItems:items animated:NO];
	
	[systemItem release];
	[flexItem release];
	[infoItem release];
	//[customItem release];
}

- (void)viewWillAppear:(BOOL)animated {
	//NSLog(@"viewWillAppear pictures: %d  photoSource: %d", [pictures count], [self.photoSource numberOfPhotos] );
	// TODO update the photoSource if the count is different
	if ([pictures count] != [self.photoSource numberOfPhotos] ) {
		[self updateUI];
	}
	
	
	[super viewWillAppear:YES];
}

- (void)viewDidLoad {
	//NSLog(@"viewDidLoad pictures: %d  photoSource: %d", [pictures count], [self.photoSource numberOfPhotos] );
	
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
								target:self action:@selector(action:)];
	self.navigationItem.rightBarButtonItem = addItem;
	[addItem release];
	//NSLog(@"hello from pictures view");
	//NSLog(@"%d", [pictures count]);
	GDataTextConstruct *titleTextConstruct = [albumFeed title];
	NSString *albumTitle = [titleTextConstruct stringValue];

	
	// create the UIToolbar at the bottom of the view controller
	//
	toolbar = [UIToolbar new];
	toolbar.barStyle = UIBarStyleBlackTranslucent;
	
	// size up the toolbar and set its frame
	[toolbar sizeToFit];
	CGFloat toolbarHeight = [toolbar frame].size.height;
	CGRect mainViewBounds = self.view.bounds;
	[toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
								 CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight * 1.0) + 2.0,
								 CGRectGetWidth(mainViewBounds),
								 toolbarHeight)];
	
	[self.view addSubview:toolbar];
	[self createToolbarItems];
	
	
	//NSLog(@"%d",[photos count]);
	self.photoSource = [[MockPhotoSource alloc]
    initWithType:MockPhotoSourceNormal
    //initWithType:MockPhotoSourceDelayed
    // initWithType:MockPhotoSourceLoadError
    // initWithType:MockPhotoSourceDelayed|MockPhotoSourceLoadError
    title:albumTitle
    photos:pictures
  photos2:nil
//  photos2:[[NSArray alloc] initWithObjects:
//    [[[MockPhoto alloc]
//      initWithURL:@"http://farm4.static.flickr.com/3280/2949707060_e639b539c5_o.jpg"
//      smallURL:@"http://farm4.static.flickr.com/3280/2949707060_8139284ba5_t.jpg"
//      size:CGSizeMake(800, 533)] autorelease],
//    nil]
	];
}
- (void)dealloc {
	[toolbar release];
	//[albums release];
	//[service release];
	//[selectedAlbumID release];
	//[pictures release];
	//[photos release];
	//[albumFeed release];  // error,  couldn't release already released
	//[albumEntry release];
    [super dealloc];
}

- (PhotoViewController*)createPhotoViewController {
	PhotoViewController *photo = [[[PhotoViewController alloc] init] autorelease];
	photo.googlePhotosService = googlePhotosService;
	photo.pictures = pictures;
	photo.albumEntry = albumEntry;
	photo.albums = albums;
	photo.currentAlbum = selectedAlbumID;
	//[self fetchSelectedAlbum:albumEntry];
	//NSLog(@"%@",albumFeed);
	photo.albumFeed = albumFeed;
	//NSLog(@"createPhotoViewer pictures: %d  photoSource: %d photos: %d", [pictures count], [self.photoSource numberOfPhotos],[photosa count] );
	return photo;
	
}
/*
- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo {
	[super didSelectPhoto:cell:photo];
}*/
@end

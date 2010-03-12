//
//  ImagePickerController.m
//  Picasa App
//
//  Created by John Wang on 6/29/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import "ImagePickerController.h"
#import "AlbumViewController.h"
#import "Picasa_AppAppDelegate.h"


@implementation ImagePickerController
@synthesize imageView;
@synthesize takePictureButton;
@synthesize selectFromCameraRollButton;

#pragma mark -

- (IBAction)getCameraPicture:(id)sender {
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.sourceType = (sender == takePictureButton) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	picker.allowsImageEditing = YES;
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (IBAction)selectExistingPicture {
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
#pragma mark  -
// changed for new 3.0 OS with Video
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// NSString *const UIImagePickerControllerOriginalImage;
	// NSString *const UIImagePickerControllerEditedImage;
	imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	// if user wants to also save the image locally to the iPhone's Caemera Roll
	//	UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum: didFinishSavingWithError: contextInfo:), context);
	
	[picker dismissModalViewControllerAnimated:YES];
	
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"testing");
	//dismissModalViewControllerAnimated
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		NSUInteger noneSelected = -1;
		selectedAlbum = &noneSelected;
    }
    return self;
}*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	/*if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		takePictureButton.hidden = YES;
		selectFromCameraRollButton.hidden = YES;
	}*/
	Picasa_AppAppDelegate *appDelegate = (Picasa_AppAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSLog (@"selectedAlbum: %d", [appDelegate.selectedAlbum intValue] );
	if ([appDelegate.selectedAlbum intValue] == -1) {
		AlbumViewController *albums = [[AlbumViewController alloc] initWithNibName:@"AlbumView" bundle:nil];
		albums.tableView.delegate = self;
		albums.hideAccessoryView = YES; // hide the Editing album name and desc ability
		[self presentModalViewController:albums animated:YES];
	}
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
	[imageView release];
	[takePictureButton release];
	[selectFromCameraRollButton release];
    [super dealloc];
}


@end

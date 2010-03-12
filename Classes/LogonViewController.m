//
//  LogonViewController.m
//  Picasa App
//
//  Created by John Wang on 6/15/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import "LogonViewController.h"
#import "AlbumViewController.h"
//#import "KeychainItemWrapper.h"

@implementation LogonViewController
@synthesize albumViewController;
@synthesize username, password;
@synthesize rememberMe;
//@synthesize keychainItemWrapper;

// hide the keyboard on a background click
- (IBAction)cancelClick:(id)sender {
	[username resignFirstResponder];
	[password resignFirstResponder];
}

- (IBAction) switchChanged:(id)sender {
	if ( rememberMe.isOn ) {
		NSLog(@"remember me please");
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:@"Are you sure?"
									  delegate:self
									  cancelButtonTitle:@"No"
									  destructiveButtonTitle:@"Yes, I'm sure."
									  otherButtonTitles:nil];
		[actionSheet showInView:self.view];
		[actionSheet release];
	}
	else
		NSLog(@"don't remember me");
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
	
	NSLog(@"index: %d", buttonIndex);
	
	// Yes, save the login data
	if (!buttonIndex == [actionSheet cancelButtonIndex])
	{
		// save edits
		//[keychainItemWrapper setObject:[textControl text] forKey:editedFieldKey];
		//[self.navigationController popViewControllerAnimated:YES];
		
	}
	//else if (buttonIndex == [actionSheet destructiveButtonIndex] ) {
		
	//}
	else {
		[rememberMe setOn:NO];
	}


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
}


- (void)dealloc {
	//[keychainItemWrapper release];
	[albumViewController release];
	[username release];
	[password release];
	[rememberMe release];
    [super dealloc];
}


@end

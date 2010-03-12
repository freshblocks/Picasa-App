//
//  ShareMessageController.m
//  Picasa App
//
//  Created by John Wang on 7/24/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import "ShareMessageController.h"
#import "Picasa_AppAppDelegate.h"

@implementation ShareMessageController
@synthesize photo,albumEntry;


-(void)send {
	[super send];
}

- (void)messageDidSend {
	[super messageDidSend];
	//self.viewState = TTViewLoaded;

}

- (void)messageWillSend:(NSArray*)fields {
	//[super messageWillSend:fields];
	
	TTMessageRecipientField* toField = [fields objectAtIndex:0];
	//NSLog(@"toField desc: %@",[toField description]);
	NSString *toAddresses = @"empty";
	for (id recipient in toField.recipients) {
		TTTableTextItem *test = (TTTableTextItem*)recipient;
		//NSLog(@"messageWillSend: %@ %@", test.text, test.URL);
		if ([toAddresses compare:@"empty"] == NSOrderedSame) {
			//NSLog(@"starting addresses");
			toAddresses = test.URL;
		}
		else {
			toAddresses = [toAddresses stringByAppendingString:@","];
			toAddresses = [toAddresses stringByAppendingString:test.URL];
		}
	}
	//NSLog(@"sending to: %@",toAddresses);
	//NSLog(@"body text: %@",_textEditor.text);
	SKPSMTPMessage *test_smtp_message = [[SKPSMTPMessage alloc] init];
    test_smtp_message.fromEmail = @"jwang392@gmail.com";
    test_smtp_message.toEmail = toAddresses; //@"jwang392@gmail.com";
    test_smtp_message.relayHost = @"smtp.gmail.com";
    test_smtp_message.requiresAuth = YES;
    test_smtp_message.login = @"jwang392@gmail.com";
    test_smtp_message.pass = @"freestyle";
    test_smtp_message.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
	NSString *toSubject = @"Invitation to view ";
	if (photo) {  // if sharing an individual photo and not the full album
		toSubject = [toSubject stringByAppendingString:@"a photo from "];
	}
	NSArray *credits = [[photo mediaGroup] mediaCredits];
	toSubject = [toSubject stringByAppendingString:[[credits objectAtIndex:0] stringValue]];
	toSubject = [toSubject stringByAppendingString:@"'s Picasa Web Album - "];
	toSubject = [toSubject stringByAppendingString:[[albumEntry title] stringValue]];
	
    test_smtp_message.subject = toSubject;// @"xcode email";
	//Invitation to view Suly's Picasa Web Album - fishing

    // Only do this for self-signed certs!
    // test_smtp_message.validateSSLChain = NO;
	test_smtp_message.delegate = self;
	GDataLink *photoHTMLLink = [photo HTMLLink];
	//NSLog(@"sharing: %@",[photoHTMLLink href]);
	
	//NSLog(@"count %d",[thumbnails count]);
	//NSLog(@"%@",photo);
    NSMutableArray *parts_to_send = [NSMutableArray array];

	NSString *bodyText = @"<html><body style=\"font-family: Arial, Helvetica, sans-serif; background-color:=white\">";
	
	bodyText = [bodyText stringByAppendingString:@"<table border=0 cellpadding=0 cellspacing=0 width=\"600px\">"];
	bodyText = [bodyText stringByAppendingString:@"<tr><td bgcolor=\"#E1ECFF\" width=\"10px\"></td>"];
	bodyText = [bodyText stringByAppendingString:@"<td width=\"*\" style=\"border: 1px solid #ccc; padding: .6em .8em;\">"];
	bodyText = [bodyText stringByAppendingString:@"<div style=\"padding-bottom: .6em; font-weight: bold; font-size: 12pt; color: #333;\">"];
	
	bodyText = [bodyText stringByAppendingString:@"You are invited to view a photo from "];
	bodyText = [bodyText stringByAppendingString:[[credits objectAtIndex:0] stringValue]];
	bodyText = [bodyText stringByAppendingString:@"\'s photo album: <a href=\""];
	bodyText = [bodyText stringByAppendingString:[[albumEntry HTMLLink] href]];
	bodyText = [bodyText stringByAppendingString:@"\">"]; // removed &feat=3Demail
	
	bodyText = [bodyText stringByAppendingString:[[albumEntry title] stringValue]];
	//bodyText = [bodyText stringByAppendingString:[[photo title]stringValue]]; // TODO photo album's name
	
	bodyText = [bodyText stringByAppendingString:@"</a></div>"];

	bodyText = [bodyText stringByAppendingString:@"<div style=\"background-color: #F5F5F5; border: 1px solid #CCC; padding: 0.8em;\">"];
	bodyText = [bodyText stringByAppendingString:@"<table cellspacing=0 cellpadding=0>"];
	bodyText = [bodyText stringByAppendingString:@"<tr>"];
	bodyText = [bodyText stringByAppendingString:@"<td valign=\"top\">"];
	bodyText = [bodyText stringByAppendingString:@"<div style=\"border: 1px solid #ccc; padding: 7px; background-color: #FFF;\">"];
	bodyText = [bodyText stringByAppendingString:@"<a href=\""];
	if (photo)
		bodyText = [bodyText stringByAppendingString:[photoHTMLLink href]];
	else {
		bodyText = [bodyText stringByAppendingString:[[albumEntry HTMLLink] href]];
	}

	bodyText = [bodyText stringByAppendingString:@"\">"];
	
	NSString * imageThumb = @"<img src=\"cid:my_image\"></a>";
	bodyText = [bodyText stringByAppendingString:imageThumb];
	//bodyText = [bodyText stringByAppendingString:@" border=\"0\" style=\"border: 1px solid #7f7f7f;/\"></a>"];
	bodyText = [bodyText stringByAppendingString:@"</div></td><td valign=\"top\" style=\"padding-left: 0.7em;\">"];
	bodyText = [bodyText stringByAppendingString:@"<div style=\"margin-bottom: 0.4em;font-weight: normal; font-size: 10pt; color: #333;\">"];

	if (photo)
		bodyText = [bodyText stringByAppendingString:[[photo photoDescription] stringValue]];
	else {
		bodyText = [bodyText stringByAppendingString:[[albumEntry photoDescription] stringValue]];
	}

	bodyText = [bodyText stringByAppendingString:@"</div><a href=\""];
	if (photo) {
		bodyText = [bodyText stringByAppendingString:[photoHTMLLink href]];
		bodyText = [bodyText stringByAppendingString:@"\" style=\"font-size: 10pt; font-weight: bold;\">View Photo</a></td>"];
	}
	else {
		bodyText = [bodyText stringByAppendingString:[[albumEntry HTMLLink] href]];
		bodyText = [bodyText stringByAppendingString:@"\" style=\"font-size: 10pt; font-weight: bold;\">View Album</a></td>"];
	}		
	bodyText = [bodyText stringByAppendingString:@"</tr></table></div><div style=\"margin: 1em 1em;\">"];
	bodyText = [bodyText stringByAppendingString:@"<div style=\"font-weight: bold; font-size: 10pt; color: #00681C;\">Message from "];
	bodyText = [bodyText stringByAppendingString:[[credits objectAtIndex:0] stringValue]];
	bodyText = [bodyText stringByAppendingString:@":</div><div style=\"font-weight: normal; font-size: 9pt; color: #333; margin-top: 0.2em;\">"];	
	bodyText = [bodyText stringByAppendingString:_textEditor.text];
	
	bodyText = [bodyText stringByAppendingString:@"</div><div style=\"font-weight: normal; font-size: 8pt; color: #666;  margin-top=: 1em;\">"];
	bodyText = [bodyText stringByAppendingString:@"If you are having problems viewing this email, copy and paste the following into your browser:<br>"];
	bodyText = [bodyText stringByAppendingString:@"<a href=\""];
	if (photo) {
		bodyText = [bodyText stringByAppendingString:[photoHTMLLink href]];
		bodyText = [bodyText stringByAppendingString:@"\">"];
		bodyText = [bodyText stringByAppendingString:[photoHTMLLink href]];
	}
	else {
		bodyText = [bodyText stringByAppendingString:[[albumEntry HTMLLink] href]];
		bodyText = [bodyText stringByAppendingString:@"\">"];
		bodyText = [bodyText stringByAppendingString:[[albumEntry HTMLLink] href]];		
	}

	bodyText = [bodyText stringByAppendingString:@"</a></div>"];
	bodyText = [bodyText stringByAppendingString:@"<div style=\"font-weight: normal; font-size: 8pt; color: #666; margin-top:0.6em;\">"];
	bodyText = [bodyText stringByAppendingString:@"To share your photos or receive notification when your friends sha"];
	bodyText = [bodyText stringByAppendingString:@"re photos, <a href=\"http://picasaweb.google.com\">get your own free Picasa"];
	bodyText = [bodyText stringByAppendingString:@" Web Albums account</a>.</div>"];
	bodyText = [bodyText stringByAppendingString:@"<div style=\"text-align: right; padding: 6px;\">"];
	bodyText = [bodyText stringByAppendingString:@"<a href=\"http://picasaweb.google.com\">"];
	bodyText = [bodyText stringByAppendingString:@"<img src=\"cid:picasaweblogo-en_US.gif\" border=\"0\" />"];
	bodyText = [bodyText stringByAppendingString:@"</a></div>"];
	
	bodyText = [bodyText stringByAppendingString:@"</div></td><td bgcolor=\"#E1ECFF\" width=\"10px\"></td>"];
	
	bodyText = [bodyText stringByAppendingString:@"</tr></table></body></html>"];
	NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/html",kSKPSMTPPartContentTypeKey,							   
							   bodyText,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];

	[parts_to_send addObject:plainPart];
	
	NSArray *thumbnails = [[photo mediaGroup] mediaThumbnails];
	NSURL *thumbURL = [NSURL URLWithString:[[thumbnails objectAtIndex:1] URLString]];  // medium thumbnail for the email
	NSData *image_data = [NSData dataWithContentsOfURL:thumbURL]; 
	
	NSDictionary *imagePart = [NSDictionary dictionaryWithObjectsAndKeys:@"image/jpeg",kSKPSMTPPartContentTypeKey,@"inline",
							   kSKPSMTPPartContentDispositionKey,[image_data encodeBase64ForData],kSKPSMTPPartMessageKey,
							   @"base64",kSKPSMTPPartContentTransferEncodingKey,@"<my_image>",kSKPSMTPPartContentIdKey,nil];
	
	
	[parts_to_send addObject:imagePart];

	NSString *image_path = [[NSBundle mainBundle] pathForResource:@"picasaweblogo-en_US" ofType:@"gif"];
	NSData *picasa_data = [NSData dataWithContentsOfFile:image_path];	
	NSDictionary *picasaPart = [NSDictionary dictionaryWithObjectsAndKeys:@"image/gif",kSKPSMTPPartContentTypeKey,@"inline",
							   kSKPSMTPPartContentDispositionKey,[picasa_data encodeBase64ForData],kSKPSMTPPartMessageKey,
							   @"base64",kSKPSMTPPartContentTransferEncodingKey,@"<picasaweblogo-en_US.gif>",kSKPSMTPPartContentIdKey,nil];
	[parts_to_send addObject:picasaPart];
	
	test_smtp_message.parts = parts_to_send;
    HighestState = 0;
    
    [test_smtp_message send];
	
}

- (id)init {
	[super init];
	return self;
}

#pragma mark SKPSMTPMessage Delegate Methods
- (void)messageState:(SKPSMTPState)messageState;
{
    //NSLog(@"HighestState:%d", HighestState);
    if (messageState > HighestState)
        HighestState = messageState;
    
    //ProgressBar.progress = (float)HighestState/(float)kSKPSMTPWaitingSendSuccess; // TODO this needs to be checked on
}
- (void)messageSent:(SKPSMTPMessage *)SMTPmessage
{
    [SMTPmessage release];
	// TODO show a screen that it was sent?
	self.viewState = TTViewLoaded;
	if ([_delegate respondsToSelector:@selector(composeControllerDoneSending:)]) {// goes to MessageAddressBookTestController. need to append Google email data
		[_delegate composeControllerDoneSending:self];
	}
	
	// Pop back to image?
	//[self.navigation popNavigationItemAnimated:NO];
    //Spinner.hidden = YES;  // TODO this needs to be checked on
    //[Spinner stopAnimating];
    //ProgressBar.hidden = YES;
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Sent!"
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];    
    [alert release];
    DEBUGLOG(@"delegate - message sent");
	*/
}

- (void)messageFailed:(SKPSMTPMessage *)SMTPmessage error:(NSError *)error
{
    [SMTPmessage release];
    /*
    Spinner.hidden = YES;
    [Spinner stopAnimating];
    ProgressBar.hidden = YES;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription]
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];    
    [alert release];
    DEBUGLOG(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
	 */
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
	photo = nil;
	albumEntry = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

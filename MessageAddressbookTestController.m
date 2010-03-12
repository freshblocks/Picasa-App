
#import "MessageAddressbookTestController.h"
//#import "SearchTestController.h"
#import	"Three20/Three20.h"
#import "MergedAddressBook.h"

@implementation MessageAddressbookTestController
@synthesize mController;
@synthesize photo;
@synthesize albumEntry;

- (id)init {
	if (self = [super init]) {
		_sendTimer = nil;
		_dataSource = [MergedAddressBook TheDataSource]; // should only call once. hopefully here is ok
  }
	
  return self;
}

- (void)dealloc {
	[_sendTimer invalidate];
	[mController release];
	[_dataSource release];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//- (TTMessageController*)composeTo:(NSString*)recipient {  // this is new way
- (void)composeTo{ // this is old way
  //id recipient = [[[TTTableField alloc] initWithText:@"Alan Jones" url:TT_NULL_URL] autorelease];
	TTTableTextItem* item = [TTTableTextItem itemWithText:nil URL:nil];
	ShareMessageController* controller = [[[ShareMessageController alloc] 
    initWithRecipients:[NSArray arrayWithObject:item]] autorelease];
	controller.showsRecipientPicker = YES;
	controller.photo = photo;
	controller.albumEntry = albumEntry;
	controller.dataSource = _dataSource;// [MergedAddressBook TheDataSource];  // multiple calls to this? - move to -init
	controller.delegate = self;
	[self.navigationController pushViewController:controller animated:NO];
	//[self presentModalViewController:controller animated:YES]; // old way
	//return controller; // new way
}

- (void)cancelAddressBook {
  //[[TTNavigationCenter defaultCenter].frontViewController dismissModalViewControllerAnimated:YES];
	[[TTNavigator navigator].visibleViewController dismissModalViewControllerAnimated:YES];  // not called for some reason
}

- (void)sendDelayed:(NSTimer*)timer {
  _sendTimer = nil;
  /*
  NSArray* fields = timer.userInfo;
  UIView* lastView = [self.view.subviews lastObject];
  CGFloat y = lastView.bottom + 20;
  
  TTMessageRecipientField* toField = [fields objectAtIndex:0];
	//NSLog(@"toField desc: %@",[toField description]);
  for (id recipient in toField.recipients) {
	  TTTableTextItem *test = (TTTableTextItem*)recipient;
	  NSLog(@"trying: %@ %@", test.text, test.URL);
    UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.backgroundColor = self.view.backgroundColor;
    label.text = [NSString stringWithFormat:@"Sent to: %@", recipient];  // recipient is of type TTTableTextItem
    [label sizeToFit];
    label.frame = CGRectMake(30, y, label.width, label.height);
    y += label.height;
    [self.view addSubview:label];
  }*/
  
  //[self.modalViewController dismissModalViewControllerAnimated:YES];
}
- (void)doneSending {
	NSLog(@"done sending");
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
	//TTNavigator* navigator = [TTNavigator navigator];
	//navigator.persistenceMode = TTNavigatorPersistenceModeAll;
	//self.navigationController.navigationBarHidden=NO;
	/*
  CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	
  self.view = [[[UIView alloc] initWithFrame:appFrame] autorelease];;
  self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
  // code changes here
  UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button setTitle:@"Compose Message" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(composeTo) // openURL instead of compose
    forControlEvents:UIControlEventTouchUpInside]; // old way
	//[button addTarget:@"tt://compose?to=Alan%20Jones" action:@selector(openURL)
	// forControlEvents:UIControlEventTouchUpInside]; // new way
  button.frame = CGRectMake(20, 20, 280, 50);
  [self.view addSubview:button];*/
	[self composeTo];
	//[navigator openURL:@"tt://compose?to" animated:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTMessageControllerDelegate

- (void)composeController:(TTMessageController*)controller didSendFields:(NSArray*)fields {
  _sendTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self
    selector:@selector(sendDelayed:) userInfo:fields repeats:NO];
}

- (void)composeControllerWillCancel:(TTMessageController*)controller { //composeControllerDidCancel
  [_sendTimer invalidate];
  _sendTimer = nil;

  //[controller dismissModalViewControllerAnimated:YES];
	[self.navigationController popViewControllerAnimated:YES];
}
- (void)composeControllerDoneSending:(TTMessageController*)controller {
	NSLog(@"done sending");
}

- (void)composeControllerShowRecipientPicker:(ShareMessageController*)controller {
	ABPeoplePickerNavigationController* ABPPNavigator = [[ABPeoplePickerNavigationController alloc] init];
	ABPPNavigator.peoplePickerDelegate = self;
	ABPPNavigator.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt: kABPersonEmailProperty]];
	mController = controller;
	[controller presentModalViewController:ABPPNavigator animated:YES];
	
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// ABPeople Picker Delegate
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	return YES;
}
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	TTContact* contact = [TTContact CreateFromAddressRef:person andEmailProperty:property identifier:identifier];
	[(TTMessageController*)mController addRecipient:[contact TTTableFieldObject] forFieldAtIndex:0];
	[mController dismissModalViewControllerAnimated:YES];
	return NO;
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	[mController dismissModalViewControllerAnimated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// SearchTestControllerDelegate
/*
- (void)searchTestController:(SearchTestController*)controller didSelectObject:(id)object {
  TTMessageController* composeController = (TTMessageController*)self.modalViewController;
  [composeController addRecipient:object forFieldAtIndex:0];
  [controller dismissModalViewControllerAnimated:YES];
}*/


@end

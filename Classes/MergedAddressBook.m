//
//  MergedAddressBook.m
//  Picasa App
//
//  Created by John Wang on 7/20/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import "MergedAddressBook.h"
#import "GData.h"
#import "GDataFeedContact.h"
#import "GDataContacts.h"
#import "Picasa_AppAppDelegate.h"

@implementation MergedAddressBook
@synthesize app;

+ (TTAddressBookDataSource*) TheDataSource
{
	ABAddressBookRef addressBook = ABAddressBookCreate(); // this is getting called 3 times. why?
	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
	
	CFIndex size = CFArrayGetCount (people);	
	NSMutableArray* ContactArray = [[NSMutableArray alloc] initWithCapacity:size];
	
	NSEnumerator *enumerator = [(NSArray*)people objectEnumerator];
	id obj;
	while ( obj = [enumerator nextObject] ) {
		// create ttcontact from ref
		// check if ttcontact is in google address book array
		// if yes, remove person from google address book array ?  or maybe try to see if email address is attached to person?
		// else move along
		[ContactArray addObjectsFromArray:[TTContact CreateFromAddressRef:obj]];
	}
	MergedAddressBook *mergedDataSource = [MergedAddressBook alloc];
	//MergedAddressBook *mergedDataSource = [[MergedAddressBook alloc] initWithContacts:ContactArray];
	UIApplication *application = [UIApplication sharedApplication];
	mergedDataSource.app = application;
	mergedDataSource.app.networkActivityIndicatorVisible = YES;
	
	[mergedDataSource fetchAllGroupsAndContacts];

	mergedDataSource = [mergedDataSource initWithContacts:ContactArray];
	TTAddressBookDataSource* dataSource = mergedDataSource;
	//[self fetchAllGroupsAndContacts];
	
	return dataSource;
}

-(id) initWithContacts:(NSArray*) ContactArray
{
	//NSMutableSet *set = [NSMutableSet setWithArray:ContactArray];
	[super initWithContacts:ContactArray];
	
	//[super initWithContacts:[set allObjects]];
	/*if(self = [self init])
	{
		_names = [ContactArray retain];
	}*/
	
	//[self fetchAllGroupsAndContacts];
	
	return self;
}

- (GDataServiceGoogleContact *)contactService {
	
	static GDataServiceGoogleContact* service = nil;
	
	if (!service) {
		service = [[GDataServiceGoogleContact alloc] init];
		
		[service setUserAgent:@"FreshBlocks-PicasaContactsApp-1.0"]; // set this to yourName-appName-appVersion
		[service setShouldCacheDatedData:YES];
		[service setServiceShouldFollowNextLinks:YES];
		
		// iPhone apps will typically disable caching dated data or will call
		// clearLastModifiedDates after done fetching to avoid wasting
		// memory.
	}
	
	// update the username/password each time the service is requested
	NSString *username = @"jwang392@gmail.com";//[mUsernameField stringValue];
	NSString *password = @"freestyle";//[mPasswordField stringValue];
	
	[service setUserCredentialsWithUsername:username
								   password:password];
	
	return service;
}
#pragma mark Fetch all groups

- (NSURL *)groupFeedURL {
	
	NSString *propName = @"full";//[mPropertyNameField stringValue];
	
	NSURL *feedURL;
	if ([propName caseInsensitiveCompare:@"full"] == NSOrderedSame
		|| [propName length] == 0) {
		
		// full feed includes all clients' extended properties
		feedURL = [GDataServiceGoogleContact groupFeedURLForUserID:kGDataServiceDefaultUser];
		
	} else if ([propName caseInsensitiveCompare:@"thin"] == NSOrderedSame) {
		
		// thin feed excludes extended properties
		feedURL = [GDataServiceGoogleContact contactURLForFeedName:kGDataGoogleContactGroupsFeedName
															userID:kGDataServiceDefaultUser
														projection:kGDataGoogleContactThinProjection];
		
	} else {
		
		feedURL = [GDataServiceGoogleContact contactGroupFeedURLForPropertyName:propName];
	}
	return feedURL;
}

// begin retrieving the list of the user's contacts
- (void)fetchAllGroupsAndContacts {
	
	[self setGroupFeed:nil];
	//[self setGroupFetchError:nil];
	//[self setGroupFetchTicket:nil];
	
	// we will fetch contacts next
	//[self setContactFeed:nil];
	
	GDataServiceGoogleContact *service = [self contactService];
	GDataServiceTicket *ticket;
	
	BOOL showDeleted = NO;//([mShowDeletedCheckbox state] == NSOnState);
	
	// request a whole buncha groups; our service object is set to
	// follow next links as well in case there are more than 2000
	const int kBuncha = 2000;
	
	NSURL *feedURL = [self groupFeedURL];
	
	GDataQueryContact *query = [GDataQueryContact contactQueryWithFeedURL:feedURL];
	[query setShouldShowDeleted:showDeleted];
	[query setMaxResults:kBuncha];
	
	ticket = [service fetchFeedWithQuery:query
								delegate:self
					   didFinishSelector:@selector(groupsFetchTicket:finishedWithFeed:error:)];
	
	//[self setGroupFetchTicket:ticket];
	
	//[self updateUI];
}

// groups fetched callback
- (void)groupsFetchTicket:(GDataServiceTicket *)ticket
         finishedWithFeed:(GDataFeedContactGroup *)feed
                    error:(NSError *)error {
	
	[self setGroupFeed:feed];
	//[self setGroupFetchError:error];
	//[self setGroupFetchTicket:nil];
	
	if (error == nil) {
		// we have the groups; now get the contacts
		[self fetchAllContacts];
	} else {
		// error fetching groups
		//[self updateUI];
	}
}
#pragma mark Fetch all contacts

- (NSURL *)contactFeedURL {
	
	NSString *propName = @"full";//[mPropertyNameField stringValue];
	
	NSURL *feedURL;
	if ([propName caseInsensitiveCompare:@"full"] == NSOrderedSame
		|| [propName length] == 0) {
		
		// full feed includes all clients' extended properties
		feedURL = [GDataServiceGoogleContact contactFeedURLForUserID:kGDataServiceDefaultUser];
		
	} else if ([propName caseInsensitiveCompare:@"thin"] == NSOrderedSame) {
		
		// thin feed excludes all extended properties
		feedURL = [GDataServiceGoogleContact contactFeedURLForUserID:kGDataServiceDefaultUser
														  projection:kGDataGoogleContactThinProjection];
	} else {
		
		feedURL = [GDataServiceGoogleContact contactFeedURLForPropertyName:propName];
	}
	return feedURL;
}

// begin retrieving the list of the user's contacts
- (void)fetchAllContacts {
	
	//[self setContactFeed:nil];
	//[self setContactFetchError:nil];
	//[self setContactFetchTicket:nil];
	
	GDataServiceGoogleContact *service = [self contactService];
	GDataServiceTicket *ticket;
	
	BOOL shouldShowDeleted = NO;//([mShowDeletedCheckbox state] == NSOnState);
	BOOL shouldQueryMyContacts = YES;// ([mMyContactsCheckbox state] == NSOnState);
	
	// request a whole buncha contacts; our service object is set to
	// follow next links as well in case there are more than 2000
	const int kBuncha = 2000;
	
	NSURL *feedURL = [self contactFeedURL];
	
	GDataQueryContact *query = [GDataQueryContact contactQueryWithFeedURL:feedURL];
	[query setShouldShowDeleted:shouldShowDeleted];
	[query setMaxResults:kBuncha];
	
	if (shouldQueryMyContacts) {
		
		GDataFeedContactGroup *groupFeed = [self groupFeed];
		GDataEntryContactGroup *myContactsGroup
		= [groupFeed entryForSystemGroupID:kGDataSystemGroupIDMyContacts];
		
		NSString *myContactsGroupID = [myContactsGroup identifier];
		
		[query setGroupIdentifier:myContactsGroupID];
	}
	
	ticket = [service fetchFeedWithQuery:query
								delegate:self
					   didFinishSelector:@selector(contactsFetchTicket:finishedWithFeed:error:)];
	
	//[self setContactFetchTicket:ticket];
	
	//[self updateUI];
}

// contacts fetched callback
- (void)contactsFetchTicket:(GDataServiceTicket *)ticket
           finishedWithFeed:(GDataFeedContact *)feed
                      error:(NSError *)error {
	//NSLog(@"num of entries in contacts: %@", [feed entries]);
	NSArray *contactEntries = [feed entries];
	
	for (int i = 0 ; i < [contactEntries count] ; i++) {
		GDataEntryContact *gContact = [contactEntries objectAtIndex:i];
		NSLog(@"%@", [[[gContact name] fullName] stringValue]);
		NSArray *gContactEmailAddys = [gContact emailAddresses];
		for (int j = 0; j < [gContactEmailAddys count] ; j++ ) {
			GDataEmail *addy = [gContactEmailAddys objectAtIndex:j];
			NSString *relFull = [addy rel];
			//NSLog(@"%@",)
			NSString *relHash = [relFull substringFromIndex:[relFull rangeOfString:@"#"].location+1 ];
			NSLog(@"email: %@ %@ %@", [addy label], [addy address] ,relHash );
		}
	}
	//UIApplication *application = [UIApplication sharedApplication];
    //app.networkActivityIndicatorVisible = NO;
	//[self setContactFeed:feed];
	//[self setContactFetchError:error];
	//[self setContactFetchTicket:nil];
	
	//[self updateUI];
}
#pragma mark setters and getters
- (GDataFeedContactGroup *)groupFeed {
	return mGroupFeed; 
}

- (void)setGroupFeed:(GDataFeedContactGroup *)feed {
	[mGroupFeed autorelease];
	mGroupFeed = [feed retain];
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

/*
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}*/

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

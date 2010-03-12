//
//  PhotoInfoViewController.m
//  Picasa App
//
//  Created by John Wang on 7/12/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import "PhotoInfoViewController.h"
#import "GData.h"


//static NSString* kLoremIpsum = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do\
eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud\
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";


@implementation PhotoInfoViewController
@synthesize photo;
@synthesize googlePhotosService;

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<TTTableViewDataSource>)createDataSource {
	// This demonstrates how to create a table with standard table "fields".  Many of these
	// fields with URLs that will be visited when the row is selected
	NSLog(@"%@",photo);
	GDataEXIFTags *EXIF = [photo EXIFTags];
	//NSArray *tags = [EXIF tags];
	//NSLog(@"count: %d", [tags count]);
	//for (int i = 0 ; i < [tags count] ; i++ )
	//	NSLog(@"%d = %@",i, [[tags objectAtIndex:i] stringValue] );
	NSArray *keys = [[EXIF tagDictionary] allKeys];
	//NSLog(@"dictionary count: %d %d", [keys count], [[EXIF tagDictionary] count]);
	NSDictionary *dictionary = [EXIF tagDictionary];
	NSMutableArray *exifArray = [[NSMutableArray alloc] init];
	NSMutableArray *detailsArray = [[NSMutableArray alloc] init];
	GDataMediaGroup *mediaGroup = [photo mediaGroup];
	GDataMediaTitle *title = [mediaGroup mediaTitle];
	GDataMediaDescription *desc = [mediaGroup mediaDescription];
	NSLog(@"%@", [title stringValue]);
	//NSNumber *size = ;
	NSNumber *sizeKB = [NSNumber numberWithInt:[[photo size] intValue]/1024];
	
	[detailsArray addObject:[TTTableCaptionedItem itemWithText:[title stringValue] caption:@"filename"]];
	[detailsArray addObject:[TTTableCaptionedItem itemWithText:[desc stringValue] caption:@"description"]];	
	[detailsArray addObject:[TTTableCaptionedItem itemWithText:[[[photo width] stringValue] stringByAppendingString:@" pixels"] caption:@"width"]];
	[detailsArray addObject:[TTTableCaptionedItem itemWithText:[[[photo height] stringValue] stringByAppendingString:@" pixels"] caption:@"height"]];
	[detailsArray addObject:[TTTableCaptionedItem itemWithText:[[sizeKB stringValue] stringByAppendingString:@" KB"] caption:@"size"]];
	[detailsArray addObject:[TTTableCaptionedItem itemWithText:[[[photo commentCount] stringValue] stringByAppendingString:@" comments"] caption:@"comments"]];
	[detailsArray addObject:[TTTableCaptionedItem itemWithText:[[photo commentsEnabled] stringValue] caption:@"comments Enabled"]]; //caption too long?
	
	for (int i = 0; i < [keys count] ; i++) {
		NSString *key = [keys objectAtIndex:i];
		NSString *value = [dictionary valueForKey:key];
		if ([key isEqualToString:@"focallength"])
			value = [value stringByAppendingString:@"mm"];
		if ([key isEqualToString:@"fstop"])
			key = @"Aperture";
		// TODO convert exposure to fraction
		
		if ([key isEqualToString:@"imageUniqueID"])  // get rid of imageUniqueID
			NSLog(@"key: %@ value: %@",key, [dictionary valueForKey:key] );
		else {
			[exifArray addObject:[TTTableCaptionedItem itemWithText:value caption:key]];
		}
	}
	[exifArray autorelease];
	[detailsArray autorelease];
	return [TTSectionedDataSource dataSourceWithArrays:
			@"Details",detailsArray,
			/*
			[TTTableTextItem itemWithText:@"TTTableTextItem" URL:@"tt://tableItemTest"],
			[TTTableTextItem itemWithText:@"TTTableTextItem (external link)" URL:@"http://foo.com"],
			[TTTableLink itemWithText:@"TTTableLink" URL:@"tt://tableItemTest"],
			[TTTableButton itemWithText:@"TTTableButton"],
			[TTTableCaptionedItem itemWithText:@"TTTableCaptionedItem" caption:@"caption"
										   URL:@"tt://tableItemTest"],
			[TTTableImageItem itemWithText:@"TTTableImageItem" URL:@"tt://tableItemTest"
									 image:@"bundle://tableIcon.png"],
			[TTTableRightImageItem itemWithText:@"TTTableRightImageItem" URL:@"tt://tableItemTest"
										  image:@"bundle://person.jpg"],
			[TTTableMoreButton itemWithText:@"TTTableMoreButton"],
			*/
			@"EXIF",exifArray
			/*[TTTableTextItem itemWithText:@"TTTableItem"],
			[TTTableCaptionedItem itemWithText:@"TTTableCaptionedItem which wraps to several lines" // This one!
									   caption:@"Text"],
			[TTTableBelowCaptionedItem itemWithText:@"TTTableBelowCaptionedItem"
											caption:kLoremIpsum],
			[TTTableLongTextItem itemWithText:kLoremIpsum],
			[TTTableGrayTextItem itemWithText:kLoremIpsum],
			[TTTableSummaryItem itemWithText:@"TTTableSummaryItem"],
			
			@"",
			[TTTableActivityItem itemWithText:@"TTTableActivityItem"],
			*/,
			nil];
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}*/

-(id) init {
	[super init];
	return [self initWithStyle:UITableViewStyleGrouped] ;
}


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

    [super dealloc];
}


@end

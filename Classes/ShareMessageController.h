//
//  ShareMessageController.h
//  Picasa App
//
//  Created by John Wang on 7/24/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import <Three20/Three20.h>
#import "GData.h"

@interface ShareMessageController : TTMessageController 
<TTMessageControllerDelegate,SKPSMTPMessageDelegate,UITextFieldDelegate, TTTextEditorDelegate>
{
	GDataEntryPhoto *photo;
	GDataEntryPhotoAlbum *albumEntry;
	//NSNumber *currentAlbum;
	UIActivityIndicatorView *Spinner; // these need to be checked
    UIProgressView *ProgressBar;  // check on these!
    SKPSMTPState HighestState;
	
}

@property (nonatomic, retain) GDataEntryPhoto *photo;
@property (nonatomic, retain) GDataEntryPhotoAlbum *albumEntry;

- (void)send;
- (void)messageDidSend;
- (void)messageWillSend:(NSArray*)fields;


@end

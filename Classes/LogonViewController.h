//
//  LogonViewController.h
//  Picasa App
//
//  Created by John Wang on 6/15/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumViewController;//, KeychainItemWrapper;

@interface LogonViewController : UIViewController <UIActionSheetDelegate> {

	AlbumViewController *albumViewController;
	IBOutlet UITextField *username;
	IBOutlet UITextField *password;
    //KeychainItemWrapper *keychainItemWrapper;
	IBOutlet UISwitch *rememberMe;

}
@property (retain, nonatomic) AlbumViewController *albumViewController;
@property (retain, nonatomic) UITextField *username;
@property (retain, nonatomic) UITextField *password;
//@property (nonatomic, retain) KeychainItemWrapper *keychainItemWrapper;
@property (nonatomic, retain) UISwitch *rememberMe;

- (IBAction) cancelClick:(id)sender;
- (IBAction) switchChanged:(id)sender;
@end

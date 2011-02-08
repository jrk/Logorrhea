//
//  AppController.h
//  Logtastic
//
//  Created by Jan Van Tol on Sat Dec 14 2002.
//  Copyright (c) 2002 Spiny Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogReader.h"
#import "OASplitView.h"

@interface AppController : NSWindowController
{
    IBOutlet NSBrowser *browser;
    IBOutlet NSButton *openInIChat;
    IBOutlet NSButton *search;
    IBOutlet NSTextField *searchField;
    IBOutlet NSTableView *tableView;
    IBOutlet NSTabView *tabView;
    IBOutlet NSProgressIndicator *progress;
    IBOutlet NSTextField *progressText;
	
    IBOutlet NSScrollView *messageScrollView;
    IBOutlet NSTextView *messageContents;
    IBOutlet OASplitView *splitView;
	
	NSString *lastSearchTerm;
	
    LogReader *logReader;
    BOOL firstLaunch;
}

- (IBAction)closeWindow:(id)sender;
- (IBAction)feedbackLink:(id)sender;
- (IBAction)browserClick:(id)sender;
- (IBAction)search:(id)sender;
- (void)searchThreaded:(id)anObject;
- (void)updateSearchStatus;
- (void)searchComplete:(id)anObject;
- (IBAction)exportChats:(id)sender;
- (IBAction)revealInFinder:(id)sender;
- (IBAction)deleteChat:(id)sender;
- (IBAction)convertChats:(id)sender;
- (id) selectedItem;

@end

//
//  AppController.m
//  Logtastic
//
//  Created by Jan Van Tol on Sat Dec 14 2002.
//  Copyright (c) 2002 Spiny Software. All rights reserved.
//

#import "AppController.h"

NSString *LRPathToLogsKey = @"Path To Logs";

@implementation AppController

//Registers the default path to the iChats folder with userDefaults.
+ (void)initialize
{
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    NSString *pathToLogs = @"~/Documents/iChats/";
    [defaultValues setObject:pathToLogs forKey:LRPathToLogsKey];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void)awakeFromNib
{
    //This is so the "No Results Found" message won't display in the table when you haven't searched for anything.
    firstLaunch = YES;
	
    [tableView setDoubleAction:@selector(openLog:)];
	[browser setDoubleAction:@selector(openLog:)];
	
    [NSApp setDelegate:self];
    [splitView setDelegate:self];
	
    //Starts the Loading Data indicators.
    [progress setUsesThreadedAnimation:YES];
    [progress setStyle:NSProgressIndicatorSpinningStyle];
    [progress startAnimation:self];
    [progressText setStringValue:@"Loading data..."];
	
	[splitView setPositionAutosaveName:@"splitView"];
	
}

//So any alerts regarding missing iChats folder will run later in the launch, instead of bouncing icon while you find the folder.
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    logReader = [[LogReader alloc] init];     
    [browser reloadColumn:0];
    
    //Hides the Loading Data indicators when loading is done.
    [progress stopAnimation:self];
    [progress setDisplayedWhenStopped:NO];
    [progressText setStringValue:@""];
}

//Apparently we need this because we don't have a standard file menu.
- (IBAction)closeWindow:(id)sender
{
    [[self window] close];
}

- (IBAction)feedbackLink:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:jan@spiny.com"]];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

//
//Opening
//


- (void)openLog:(id)sender
{
	[[self selectedItem] open];
}


-(void) refreshChatContents:(Chat *) chat
{
	[messageContents setString:@""];
	int foundIndex = 0;
	
	if (chat != nil)
	{
		NSAttributedString *contents;
		
		if ([[[tabView selectedTabViewItem] label] isEqualToString:@"Search"] && lastSearchTerm != nil)
		{
			contents = [chat getFormattedContentsWithSearchTermsHilighted:lastSearchTerm firstFoundIndex:&foundIndex];
		}
		else
		{
			contents = [chat getFormattedContents];
		}
		
		[[messageContents textStorage] insertAttributedString:contents atIndex:0];
	}
	
	if (foundIndex != 0)
	{
		[messageContents scrollRangeToVisible:NSMakeRange(foundIndex, 1)];
	}
	else
	{
		[messageContents scrollPoint:NSMakePoint(0,0)];
	}
	
	[[messageContents enclosingScrollView] reflectScrolledClipView:(NSClipView *) messageContents];
}

//
//Tab stuff
//

//For dis/enabling Open in iChat button.
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ([[tabViewItem label] isEqualToString:@"Browse"])
	{
        [self browserClick:browser];
    }
	else
	{
        [self tableViewSelectionDidChange:nil];
    }
}

//
// Browser stuff
//

//For displaying the chat contents
-(IBAction)browserClick:(id)sender
{
	[self refreshChatContents:[self selectedItem]];
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
    if(column == 0)
	{
        return [logReader numberOfPeople];
    }
	else if(column == 1)
	{
        return [logReader numberOfChatsForBuddyAtIndex:[browser selectedRowInColumn:0]];
    }
    return 0;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column
{
    if(column == 0)
	{
        [cell setStringValue:[[logReader buddyForRow:row] description]];
		[cell setLeaf:NO];
    }
	else if(column == 1)
	{
        [cell setStringValue:[[logReader chatAtIndex:row forBuddyAtIndex:[browser selectedRowInColumn:0]] description]];
        [cell setLeaf:YES];
    }
}

// NSSplitView delegate method -- enforces a minimum size for the splitter.
- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset {
	float minimumHeight = MAX(160, proposedMin);
	return minimumHeight;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset
{
	float maximumHeight = MIN([sender bounds].size.height*.90, proposedMax);
	return maximumHeight;
}


//
// Searching
//

//Asks logReader to search. Results are stored in logReader's searchResults NSMutableArray (mutable so we can sort it), from which we get values for the tableView.
-(IBAction)search:(id)sender {

	[self refreshChatContents:nil];
	
    [progress startAnimation:self];
    [progressText setStringValue:@"Searching..."];
	[progressText display];
	[search setEnabled:NO];
	
	[NSThread detachNewThreadSelector:@selector(searchThreaded:) toTarget:self withObject:nil];
}

- (void)searchThreaded:(id)anObject
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	if (lastSearchTerm)
		[lastSearchTerm release];
	
	lastSearchTerm = [[searchField stringValue] retain];
	
    [logReader searchForString:[searchField stringValue] statusObj:self];
	
	[self performSelectorOnMainThread:@selector(searchComplete:) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

- (void)updateSearchStatus
{
	[tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];	
}

- (void)searchComplete:(id)anObject
{
	[tableView reloadData];

    [progress stopAnimation:self];
    [progress setDisplayedWhenStopped:NO];
    [progressText setStringValue:@""];	
	[search setEnabled:YES];
    firstLaunch = NO;	
}

//
//TableView
//

//Basic sorting. Note that this is not included in 1.0.
// TO DO: Reversible sorting.
- (void) tableView:(NSTableView *)aTableView didClickTableColumn:(NSTableColumn *)tableColumn
{
    if ([[tableColumn identifier] isEqualToString:@"buddy"])
	{
        [[logReader searchResults] sortUsingSelector:@selector(compareByBuddy:)];
    }
	else
	{
        [[logReader searchResults] sortUsingSelector:@selector(compareByDate:)];
    }
	
    [tableView reloadData];
}

//Displays the chat
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if ([tableView selectedRow] != -1)
	{
		Chat *chat = [[logReader searchResults] objectAtIndex:[tableView selectedRow]];
		[self refreshChatContents:chat];
    }
	else
	{
		[self refreshChatContents:nil];
    }
}

//If there are no results, return 1 so the error message will display. Don't display error on first launch of the program.
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if ([logReader numberOfSearchResults] == 0 && firstLaunch == NO)
	{
        return 1;
    }
	else
	{
        return [logReader numberOfSearchResults];
    }
}

//If there are no results, disallow selecting so the error won't be selectable. Notice we're asking the logReader directly for the number of results, instead of possibly using the fake 1 that we previously set.
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
    if ([logReader numberOfSearchResults] == 0)
	{
        return NO;
    }
	else
	{
        return YES;
    }
}

//Returns table values
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
    [aTableColumn retain];
    [aTableColumn autorelease];
    
    //If there are no results, and if this isn't the first launch, return No Results.
    if ([logReader numberOfSearchResults] == 0 && firstLaunch == NO)
	{
        if ([[aTableColumn identifier] isEqualToString:@"buddy"])
		{
            return @"No results found";
        }
		else
		{
            return @"";
        }
    }
    
    if ([[aTableColumn identifier] isEqualToString: @"buddy"])
	{
        return [[[[logReader searchResults] objectAtIndex: rowIndex] buddy] description];
    }
	else if ([[aTableColumn identifier] isEqualToString: @"chat"])
	{
        return [[[logReader searchResults] objectAtIndex: rowIndex] description];
    }
    
    return nil;
}

//Gray-out the "No results" cell
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if ([logReader numberOfSearchResults] == 0 && firstLaunch == NO)
	{
		[aCell setTextColor:[NSColor disabledControlTextColor]];
	}
	else
	{
		[aCell setTextColor:[NSColor controlTextColor]];
	}
}

//Export Chats to (big) text file

- (IBAction)exportChats:(id)sender{
      NSSavePanel *savePanel=[NSSavePanel savePanel];
	  
    [savePanel setRequiredFileType:@"txt"];

	[savePanel beginSheetForDirectory:nil file:@"iChat Export" modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(exportSavePanelDidEnd: returnCode: contextInfo:) contextInfo:nil];
}

- (void)exportSavePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		NSString *fileName = [[sheet filename] retain];
		
		[sheet close];
		
		[progress startAnimation:self];
		[progressText setStringValue:@"Exporting data..."];
		[progressText display];
	
		Buddy *thisBuddy;
		NSMutableString *exportString=[[NSMutableString alloc] initWithString:@""];
		
		for(unsigned i=0; i < [logReader numberOfPeople]; i++)
		{
			thisBuddy=[logReader buddyForRow:i];
			[progressText setStringValue:[NSString stringWithFormat:@"Exporting %@",thisBuddy]];
			[progressText display];
			
			for(unsigned j=0; j < [thisBuddy numberOfChats]; j++)
			{
				[exportString appendString:[[thisBuddy chatAtIndex:j] exportableContents]];
			}
		}
	
		[exportString writeToFile:fileName atomically:YES];
	
		[progress stopAnimation:self];
		[progress setDisplayedWhenStopped:NO];
		[progressText setStringValue:@""];
		
		[fileName release];
	}
}

- (id) selectedItem
{
	id ret = nil;
	
    if ([[[tabView selectedTabViewItem] label] isEqualToString:@"Browse"])
	{
		int selCol = [browser selectedColumn];
		if (selCol != 1)
			return nil;
		
        ret = [[logReader buddyForRow:[browser selectedRowInColumn:0]] chatAtIndex:[browser selectedRowInColumn:1]];
    } 
	else
	{
        if ([tableView selectedRow] != -1)
		{
            ret = [[logReader searchResults] objectAtIndex:[tableView selectedRow]];
        }
    }

	return ret;
	
}

- (IBAction)revealInFinder:(id)sender
{
	NSString *path = nil;
	
	path = [[self selectedItem] path];
	
	[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:@""];
}

- (IBAction)deleteChat:(id)sender
{
	NSString *path = nil;
	
	Chat *chat = [self selectedItem];
	path = [chat path];
	
	if (path != nil)
	{
		NSString *source = [path stringByDeletingLastPathComponent];
		NSString *file = [path lastPathComponent];
		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation source:source destination:@"" files:[NSArray arrayWithObject:file] tag:0];

		Buddy *b = [chat buddy];
		[b deleteChat:chat];
		[[logReader searchResults] removeObject:chat];
		[tableView reloadData];
		[browser reloadColumn:1];
		[self refreshChatContents:[self selectedItem]];
	}
}

- (IBAction)convertChats:(id)sender
{
	//...
}

//Disable the Reveal Chat in Finder menu item if there is no chat selected.
- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
	//The Reveal Chat in Finder menu item has the tag 1
	SEL action = [menuItem action];
	
	if (action == @selector(revealInFinder:) ||
		action == @selector(deleteChat:))
	{
		return [self selectedItem] != nil;
	}
	
	return YES;
}



@end

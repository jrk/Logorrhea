//
//  LogReader.m
//  Logtastic
//
//  Created by Jan Van Tol on Sat Dec 14 2002.
//  Copyright (c) 2002 Spiny Software. All rights reserved.
//

#import "LogReader.h"
#import "AddressBookUtils.h"
#import "AppController.h"
#import "AGRegex.h"

extern NSString *LRPathToLogsKey;

@implementation LogReader

- (id)init
{
    self = [super init];
    
    //Init the search results array.
    searchResults = [[NSMutableArray alloc] init];
    
    //Inits set and array to hold buddy names. The set is to filter duplicates.
    NSMutableSet *buddySet = [[NSMutableSet alloc] init];
    //Inits array to hold actually Buddy objects, which is the end result
    buddies = [[NSMutableArray alloc] init];
    
    //Grab path to iChats folder
    NSString *pathToChats = [[NSUserDefaults standardUserDefaults] objectForKey:LRPathToLogsKey];
	
	pathToChats = [pathToChats stringByExpandingTildeInPath];
	
    NSFileManager *manager = [NSFileManager defaultManager];
    //If iChats folder doesn't exist...
    if ([manager fileExistsAtPath:pathToChats] == NO)
	{
        //Run alert allow user to pick new path
        NSBeep();
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setCanChooseFiles:NO];
        [panel setCanChooseDirectories:YES];
        [panel setPrompt:@"Choose"];
        [panel setTitle:@"Locate the \"iChats\" folder"];
        int button = [panel runModalForDirectory:NSHomeDirectory() file:nil types:nil];
        if (button == NSOKButton) {
            pathToChats = [[panel filename] retain];
            [pathToChats autorelease];
            [[NSUserDefaults standardUserDefaults] setObject:pathToChats forKey:LRPathToLogsKey];
        }
		else if (button == NSCancelButton)
		{
            [NSApp terminate:self];
        }
    }
    
    //If iChats folder is empty, run alert -- Rare situation.
    NSArray *contents = [manager subpathsAtPath:pathToChats];
    if ([contents count] == 0) {
        NSRunAlertPanel(@"No Logs Found", @"Logging might not be enabled in iChat.", nil, nil, nil);
    }
    	
	NSString *pathToChatsWithSlash = [pathToChats stringByAppendingString:@"/"];

	// try to match on date pattern -- go for most international variants
	AGRegex *regex = [AGRegex regexWithPattern:@" \\S{2,} (([0-9]{4}|[0-9]{2}).){3}"];
	
    //Creates a set with all of the buddies as Buddy objects
    for (unsigned int i=0; i < [contents count]; i++)
	{
		NSString *buddyName = nil;
		
		NSString *pathName = [contents objectAtIndex:i];
		NSString *fileName = [pathName lastPathComponent];
		NSString *pathExtension = [fileName pathExtension];
        if ([pathExtension isEqualToString:@"chat"] || [pathExtension isEqualToString:@"ichat"])
		{
			NSString *fileNameWithoutExtension = [fileName stringByDeletingPathExtension];
			//If the log is numbered, which the first log isn't, then add to the set.

			NSRange range;
			
			AGRegexMatch *match = [regex findInString:fileNameWithoutExtension];
			if (match)
			{
				range = [match range];
				if (range.length > 0 && range.location != 0)
				{
					buddyName = [fileNameWithoutExtension substringToIndex:(range.location)];
				}
			}
			else
			{
				// read old-style chat files

				range = [fileNameWithoutExtension rangeOfString:@"#"];
				if (range.location != NSNotFound && range.location != 0)
				{
					buddyName = [fileNameWithoutExtension substringToIndex:(range.location -1)];
				}
				else
				{
					//else it must not be a numbered/dated log, so add it.
					buddyName = fileNameWithoutExtension;
				}
			}
			
			if (buddyName)
			{
				Buddy *buddy = [buddySet member:buddyName];
				
				if (!buddy)
				{
					NSString *realName = [AddressBookUtils lookupRealNameForIMNick:buddyName];
					if (realName)
					{
						buddyName = realName;
						buddy = [buddySet member:buddyName];
						if (!buddy)
						{
							buddy = [[Buddy alloc] initWithName:buddyName];
							[buddySet addObject:buddy];
						}
					}
					else
					{
						buddy = [[Buddy alloc] initWithName:buddyName];
						[buddySet addObject:buddy];
					}
				}

				[buddy addChatFile:[pathToChatsWithSlash stringByAppendingString:pathName]];
			}
			
		}
    }
    
    //Converts set to array and sorts
    [buddies setArray:[buddySet allObjects]];
    [buddies sortUsingSelector:@selector(caseInsensitiveCompare:)];
	[buddies makeObjectsPerformSelector:@selector(doSort)]; // do the date sorting
	[buddySet release];
	
    return self;
}


//Returns the number of buddies
- (unsigned)numberOfPeople
{
    return [buddies count];
}

//Returns number of chats in the buddy at index in buddies.
- (int)numberOfChatsForBuddyAtIndex:(int)index {
    return [[buddies objectAtIndex: index] numberOfChats];
}

//Should probably be buddyAtIndex, or we could simply get buddies, then use objectAtIndex on it.
- (Buddy *)buddyForRow:(int)row {
    return [buddies objectAtIndex:row];
}

//Returns the chat at chatIndex for the buddie at buddyIndex
- (Chat *)chatAtIndex:(int)chatIndex forBuddyAtIndex:(int)buddyIndex {
    return [[buddies objectAtIndex:buddyIndex] chatAtIndex:chatIndex];
}

//
// Searching
//

- (void)searchForString:(NSString *)string statusObj:(id) statusObject
{
    [string retain];
    //Remove old results
    [searchResults removeAllObjects];
    
    //Asks each buddy for an array containing all the Chat objects with string in them, then adds the results to searchResults.
    for (unsigned int i=0; i < [buddies count]; i++) {
		[(AppController *) statusObject updateSearchStatus];
        [searchResults addObjectsFromArray: [[buddies objectAtIndex: i] chatsWithString: string]];
    }
}

- (int)numberOfSearchResults
{
    return [searchResults count];
}

- (NSMutableArray *)searchResults
{
    return searchResults;
}

@end

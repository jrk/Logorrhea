//
//  LogReader.h
//  Logtastic
//
//  Created by Jan Van Tol on Sat Dec 14 2002.
//  Copyright (c) 2002 Spiny Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Buddy.h"

@class Buddy;

@interface LogReader : NSObject
{
    NSMutableArray *buddies;
    NSMutableArray *searchResults;
}

- (unsigned)numberOfPeople;
- (int)numberOfChatsForBuddyAtIndex:(int)index;
- (Buddy *)buddyForRow:(int)row;
- (Chat *)chatAtIndex:(int)chatIndex forBuddyAtIndex:(int)buddyIndex;

//Searching
- (void)searchForString:(NSString *)string statusObj:(id) statusObject;
- (int)numberOfSearchResults;
- (NSMutableArray *)searchResults;

@end

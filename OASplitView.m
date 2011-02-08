// Copyright 2000-2002 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// http://www.omnigroup.com/DeveloperResources/OmniSourceLicense.html.

#import "OASplitView.h"

#import <AppKit/AppKit.h>
//#import <OmniBase/OmniBase.h>

//RCS_ID("$Header: /Network/Source/CVS/OmniGroup/Frameworks/OmniAppKit/Widgets.subproj/OASplitView.m,v 1.4 2002/03/09 01:53:58 kc Exp $")

@interface OASplitView (Private)
- (void)didResizeSubviews:(NSNotification *)notification;
- (void)observeSubviewResizeNotifications;
@end

@implementation OASplitView

- (id)initWithFrame:(NSRect)frame;
{
    if ([super initWithFrame:frame] == nil)
        return nil;
        
    [self observeSubviewResizeNotifications];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder;
{
    if ([super initWithCoder:coder] == nil)
        return nil;
        
    [self observeSubviewResizeNotifications];

    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [positionAutosaveName release];
    
    [super dealloc];
}

- (void)setPositionAutosaveName:(NSString *)name;
{
    if (positionAutosaveName != name) {
        NSUserDefaults *userDefaults;
        NSArray *subviewFrameStrings;

        [positionAutosaveName release];
        positionAutosaveName = [name retain];
        
        userDefaults = [NSUserDefaults standardUserDefaults];
        if ((subviewFrameStrings = [userDefaults arrayForKey:[self positionAutosaveName]]) != nil) {
            NSArray *subviews;
            unsigned int frameStringsCount;
            unsigned int subviewIndex, subviewCount;
        
            frameStringsCount = [subviewFrameStrings count];
            subviews = [self subviews];

            // Walk through our subviews re-applying frames so we don't explode in the event that the archived frame strings become out of sync with our subview count
            for (subviewIndex = 0, subviewCount = [subviews count]; subviewIndex < subviewCount && subviewIndex < frameStringsCount; subviewIndex++) {
                NSView *subview;
                
                subview = [subviews objectAtIndex:subviewIndex];
                [subview setFrame:NSRectFromString([subviewFrameStrings objectAtIndex:subviewIndex])];
            }
        }
    }
    
}

- (NSString *)positionAutosaveName;
{
    return positionAutosaveName;
}

@end

@implementation OASplitView (Private)

- (void)didResizeSubviews:(NSNotification *)notification;
{
    if ([positionAutosaveName length] > 0) {
        NSArray *subviews;
        NSMutableArray *subviewFrameStrings;
        unsigned int subviewIndex, subviewCount;
    
        subviewFrameStrings = [NSMutableArray array];
        subviews = [self subviews];
        for (subviewIndex = 0, subviewCount = [subviews count]; subviewIndex < subviewCount; subviewIndex++) {
            NSView *subview;
            
            subview = [subviews objectAtIndex:subviewIndex];
            [subviewFrameStrings addObject:NSStringFromRect([subview frame])];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:subviewFrameStrings forKey:positionAutosaveName];
    }
}

- (void)observeSubviewResizeNotifications;
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResizeSubviews:) name:NSSplitViewDidResizeSubviewsNotification object:self];
}

@end


// Copyright 2000-2002 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// http://www.omnigroup.com/DeveloperResources/OmniSourceLicense.html.
//
// $Header: /Network/Source/CVS/OmniGroup/Frameworks/OmniAppKit/Widgets.subproj/OASplitView.h,v 1.3 2002/03/09 01:53:58 kc Exp $

#import <AppKit/NSSplitView.h>

@interface OASplitView : NSSplitView
{
    NSString *positionAutosaveName;
}

- (void)setPositionAutosaveName:(NSString *)name;
- (NSString *)positionAutosaveName;

@end

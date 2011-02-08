// AGRegex.h
//
// Copyright (c) 2002 Aram Greenman. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>

#import "pcre.h"

@class AGRegex, NSArray, NSString;

enum {
	AGRegexCaseInsensitive = 1,
	AGRegexDotAll = 2,
	AGRegexExtended = 4,
	AGRegexLazy = 8,
	AGRegexMultiline = 16
};

@interface AGRegexMatch : NSObject {
	AGRegex *regex;
	NSString *string;
	int *matchv;
	int count;
}

- (int)count;

- (NSString *)group;
- (NSString *)groupAtIndex:(int)idx;
- (NSString *)groupNamed:(NSString *)name;

- (NSRange)range;
- (NSRange)rangeAtIndex:(int)idx;
- (NSRange)rangeNamed:(NSString *)name;

- (NSString *)string;

@end

@interface AGRegex : NSObject {
	const pcre*			regex;
	const pcre_extra*	extra;
	int groupCount;
}

+ (id)regexWithPattern:(NSString *)pat;
+ (id)regexWithPattern:(NSString *)pat options:(int)opts;

- (id)initWithPattern:(NSString *)pat;
- (id)initWithPattern:(NSString *)pat options:(int)opts;

- (AGRegexMatch *)findInString:(NSString *)str;
- (AGRegexMatch *)findInString:(NSString *)str range:(NSRange)r;

- (NSArray *)findAllInString:(NSString *)str;
- (NSArray *)findAllInString:(NSString *)str range:(NSRange)r;

- (NSString *)replaceWithString:(NSString *)rep inString:(NSString *)str;
- (NSString *)replaceWithString:(NSString *)rep inString:(NSString *)str limit:(int)lim;

- (NSArray *)splitString:(NSString *)str;
- (NSArray *)splitString:(NSString *)str limit:(int)lim;

@end
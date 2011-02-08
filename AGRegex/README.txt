
AGRegex provides Perl-compatible pattern matching to Cocoa applications.

Regular expression support is provided by the PCRE library package, which is open source software, written by Philip Hazel, and copyright by the University of Cambridge, England.

<http://www.pcre.org>
<ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre>

For complete regular expression syntax see the PCRE documentation included in this folder.

USAGE

An AGRegex is created with -initWithPattern: or -initWithPattern:options: or the corresponding class methods +regexWithPattern: or +regexWithPattern:options:. These take a regular expression pattern string and the bitwise OR of zero or more option flags. For example:

	AGRegex *regex = [[AGRegex alloc] initWithPattern:@"(paran|andr)oid" options:AGRegexCaseInsensitive];
	
As of version 0.3 (PCRE 4.0), AGRegex handles all strings as UTF-8.

Matching is done with -findInString: or -findInString:range: which look for the first occurrence of the pattern in the target string and return an AGRegexMatch or nil if the pattern was not found.

	AGRegexMatch *match = [regex findInString:@"paranoid android"];
	
A match object returns a captured subpattern by -group, -groupAtIndex:, or -groupNamed:, or the range of a captured subpattern by -range, -rangeAtIndex:, or -rangeNamed:. The subpatterns are indexed in order of their opening parentheses, 0 is the entire pattern, 1 is the first capturing subpattern, and so on. -count returns the total number of subpatterns, including the pattern itself. The following prints the result of our last match case:

	for (i = 0; i < [match count]; i++)
		NSLog(@"%d %@ %@", i, NSStringFromRange([match rangeAtIndex:i]), [match groupAtIndex:i]);

2002-11-13 02:09:28.010 RegexTest[1393] 0 {0, 8} paranoid
2002-11-13 02:09:28.011 RegexTest[1393] 1 {0, 5} paran

If any of the subpatterns didn't match, -groupAtIndex: will  return nil, and -rangeAtIndex: will return {NSNotFound, 0}. For example, if we change our original pattern to "(?:(paran)|(andr))oid" we will get the following output:

2002-11-13 02:09:28.010 RegexTest[1393] 0 {0, 8} paranoid
2002-11-13 02:09:28.011 RegexTest[1393] 1 {0, 5} paran
2002-11-13 02:09:28.012 RegexTest[1393] 2 {2147483647, 0} (null)

-findAllInString: and -findAllInString:range: return an NSArray of all non-overlapping occurrences of the pattern in the target string. For example,

	NSArray *all = [regex findAllInString:@"paranoid android"];

The first object in the returned array is the match case for "paranoid" and the second object is the match case for "android".

AGRegex provides the methods -replaceWithString:inString: and -replaceWithString:inString:limit: to perform substitution on strings.

	AGRegex *regex = [AGRegex regexWithPattern:@"remote"];
	NSString *result = [regex replaceWithString:@"complete" inString:@"remote control"]; // result is "complete control"

Captured subpatterns can be interpolated into the replacement string using the syntax $x or ${x} where x is the index or name of the subpattern. $0 and $& both refer to the entire pattern. Additionally, the case modifier sequences \U...\E, \L...\E, \u, and \l are allowed in the replacement string. All other escape sequences are handled literally.

	AGRegex *regex = [AGRegex regexWithPattern:@"[usr]"];
	NSString *result = [regex replaceWithString:@"\\u$&." inString:@"Back in the ussr"]; // result is "Back in the U.S.S.R."

Note that you have to escape a backslash to get it into an NSString literal. 

As of version 0.3 (PCRE 4.0), named subpatterns may also be used in the pattern or replacement strings. 

	AGRegex *regex = [AGRegex regexWithPattern:@"(?P<who>\\w+) is a (?P<what>\\w+)"];
	NSString *result = [regex replaceWithString:@"Jackie is a $what, $who is a runt" inString:@"Judy is a punk"]); // result is "Jackie is a punk, Judy is a runt"

Finally, AGRegex provides -splitString: and -splitString:limit: which return an NSArray created by splitting the target string at each occurrence of the pattern. For example:

	AGRegex *regex = [AGRegex regexWithPattern:@"ea?"];
	NSArray *result = [regex splitString:@"Repeater"]; // result is "R", "p", "t", "r"

If there are captured subpatterns, they are returned in the array. 

	AGRegex *regex = [AGRegex regexWithPattern:@"e(a)?"];
	NSArray *result = [regex splitString:@"Repeater"]; // result is "R", "p", "a", "t", "r"

In Perl, this would return "R", undef, "p", "a", "t", undef, "r". Unfortunately, there is no convenient way to represent this in an NSArray. (NSNull could be used in place of undef, but then all members of the array couldn't be expected to be NSStrings.)

BUGS

-replaceWithString:inString:... won't see a backreference preceded by a backslash in the replacement string, whether the backslash itself is escaped or not.

-splitString:... will split at an empty match immediately following a non-empty match. While this is not necessarily a bug, it is at least inconsistent with Perl's split operator.
	
CONTACT

<grnmn@users.sourceforge.net>

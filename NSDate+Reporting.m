//
// NSDate+Reporting.m
//
// Created by Mel Sampat on 5/11/12.
// Copyright (c) 2012 Mel Sampat.


// MIT LICENSE:

// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
// THE SOFTWARE.

#import "NSDate+Reporting.h"

#define Sunday 1
#define Monday 2
#define Tuesday 3
#define Wednesday 4
#define Thursday 5
#define Friday 6
#define Saturday 7

// Private Helper functions
@interface NSDate (Private)

+ (void)zeroOutTimeComponents:(NSDateComponents **)components;
+ (NSDate *)firstDayOfQuarterFromDate:(NSDate *)date;
@end


@implementation NSDate (Reporting)

+ (NSDate *)dateWithYear:(int)year month:(int)month day:(int)day {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    // Assign the year, month and day components.
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];    

    // Zero out the hour, minute and second components.    
    [self zeroOutTimeComponents:&components];
    
    // Generate a valid NSDate and return it.
    NSCalendar *gregorianCalendar = [NSDate calendar];
    return [gregorianCalendar dateFromComponents:components];    
}

+ (NSDate *)midnightOfDate:(NSDate *)date {
    NSCalendar *calendar = [NSDate calendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    return [calendar dateFromComponents:[calendar components:preservedComponents fromDate:date]];
}

+ (NSDate *)midnightToday {
    return [self midnightOfDate:[NSDate date]];
}

+ (NSDate *)midnightTomorrow {
    NSDate *midnightToday = [self midnightToday];
    return [self oneDayAfter:midnightToday];
}

+ (NSDate *)oneDayAfter:(NSDate *)date {
	NSDateComponents *oneDayComponent = [[NSDateComponents alloc] init];
	[oneDayComponent setDay:1];
    
	NSCalendar *gregorianCalendar = [NSDate calendar];
	return [gregorianCalendar dateByAddingComponents:oneDayComponent
                                              toDate:date 
                                             options:0];
}

+ (NSDate *)oneDayBefore:(NSDate *)date {
	NSDateComponents *oneDayComponent = [[NSDateComponents alloc] init];
	[oneDayComponent setDay:-1];
    
	NSCalendar *gregorianCalendar = [NSDate calendar];
	return [gregorianCalendar dateByAddingComponents:oneDayComponent
                                              toDate:date
                                             options:0];
}

+ (NSDate *)oneSecondBefore:(NSDate *)date {
	NSDateComponents *oneDayComponent = [[NSDateComponents alloc] init];
	[oneDayComponent setSecond:-1];
    
	NSCalendar *gregorianCalendar = [NSDate calendar];
	return [gregorianCalendar dateByAddingComponents:oneDayComponent
                                              toDate:date
                                             options:0];
}

+ (NSDate *)firstDayOfCurrentMonth {
    NSCalendar *gregorianCalendar = [NSDate calendar];
    
    // Start out by getting just the year, month and day components of the current date.    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
                                                        fromDate:currentDate];
    
    // Change the Day component to 1 (for the first day of the month), and zero out the time components.
    [components setDay:1];
    [self zeroOutTimeComponents:&components];
    
    return [gregorianCalendar dateFromComponents:components];
}

+ (NSDate *)firstDayOfPreviousMonth {
    // Set up a "minus one month" component.
    NSDateComponents *minusOneMonthComponent = [[NSDateComponents alloc] init];
	[minusOneMonthComponent setMonth:-1];
    
    // Subtract 1 month from today's date. This gives us "one month ago today".
    NSCalendar *gregorianCalendar = [NSDate calendar];
    NSDate *currentDate = [NSDate date];
    NSDate *oneMonthAgoToday = [gregorianCalendar dateByAddingComponents:minusOneMonthComponent
                                                                  toDate:currentDate
                                                                 options:0];
    
    // Now extract the year, month and day components of oneMonthAgoToday.
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit 
                                                        fromDate:oneMonthAgoToday];    
    
    // Change the day to 1 (since we want the first day of the previous month).
    [components setDay:1];
    
    // Zero out the time components so we get midnight.
    [self zeroOutTimeComponents:&components];
    
    // Finally, create a new NSDate from components and return it.
    return [gregorianCalendar dateFromComponents:components];    
}

+ (NSDate *)firstDayOfNextMonth {
    NSDate *firstDayOfCurrentMonth = [self firstDayOfCurrentMonth];
    
    // Set up a "plus 1 month" component.
    NSDateComponents *plusOneMonthComponent = [[NSDateComponents alloc] init];
	[plusOneMonthComponent setMonth:1];
    
    // Add 1 month to firstDayOfCurrentMonth.
    NSCalendar *gregorianCalendar = [NSDate calendar];
    return [gregorianCalendar dateByAddingComponents:plusOneMonthComponent
                                              toDate:firstDayOfCurrentMonth
                                             options:0];    
}

+ (NSDate *)firstDayOfCurrentQuarter {
    return [self firstDayOfQuarterFromDate:[NSDate date]];
}

+ (NSDate *)firstDayOfPreviousQuarter {
    NSDate *firstDayOfCurrentQuarter = [self firstDayOfCurrentQuarter];
    
    // Set up a "minus one day" component.
    NSDateComponents *minusOneDayComponent = [[NSDateComponents alloc] init];
	[minusOneDayComponent setDay:-1];
    
    // Subtract 1 day from firstDayOfCurrentQuarter.
    NSCalendar *gregorianCalendar = [NSDate calendar];
    NSDate *lastDayOfPreviousQuarter = [gregorianCalendar dateByAddingComponents:minusOneDayComponent
                                                                          toDate:firstDayOfCurrentQuarter
                                                                         options:0];    
    return [self firstDayOfQuarterFromDate:lastDayOfPreviousQuarter];
}

+ (NSDate *)firstDayOfNextQuarter {
    NSDate *firstDayOfCurrentQuarter = [self firstDayOfCurrentQuarter];
    
    // Set up a "plus 3 months" component.
    NSDateComponents *plusThreeMonthsComponent = [[NSDateComponents alloc] init];
	[plusThreeMonthsComponent setMonth:3];
    
    // Add 3 months to firstDayOfCurrentQuarter.
    NSCalendar *gregorianCalendar = [NSDate calendar];
    return [gregorianCalendar dateByAddingComponents:plusThreeMonthsComponent
                                              toDate:firstDayOfCurrentQuarter
                                             options:0];
}

+ (NSDate *)firstDayOfCurrentYear {
    NSCalendar *gregorianCalendar = [NSDate calendar];
    
    // Start out by getting just the year, month and day components of the current date.    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit 
                                                        fromDate:currentDate];
    
    // Change the Day and Month components to 1 (for the first day of the year), and zero out the time components.
    [components setDay:1];
    [components setMonth:1];
    [self zeroOutTimeComponents:&components];
    
    return [gregorianCalendar dateFromComponents:components];    
}

+ (NSDate *)firstDayOfPreviousYear {
    NSCalendar *gregorianCalendar = [NSDate calendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                        fromDate:currentDate];
    [components setDay:1];
    [components setMonth:1];
    [components setYear:components.year - 1];
    
    // Zero out the time components so we get midnight.
    [self zeroOutTimeComponents:&components];
    return [gregorianCalendar dateFromComponents:components];
}

+ (NSDate *)firstDayOfNextYear {
    NSDate *firstDayOfCurrentYear = [self firstDayOfCurrentYear];
    
    // Set up a "plus 1 year" component.
    NSDateComponents *plusOneYearComponent = [[NSDateComponents alloc] init];
	[plusOneYearComponent setYear:1];
    
    // Add 1 year to firstDayOfCurrentYear.
    NSCalendar *gregorianCalendar = [NSDate calendar];
    return [gregorianCalendar dateByAddingComponents:plusOneYearComponent
                                              toDate:firstDayOfCurrentYear
                                             options:0];
}

- (NSDate *)midnight;
{
    return [NSDate midnightOfDate:self];
}

- (NSDate *)noon;
{
    NSCalendar *gregorianCalendar = [NSDate calendar];
    
    // Start out by getting just the year, month and day components of the specified date.
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                        fromDate:self];
    // Zero out the hour, minute and second components.
    [NSDate zeroOutTimeComponents:&components];
    
    // Set to noon
    [components setHour:12];
    
    // Convert the components back into a date and return it.
    return [gregorianCalendar dateFromComponents:components];
}

- (NSDate *)justBeforeMidnight;
{
    return [NSDate oneSecondBefore:[NSDate oneDayAfter:[NSDate midnightOfDate:self]]];
}

- (BOOL)isSunday;
{
    return [self dayOfWeek] == Sunday;
}

- (BOOL)isMonday;
{
    return [self dayOfWeek] == Monday;
}

- (BOOL)isTuesday;
{
    return [self dayOfWeek] == Tuesday;
}

- (BOOL)isWednesday;
{
    return [self dayOfWeek] == Wednesday;
}

- (BOOL)isThursday;
{
    return [self dayOfWeek] == Thursday;
}

- (BOOL)isFriday;
{
    return [self dayOfWeek] == Friday;
}

- (BOOL)isSaturday;
{
    return [self dayOfWeek] == Saturday;
}

+ (NSInteger)daysBetweenTodayAndDate:(NSDate *)date;
{
    return [self daysBetweenDate:date andDate:[NSDate date]];
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSDate calendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (NSDate *)tomorrow;
{
    return [NSDate oneDayAfter:self];
}

- (NSDate *)yesterday;
{
    return [NSDate oneDayBefore:self];
}

#pragma mark - Private Helper functions

- (NSInteger)dayOfWeek;
{
    NSCalendar *gregorianCalendar = [NSDate calendar];
    return [[gregorianCalendar components:NSWeekdayCalendarUnit fromDate:self] weekday];
}

#ifdef DEBUG
- (void)logWithComment:(NSString *)comment {
    NSString *output = [NSDateFormatter localizedStringFromDate:self
                                                      dateStyle:NSDateFormatterMediumStyle 
                                                      timeStyle:NSDateFormatterMediumStyle];
    NSLog(@"%@: %@", comment, output);
}
#endif


+ (void)zeroOutTimeComponents:(NSDateComponents **)components {
    [*components setHour:0];
    [*components setMinute:0];
    [*components setSecond:0];
}

+ (NSDate *)firstDayOfQuarterFromDate:(NSDate *)date {
    NSCalendar *gregorianCalendar = [NSDate calendar];
    NSDateComponents *components = [gregorianCalendar components:NSMonthCalendarUnit | NSYearCalendarUnit
                                                        fromDate:date];
    
    NSInteger quarterNumber = floor((components.month - 1) / 3) + 1;
    // NSLog(@"Quarter number: %d", quarterNumber);
    
    NSInteger firstMonthOfQuarter = (quarterNumber - 1) * 3 + 1;
    [components setMonth:firstMonthOfQuarter];
    [components setDay:1];
    
    // Zero out the time components so we get midnight.    
    [self zeroOutTimeComponents:&components];
    return [gregorianCalendar dateFromComponents:components];    
}

+ (NSCalendar *)calendar;
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return calendar;
}

@end

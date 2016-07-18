//
//  RequestResponseParser.m
//  ImagePOC
//
//  Created by Swapnil Rane on 15/07/16.
//  Copyright © 2016 swapnil. All rights reserved.
//

#import "RequestResponseParser.h"
#import "DetailsInfo.h"
#import "CoreDataManager.h"
#import "CJSONDeserializer.h"

@implementation RequestResponseParser

#pragma mark - Public Mathod

/*! This method will fetch data from web service */
-(void)callApiRequest: (CompletionHandler)completionHandler {
    
    NSError *error = nil;
    NSString *jsonString = [NSString stringWithContentsOfURL:[NSURL URLWithString: @"https://dl.dropboxusercontent.com/u/746330/facts.json"] encoding:NSISOLatin1StringEncoding error:&error];
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *jsonDictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
    
    if (error) {
        
        NSLog(@"Response Request - %@", error);
        
    } else {
        
        if(![[CoreDataManager sharedInstance]isDataAvailableForEntity:@"DetailsInfo"]) {
            BOOL status = [self parseResponseData:jsonDictionary];
            completionHandler(status, nil);
        }
        else {
            completionHandler(true, nil);
        }
    }
}

#pragma mark - Private Mathod
/*! This method will parse response data and store in core data */
- (BOOL)parseResponseData:(NSDictionary*)resultData {
    
    BOOL result = NO;
    CoreDataManager *coreDataManager = [[CoreDataManager alloc] init];
    
    @try {
        
        if ([resultData count]) {
            
            NSString *title = [resultData objectForKey:@"title"];
            
            [[NSUserDefaults standardUserDefaults] setObject:title forKey:@"title"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSArray *dataArray = [resultData objectForKey:@"rows"];
            
            for (NSDictionary *data in dataArray) {
                
                if([data objectForKey:@"title"] == [NSNull null] && [data objectForKey:@"description"] == [NSNull null] && [data objectForKey:@"imageHref"] == [NSNull null]) {
                    
                    //Do nothing
                }
                else {
                    
                    DetailsInfo *detailsInfoData = [NSEntityDescription insertNewObjectForEntityForName:@"DetailsInfo" inManagedObjectContext:[coreDataManager managedObjectContext]];
                    
                    detailsInfoData.title = [self validateValueForObject:[data objectForKey:@"title"]];
                    detailsInfoData.detailDescription = [self validateValueForObject:[data objectForKey:@"description"]];
                    detailsInfoData.imageRef = [self validateValueForObject:[data objectForKey:@"imageHref"]];
                }
            }
            
            result = [[coreDataManager managedObjectContext]save:nil];
        }
        
    } @catch (NSException *exception) {
        
        NSLog(@"Name: %@", exception.name);
        
        NSLog(@"Reason: %@", exception.reason);
    }
    
    return result;
}

/*! This method validate value for object paramater
 @param (id)object: object for validating
 @return (id) : validated object value
 */
- (id)validateValueForObject:(id)object {
    
    if (object == [NSNull null]) {
        
        return nil;
    }
    
    return object;
}

@end
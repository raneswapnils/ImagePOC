//
//  RequestResponseParser.h
//  ImagePOC
//
//  Created by Swapnil Rane on 15/07/16.
//  Copyright © 2016 swapnil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestResponseParser : NSObject

typedef void(^CompletionHandler)(BOOL status,NSError *error);

/*! This method will fetch data from web service */
-(void)callApiRequest: (CompletionHandler)completionHandler;

@end

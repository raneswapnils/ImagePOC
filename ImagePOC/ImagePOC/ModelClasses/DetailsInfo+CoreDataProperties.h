//
//  DetailsInfo+CoreDataProperties.h
//  ImagePOC
//
//  Created by Swapnil Rane on 18/07/16.
//  Copyright © 2016 swapnil. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DetailsInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *detailDescription;
@property (nullable, nonatomic, retain) NSString *imageRef;

@end

NS_ASSUME_NONNULL_END

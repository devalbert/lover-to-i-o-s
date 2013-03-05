//
//  ChaosCoreData.h
//  ChaosFramework
//
//  Created by Albert Zhao on 2/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@interface ChaosCoreData : NSObject {
  @private
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    
    NSString *coreModelName;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (id)initWithModelName:(NSString *)modelName;

- (NSArray *)searchInEntity:(NSString *)entityName predicate:(NSPredicate *)predicate;
- (NSArray *)searchInEntity:(NSString *)entityName predicate:(NSPredicate *)predicate sorter:(NSSortDescriptor *)sortDescriptor;

- (BOOL)saveObject;

@end
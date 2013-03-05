//
//  ChaosCoreData.m
//  ChaosFramework
//
//  Created by Albert Zhao on 2/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ChaosCoreData.h"


@interface ChaosCoreData(DatabaseURL)
- (NSURL *)applicationDocumentsDirectory;
@end

@interface ChaosCoreData(CRUD)
- (BOOL)saveContext;
@end

@implementation ChaosCoreData

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)dealloc {
    [_managedObjectModel release];
    [_managedObjectContext release];
    [_persistentStoreCoordinator release];
    [coreModelName release];
    [super dealloc];
}

- (id)initWithModelName:(NSString *)modelName {
    self = [super init];
    if (self) {
        coreModelName = [modelName retain];
        NSAssert(coreModelName, @"CoreModelName can't be nil");
    }
    return self;
}

- (NSArray *)searchInEntity:(NSString *)entityName predicate:(NSPredicate *)predicate {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSEntityDescription *identifierDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:identifierDescription];
    if (predicate) {
        [request setPredicate:predicate];
    }
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    if (!error) {
        return results;
    } else {
        return nil;
    }
}

- (NSArray *)searchInEntity:(NSString *)entityName predicate:(NSPredicate *)predicate sorter:(NSSortDescriptor *)sortDescriptor {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSEntityDescription *identifierDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:identifierDescription];
    if (predicate) {
        [request setPredicate:predicate];
    }
    if (sortDescriptor) {
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    if (!error) {
        return results;
    } else {
        return nil;
    }
}

- (BOOL)saveObject {
    return [self saveContext];
}

#pragma mark - CoreData
- (BOOL)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if ([managedObjectContext hasChanges]) {
        [managedObjectContext lock];
        BOOL saveSuccess = NO;
        if (managedObjectContext != nil) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            } else {
                saveSuccess = YES;
            }
        }
        [managedObjectContext unlock];
        return saveSuccess;
    }
    return YES;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:coreModelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", coreModelName]];
    
    NSString *storePath = [[self applicationDocumentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", coreModelName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn’t exist, copy the default store.
    if (![fileManager fileExistsAtPath:storePath]) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:coreModelName ofType:@"sqlite"];
        if (defaultStorePath) {
            [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
        }
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)applicationDocumentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end

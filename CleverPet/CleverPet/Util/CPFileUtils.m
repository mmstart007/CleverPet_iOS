//
//  CPFileUtils.m
//  CleverPet
//
//  Created by Dan Wright on 2016-02-25.
//  Copyright © 2016 CleverPet, Inc. All rights reserved.
//

#import "CPFileUtils.h"

@implementation CPFileUtils

+ (void)saveImage:(UIImage *)image forPet:(NSString *)petId
{
    [CPFileUtils createMediaFolder];
    NSString *imagePath = [self pathForPetImage:petId];
    if (image) {
        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];;
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    }
}

+ (UIImage*)getImageForPet:(NSString *)petId
{
    NSString *imagePath = [CPFileUtils pathForPetImage:petId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        return [UIImage imageWithContentsOfFile:imagePath];
    }
    return nil;
}

+ (void)createMediaFolder
{
    NSString *mediaFolderPath = [CPFileUtils mediaFolderPath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:mediaFolderPath])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:mediaFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
        
        if(error)
        {
            NSLog(@"Error creating media folder");
        }
        else
        {
            [CPFileUtils setDoNotBackupFlagForURL:[NSURL fileURLWithPath:mediaFolderPath]];
        }
    }
}

+ (NSString*)pathForPetImage:(NSString*)petId
{
    return [[CPFileUtils mediaFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", petId]];
}

+ (void)setDoNotBackupFlagForURL:(NSURL *)url
{
    if([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
    {
        NSError *error = nil;
        [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        
        if(error)
        {
            NSLog(@"Error excluding %@ from backup", [url path]);
        }
    }
}

+ (NSString*)mediaFolderPath
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *mediaUrl = [docDir stringByAppendingPathComponent:@"profilePhotos"];
    return mediaUrl;
}

@end

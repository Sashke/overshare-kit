//
// Created by Sashke on 27.04.14.
// Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import "OSKEvernoteUtility.h"
#import "EDAMTypes.h"
#import "NSData+EvernoteSDK.h"
#import "ENMLWriter.h"


@implementation OSKEvernoteUtility {

}

+ (NSMutableArray *)createResourcesForImages:(NSArray *)images{
    NSMutableArray *resources = [NSMutableArray array];
    for(UIImage *image in images){
        NSData *imageData = UIImagePNGRepresentation(image);
        NSData *dataHash = [imageData enmd5];
        EDAMData *edamData = [[EDAMData alloc] initWithBodyHash:dataHash
                                                           size:imageData.length
                                                           body:imageData];
        EDAMResource *resource = [[EDAMResource alloc] initWithGuid:nil
                                                           noteGuid:nil
                                                               data:edamData
                                                               mime:@"image/png" width:0
                                                             height:0
                                                           duration:0
                                                             active:NO
                                                        recognition:nil
                                                         attributes:nil
                                                  updateSequenceNum:0
                                                      alternateData:nil];
        [resources addObject:resource];
    }
    return resources;
}

+ (EDAMNote *)createNoteWithTitle:(NSString *)title text:(NSString *)text images:(NSArray *)images{
    NSMutableArray *resources = [NSMutableArray array];
    if (images!=nil && [images count]>0){
        resources = [self createResourcesForImages:images];
    }

    ENMLWriter *writer=[[ENMLWriter alloc] init];
    [writer startDocument];
    [writer startElement:@"span"];
    for (EDAMResource *imageResource in resources)
        [writer writeResource:imageResource];
    [writer endElement];
    [writer startElement:@"p"];
    [writer writeString:text];
    [writer endElement];
    [writer endDocument];
    NSString *noteContent=writer.contents;

    EDAMNote *newNote = [[EDAMNote alloc]init];
    [newNote setContent:noteContent];
    [newNote setTitle:title];
    [newNote setContentLength:noteContent.length];
    [newNote setResources:resources];
    return newNote;
}
@end
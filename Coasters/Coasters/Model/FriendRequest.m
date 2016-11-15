//
//  FriendRequest.m
//  
//
//  Created by 丁付德 on 15/11/12.
//
//

#import "FriendRequest.h"

@implementation FriendRequest

// Insert code here to add functionality to your managed object subclass

-(void)perfect
{
    self.year = @([self.dateTime getFromDate:1]);
    self.month = @([self.dateTime getFromDate:2]);
    self.day = @([self.dateTime getFromDate:3]);
}

@end

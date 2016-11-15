//
//  XMLHelper.m
//  Coasters
//
//  Created by 丁付德 on 16/6/7.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "XMLHelper.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"

#import "Country.h"
#import "State.h"
#import "City.h"

@implementation XMLHelper

+(instancetype)shareManager
{
    static XMLHelper *manager;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [[XMLHelper alloc] init];
    });
    return manager;
}


-(void)initCityData
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
    {
        NSString *lang_pre; // 1:中文  2:英文  3:法文  4:西班牙
        int lang = [DFD getLanguage];
        
        if ([[Country numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"language == %@", @(lang)] inContext:localContext] intValue]){
            return;
        }
        // !!!!! 这里只有中英的地区
        switch (lang) {
            case 1:
                lang_pre = @"zh";
                break;
            case 2:
                lang_pre = @"en";
                break;
            case 3:
                lang_pre = @"fr";
                lang_pre = @"en";
                break;
            case 4:
                lang_pre = @"es";
                lang_pre = @"en";
                break;
        }
        
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"LocList_%@", lang_pre] ofType:@"xml"];
        NSString *xmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        DDXMLDocument *xmlDoc = [[DDXMLDocument alloc]initWithXMLString:xmlString options:0 error:nil];
        NSArray *arrCountry;
        arrCountry = [xmlDoc nodesForXPath:@"Location/CountryRegion" error:nil];
        
        for (int i = 0; i < [arrCountry count]; i++)
        {
            DDXMLElement *country_ = arrCountry[i];
            NSArray *arrState = ((DDXMLNode *)arrCountry[i]).children;
            Country *country = [Country MR_createEntityInContext:localContext];
            country.countryName = [[country_ attributeForName:@"Name"] stringValue];
            country.countryID =   [[country_ attributeForName:@"Code"] stringValue];
            country.language = @(lang);
            NSMutableArray *arr_state = [[NSMutableArray alloc] init];
            for (int j = 0; j < arrState.count; j++)
            {
                DDXMLElement *state_ = arrState[j];
                State *state         = [State MR_createEntityInContext:localContext];
                state.stateName      = [[state_ attributeForName:@"Name"] stringValue];
                state.stateID        = [[state_ attributeForName:@"Code"] stringValue];
                if (!state.stateName.length) {
                    state.stateName = @"";
                    state.stateID = @"0";
                }
                state.language       = @(lang);
                state.country        = country;
                [arr_state addObject:state];
                
                if ([state.stateID isEqualToString:@"11"] ||
                    [state.stateID isEqualToString:@"12"] ||
                    [state.stateID isEqualToString:@"31"] ||
                    [state.stateID isEqualToString:@"50"])
                {
                    continue;
                }
                
                NSMutableArray *arr_city = [[NSMutableArray alloc] init];
                NSArray *arrCity = ((DDXMLNode *)arrState[j]).children;
                for (int m = 0; m < arrCity.count; m++)
                {
                    DDXMLElement *city_ = arrCity[m];
                    City *city          = [City MR_createEntityInContext:localContext];
                    city.cityName       = [[city_ attributeForName:@"Name"] stringValue];
                    city.cityID         = [[city_ attributeForName:@"Code"] stringValue];
                    city.language       = @(lang);
                    city.state          = state;
                    [arr_city addObject:city];
                }
                [state addCities:[NSSet setWithArray:arr_city]];
                [country addStates:[NSSet setWithArray:arr_state]];
            }
        }
        DLSave;
        DBSave;
    }];
}


@end

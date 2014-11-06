//
//  ConfigTransformer.swift
//  MTSyncTheme
//
//  Created by Taku AMANO on 2014/11/15.
//  Copyright (c) 2014年 Taku AMANO. All rights reserved.
//

import Cocoa

class StringIsEmptyTransformer: NSValueTransformer {
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if (value == nil) {
            return false
        }
        return value as String != ""
    }
}

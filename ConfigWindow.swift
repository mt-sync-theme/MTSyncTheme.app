//
//  ConfigWindow.swift
//  MTSyncTheme
//
//  Created by Taku AMANO on 2014/11/07.
//  Copyright (c) 2014年 Taku AMANO. All rights reserved.
//

import Cocoa

class ConfigWindow: NSObject {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var configWindow: NSPanel!
    @IBOutlet weak var config: Config!
    
    @IBAction func doneConfig(sender: NSButton) {
        config.sync()

        var error: NSError?
        config.validate(&error)
        
        if (error == nil) {
            NSApplication.sharedApplication().endSheet(configWindow)
            configWindow.orderOut(self)
        }
        else {
            let alert = NSAlert(error: error!)
            alert.runModal()
        }
    }

    @IBAction func selectDirectory(sender: NSButton) {
        var panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.canChooseFiles = false

        panel.beginSheetModalForWindow(configWindow, completionHandler: { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                self.config.setURL(panel.URL!)
            }
        })
    }
}
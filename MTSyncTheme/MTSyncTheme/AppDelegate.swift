//
//  AppDelegate.swift
//  MTSyncTheme
//
//  Created by Taku AMANO on 2014/11/06.
//  Copyright (c) 2014年 Taku AMANO. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSDraggingDestination {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var configWindow: NSPanel!
    @IBOutlet weak var logWindow: NSWindow!
    @IBOutlet weak var updateWindow: NSPanel!
    @IBOutlet weak var latestVersionField: NSTextField!
    @IBOutlet weak var config: Config!
    
    var latestVersionURL:String = ""
    
    override class func initialize() {
        NSValueTransformer.setValueTransformer(StringIsEmptyTransformer(), forName: "StringIsEmptyTransformer")
        NSValueTransformer.setValueTransformer(StringIsNotEmptyTransformer(), forName: "StringIsNotEmptyTransformer")
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        window.registerForDraggedTypes([NSFilenamesPboardType])
        checkForUpdate()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func application(sender: NSApplication, openFile filename: String) -> Bool {
        config.load(filename)
        return true
    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if (!flag) {
            window.makeKeyAndOrderFront(self)
        }
        
        return true
    }
    
    func draggingEntered(info: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Generic
    }
    
    func draggingUpdated(info: NSDraggingInfo) -> NSDragOperation {
        let board = info.draggingPasteboard()
        let files = board.propertyListForType(NSFilenamesPboardType) as Array<String>
        return Config.isValidThemeDirectory(files[0]) ? NSDragOperation.Copy : NSDragOperation.None
    }
    
    func performDragOperation(info: NSDraggingInfo) -> Bool {
        let board = info.draggingPasteboard()
        let files = board.propertyListForType(NSFilenamesPboardType) as Array<String>
        config.load(files[0])
        return true
    }
    
    func windowWillClose(notification: NSNotification) {
        let window = notification.object as NSWindow
        dispatch_async(dispatch_get_main_queue(), {
            NSApplication.sharedApplication().addWindowsItem(window, title: window.title!, filename: false)
        })
    }
    
    @IBAction func showHelp(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/mt-sync-theme/MTSyncTheme.app")!)
    }
    
    func checkForUpdate() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let URL = NSURL(string: "https://api.github.com/repos/mt-sync-theme/MTSyncTheme.app/releases")
            let req = NSURLRequest(URL: URL!)
            let connection: NSURLConnection = NSURLConnection(request: req, delegate: self, startImmediately: false)!
            
            NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue(), completionHandler: { (res: NSURLResponse?, data: NSData?, error: NSError?) -> () in
                
                
                if (error != nil) {
                    return
                }
                if ((res as NSHTTPURLResponse).statusCode != 200) {
                    return
                }
                
                let json: NSArray = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSArray
                
                var latest:AnyObject?
                for release in json {
                    let tagName:String = release["tag_name"] as String
                    if let match = tagName.rangeOfString("v\\d+\\.\\d+\\.\\d+", options: .RegularExpressionSearch) {
                        latest = release
                        break;
                    }
                    
                }
                
                if (latest == nil) {
                    return
                }
                
                let latestTagName = latest?["tag_name"] as String
                let latestVersion = latestTagName.substringFromIndex(advance(latestTagName.startIndex, 1))
                let currentVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as String
                if (currentVersion.compare(latestVersion, options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedDescending) {
                    return
                }

                self.latestVersionURL = latest?["html_url"] as String
                dispatch_async(dispatch_get_main_queue(), {
                    self.latestVersionField.stringValue = latestVersion
                    self.updateWindow.makeKeyAndOrderFront(self)
                })
            })
        })
    }
    
    @IBAction func openDownloadPage(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: latestVersionURL)!)
    }

    @IBAction func openConfigWindow(sender: AnyObject) {
        if (configWindow.visible) {
            return
        }
        NSApplication.sharedApplication().beginSheet(configWindow, modalForWindow: window, modalDelegate: self, didEndSelector: nil
            , contextInfo: nil)
    }
}
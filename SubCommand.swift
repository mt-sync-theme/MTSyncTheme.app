//
//  SubCommand.swift
//  MTSyncTheme
//
//  Created by Taku AMANO on 2014/11/07.
//  Copyright (c) 2014年 Taku AMANO. All rights reserved.
//

import Cocoa

class SubCommand: NSObject {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var passwordWindow: NSWindow!
    @IBOutlet weak var config: Config!
    @IBOutlet weak var logWindow: NSWindow!
    @IBOutlet weak var logScrollView: NSScrollView!
    @IBOutlet var logView: NSTextView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    var watchTask: NSTask!
    var isOpenedlogWindow: Bool = false
    var logList: Array<String> = []
    dynamic var password: String = ""
    
    @IBAction func resetLog(sender: AnyObject) {
        logList = []
        logView.string = ""
    }
    
    @IBAction func closePasswordWindow(sender: AnyObject) {
        password = passwordField.stringValue
        NSApplication.sharedApplication().endSheet(passwordWindow)
        passwordWindow.orderOut(self)
    }
    
    func runWithPassword(param:Dictionary<String,Any>) {
        if (!isOpenedlogWindow) {
            logWindow.makeKeyAndOrderFront(self)
        }
        isOpenedlogWindow = true
        
        let command = param["command"] as String
        let bundle = NSBundle.mainBundle();
        let absPath = bundle.pathForResource("mt-sync-theme", ofType: nil)
        let isWatchCommand = param["isWatchCommand"] as Bool
        
        if (isWatchCommand) {
            if (self.watchTask != nil) {
                let oldTask = self.watchTask
                self.watchTask.terminate()
                self.watchTask = nil
                
                if (oldTask.arguments[0] as NSString == command) {
                    return;
                }
            }
        }
        
        (param["preRun"] as ()->())()
        
        let task = NSTask()
        task.launchPath = absPath!
        task.arguments = [
            command,
            "--theme-directory", config.directory,
            "--endpoint", config.endpoint,
            "--username", config.username,
        ]
        if (isWatchCommand) {
            self.watchTask = task
        }
        
        if (config.urlHandler != "") {
            task.arguments.append("--url-handler")
            task.arguments.append(config.urlHandler)
        }
        
        let stdOut = NSPipe()
        task.standardOutput = stdOut
        let stdErr = NSPipe()
        task.standardError = stdErr
        
        let handler =  { (file:NSFileHandle!) -> Void in
            let data = file.availableData
            let output: String! = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            if (output == nil) {
                return
            }
            
            self.logList.append(output)
            if (self.logList.count > 1000) {
                self.logList.removeAtIndex(0)
            }
            
            let logClipView = self.logScrollView.contentView
            dispatch_async(dispatch_get_main_queue(), {
                self.logView.string = "\n".join(self.logList)
                let scrollOrigin = NSMakePoint(0.0, NSMaxY((self.logScrollView.documentView as NSView).frame)-NSHeight(logClipView.bounds))
                logClipView.scrollPoint(scrollOrigin)
            })
        }
        
        stdErr.fileHandleForReading.readabilityHandler = handler
        stdOut.fileHandleForReading.readabilityHandler = handler
        
        task.terminationHandler = { (task:NSTask?) -> () in
            stdErr.fileHandleForReading.readabilityHandler = nil
            stdOut.fileHandleForReading.readabilityHandler = nil
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let tmpfile = NSTemporaryDirectory().stringByAppendingPathComponent("MTSyncThemePassword")
            self.password.writeToFile(tmpfile, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
            var env = NSProcessInfo().environment
            env["MT_SYNC_THEME_PASSWORD_FILE"] = tmpfile
            env["MT_SYNC_THEME_PASSWORD_FILE_REMOVE"] = tmpfile
            task.environment = env
            
            if (!isWatchCommand) {
                self.progressIndicator.doubleValue = 20.0
            }
            
            
            task.launch()
            task.waitUntilExit()
            
            var error:NSError?
            if task.terminationStatus != 0 {
                
                switch task.terminationStatus {
                case 101:
                    error = NSError(domain: "MTSyncTheme.app.mt-sync-theme.github.com", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: NSLocalizedString("Cannot connect to the endpoint", comment: ""),
                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please check the endpoint and the status of the MT", comment: ""),
                        ])
                case 102:
                    error = NSError(domain: "MTSyncTheme.app.mt-sync-theme.github.com", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: NSLocalizedString("mt-data-api.cgi returned an unexpected data", comment: ""),
                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please check the endpoint and the status of the MT", comment: ""),
                        ])
                case 151:
                    error = NSError(domain: "MTSyncTheme.app.mt-sync-theme.github.com", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: NSLocalizedString("mt-data-api.cgi returned an authentication error", comment: ""),
                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please confirm the username and the password", comment: ""),
                        ])
                    self.password = ""
                case 173:
                    error = NSError(domain: "MTSyncTheme.app.mt-sync-theme.github.com", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: NSLocalizedString("mt-data-api.cgi returned an 403 error", comment: ""),
                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please confirm your permission. The SyncedTheme plugin requires system level edit_templates permission", comment: ""),
                        ])
                case 174:
                    error = NSError(domain: "MTSyncTheme.app.mt-sync-theme.github.com", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: NSLocalizedString("mt-data-api.cgi returned an 404 error", comment: ""),
                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please confirm that The SyncedTheme plugin is installed", comment: ""),
                        ])
                default:
                    error = NSError(domain: "MTSyncTheme.app.mt-sync-theme.github.com", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: NSLocalizedString("mt-sync-theme returned an error:", comment: "") + String(task.terminationStatus),
                        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please check the status of the MT", comment: ""),
                        ])
                }
            }
            
            (param["postRun"] as ()->())()
            
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = NSAlert(error: error!)
                    alert.runModal()
                })
            }
            
            if (!isWatchCommand) {
                self.progressIndicator.doubleValue = 100.0
                var delta: Int64 = 1 * Int64(NSEC_PER_SEC) / 2
                var time = dispatch_time(DISPATCH_TIME_NOW, delta)
                dispatch_after(time, dispatch_get_main_queue(), {
                    self.progressIndicator.hidden = true
                });
            }
        })
    }
    
    func runWithPassword(sheet:NSWindow, returnCode:NSInteger, contextInfo:UnsafeMutablePointer<Void>) {
        let param = UnsafeMutablePointer<Dictionary<String,Any>>(contextInfo).memory
        contextInfo.destroy()
        dispatch_async(dispatch_get_main_queue(), {
            self.runWithPassword(param)
        })
    }
    
    func run(param:Dictionary<String,Any>) {
        if (self.password == "") {
            var contextInfo = UnsafeMutablePointer<Dictionary<String,Any>>.alloc(1)
            contextInfo.memory = param
            self.password = ""
            NSApplication.sharedApplication().beginSheet(passwordWindow, modalForWindow: window, modalDelegate: self, didEndSelector: "runWithPassword:returnCode:contextInfo:", contextInfo: contextInfo)
        }
        else {
            runWithPassword(param)
        }
    }
    
    func watchCommand(sender: NSButton, command: String) {
        run([
            "isWatchCommand": true,
            "command": command,
            "preRun": {
                () -> () in
                sender.image = NSImage(named: NSImageNameStopProgressTemplate)
                sender.state = NSOnState
            },
            "postRun": {
                () -> () in
                sender.image = NSImage(named: NSImageNameGoRightTemplate)
            }
            ])
    }
    
    @IBAction func preview(sender: NSButton) {
        watchCommand(sender, command: "preview")
    }
    
    @IBAction func onTheFly(sender: NSButton) {
        watchCommand(sender, command: "on-the-fly")
    }
    
    func immediateCommand(command:String) {
        run([
            "isWatchCommand": false,
            "command": command,
            "preRun": {
                () -> () in
                self.progressIndicator.hidden = false
                self.progressIndicator.doubleValue = 10.0
            },
            "postRun": {
                () -> () in
                //
            }
            ])
    }
    
    @IBAction func sync(sender: NSButton) {
        immediateCommand("sync")
    }
    
    @IBAction func apply(sender: NSButton) {
        immediateCommand("apply")
    }
    
    @IBAction func rebuild(sender: NSButton) {
        immediateCommand("rebuild")
    }
}

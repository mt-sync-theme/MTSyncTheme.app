//
//  Config.swift
//  MTSyncTheme
//
//  Created by Taku AMANO on 2014/11/14.
//  Copyright (c) 2014年 Taku AMANO. All rights reserved.
//

import Cocoa

class Config: NSObject {
    dynamic var directory: NSString = ""
    dynamic var endpoint: NSString = ""
    dynamic var username: NSString = ""
    dynamic var urlHandler: NSString = ""
    @IBOutlet weak var subCommand: SubCommand!
    @IBOutlet weak var appDelegate: AppDelegate!
    
    @IBOutlet weak var directoryField: NSTextField!
    @IBOutlet weak var endpointField: NSTextField!
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var urlHandlerField: NSComboBox!
    
    func sync() {
        directory = directoryField.stringValue
        endpoint = endpointField.stringValue
        username = usernameField.stringValue
        urlHandler = urlHandlerField.stringValue
    }
    
    @IBAction func save(sender: AnyObject) {
        sync()
        
        let dict = [
            "endpoint": endpoint,
            "username": username,
            "url_handler": urlHandler,
        ]
        
        var yamlData = ""
        for (k, v) in dict {
            yamlData += "\(k): \(v)\n"
        }
        
        var error: NSError?
        let file = configFile()
        yamlData.writeToFile(file, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
        
        if (error != nil) {
            //
        }
    }
    
    func loadYAML(file:String) {
        if (!NSFileManager.defaultManager().fileExistsAtPath(file)) {
            return;
        }
        
        var stream = NSInputStream(fileAtPath: file)
        
        var nsDict = YAMLSerialization.objectWithYAMLStream(stream, options: kYAMLReadOptionStringScalars, error: nil) as NSDictionary
        var yaml = nsDict as Dictionary<String, String>
        
        if (yaml["endpoint"] != nil) {
            endpoint = yaml["endpoint"]!
        }
        if (yaml["username"] != nil) {
            username = yaml["username"]!
        }
        if (yaml["url_handler"] != nil) {
            urlHandler = yaml["url_handler"]!
        }
    }
    
    class func normalizeDirectory(directory:String) -> String {
        var dir = directory
        var isDir = UnsafeMutablePointer<ObjCBool>.alloc(1)
        NSFileManager.defaultManager().fileExistsAtPath(dir, isDirectory: isDir)
        if (!isDir.memory) {
            dir = dir.stringByDeletingLastPathComponent
        }
        isDir.dealloc(1)
        
        return dir
    }
    
    class func isValidThemeDirectory(directory:String) -> Bool {
        let dir = normalizeDirectory(directory)
        let theme_yaml = dir.stringByAppendingPathComponent("theme.yaml")
        return NSFileManager.defaultManager().fileExistsAtPath(theme_yaml)
    }
    
    func load(directory:String) {
        let dir = Config.normalizeDirectory(directory)
        
        if (!Config.isValidThemeDirectory(dir)) {
            let alert = NSAlert(error: errorInvalidDirectory())
            alert.runModal()
        }
        
        self.directory = directory
        loadYAML(configFile());
        
        if (endpoint == "" || username == "") {
            appDelegate.openConfigWindow(self)
        }
    }
    
    @IBAction func loadClicked(sender: AnyObject) {
        load(directory)
    }
    
    @IBAction func reset(sender: AnyObject) {
        directory = ""
        
        endpoint = ""
        username = ""
        urlHandler = ""
    }
    
    func configFile() -> String {
        var file = directory.stringByAppendingPathComponent("mt-sync-theme.yaml")
        return file;
    }
    
    func isEmpty() -> Bool {
        return endpoint.length == 0 && username.length == 0 && urlHandler.length == 0
    }
    
    func setURL(url: NSURL) {
        directory = url.path!
        load(directory)
    }
    
    func errorInvalidDirectory() -> NSError {
        return NSError(domain: "MTSyncTheme.app.mt-sync-theme.github.com", code: 1, userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Cannot find a theme.yaml", comment: ""),
            NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please choose a theme directory", comment: ""),
            ])
    }
    
    func validate(inout error: NSError?) {
        subCommand.password = ""
        
        
        if (directory == "") {
            return;
        }
        
        
        if (!Config.isValidThemeDirectory(directory)) {
            error = errorInvalidDirectory()
        }
    }
}
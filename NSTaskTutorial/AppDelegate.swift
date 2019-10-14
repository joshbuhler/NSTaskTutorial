//
//  AppDelegate.swift
//  NSTaskTutorial
//
//  Created by Joshua Buhler on 10/14/19.
//  Copyright © 2019 Hairyman. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let args = [""]
        runScript(args)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    var theTask:Process!
    var outputPipe:Pipe!
    
    func runScript(_ arguments:[String]) {
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async {
            
            
            self.theTask = Process()
            self.theTask.launchPath = "/usr/bin/uptime"
            self.theTask.arguments = arguments
            self.theTask.terminationHandler = { task in
                
                DispatchQueue.main.async(execute: {
                    print ("executing")
                })
            }
            
            self.captureStandardOutputAndRouteToTextView(self.theTask)
            
            self.theTask.launch()
            self.theTask.waitUntilExit()
        }
    }
    
    func stopTask(_ sender:AnyObject) {
        
        //      if isRunning {
        //        buildTask.terminate()
        //      }
        
    }
    
    func captureStandardOutputAndRouteToTextView(_ task:Process) {
        
        //1.
        outputPipe = Pipe()
        task.standardOutput = outputPipe
        
        //2.
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        //3.
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            //4.
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            print ("output: \(outputString)")
            //5.
            DispatchQueue.main.async(execute: {
                //            let previousOutput = self.outputText.string ?? ""
                //            let nextOutput = previousOutput + "\n" + outputString
                //            self.outputText.string = nextOutput
                //
                //            let range = NSRange(location:nextOutput.characters.count,length:0)
                //            self.outputText.scrollRangeToVisible(range)
                
            })
            
            //6.
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            
        }
    }
}


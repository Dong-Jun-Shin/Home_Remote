//
//  SessionHandler.swift
//  Home_Remote
//
//  Created by 임시 사용자 (DJ) on 2021/06/17.
//

import Foundation
import WatchConnectivity

class SessionHandler : NSObject, WCSessionDelegate{
    //1: Singleton
    static let shared = SessionHandler()
    
    //2: Property to manage session
    private var session = WCSession.default
    
    override init(){
        super.init()
        
        //3: Start and avtivate session if it's supported
        if isSuported(){
            session.delegate = self
            session.activate()
        }
        
        print("isPaired? : \(session.isPaired), isWatchAppInsatalled?: \(session.isWatchAppInstalled)")
    }
    
    func isSuported() -> Bool{
        return WCSession.isSupported()
    }
    
    //4. Required protocols
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState: \(activationState) error: \(String(describing: error))")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive: \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate: \(session)")
        self.session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["request"] as? String == "version"{
            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
        } else {
            let msg = message["request"] as? String
            replyHandler(["message" : "App sent same \(msg)"])
        }
    }
    
    func sendMessage(msg: String){
        self.session.sendMessage(["msg" : msg], replyHandler: nil) { (error) in
            print("Error sending message: \(error)")
        }
    }
}

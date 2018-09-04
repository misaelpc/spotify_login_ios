//
//  ViewController.swift
//  bearspotify
//
//  Created by Misael Pérez Chamorro on 4/8/18.
//  Copyright © 2018 Misael Pérez Chamorro. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
  
  var auth = SPTAuth.defaultInstance()!
  var session:SPTSession!
  var player: SPTAudioStreamingController?
  var loginUrl: URL?
  let nc = NotificationCenter.default
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
     // Note that default is now a property, not a method call
    nc.addObserver(forName:Notification.Name(rawValue:"loginSuccessfull"),
                   object:nil, queue:nil) {
                    notification in
                    self.updateAfterFirstLogin()
                    // Handle notification
    }
    //NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: self)
    
    //NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFirstLogin)
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setup () {
    SPTAuth.defaultInstance().clientID = "813e9ee658044c30bbdbc78937fcd878"
    SPTAuth.defaultInstance().redirectURL = URL(string: "bearspotify://returnAfterLogin")
    
    SPTAuth.defaultInstance().tokenSwapURL = URL(string: "http://localhost:4000/api/v1/swap")
    SPTAuth.defaultInstance().tokenRefreshURL = URL(string: "http://localhost:4000/api/v1/refresh")
    
    SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistModifyPrivateScope]
    loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
  }
  
  @IBAction func loginButtonWasTouchedUpInside(sender: Any) {
    if UIApplication.shared.openURL(loginUrl!) {
      if auth.canHandle(auth.redirectURL) {
        
      }
    }
  }
  
  @objc func updateAfterFirstLogin () {
    let userDefaults = UserDefaults.standard
    if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
      let sessionDataObj = sessionObj as! Data
      let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
      self.session = firstTimeSession
      initializePlayer(authSession: session)
    }
  }
  
  func initializePlayer(authSession:SPTSession){
    if self.player == nil {
      self.player = SPTAudioStreamingController.sharedInstance()
      self.player!.playbackDelegate = self
      self.player!.delegate = self
      try! player!.start(withClientId: auth.clientID)
      self.player!.login(withAccessToken: authSession.accessToken)
    }
  }
  
  
  func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
    // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
    print("logged in")
    self.player?.playSpotifyURI("spotify:track:58s6EuEYJdlb0kO7awm3Vp", startingWith: 0, startingWithPosition: 0, callback: { (error) in
      if (error != nil) {
        print("playing!")
      }
    })
  }
  


}


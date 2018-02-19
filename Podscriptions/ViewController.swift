//
//  ViewController.swift
//  Podscriptions
//
//  Created by Jeff Chimney on 2018-02-18.
//  Copyright © 2018 Jeff Chimney. All rights reserved.
//

import Cocoa
import CloudKit

class ViewController: NSViewController, XMLParserDelegate {

    var eName: String = String()
    var episodes: [Episode] = []
    var filteredEpisodes: [Episode] = []
    var episodeID: String = String()
    var episodeTitle: String = String()
    var episodeDescription = String()
    var episodeDuration = String()
    var episodeURL: URL!
    var channelTitle = ""
    var channelDescription = ""
    
    var recordBeingParsed: CKRecord!
    var rssFeedBeingParsed = ""
    var latestEpisode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        CloudKitDataHelper.getAllPodcasts { (success, results) in
            for result in results {
                self.recordBeingParsed = result
                
                let feedString = result.object(forKey: "rssFeed")! as! String
                let feedURL = URL(string: feedString)
                
                self.rssFeedBeingParsed = feedString
                self.latestEpisode = result.object(forKey: "latestEpisode")! as! String
                
                if let parser = XMLParser(contentsOf: feedURL!) {
                    parser.delegate = self
                    parser.parse()
                }
                print("Finished parsing: \(feedURL!)")
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // XMLParser Delegate Methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "enclosure" {
            let audioURL = attributeDict["url"]
            let urlString: String = audioURL!
            let url: URL = URL(string: urlString)!
            print("URL for podcast download: \(url)")
            episodeURL = url
        }
        
        eName = elementName
        if elementName == "item" {
            episodeID = String()
            episodeTitle = String()
            episodeDescription = String()
            episodeDuration = String()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            
            let episode = Episode()
            episode.id = episodeID
            episode.title = episodeTitle
            print(episodeTitle)
            episode.itunesSubtitle = episodeDescription
            episode.itunesDuration = episodeDuration
            episode.audioUrl = episodeURL

            // there is a new episode
            if episode.title != latestEpisode {
                // update latest episode in CloudKit
                CloudKitDataHelper.updateLatestEpisode(title: episode.title, record: recordBeingParsed)
                
                // get all device tokens subscribed to this podcast
                CloudKitDataHelper.getAllSubscriptionsFor(podcast: recordBeingParsed)
                
                // send notification to subscribed devices
                
            } else {
                print("No new episodes for \(recordBeingParsed.object(forKey: "title") as! String)")
            }
            
            parser.abortParsing() // stop parsing after first item
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            switch eName {
            case "title":
                if channelTitle == "" {
                    channelTitle = data
                } else {
                    episodeTitle += data
                }
            case "description":
                if channelDescription == "" {
                    channelDescription = data
                } else {
                    episodeDescription += data
                }
            case "guid":
                episodeID = data
            case "itunes:duration":
                episodeDuration = data
            default:
                break
            }
        }
    }


}


//
//  ViewController.swift
//  Podscriptions
//
//  Created by Jeff Chimney on 2018-02-18.
//  Copyright © 2018 Jeff Chimney. All rights reserved.
//

import Cocoa

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        CloudKitDataHelper.getAllPodcasts { (success, results) in
            for result in results {
                let feedString = result.object(forKey: "rssFeed")! as! String
                let feedURL = URL(string: feedString)
                if let parser = XMLParser(contentsOf: feedURL!) {
                    parser.delegate = self
                    parser.parse()
                }
                print("Looking for: \(feedURL!)")
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

            // Check first episode title returned against that stored in CloudKit (first will be the latest), update it if you need to, send a notification, then break.
            
            parser.abortParsing()
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


//
//  Episode.swift
//  Podscriptions
//
//  Created by Jeff Chimney on 2018-02-18.
//  Copyright © 2018 Jeff Chimney. All rights reserved.
//

import Foundation

class Episode {
    var id: String = String()
    var title: String = String()
    var description: String = String()
    var pubDate: String = String()
    var audioUrl: URL!
    var localURL: URL!
    var audioType: String = String()
    var episodeLink: String = String()
    var itunesAuthor: String = String()
    var itunesSubtitle: String = String()
    var itunesSummary: String = String()
    var itunesExplicit: String = String()
    var itunesDuration: String = String()
    var itunesContent: String = String()
    var itunesImage: String = String()
    var downloaded: Bool!
}


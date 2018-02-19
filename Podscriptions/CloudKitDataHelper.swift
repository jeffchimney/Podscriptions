//
//  CloudKitDataHelper.swift
//  Podwise
//
//  Created by Jeff Chimney on 2018-02-18.
//  Copyright © 2018 Jeff Chimney. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitDataHelper {
    
    static func getAllPodcasts(completionHandler:@escaping (_ success: Bool, _ records: [CKRecord]) -> Void) {
        let container = CKContainer(identifier: "iCloud.com.JeffsApps.Podwise")
        let publicDB: CKDatabase = container.publicCloudDatabase
    
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Podcasts", predicate: predicate)
        var result = false
        publicDB.perform(query, inZoneWith: nil, completionHandler: {results, er in
            
            if results != nil {
                print(results!.count)
                if results!.count >= 1 {
                    result = true
                    print(result)
                    completionHandler(result, results!)
                } else {
                    result = false
                    print(result)
                    completionHandler(result, [])
                }
            }
        })
    }
}


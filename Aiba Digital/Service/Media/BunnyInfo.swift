import Foundation

struct BunnyInfo {
    
    static let storageHostname: String = {
        return plist.object(forKey: "STORAGE_HOSTNAME") as! String
    }()
    
    static let storageName: String = {
        return plist.object(forKey: "STORAGE_NAME") as! String
    }()
    
    static let storagePullZone: String = {
        return plist.object(forKey: "STORAGE_PULL_ZONE") as! String
    }()
    
    static let storageDirectory: String = {
        return plist.object(forKey: "STORAGE_DIRECTORY") as! String
    }()
    
    static let storageAPIKey: String = {
        return plist.object(forKey: "STORAGE_API_KEY") as! String
    }()
  
    static let streamLibraryID: String = {
        return plist.object(forKey: "STREAM_LIBRARY_ID") as! String
    }()
    
    static let streamCollectionID: String = {
        return plist.object(forKey: "STREAM_COLLECTION_ID") as! String
    }()
    
    static let streamAPIKey: String = {
        return plist.object(forKey: "STREAM_API_KEY") as! String
    }()
    
    static let streamPullZone: String = {
        return plist.object(forKey: "STREAM_PULL_ZONE") as! String
    }()
    
    private static let plist: NSDictionary = {
        let filePath = Bundle.main.path(forResource: "BunnyService-Info", ofType: "plist")!
        let plist = NSDictionary(contentsOfFile: filePath)!
        return plist
    }()
    
}

import Foundation
import UIKit
import Combine

class FileUploader: NSObject, URLSessionTaskDelegate {
    
    private var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "BunnyCDN-Info", ofType: "plist") else {
           fatalError("'BunnyCDN-Info.plist' not found.")
        }

        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
           fatalError("'API_KEY' not found in 'BunnyCDN-Info.plist'.")
        }
        return value
    }
    
    private lazy var urlSession = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: .main
    )
    

    func upload(){
      
        let httpUrl = "https://sg.storage.bunnycdn.com/aibapoststorage/photo/6"
        guard let url = URL(string: httpUrl) else { return }
      
        var request = URLRequest(url: url,cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "PUT"
        request.httpBody = UIImage(named: "image3")!.pngData()!
        request.setValue(apiKey, forHTTPHeaderField: "AccessKey")
        request.setValue("image/apng", forHTTPHeaderField: "content-type")
        var data: Data
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
            }
        }
        task.resume()
    }

    func uploadImage() -> AnyPublisher<Double, Error> {
        
        guard let url = URL(string: "https://sg.storage.bunnycdn.com/aibapoststorage/photo/7") else { return Empty(outputType: Double.self, failureType: Error.self).eraseToAnyPublisher()}
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "PUT"
        request.setValue(apiKey, forHTTPHeaderField: "AccessKey")
  //      request.setValue("image/apng", forHTTPHeaderField: "content-type")
        let progressSubject = CurrentValueSubject<Double, Error>(0)
        
        let task = urlSession.uploadTask(with: request, from: UIImage(named: "image3")!.pngData()!) { responseData, response, error in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
            }
            progressSubject.send(completion: .finished)
        }
        task.resume()
        
        return progressSubject.eraseToAnyPublisher()
    }
   

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        print(progress*100)
    }
    
    
   // func upload(_ data [Data])

}

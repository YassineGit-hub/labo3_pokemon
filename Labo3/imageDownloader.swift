import UIKit

class ImageDownloader {
    static let shared = ImageDownloader()
    private let queue = DispatchQueue(label: "ImageDownloader", attributes: .concurrent)
    private init() {}

    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        queue.async {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    completion(image)
                }
            }.resume()
        }
    }
}

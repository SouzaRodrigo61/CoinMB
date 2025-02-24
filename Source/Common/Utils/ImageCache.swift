//
//  ImageCache.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 24/02/2025.
//

import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private var downloadTasks: [String: URLSessionDataTask] = [:]
    
    private init() {
        cache.countLimit = 100 // Limite de imagens no cache
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Verifica se a imagem já está no cache
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        // Cancela download anterior se existir
        downloadTasks[urlString]?.cancel()
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer { self?.downloadTasks.removeValue(forKey: urlString) }
            
            guard let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                completion(nil)
                return
            }
            
            self?.cache.setObject(image, forKey: urlString as NSString)
            completion(image)
        }
        
        downloadTasks[urlString] = task
        task.resume()
    }
    
    func clearCache() {
        cache.removeAllObjects()
        downloadTasks.values.forEach { $0.cancel() }
        downloadTasks.removeAll()
    }
} 
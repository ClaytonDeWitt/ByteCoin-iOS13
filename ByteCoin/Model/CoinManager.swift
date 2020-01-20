//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation


protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
    
}

struct CoinManager {
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    
    func getCoinPrice(for currency: String) {
        
        //Use string concatenation to add the selected currency at the end of baseURL
        let urlString = baseURL + currency
    
        //Use optional binding to unwrap the URL that's created from the URLString
        if let url = URL(string: urlString) {
            
            //Create a new URLSession object with default configuration.
            let session = URLSession(configuration: .default)
            
            //Create a new data task for the URLSession
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                    
                   if let bitcoinPrice = self.parseJSON(safeData) {
                        
                    let priceString = String(format: "%.2f", bitcoinPrice)
                        
                    self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                    
                }
            }
            
        task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.last
            
            return lastPrice
        
        } catch {
            delegate?.didFailWithError( error:error)
            return nil
        }
    }
    
}

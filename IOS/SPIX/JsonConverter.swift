//
//  JSON.swift
//  SPIX
//
//  Created by Rodrigo Maicá on 3/31/15.
//  Copyright (c) 2015 BEASTROX. All rights reserved.
//

import Foundation

public struct JsonConverter {
    
    public static func stringify(jsonObj: AnyObject) -> String {
        if((jsonObj as? [Dictionary<String, AnyObject>]) != nil || (jsonObj as? [Array<AnyObject>]) != nil){
            var e: NSError?
            var jsonData: NSData?
            do {
                jsonData = try JSONSerialization.data(withJSONObject: jsonObj, options: JSONSerialization.WritingOptions(rawValue: 0)) as NSData
            } catch let error as NSError {
                e = error
                jsonData = nil
            };
            
            if e != nil {
                print(e!);
                return "\(jsonObj)";
            } else {
                return NSString(data: jsonData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
            }
        } else {
            return "\(jsonObj)";
        }
    }
    
    public static func parse(jsonString: String) -> Any {
        let isObject = jsonString.hasPrefix("{");
        
        var e: NSError?
        let data: NSData! = jsonString.data(using: String.Encoding.utf8)! as NSData
        var jsonObj: Any!
        do {
            jsonObj = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
        } catch let error as NSError {
            e = error
            jsonObj = nil
        };
        
        if e != nil {
            print(e!);
            return isObject ? Dictionary<String, AnyObject>() : Array<AnyObject>();
        } else {
            return jsonObj as AnyObject;
        }
    }
    
}

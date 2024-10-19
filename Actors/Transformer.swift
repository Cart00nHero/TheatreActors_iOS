//
//  Transformer.swift
//  PrivateKitchen
//
//  Created by 林祐正 on 2022/1/20.
//

import Foundation
import Theatre
import SwiftProtobuf

class Transformer: Actor {
    private func actConvert<T1: Codable, T2: Codable>(_ from: T1, type: T2.Type) -> T2? {
        do {
            let json = try JSONEncoder().encode(from)
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: json)
        } catch {
            print(error)
            return nil
        }
    }
    
    private func actCodableToJson<T: Codable>(_ entity: T) -> String {
        do {
            let jsonData = try JSONEncoder().encode(entity)
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print(error)
            return ""
        }
    }

    private func actCodableToEntity<T1: Codable, T2>(_ entity: T1, _ type: T2.Type) -> T2? {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(entity)
            return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? T2
        } catch {
            print(error)
            return nil
        }
    }

    private func actEntityToCodable<T: Codable>(_ from: Any, _ type: T.Type) -> T? {
        guard let json = try? JSONSerialization.data(withJSONObject: from, options: .fragmentsAllowed) else {
            return nil
        }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(type, from: json)
        } catch {
            print(error)
            return nil
        }
    }
    private func actEntityToJson(_ entity: Any) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: entity, options: .fragmentsAllowed)
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print(error)
            return ""
        }
    }
    private func actJsonToCodable<T: Codable>(_ json: String, _ type: T.Type) -> T? {
        let jsonData = Data(json.utf8)
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(type, from: jsonData)
        } catch {
            print(error)
            return nil
        }
    }

    private func actJsonToEntity<T>(_ json: String, _ type: T.Type) -> T? {
        let jsonData = Data(json.utf8)
        do {
            return try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? T
        } catch {
            print(error)
            return nil
        }
    }
    
    private func actJsonToMessage<T: Message>(_ json: String, _ type: T.Type) -> T? {
        do {
            var decodeOptions = JSONDecodingOptions()
            decodeOptions.ignoreUnknownFields = true
            return try T.init(jsonString: json, options: decodeOptions)
        } catch {
            print(error)
            return nil
        }
    }
    private func actJsonToMessages<T: Message>(_ json: String, type: T.Type) -> [T] {
        do {
            var decodeOptions = JSONDecodingOptions()
            decodeOptions.ignoreUnknownFields = true
            return try T.array(fromJSONString: json, options: decodeOptions)
        } catch {
            print(error)
            return []
        }
    }
    private func actDataToMessage<T: Message>(_ data: Data, type: T.Type) -> T? {
        do {
            var decodeOptions = JSONDecodingOptions()
            decodeOptions.ignoreUnknownFields = true
            return try T.init(jsonUTF8Data: data, options: decodeOptions)
        } catch {
            print(error)
            return nil
        }
    }
    private func actDataToMessages<T: Message>(_ data: Data, type: T.Type) -> [T] {
        do {
            var decodeOptions = JSONDecodingOptions()
            decodeOptions.ignoreUnknownFields = true
            return try T.array(fromJSONUTF8Data: data, options: decodeOptions)
        } catch {
            print(error)
            return []
        }
    }
    private func actMessageToJson<T: Message>(_ message: T) -> String {
        do {
            return try message.jsonString()
        } catch {
            print(error)
            return ""
        }
    }
    private func actMessagesToJson<T: Message>(_ messages: [T]) -> String {
        do {
            return try T.jsonString(from: messages)
        } catch {
            print(error)
            return  ""
        }
    }
    func actTransfer<T1, T2>(_ from: T1, type: T2.Type) -> T2? {
        do {
            let json: Data = try JSONSerialization.data(
                withJSONObject: from,
                options: .fragmentsAllowed)
            return try JSONSerialization.jsonObject(
                with: json, options: .fragmentsAllowed) as? T2
        } catch {
            print(error)
            return nil
        }
    }
}
extension Transformer: TransformerBehaviors {
    func convert<T1: Codable,T2: Codable>(from: T1, to type: T2.Type) -> Teleport<T2?> {
        let export = install(T2?(nil))
        act { [unowned self] in
            export.portal = actConvert(from, type: type)
        }
        return export
    }
    func codableToJson<T: Codable>(from entity: T) -> Teleport<String> {
        let export = install(String(""))
        act { [unowned self] in
            export.portal = actCodableToJson(entity)
        }
        return export
    }
    func codableToEntity<T1: Codable, T2>(from entity: T1, to type: T2.Type) -> Teleport<T2?> {
        let export = install(T2?(nil))
        act { [unowned self] in
            export.portal = actCodableToEntity(entity, type)
        }
        return export
    }
    func entityToCodable<T: Codable>(from entity: Any,to type: T.Type) -> Teleport<T?> {
        let export = install(T?(nil))
        act { [unowned self] in
            export.portal = actEntityToCodable(entity, type)
        }
        return export
    }
    func entityToJson(from entity: Any) -> Teleport<String> {
        let export = install(String(""))
        act { [unowned self] in
            export.portal = actEntityToJson(entity)
        }
        return export
    }
    
    func jsonToCodable<T: Codable>(from json: String, to type: T.Type) -> Teleport<T?> {
        let export = install(T?(nil))
        act { [unowned self] in
            export.portal = actJsonToCodable(json, type)
        }
        return export
    }
    func jsonToEntity<T>(from json: String, to type: T.Type) -> Teleport<T?> {
        let export = install(T?(nil))
        act { [unowned self] in
            export.portal = actJsonToEntity(json, type)
        }
        return export
    }
    func jsonToMessage<T: Message>(from json: String, to type: T.Type) -> Teleport<T?> {
        let export = install(T?(nil))
        act { [unowned self] in
            export.portal = actJsonToMessage(json, type)
        }
        return export
    }
    func jsonToMessages<T: Message>(from json: String, to type: T.Type) -> Teleport<[T]> {
        let export = install([T]())
        act { [unowned self] in
            export.portal = actJsonToMessages(json, type: type)
        }
        return export
    }
    func dataToMessage<T: Message>(from data: Data, to type: T.Type) -> Teleport<T?> {
        let export = install(T?(nil))
        act { [unowned self] in
            export.portal = actDataToMessage(data, type: type)
        }
        return export
    }
    func dataToMessages<T: Message>(from data: Data, to type: T.Type) -> Teleport<[T]> {
        let export = install([T]())
        act { [unowned self] in
            export.portal = actDataToMessages(data, type: type)
        }
        return export
    }
    func messageToJson<T: Message>(from message: T) -> Teleport<String> {
        let export = install(String(""))
        act { [unowned self] in
            export.portal = actMessageToJson(message)
        }
        return export
    }
    func messagesToJson<T: Message>(from messages: [T]) -> Teleport<String> {
        let export = install(String(""))
        act { [unowned self] in
            export.portal = actMessagesToJson(messages)
        }
        return export
    }
    func transfer<T1, T2>(from entity: T1, to type: T2.Type) -> Teleport<T2?> {
        let export = install(T2?(nil))
        act { [unowned self] in
            export.portal = actTransfer(entity, type: type)
        }
        return export
    }
}

protocol TransformerBehaviors {
    func convert<T1: Codable,T2: Codable>(from: T1, to type: T2.Type) -> Teleport<T2?>
    func codableToJson<T: Codable>(from entity: T) -> Teleport<String>
    func codableToEntity<T1: Codable, T2>(from entity: T1, to type: T2.Type) -> Teleport<T2?>
    func entityToCodable<T: Codable>(from entity: Any,to type: T.Type) -> Teleport<T?>
    func entityToJson(from entity: Any) -> Teleport<String>
    func jsonToCodable<T: Codable>(from json: String, to type: T.Type) -> Teleport<T?>
    func jsonToEntity<T>(from json: String, to type: T.Type) -> Teleport<T?>
    func jsonToMessage<T: Message>(from json: String, to type: T.Type) -> Teleport<T?>
    func jsonToMessages<T: Message>(from json: String, to type: T.Type) -> Teleport<[T]>
    func dataToMessage<T: Message>(from data: Data, to type: T.Type) -> Teleport<T?>
    func dataToMessages<T: Message>(from data: Data, to type: T.Type) -> Teleport<[T]>
    func messageToJson<T: Message>(from message: T) -> Teleport<String>
    func messagesToJson<T: Message>(from messages: [T]) -> Teleport<String>
    func transfer<T1, T2>(from entity: T1, to type: T2.Type) -> Teleport<T2?>
}

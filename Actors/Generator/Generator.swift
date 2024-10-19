//
//  Generator.swift
//  PrivateKitchen
//
//  Created by 林祐正 on 2022/1/21.
//

import Foundation
import Theatre

final class Generator: Actor {
    
    private func actGenSnowFlakeId() -> Int64 {
//        let generator = SnowflakeSwift(IDCID: 4, machineID: 30)
        let generator = SpotFlake.Node(node: 1)
        return generator?.generate().rawValue ?? 0
    }
    /*
     let translator = ShortUUID()
     let shortId = translator.generate()  // eGQRS1nM2t3E8xxcc2BhjA

     // Translate UUIDs to and from the shortened format
     translator.toUUID(shortId) // a44521d0-0fb8-4ade-8002-3385545c3318
     translator.fromUUID(UUID(uuidString: "a44521d0-0fb8-4ade-8002-3385545c3318")!) // mhvXdrZT4jP5T8vBxuvm75

     // See the alphabet used by a translator
     translator.alphabet

     // View the constants
     ShortUUID.flickrBase58 // Avoids similar characters (0/O, 1/I/l, etc.)
     ShortUUID.cookieBase90 // Safe for HTTP cookies values for smaller IDs.
     
     from: https://github.com/jrikhof/short-uuid-swift
     */
    private func actGenShortUUID() -> String {
        let generator = ShortUUID()
        return generator.generate()
    }
}
extension Generator: GeneratorBehaviors {
    func genSnowFlake() -> Teleport<Int64> {
        let export: Teleport<Int64> = install(Int64(0))
        act { [unowned self] in
            export.portal = actGenSnowFlakeId()
        }
        return export
    }
    
    func genShortUUID() -> Teleport<String> {
        let export = install(String(""))
        act { [unowned self] in
            export.portal = actGenShortUUID()
        }
        return export
    }
}
protocol GeneratorBehaviors {
    func genSnowFlake() -> Teleport<Int64>
    func genShortUUID() -> Teleport<String>
}

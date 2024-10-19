//
//  TimeKeeper.swift
//  iListen
//
//  Created by 林祐正 on 2021/10/25.
//  Copyright © 2021 SmartFun. All rights reserved.
//

import Foundation
import Theatre

fileprivate class BackgroundTimer {
    private let repeating: DispatchTimeInterval
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + repeating, repeating: repeating)
        t.setEventHandler { [unowned self] in
            eventHandler?()
        }
        return t
    }()
    var eventHandler: (() -> Void)?
    
    init(_ repeating: DispatchTimeInterval) {
        self.repeating = repeating
    }
    
    private enum State: Int, CaseIterable {
        case suspended
        case resumed
    }
    
    private var state: State = .suspended
    
    func activate() {
        timer.activate()
    }
    
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
    
    func cancel() {
        timer.cancel()
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        eventHandler = nil
    }
}

final class TimeKeeper: Actor {
    private var bgTimer: BackgroundTimer?
    private func actScheduleTimer(
        _ repeatTime: DispatchTimeInterval, 
        _ timeUp:@escaping() -> Void
    ) {
        guard bgTimer == nil else { return }
        bgTimer = BackgroundTimer(repeatTime)
        bgTimer?.eventHandler = timeUp
        bgTimer?.activate()
    }
    private func actResume() {
        bgTimer?.resume()
    }
    private func actSuspend() {
        bgTimer?.suspend()
    }
    
    private func actCancel() {
        bgTimer?.cancel()
    }
    
    private func actStop() {
        bgTimer = nil
    }
}

// MARK: - TimeKeeper entrance
extension TimeKeeper: TimeKeeperBehaviors {
    func scheduleTimer(_ repeatTime: DispatchTimeInterval, _ timeUp:@escaping() -> Void) {
        act { [unowned self] in
            actScheduleTimer(repeatTime, timeUp)
        }
    }
    func resume() {
        act(actResume)
    }
    func suspend() {
        act(actSuspend)
    }
    func cancel() {
        act(actCancel)
    }
    func stop() {
        act(actStop)
    }
}
protocol TimeKeeperBehaviors {
    func scheduleTimer(_ repeatTime: DispatchTimeInterval, _ timeUp:@escaping() -> Void)
    func resume()
    func suspend()
    func cancel()
    func stop()
}

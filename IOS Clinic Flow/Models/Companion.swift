//
//  Companion.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-07.
//

import Foundation

// MARK: - Companion Alert
//data for the alert notification screen
struct CompanionAlert: Identifiable {
    let id: Int
    let text: String
    let time: String
    let type: String
}

// MARK: - UpcomingA ppointment
// data for the upcoming appointment
struct UpcomingAppointment {
    let doctor: String
    let specialty: String
    let date: String
    let time: String
    let location: String
    let token: String
}

// MARK: - Queue Data
// data for the companion's queue view
struct CompanionQueueData {
    let position: Int
    let doctor: String
    let room: String
    let estimatedWait: String
    let currentStep: String
    let steps: [VisitStep]
}

// MARK: - Care For Person
// this is the data of the person that logged-in user monitoring
struct CareForPerson: Identifiable {
    let id: Int
    let name: String
    let relation: String
    let age: Int
    let phone: String
    let avatar: String
    let conditions: [String]
    let lastVisit: String
    var upcomingAppt: UpcomingAppointment?
    var queueData: CompanionQueueData?
    var alerts: [CompanionAlert]
}

// MARK: - MyCompanion
//this is the data of the person that monitoring the loggedin user
struct MyCompanion: Identifiable {
    let id: Int
    let name: String
    let relation: String
    let avatar: String
    let phone: String
    let permissions: [String]
    let linkedSince: String
    let status: String
}


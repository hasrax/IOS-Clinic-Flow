//
//  CompanionQueueView.swift
//  IOS Clinic Flow
//
//  Created by COBSCCOMP24.2P-023 on 2026-03-10.
//

import SwiftUI

// MARK: - Companion Queue model structure
private struct CQStep {
    let title: String
    let date: String
    let timeLabel: String
    let timeColor: Color
    let state: State
    enum State { case done, active, pending }
}

//data for the companion queue
struct CompanionQueueView: View {
    @Environment(\.dismiss) private var dismiss
    let person: CareForPerson

    // Use constant binding — neutral mode doesn't highlight any tab.
    private var tabBinding: Binding<TabItem> {
        .constant(.home)
    }

    private func steps(for queue: CompanionQueueData) -> [CQStep] {
        [
            CQStep(title: "Registration",   date: "14 , February 2025", timeLabel: "1.45 PM",      timeColor: .textSecondary,        state: .done),
            CQStep(title: "Consultation",   date: "25 , February 2025", timeLabel: "NOW",           timeColor: Color(hex: "EF4444"),  state: .active),
            CQStep(title: "Lab Test",       date: "Not yet scheduled",  timeLabel: "Time pending",  timeColor: .textTertiary,         state: .pending),
            CQStep(title: "Pharmacy",       date: "Not yet scheduled",  timeLabel: "Time pending",  timeColor: .textTertiary,         state: .pending),
            CQStep(title: "Payment",        date: "Not yet scheduled",  timeLabel: "Time pending",  timeColor: .textTertiary,         state: .pending),
        ]
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                if let queue = person.queueData {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {

                            VStack(spacing: 0) {
                                NavBar(
                                    title: "Queue Status",
                                    subtitle: person.name,
                                    onBack: { dismiss() },
                                    backColor: .white,
                                    titleColor: .white,
                                    subtitleColor: .white.opacity(0.75),
                                    backgroundColor: .clear
                                )
                                .padding(.top, 44)

                                //live indicator
                                HStack {
                                    HStack(spacing: 6) {
                                        Image(systemName: "antenna.radiowaves.left.and.right")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.errorRed)
                                        Text("Live")
                                            .font(.custom("Inter_18pt-Bold", size: 13))
                                            .foregroundColor(.errorRed)
                                    }
                                    Spacer()
                                    Text("Queue #\(queue.position)")
                                        .font(.custom("Inter_18pt-Bold", size: 14))
                                        .foregroundColor(Color(hex: "F59E0B"))
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 8)
                                .padding(.bottom, 12)

                                // Doctor name
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(queue.doctor)
                                        .font(.custom("Inter_18pt-ExtraBold", size: 22))
                                        .foregroundColor(.white)
                                    Text("Tracking for \(person.name)")
                                        .font(.custom("Inter_18pt-Regular", size: 13))
                                        .foregroundColor(.white.opacity(0.75))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 24)

                                // the circle that shows queue
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.15), lineWidth: 10)
                                        .frame(width: 130, height: 130)
                                    Circle()
                                        .trim(from: 0, to: CGFloat(queue.position) / 10.0)
                                        .stroke(
                                            Color.successGreen,
                                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                        )
                                        .rotationEffect(.degrees(-90))
                                        .frame(width: 130, height: 130)
                                    VStack(spacing: 2) {
                                        Text("\(queue.position)")
                                            .font(.custom("Inter_18pt-Black", size: 48))
                                            .foregroundColor(.white)
                                        Text("IN")
                                            .font(.custom("Inter_18pt-Bold", size: 11))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("QUEUE")
                                            .font(.custom("Inter_18pt-Bold", size: 11))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                .padding(.bottom, 24)

                                // Time/Location
                                HStack(spacing: 28) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text(queue.estimatedWait)
                                            .font(.custom("Inter_18pt-Regular", size: 13))
                                            .foregroundColor(.white.opacity(0.85))
                                    }
                                    HStack(spacing: 6) {
                                        Image(systemName: "mappin.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text(queue.room)
                                            .font(.custom("Inter_18pt-Regular", size: 13))
                                            .foregroundColor(.white.opacity(0.85))
                                    }
                                }
                                .padding(.bottom, 40)
                            }
                            .background(
                                LinearGradient.primaryGradient
                                    .ignoresSafeArea(edges: .top)
                                    .clipShape(UnevenRoundedRectangle(
                                        topLeadingRadius: 0,
                                        bottomLeadingRadius: 28,
                                        bottomTrailingRadius: 28,
                                        topTrailingRadius: 0,
                                        style: .continuous
                                    ))
                            )

                            // Visit Progress
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Visit Progress")
                                    .font(.custom("Inter_18pt-Bold", size: 20))
                                    .foregroundColor(.textPrimary)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 24)

                                ForEach(steps(for: queue), id: \.title) { step in
                                    CQStepCard(step: step)
                                        .padding(.horizontal, 20)
                                }
                            }
                            .padding(.bottom, 24)
                        }
                    }
                    .ignoresSafeArea(edges: .top)

                    // Bottom bar
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.surfaceMuted)
                            .frame(height: 1)
                        Button {} label: {
                            Text("Call \(person.name.components(separatedBy: " ").first ?? person.name) Perera")
                                .font(.custom("Inter_18pt-SemiBold", size: 15))
                                .foregroundColor(.primaryBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primaryBlue, lineWidth: 1.5)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white)

                        BottomTabBar(selectedTab: tabBinding, isNeutral: true)
                    }
                } else {
                    // No queue data
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.clock")
                            .font(.system(size: 44))
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(person.name) is not currently in queue")
                            .font(.custom("Inter_18pt-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()

                    VStack(spacing: 0) {
                        Rectangle().fill(Color.surfaceMuted).frame(height: 1)
                        BottomTabBar(selectedTab: tabBinding, isNeutral: true)
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - CQ Step Card

private struct CQStepCard: View {
    let step: CQStep

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                switch step.state {
                case .done:
                    Circle().fill(Color.successGreen).frame(width: 38, height: 38)
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                case .active:
                    Circle().fill(Color.primaryBlue).frame(width: 38, height: 38)
                    Circle().fill(Color.white).frame(width: 12, height: 12)
                case .pending:
                    Circle().stroke(Color(hex: "D1D5DB"), lineWidth: 2).frame(width: 38, height: 38)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(step.title)
                    .font(.custom("Inter_18pt-SemiBold", size: 14))
                    .foregroundColor(
                        step.state == .done   ? .successGreen :
                        step.state == .active ? .primaryBlue  : .textPrimary
                    )
                HStack(spacing: 18) {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11)).foregroundColor(.textTertiary)
                        Text(step.date)
                            .font(.custom("Inter_18pt-Regular", size: 12)).foregroundColor(.textSecondary)
                    }
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 11)).foregroundColor(.textTertiary)
                        Text(step.timeLabel)
                            .font(.custom("Inter_18pt-Regular", size: 12)).foregroundColor(step.timeColor)
                    }
                }
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

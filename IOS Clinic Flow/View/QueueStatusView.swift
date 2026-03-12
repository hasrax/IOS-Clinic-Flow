//
//  QueueStatusView.swift
//  IOS Clinic Flow
//
//  Created by Lakindu Siriwardena on 2026-03-10.
//
import SwiftUI

// MARK: - Queue Step Model
private struct QueueStep {
    let title: String
    let date: String
    let timeLabel: String
    let timeColor: Color
    let state: StepState

    enum StepState { case done, active, pending }
}

// MARK: - Curved bottom shape
private struct QueueCurvedShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 60))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.maxY - 60),
            control: CGPoint(x: rect.midX, y: rect.maxY + 50)
        )
        path.closeSubpath()
        return path
    }
}

struct QueueStatusView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navTab: TabItem = .home
//the dismiss to go do the  initial page
    private let steps: [QueueStep] = [
        QueueStep(title: "Registration",  date: "14 , February 2025", timeLabel: "1.45 PM",      timeColor: .textSecondary,            state: .done),
        QueueStep(title: "Consultation",  date: "25 , February 2025", timeLabel: "12 min",       timeColor: Color(hex: "EF4444"),      state: .active),
        QueueStep(title: "Lab Test",      date: "Not yet scheduled",  timeLabel: "Time pending", timeColor: .textTertiary,             state: .pending),
        QueueStep(title: "Pharmacy",      date: "Not yet scheduled",  timeLabel: "Time pending", timeColor: .textTertiary,             state: .pending),
        QueueStep(title: "Payment",       date: "Not yet scheduled",  timeLabel: "Time pending", timeColor: .textTertiary,             state: .pending),
    ]
//hardcopded clinic steps because lack of backend xxxx
    var body: some View {
        ZStack(alignment: .top) {
            //for all child components to start from the top insread of center
            Color.appBackground.ignoresSafeArea()

            // Blue curved header background
            LinearGradient.primaryGradient
                .clipShape(QueueCurvedShape())
                .frame(height: 380)
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // ── Header info area ──
                        VStack(spacing: 0) {
                            // a more detail and indepth version of the live status update that we pout in the home view
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
                                Text("BM240126-11")
                                    .font(.custom("Inter_18pt-Bold", size: 14))
                                    .foregroundColor(Color(hex: "F59E0B"))
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 12)

                            // Ddoctors information
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Dr. Prasad Pathirana")
                                    .font(.custom("Inter_18pt-ExtraBold", size: 22))
                                    .foregroundColor(.white)
                                Text("Ophthalmologist")
                                    .font(.custom("Inter_18pt-Regular", size: 13))
                                    .foregroundColor(.white.opacity(0.75))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)

                            // queue circle oermanattly showing 72percent duo to the hardcodeing thingamabob
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 10)
                                    .frame(width: 130, height: 130)
                                Circle()
                                    .trim(from: 0, to: 0.72)
                                    .stroke(
                                        Color.successGreen,
                                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                    )
                                //to show the statuys of the queue as i9n whos currently in the appointment room and whos not
                                //again hardcoded because... obvious reasons xxxx
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 130, height: 130)
                                VStack(spacing: 2) {
                                    Text("6")
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

                            // time and location view
                            HStack(spacing: 28) {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("12 min")
                                        .font(.custom("Inter_18pt-Regular", size: 13))
                                        .foregroundColor(.white.opacity(0.85))
                                }
                                HStack(spacing: 6) {
                                    Image(systemName: "mappin.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("Room 89B, Floor 3")
                                        .font(.custom("Inter_18pt-Regular", size: 13))
                                        .foregroundColor(.white.opacity(0.85))
                                }
                            }
                            .padding(.bottom, 40)
                        }

                        // progess of the visiti design
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Visit Progress")
                                .font(.custom("Inter_18pt-Bold", size: 20))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)

                            ForEach(steps, id: \.title) { step in
                                QueueStepCard(step: step)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }

                // nav buttons on bottom bar
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.surfaceMuted)
                        .frame(height: 1)
                    HStack(spacing: 16) {
                        OutlinedActionButton(label: "Navigate", icon: "map.fill") {}
                        OutlinedActionButton(label: "Checklist", icon: "checklist") {}
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white)
                }

                BottomTabBar(selectedTab: $navTab, isNeutral: true)
            }
        }
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Queue Status")
                    .font(.custom("Inter_18pt-Bold", size: 18))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - queue step card
private struct QueueStepCard: View {
    let step: QueueStep
//reusable card for queue step
    var body: some View {
        HStack(spacing: 14) {
            // state of each step
            ZStack {
                switch step.state {
                case .done:
                    Circle().fill(Color.successGreen).frame(width: 38, height: 38)
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    //completed step design
                case .active:
                    Circle().fill(Color.primaryBlue).frame(width: 38, height: 38)
                    Circle().fill(Color.white).frame(width: 12, height: 12)
                    //active step desing
                case .pending:
                    Circle().stroke(Color(hex: "D1D5DB"), lineWidth: 2).frame(width: 38, height: 38)
                    //pending steps design
                }
            }

            // Content
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
                            .font(.system(size: 11))
                            .foregroundColor(.textTertiary)
                        Text(step.date)
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(.textTertiary)
                        Text(step.timeLabel)
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(step.timeColor)
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

// MARK: - action button (outlined)
private struct OutlinedActionButton: View {
    let label: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                Text(label)
                    .font(.custom("Inter_18pt-SemiBold", size: 15))
            }
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
    }
}

#Preview {
    NavigationStack {
        QueueStatusView()
    }
}


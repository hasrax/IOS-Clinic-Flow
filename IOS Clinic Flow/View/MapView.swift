//
//  MapView.swift  — UX Redesign
//  IOS Clinic Flow
//
//  UX improvements over original:
//    • Map is the hero — takes up most of the screen immediately
//    • Floor tabs are persistent, pill-style, always visible above the map
//    • Route card starts collapsed (shows just From/To summary); expands on tap
//    • "Tap a room" mode gives clear visual feedback on ALL rooms (dim unselectable ones)
//    • Directions live in a draggable bottom sheet — never pushes the map off-screen
//    • Step indicator is a compact progress bar + current step bubble, not a full list
//    • "Swap" button lets user reverse From/To instantly
//    • Double-tap any room to set as destination (when no mode is active)
//    • Room highlight pulses when it is the active step destination
//    • Legend lives inside a small persistent corner badge, not a separate row
//

import SwiftUI

// MARK: - Room category (all-blue palette)
private enum RoomCategory {
    case entry, services, diagnostic, clinical, critical, surgical, support

    // All rooms share the same blue-tinted fill/border — differentiated only by shade
    var fill: Color { switch self {
        case .entry:      return Color(hex: "1E4DB7")   // strong blue  — entrance/elevator
        case .services:   return Color(hex: "2563EB")   // medium blue  — reception/nurses
        case .diagnostic: return Color(hex: "EBF4FF")   // very pale blue
        case .clinical:   return Color(hex: "DBE9FF")   // pale blue
        case .critical:   return Color(hex: "BFDBFE")   // slightly deeper pale blue
        case .surgical:   return Color(hex: "D1E8FF")   // mid-pale blue
        case .support:    return Color(hex: "F0F7FF")   // near-white blue
    }}
    var border: Color { switch self {
        case .entry:      return Color(hex: "1E4DB7")
        case .services:   return Color(hex: "3B82F6")
        case .diagnostic: return Color(hex: "93C5FD")
        case .clinical:   return Color(hex: "60A5FA")
        case .critical:   return Color(hex: "3B82F6")
        case .surgical:   return Color(hex: "60A5FA")
        case .support:    return Color(hex: "BAD4F5")
    }}
    var textColor: Color { switch self {
        case .entry, .services: return .white
        default:                return Color(hex: "1A3A6E")
    }}
    var icon: String { switch self {
        case .entry:      return "door.right.hand.open"
        case .services:   return "building.2"
        case .diagnostic: return "waveform.path.ecg"
        case .clinical:   return "stethoscope"
        case .critical:   return "heart.text.square"
        case .surgical:   return "scissors"
        case .support:    return "archivebox"
    }}
}

// MARK: - Room (extended with category)
private struct RoomInfo: Identifiable {
    let id = UUID()
    let name: String
    let x: CGFloat; let y: CGFloat
    let width: CGFloat; let height: CGFloat
    var category: RoomCategory = .clinical
    var isEntrance: Bool = false
    var cx: CGFloat { x + width  / 2 }
    var cy: CGFloat { y + height / 2 }
}

// MARK: - Route definition
private struct RouteDefinition {
    let from: String
    let to:   String
    let waypoints: [CGPoint]
    let steps: [String]
}

// MARK: - Floor data
private struct FloorData {
    let floor: Int
    let floorName: String        // human-readable label shown on the floor tab
    let rooms: [RoomInfo]
    let routes: [RouteDefinition]
    let defaultFrom: String
    let defaultTo:   String
}

// ─────────────────────────────────────────────────────────────────────────────
// FLOOR PLAN  —  single central spine layout
//
//  Each floor has ONE wide horizontal corridor (y 0.44 – 0.56, centre y=0.50).
//  Rooms open north (y 0.02–0.42) and south (y 0.58–0.88) off this spine.
//  Door "stub" for every room is at the corridor edge (y=0.44 for north rooms,
//  y=0.56 for south rooms) at the room's centre-x.
//
//  Route formula:
//    Exit room bottom/top → step into corridor (y=0.50) → walk horizontally
//    to destination cx → step out of corridor into destination.
//
//  Canvas is 0–1 normalised.  Rooms span full width with 0.02 margins.
//  North wall: 4 rooms  ×  ~0.23 wide.  South wall: 3–4 rooms  ×  ~0.30 wide.
// ─────────────────────────────────────────────────────────────────────────────

// Corridor centre Y for all floors
private let cY: CGFloat = 0.50

private let floorData: [FloorData] = [

    // ── FLOOR 1  ──  General Outpatient
    // North wall (top, y 0.02–0.42):   Pharmacy | Waiting Area | Consultation 1 | Consultation 2
    // South wall (bottom, y 0.58–0.88): Reception | Laboratory | X-Ray
    // Far left bottom:                  Entrance
    FloorData(
        floor: 1,
        floorName: "Outpatient",
        rooms: [
            // North wall — 4 equal rooms
            RoomInfo(name: "Pharmacy",        x: 0.02, y: 0.02, width: 0.22, height: 0.40, category: .diagnostic),
            RoomInfo(name: "Waiting Area",    x: 0.26, y: 0.02, width: 0.22, height: 0.40, category: .support),
            RoomInfo(name: "Consultation 1",  x: 0.50, y: 0.02, width: 0.22, height: 0.40, category: .clinical),
            RoomInfo(name: "Consultation 2",  x: 0.74, y: 0.02, width: 0.24, height: 0.40, category: .clinical),
            // South wall — 3 rooms + entrance
            RoomInfo(name: "Entrance",        x: 0.02, y: 0.58, width: 0.20, height: 0.30, category: .entry, isEntrance: true),
            RoomInfo(name: "Reception",       x: 0.24, y: 0.58, width: 0.26, height: 0.30, category: .services),
            RoomInfo(name: "Laboratory",      x: 0.52, y: 0.58, width: 0.22, height: 0.30, category: .diagnostic),
            RoomInfo(name: "X-Ray",           x: 0.76, y: 0.58, width: 0.22, height: 0.30, category: .diagnostic),
        ],
        routes: [
            RouteDefinition(from: "Entrance", to: "Reception",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.37, y: 0.50), CGPoint(x: 0.37, y: 0.58)],
                steps: ["Exit the Entrance.", "Step into the main corridor.", "Walk right.", "Reception is on your right."]),
            RouteDefinition(from: "Entrance", to: "Laboratory",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.63, y: 0.50), CGPoint(x: 0.63, y: 0.58)],
                steps: ["Exit the Entrance.", "Step into the main corridor.", "Walk right past Reception.", "Laboratory is ahead on the right."]),
            RouteDefinition(from: "Entrance", to: "X-Ray",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.87, y: 0.50), CGPoint(x: 0.87, y: 0.58)],
                steps: ["Exit the Entrance.", "Step into the main corridor.", "Walk to the far end.", "X-Ray is at the end on the right."]),
            RouteDefinition(from: "Entrance", to: "Pharmacy",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.13, y: 0.50), CGPoint(x: 0.13, y: 0.42)],
                steps: ["Exit the Entrance.", "Step into the main corridor.", "Turn left immediately.", "Pharmacy is directly ahead."]),
            RouteDefinition(from: "Reception", to: "Laboratory",
                waypoints: [CGPoint(x: 0.37, y: 0.58), CGPoint(x: 0.37, y: 0.50), CGPoint(x: 0.63, y: 0.50), CGPoint(x: 0.63, y: 0.58)],
                steps: ["Exit Reception.", "Step into the corridor.", "Walk right.", "Laboratory is ahead."]),
        ],
        defaultFrom: "Entrance",
        defaultTo:   "Laboratory"
    ),

    // ── FLOOR 2  ──  Inpatient / Acute
    FloorData(
        floor: 2,
        floorName: "Inpatient",
        rooms: [
            RoomInfo(name: "ICU",             x: 0.02, y: 0.02, width: 0.30, height: 0.40, category: .critical),
            RoomInfo(name: "Ward A",          x: 0.34, y: 0.02, width: 0.20, height: 0.40, category: .clinical),
            RoomInfo(name: "Ward B",          x: 0.56, y: 0.02, width: 0.20, height: 0.40, category: .clinical),
            RoomInfo(name: "Nurses Station",  x: 0.78, y: 0.02, width: 0.20, height: 0.40, category: .services),
            RoomInfo(name: "Elevator",        x: 0.02, y: 0.58, width: 0.20, height: 0.30, category: .services, isEntrance: true),
            RoomInfo(name: "Pharmacy Store",  x: 0.24, y: 0.58, width: 0.22, height: 0.30, category: .diagnostic),
            RoomInfo(name: "Radiology",       x: 0.48, y: 0.58, width: 0.24, height: 0.30, category: .diagnostic),
            RoomInfo(name: "Cardiology",      x: 0.74, y: 0.58, width: 0.24, height: 0.30, category: .critical),
        ],
        routes: [
            RouteDefinition(from: "Elevator", to: "ICU",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.17, y: 0.50), CGPoint(x: 0.17, y: 0.42)],
                steps: ["Exit the Elevator.", "Enter the corridor.", "Move left.", "ICU is directly across."]),
        ],
        defaultFrom: "Elevator",
        defaultTo:   "ICU"
    ),

    // ── FLOOR 3  ──  Surgical Suite
    FloorData(
        floor: 3,
        floorName: "Surgical",
        rooms: [
            RoomInfo(name: "Op. Theatre 1",  x: 0.02, y: 0.02, width: 0.32, height: 0.40, category: .surgical),
            RoomInfo(name: "Op. Theatre 2",  x: 0.36, y: 0.02, width: 0.32, height: 0.40, category: .surgical),
            RoomInfo(name: "Prep Room",      x: 0.70, y: 0.02, width: 0.28, height: 0.40, category: .clinical),
            RoomInfo(name: "Elevator",       x: 0.02, y: 0.58, width: 0.20, height: 0.30, category: .services, isEntrance: true),
            RoomInfo(name: "Recovery",       x: 0.24, y: 0.58, width: 0.26, height: 0.30, category: .critical),
            RoomInfo(name: "Scrub Room",     x: 0.52, y: 0.58, width: 0.22, height: 0.30, category: .support),
            RoomInfo(name: "Sterilisation",  x: 0.76, y: 0.58, width: 0.22, height: 0.30, category: .support),
        ],
        routes: [
            RouteDefinition(from: "Elevator", to: "Op. Theatre 1",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.18, y: 0.50), CGPoint(x: 0.18, y: 0.42)],
                steps: ["Exit the Elevator.", "Enter the surgical corridor.", "Walk straight ahead.", "Op. Theatre 1 is directly opposite."]),
        ],
        defaultFrom: "Elevator",
        defaultTo:   "Op. Theatre 1"
    ),
]

// MARK: - Routing engine
private func findRoute(floor: FloorData, from: String, to: String) -> RouteDefinition? {
    if from == to { return nil }
    if let r = floor.routes.first(where: { $0.from == from && $0.to == to }) { return r }
    if let r = floor.routes.first(where: { $0.from == to && $0.to == from }) {
        return RouteDefinition(
            from: from, to: to,
            waypoints: r.waypoints.reversed(),
            steps: r.steps.reversed().map { "↩ " + $0 }
        )
    }
    return nil
}

// MARK: - Animated route stroke
private struct AnimatedRoute: View {
    let path: Path
    let color: Color
    @State private var phase: CGFloat = 0
    var body: some View {
        path.stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [7, 5], dashPhase: phase))
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) { phase = -24 }
            }
    }
}

// MARK: - Pulsing start dot
private struct PulsingDot: View {
    let position: CGPoint
    let color: Color
    @State private var pulse = false
    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.20)).frame(width: pulse ? 28 : 14, height: pulse ? 28 : 14)
            Circle().fill(color.opacity(0.45)).frame(width: 14, height: 14)
            Circle().fill(color).frame(width: 8, height: 8)
        }
        .position(position)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}

// MARK: - Room chip (inline autocomplete suggestion)
private struct RoomChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.custom("Inter_18pt-Regular", size: 11))
                .foregroundColor(isSelected ? .white : .primaryBlue)
                .padding(.horizontal, 11).padding(.vertical, 6)
                .background(isSelected ? Color.primaryBlueDark : Color.primaryBlueTint)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.primaryBlue.opacity(0.2), lineWidth: 1))
        }
    }
}

// MARK: - Compact route input bar
/// Collapses to a single tappable row; expands to show From/To text fields + room chips.
private struct RouteInputBar: View {
    @Binding var fromText: String
    @Binding var toText: String
    let allRooms: [String]
    let defaultFrom: String
    let onRouteChange: () -> Void
    let onSwap: () -> Void

    @State private var isExpanded = false
    @FocusState private var focusedField: FieldID?
    enum FieldID { case from, to }

    private var fromFiltered: [String] {
        guard !fromText.isEmpty else { return allRooms }
        return allRooms.filter { $0.localizedCaseInsensitiveContains(fromText) }
    }
    private var toFiltered: [String] {
        guard !toText.isEmpty else { return allRooms }
        return allRooms.filter { $0.localizedCaseInsensitiveContains(toText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Collapsed summary row ──────────────────────────────────────
            Button { withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { isExpanded.toggle() } } label: {
                HStack(spacing: 0) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 13)).foregroundColor(.primaryBlue)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        if fromText.isEmpty && toText.isEmpty {
                            Text("Where do you need to go?")
                                .font(.custom("Inter_18pt-Medium", size: 14))
                                .foregroundColor(.textSecondary)
                        } else {
                            HStack(spacing: 6) {
                                Text(fromText.isEmpty ? "Start" : fromText)
                                    .font(.custom("Inter_18pt-SemiBold", size: 13))
                                    .foregroundColor(fromText.isEmpty ? .textTertiary : .textPrimary)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                Text(toText.isEmpty ? "Destination" : toText)
                                    .font(.custom("Inter_18pt-SemiBold", size: 13))
                                    .foregroundColor(toText.isEmpty ? .textTertiary : Color(hex: "1E7A3A"))
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textTertiary)
                        .padding(.trailing, 14)
                        .animation(.spring(response: 0.3), value: isExpanded)
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            // ── Expanded fields ──────────────────────────────────────────────────────
            if isExpanded {
                VStack(spacing: 0) {
                    Divider().padding(.horizontal, 14)

                    // FROM
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(Color.primaryBlueDark).frame(width: 10, height: 10)
                            Circle().stroke(Color.primaryBlueDark.opacity(0.3), lineWidth: focusedField == .from ? 3 : 0).frame(width: 16, height: 16)
                        }
                        .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("FROM").font(.custom("Inter_18pt-Bold", size: 9)).foregroundColor(.textTertiary).tracking(0.8)
                            TextField("e.g. Entrance, Reception…", text: $fromText)
                                .font(.custom("Inter_18pt-Regular", size: 14))
                                .foregroundColor(.textPrimary)
                                .focused($focusedField, equals: .from)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .to }
                                .onChange(of: fromText) { _, _ in onRouteChange() }
                        }

                        if !fromText.isEmpty {
                            Button { fromText = ""; onRouteChange() } label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.textTertiary).font(.system(size: 16))
                            }
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)

                    // Suggestions for FROM
                    if focusedField == .from && fromFiltered.count > 0 && fromFiltered.count < allRooms.count {
                        suggestionList(rooms: fromFiltered, onSelect: { r in fromText = r; focusedField = .to; onRouteChange() })
                    }

                    // Connector + Swap
                    HStack(spacing: 0) {
                        Rectangle().fill(Color(hex: "D1D5DB")).frame(width: 2, height: 20)
                            .padding(.leading, 25)
                        Spacer()
                        Button(action: onSwap) {
                            HStack(spacing: 5) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Swap").font(.custom("Inter_18pt-SemiBold", size: 11))
                            }
                            .foregroundColor(.primaryBlue)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.primaryBlueTint).cornerRadius(20)
                        }
                        .padding(.trailing, 14)
                    }

                    // TO
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.fill")
                            .font(.system(size: 12)).foregroundColor(Color(hex: "5DB874"))
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("TO").font(.custom("Inter_18pt-Bold", size: 9)).foregroundColor(.textTertiary).tracking(0.8)
                            TextField("e.g. Laboratory, ICU…", text: $toText)
                                .font(.custom("Inter_18pt-Regular", size: 14))
                                .foregroundColor(.textPrimary)
                                .focused($focusedField, equals: .to)
                                .submitLabel(.done)
                                .onSubmit { focusedField = nil; isExpanded = false; onRouteChange() }
                                .onChange(of: toText) { _, _ in onRouteChange() }
                        }

                        if !toText.isEmpty {
                            Button { toText = ""; onRouteChange() } label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.textTertiary).font(.system(size: 16))
                            }
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)

                    // Suggestions for TO
                    if focusedField == .to && toFiltered.count > 0 && toFiltered.count < allRooms.count {
                        suggestionList(rooms: toFiltered, onSelect: { r in toText = r; focusedField = nil; isExpanded = false; onRouteChange() })
                    }

                    // Quick chips for TO
                    if focusedField != .from {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(allRooms, id: \.self) { name in
                                    RoomChip(name: name, isSelected: toText == name) {
                                        toText = name
                                        if fromText.isEmpty { fromText = defaultFrom }
                                        focusedField = nil; isExpanded = false
                                        onRouteChange()
                                    }
                                }
                            }
                            .padding(.horizontal, 14).padding(.bottom, 14)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    @ViewBuilder
    private func suggestionList(rooms: [String], onSelect: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(rooms.prefix(4), id: \.self) { room in
                Button { onSelect(room) } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "mappin").font(.system(size: 11)).foregroundColor(.primaryBlue)
                        Text(room).font(.custom("Inter_18pt-Regular", size: 13)).foregroundColor(.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 14).padding(.vertical, 9)
                }
                if room != rooms.prefix(4).last { Divider().padding(.leading, 38) }
            }
        }
        .background(Color(hex: "F8FAFF"))
        }
}

// MARK: - Direction bottom sheet

private struct DirectionsSheet: View {
    let route: RouteDefinition
    @Binding var activeStep: Int
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule().fill(Color(hex: "D1D5DB")).frame(width: 36, height: 4).padding(.top, 10)

            // Collapsed: progress bar + current step
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.primaryBlueDark).frame(width: 32, height: 32)
                    Text("\(activeStep + 1)").font(.custom("Inter_18pt-Bold", size: 14)).foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(route.steps[activeStep])
                        .font(.custom("Inter_18pt-Medium", size: 13))
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    // Progress pills
                    HStack(spacing: 4) {
                        ForEach(0..<route.steps.count, id: \.self) { i in
                            Capsule()
                                .fill(i == activeStep ? Color.primaryBlueDark : (i < activeStep ? Color.primaryBlue.opacity(0.4) : Color(hex: "E5E7EB")))
                                .frame(width: i == activeStep ? 22 : 8, height: 4)
                                .animation(.spring(response: 0.3), value: activeStep)
                        }
                        Spacer()
                        Text("Step \(activeStep + 1) of \(route.steps.count)")
                            .font(.custom("Inter_18pt-Regular", size: 10))
                            .foregroundColor(.textTertiary)
                    }
                }

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { isExpanded.toggle() }
                } label: {
                    Image(systemName: isExpanded ? "chevron.down" : "list.bullet")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                        .frame(width: 30, height: 30)
                        .background(Color.primaryBlueTint).cornerRadius(8)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)

            // Step controls
            HStack(spacing: 10) {
                Button {
                    if activeStep > 0 { withAnimation(.spring()) { activeStep -= 1 } }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left").font(.system(size: 11, weight: .semibold))
                        Text("Back").font(.custom("Inter_18pt-SemiBold", size: 12))
                    }
                    .foregroundColor(activeStep == 0 ? .textTertiary : .primaryBlue)
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(activeStep == 0 ? Color(hex: "F3F4F6") : Color.primaryBlueTint)
                    .cornerRadius(10)
                }
                .disabled(activeStep == 0)

                Button {
                    if activeStep < route.steps.count - 1 { withAnimation(.spring()) { activeStep += 1 } }
                } label: {
                    HStack(spacing: 6) {
                        Text(activeStep == route.steps.count - 1 ? "Arrived!" : "Next")
                            .font(.custom("Inter_18pt-SemiBold", size: 12))
                        if activeStep < route.steps.count - 1 {
                            Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold))
                        } else {
                            Image(systemName: "checkmark").font(.system(size: 11, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(activeStep == route.steps.count - 1 ? Color(hex: "5DB874") : Color.primaryBlueDark)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 16).padding(.bottom, 12)

            // Expanded full step list
            if isExpanded {
                Divider()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(route.steps.enumerated()), id: \.offset) { i, step in
                            Button {
                                withAnimation(.spring()) { activeStep = i }
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(i == activeStep ? Color.primaryBlueDark : (i < activeStep ? Color.primaryBlue.opacity(0.25) : Color(hex: "F3F4F6")))
                                            .frame(width: 26, height: 26)
                                        if i < activeStep {
                                            Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundColor(.primaryBlue)
                                        } else {
                                            Text("\(i + 1)").font(.custom("Inter_18pt-Bold", size: 10))
                                                .foregroundColor(i == activeStep ? .white : .textTertiary)
                                        }
                                    }
                                    Text(step)
                                        .font(.custom("Inter_18pt-Regular", size: 13))
                                        .foregroundColor(i == activeStep ? .textPrimary : .textSecondary)
                                        .multilineTextAlignment(.leading)
                                        .padding(.top, 4)
                                    Spacer()
                                }
                                .padding(.horizontal, 16).padding(.vertical, 8)
                                .background(i == activeStep ? Color.primaryBlueTint.opacity(0.6) : Color.clear)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .frame(maxHeight: 220)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.10), radius: 20, x: 0, y: -6)
    }
}

// MARK: - Main view
struct ClinicMapView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFloor = 0
    @State private var navTab: TabItem = .home
    @State private var mapScale: CGFloat = 1.0
    @State private var mapOffset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var activeStep: Int = 0

    // Routing
    @State private var fromText = ""
    @State private var toText   = ""
    @State private var activeRoute: RouteDefinition? = nil
    @State private var pickingFor: PickTarget = .none
    @State private var directionsExpanded = false

    enum PickTarget { case from, to, none }

    private var floor: FloorData { floorData[selectedFloor] }
    private var allRoomNames: [String] { floor.rooms.map(\.name) }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "F4F6FA").ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Nav bar ─────────────────────────────────────────────────────────────────
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
                    }
                    Spacer()
                    VStack(spacing: 1) {
                        Text("Clinic Navigation")
                            .font(.custom("Inter_18pt-Bold", size: 17)).foregroundColor(.textPrimary)
                        Text("Floor \(selectedFloor + 1) · \(floor.rooms.count) rooms")
                            .font(.custom("Inter_18pt-Regular", size: 11)).foregroundColor(.textSecondary)
                    }
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(Color.appBackground)

                // ── Scrollable content ─────────────────────────────────────────────────────────────
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {

                        // Route input
                        RouteInputBar(
                            fromText: $fromText,
                            toText: $toText,
                            allRooms: allRoomNames,
                            defaultFrom: floor.defaultFrom,
                            onRouteChange: resolveRoute,
                            onSwap: swapRoute
                        )
                        .padding(.horizontal, 16).padding(.top, 12)

                        // Floor switcher
                        HStack(spacing: 0) {
                            ForEach(0..<floorData.count, id: \.self) { i in
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        selectedFloor = i
                                        mapScale = 1; mapOffset = .zero; lastOffset = .zero
                                        activeStep = 0; directionsExpanded = false
                                        fromText = floorData[i].defaultFrom; toText = floorData[i].defaultTo
                                        pickingFor = .none
                                    }
                                    resolveRoute()
                                } label: {
                                    VStack(spacing: 2) {
                                        Text("FLOOR").font(.custom("Inter_18pt-Regular", size: 9)).tracking(0.5)
                                            .foregroundColor(selectedFloor == i ? .white : .textTertiary)
                                        Text("\(i + 1)").font(.custom("Inter_18pt-Bold", size: 20))
                                            .foregroundColor(selectedFloor == i ? .white : .textPrimary)
                                        Text(floorData[i].floorName).font(.custom("Inter_18pt-Regular", size: 8)).tracking(0.3)
                                            .foregroundColor(selectedFloor == i ? .white.opacity(0.8) : .textTertiary)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 8)
                                    .background(selectedFloor == i
                                        ? AnyView(Color.primaryBlueDark.cornerRadius(10))
                                        : AnyView(Color.clear))
                                }
                            }
                        }
                        .padding(4)
                        .background(Color.white).cornerRadius(14)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 16).padding(.top, 12)

                        // ── Map — fixed height so the scroll works properly ─
                        ZStack {
                            RoundedRectangle(cornerRadius: 20).fill(Color.appBackground)
                            RoundedRectangle(cornerRadius: 20).stroke(Color.primaryBlueDark.opacity(0.25), lineWidth: 1.5)

                            // Zoomable map content
                            GeometryReader { geo in
                                let w = geo.size.width - 20; let h = geo.size.height - 20
                                ZStack {
                                    corridorLayer(w: w, h: h)
                                    ForEach(floor.rooms) { room in
                                        roomCell(room: room, w: w, h: h)
                                            .onTapGesture { handleRoomTap(room.name) }
                                    }
                                    if let route = activeRoute {
                                        routeLayer(route: route, w: w, h: h)
                                    }
                                }
                                .padding(10)
                                .scaleEffect(mapScale, anchor: .center)
                                .offset(mapOffset)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .frame(height: 420)
                        .padding(.horizontal, 16).padding(.top, 12)
                        .shadow(color: Color.primaryBlue.opacity(0.10), radius: 16, x: 0, y: 6)

                        // Directions card
                        if let route = activeRoute {
                            DirectionsSheet(route: route, activeStep: $activeStep, isExpanded: $directionsExpanded)
                                .padding(.horizontal, 16).padding(.top, 12)
                        }

                        // Bottom padding
                        Spacer().frame(height: 100)
                    }
                }

                BottomTabBar(selectedTab: $navTab)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            fromText = floor.defaultFrom
            toText   = floor.defaultTo
            resolveRoute()
        }
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
    }

    // MARK: - Room tap
    private func handleRoomTap(_ name: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            toText = name
            if fromText.isEmpty { fromText = floor.defaultFrom }
            resolveRoute()
        }
    }

    // MARK: - Route resolution
    private func resolveRoute() {
        withAnimation(.easeInOut(duration: 0.3)) {
            activeRoute = findRoute(floor: floor, from: fromText, to: toText)
            activeStep  = 0
            if activeRoute != nil { directionsExpanded = false }
        }
    }

    // MARK: - Swap
    private func swapRoute() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            let tmp = fromText; fromText = toText; toText = tmp
            resolveRoute()
        }
    }

    // MARK: - Corridor layer
    @ViewBuilder
    private func corridorLayer(w: CGFloat, h: CGFloat) -> some View {
        Canvas { ctx, _ in
            // Outer building wall
            let wallPath = Path(roundedRect: CGRect(x: 0.01*w, y: 0.01*h, width: 0.98*w, height: 0.98*h), cornerRadius: 10)
            ctx.stroke(wallPath, with: .color(Color(hex: "94A3B8").opacity(0.30)), style: StrokeStyle(lineWidth: 1.5))

            // Central spine corridor
            var spine = Path()
            spine.addRoundedRect(in: CGRect(x: 0.01*w, y: 0.44*h, width: 0.98*w, height: 0.12*h),
                                 cornerSize: CGSize(width: 6, height: 6))
            ctx.fill(spine, with: .color(Color(hex: "DBEAFE").opacity(0.55)))
            ctx.stroke(spine, with: .color(Color(hex: "93C5FD").opacity(0.70)), lineWidth: 1.0)
        }
    }

    // MARK: - Room cell
    private func roomCell(room: RoomInfo, w: CGFloat, h: CGFloat) -> some View {
        let rw = room.width * w;  let rh = room.height * h
        let rx = room.x * w + rw / 2; let ry = room.y * h + rh / 2
        let isFrom  = room.name == fromText
        let isDest  = room.name == toText

        let fillColor: Color  = isFrom ? Color.primaryBlueDark
                              : isDest ? Color(hex: "D4EDD6")
                              : room.category.fill
        let borderColor: Color = isFrom ? Color.primaryBlueDark
                               : isDest  ? Color(hex: "5DB874")
                               : room.category.border

        return ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 9)
                .fill(fillColor)
                .overlay(RoundedRectangle(cornerRadius: 9)
                    .stroke(borderColor, lineWidth: (isFrom || isDest) ? 2 : 1))

            VStack(spacing: 3) {
                Image(systemName: isFrom ? "location.fill"
                               : isDest  ? "mappin.circle.fill"
                               : room.category.icon)
                    .font(.system(size: min(rw, rh) * 0.18, weight: .medium))
                    .foregroundColor(.white)

                Text(room.name)
                    .font(.custom("Inter_18pt-SemiBold", size: min(rw * 0.13, 9)))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 4)
            }
        }
        .frame(width: rw, height: rh).position(x: rx, y: ry)
        .scaleEffect((isFrom || isDest) ? 1.02 : 1.0)
        .animation(.spring(response: 0.2), value: isFrom || isDest)
    }

    // MARK: - Route layer
    @ViewBuilder
    private func routeLayer(route: RouteDefinition, w: CGFloat, h: CGFloat) -> some View {
        let pts = route.waypoints.map { CGPoint(x: $0.x * w, y: $0.y * h) }
        if pts.count < 2 { EmptyView() } else {
            let routePath = Path { p in p.move(to: pts[0]); for pt in pts.dropFirst() { p.addLine(to: pt) } }
            ZStack {
                routePath.stroke(Color.primaryBlueDark.opacity(0.18), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                AnimatedRoute(path: routePath, color: Color.primaryBlueDark)
                PulsingDot(position: pts.first!, color: Color.primaryBlueDark)
            }
        }
    }
}

// MARK: - Clamp helper
private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self { min(max(self, range.lowerBound), range.upperBound) }
}

#Preview {
    NavigationStack { ClinicMapView() }
}
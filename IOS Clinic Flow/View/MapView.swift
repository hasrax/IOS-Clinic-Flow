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
            // Helper: all routes go Entrance → corridor (y=0.50) → dest cx → into room
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
            RouteDefinition(from: "Entrance", to: "Waiting Area",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.37, y: 0.50), CGPoint(x: 0.37, y: 0.42)],
                steps: ["Exit the Entrance.", "Step into the main corridor.", "Walk right.", "Waiting Area is on the left side of the corridor."]),
            RouteDefinition(from: "Entrance", to: "Consultation 1",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.61, y: 0.50), CGPoint(x: 0.61, y: 0.42)],
                steps: ["Exit the Entrance.", "Step into the main corridor.", "Walk right, past the Waiting Area.", "Consultation 1 is on the left side."]),
            RouteDefinition(from: "Entrance", to: "Consultation 2",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.86, y: 0.50), CGPoint(x: 0.86, y: 0.42)],
                steps: ["Exit the Entrance.", "Step into the main corridor.", "Walk to the far end.", "Consultation 2 is on the left side."]),
            RouteDefinition(from: "Reception", to: "Laboratory",
                waypoints: [CGPoint(x: 0.37, y: 0.58), CGPoint(x: 0.37, y: 0.50), CGPoint(x: 0.63, y: 0.50), CGPoint(x: 0.63, y: 0.58)],
                steps: ["Exit Reception.", "Step into the corridor.", "Walk right.", "Laboratory is ahead."]),
            RouteDefinition(from: "Pharmacy", to: "Consultation 1",
                waypoints: [CGPoint(x: 0.13, y: 0.42), CGPoint(x: 0.13, y: 0.50), CGPoint(x: 0.61, y: 0.50), CGPoint(x: 0.61, y: 0.42)],
                steps: ["Exit Pharmacy.", "Step into the corridor.", "Walk right.", "Consultation 1 is across the corridor."]),
        ],
        defaultFrom: "Entrance",
        defaultTo:   "Laboratory"
    ),

    // ── FLOOR 2  ──  Inpatient / Acute
    // North wall: ICU | Ward A | Ward B | Nurses Station
    // South wall: Elevator | Pharmacy Store | Radiology | Cardiology
    FloorData(
        floor: 2,
        floorName: "Inpatient",
        rooms: [
            // North wall
            RoomInfo(name: "ICU",             x: 0.02, y: 0.02, width: 0.30, height: 0.40, category: .critical),
            RoomInfo(name: "Ward A",          x: 0.34, y: 0.02, width: 0.20, height: 0.40, category: .clinical),
            RoomInfo(name: "Ward B",          x: 0.56, y: 0.02, width: 0.20, height: 0.40, category: .clinical),
            RoomInfo(name: "Nurses Station",  x: 0.78, y: 0.02, width: 0.20, height: 0.40, category: .services),
            // South wall
            RoomInfo(name: "Elevator",        x: 0.02, y: 0.58, width: 0.20, height: 0.30, category: .services, isEntrance: true),
            RoomInfo(name: "Pharmacy Store",  x: 0.24, y: 0.58, width: 0.22, height: 0.30, category: .diagnostic),
            RoomInfo(name: "Radiology",       x: 0.48, y: 0.58, width: 0.24, height: 0.30, category: .diagnostic),
            RoomInfo(name: "Cardiology",      x: 0.74, y: 0.58, width: 0.24, height: 0.30, category: .critical),
        ],
        routes: [
            RouteDefinition(from: "Elevator", to: "ICU",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.17, y: 0.50), CGPoint(x: 0.17, y: 0.42)],
                steps: ["Exit the Elevator.", "Enter the corridor.", "Move left.", "ICU is directly across."]),
            RouteDefinition(from: "Elevator", to: "Ward A",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.44, y: 0.50), CGPoint(x: 0.44, y: 0.42)],
                steps: ["Exit the Elevator.", "Enter the corridor.", "Walk right.", "Ward A is on the left side."]),
            RouteDefinition(from: "Elevator", to: "Ward B",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.66, y: 0.50), CGPoint(x: 0.66, y: 0.42)],
                steps: ["Exit the Elevator.", "Enter the corridor.", "Walk right past Ward A.", "Ward B is on the left side."]),
            RouteDefinition(from: "Elevator", to: "Nurses Station",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.88, y: 0.50), CGPoint(x: 0.88, y: 0.42)],
                steps: ["Exit the Elevator.", "Enter the corridor.", "Walk to the far end.", "Nurses Station is on the left."]),
            RouteDefinition(from: "Elevator", to: "Pharmacy Store",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.35, y: 0.50), CGPoint(x: 0.35, y: 0.58)],
                steps: ["Exit the Elevator.", "Enter the corridor.", "Walk right.", "Pharmacy Store is on your right."]),
            RouteDefinition(from: "Elevator", to: "Radiology",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.60, y: 0.50), CGPoint(x: 0.60, y: 0.58)],
                steps: ["Exit the Elevator.", "Enter the corridor.", "Walk right.", "Radiology is on your right."]),
            RouteDefinition(from: "Elevator", to: "Cardiology",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.86, y: 0.50), CGPoint(x: 0.86, y: 0.58)],
                steps: ["Exit the Elevator.", "Enter the corridor.", "Walk to the far end.", "Cardiology is on the right."]),
            RouteDefinition(from: "ICU", to: "Nurses Station",
                waypoints: [CGPoint(x: 0.17, y: 0.42), CGPoint(x: 0.17, y: 0.50), CGPoint(x: 0.88, y: 0.50), CGPoint(x: 0.88, y: 0.42)],
                steps: ["Exit the ICU.", "Enter the corridor.", "Walk right to the end.", "Nurses Station is ahead."]),
            RouteDefinition(from: "Radiology", to: "ICU",
                waypoints: [CGPoint(x: 0.60, y: 0.58), CGPoint(x: 0.60, y: 0.50), CGPoint(x: 0.17, y: 0.50), CGPoint(x: 0.17, y: 0.42)],
                steps: ["Exit Radiology.", "Enter the corridor.", "Walk left.", "ICU is on the left side."]),
        ],
        defaultFrom: "Elevator",
        defaultTo:   "ICU"
    ),

    // ── FLOOR 3  ──  Surgical Suite
    // North wall: Op. Theatre 1 | Op. Theatre 2 | Prep Room
    // South wall: Elevator | Recovery | Scrub Room | Sterilisation
    FloorData(
        floor: 3,
        floorName: "Surgical",
        rooms: [
            // North wall — theatres
            RoomInfo(name: "Op. Theatre 1",  x: 0.02, y: 0.02, width: 0.32, height: 0.40, category: .surgical),
            RoomInfo(name: "Op. Theatre 2",  x: 0.36, y: 0.02, width: 0.32, height: 0.40, category: .surgical),
            RoomInfo(name: "Prep Room",      x: 0.70, y: 0.02, width: 0.28, height: 0.40, category: .clinical),
            // South wall — support
            RoomInfo(name: "Elevator",       x: 0.02, y: 0.58, width: 0.20, height: 0.30, category: .services, isEntrance: true),
            RoomInfo(name: "Recovery",       x: 0.24, y: 0.58, width: 0.26, height: 0.30, category: .critical),
            RoomInfo(name: "Scrub Room",     x: 0.52, y: 0.58, width: 0.22, height: 0.30, category: .support),
            RoomInfo(name: "Sterilisation",  x: 0.76, y: 0.58, width: 0.22, height: 0.30, category: .support),
        ],
        routes: [
            RouteDefinition(from: "Elevator", to: "Op. Theatre 1",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.18, y: 0.50), CGPoint(x: 0.18, y: 0.42)],
                steps: ["Exit the Elevator.", "Enter the surgical corridor.", "Walk straight ahead.", "Op. Theatre 1 is directly opposite."]),
            RouteDefinition(from: "Elevator", to: "Op. Theatre 2",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.52, y: 0.50), CGPoint(x: 0.52, y: 0.42)],
                steps: ["Exit the Elevator.", "Enter the surgical corridor.", "Walk right.", "Op. Theatre 2 is on the left side."]),
            RouteDefinition(from: "Elevator", to: "Prep Room",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.84, y: 0.50), CGPoint(x: 0.84, y: 0.42)],
                steps: ["Exit the Elevator.", "Enter the surgical corridor.", "Walk to the far end.", "Prep Room is on the left."]),
            RouteDefinition(from: "Elevator", to: "Recovery",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.37, y: 0.50), CGPoint(x: 0.37, y: 0.58)],
                steps: ["Exit the Elevator.", "Enter the corridor.", "Walk right.", "Recovery is on your right."]),
            RouteDefinition(from: "Elevator", to: "Scrub Room",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.63, y: 0.50), CGPoint(x: 0.63, y: 0.58)],
                steps: ["Exit the Elevator.", "Enter the corridor.", "Walk right past Recovery.", "Scrub Room is on the right."]),
            RouteDefinition(from: "Elevator", to: "Sterilisation",
                waypoints: [CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.12, y: 0.50), CGPoint(x: 0.87, y: 0.50), CGPoint(x: 0.87, y: 0.58)],
                steps: ["Exit the Elevator.", "Enter the corridor.", "Walk to the far end.", "Sterilisation is at the end right."]),
            RouteDefinition(from: "Recovery", to: "Op. Theatre 1",
                waypoints: [CGPoint(x: 0.37, y: 0.58), CGPoint(x: 0.37, y: 0.50), CGPoint(x: 0.18, y: 0.50), CGPoint(x: 0.18, y: 0.42)],
                steps: ["Exit Recovery.", "Enter the corridor.", "Walk left.", "Op. Theatre 1 is opposite."]),
            RouteDefinition(from: "Scrub Room", to: "Op. Theatre 2",
                waypoints: [CGPoint(x: 0.63, y: 0.58), CGPoint(x: 0.63, y: 0.50), CGPoint(x: 0.52, y: 0.50), CGPoint(x: 0.52, y: 0.42)],
                steps: ["Exit Scrub Room.", "Enter the corridor.", "Move left.", "Op. Theatre 2 is directly opposite."]),
            RouteDefinition(from: "Op. Theatre 1", to: "Op. Theatre 2",
                waypoints: [CGPoint(x: 0.18, y: 0.42), CGPoint(x: 0.18, y: 0.50), CGPoint(x: 0.52, y: 0.50), CGPoint(x: 0.52, y: 0.42)],
                steps: ["Exit Op. Theatre 1.", "Enter the corridor.", "Walk right.", "Op. Theatre 2 is ahead."]),
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

            // ── Expanded fields ────────────────────────────────────────────
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
/// A compact bottom sheet that slides up over the map showing the current step + progress.
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

// RoundedCorner shape + cornerRadius(_:corners:) extension
// are declared in your shared extensions file — no redeclaration needed here.

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
                // ── Nav bar ────────────────────────────────────────────────
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

                // ── Scrollable content ─────────────────────────────────────
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

                            // Subtle dot grid
                            Canvas { ctx, size in
                                let spacing: CGFloat = size.width / 14
                                var p = Path()
                                var cx: CGFloat = spacing
                                while cx < size.width {
                                    var cy: CGFloat = spacing
                                    while cy < size.height {
                                        p.addEllipse(in: CGRect(x: cx - 1, y: cy - 1, width: 2, height: 2))
                                        cy += spacing
                                    }
                                    cx += spacing
                                }
                                ctx.fill(p, with: .color(Color.primaryBlue.opacity(0.07)))
                            }.cornerRadius(20)

                            // Watermark
                            Text("FLOOR \(selectedFloor + 1)")
                                .font(.custom("Inter_18pt-Bold", size: 52))
                                .foregroundColor(Color.primaryBlue.opacity(0.04))
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                            // North indicator
                            VStack(spacing: 2) {
                                Image(systemName: "arrow.up").font(.system(size: 9, weight: .bold))
                                Text("N").font(.custom("Inter_18pt-Bold", size: 8))
                            }
                            .foregroundColor(Color.primaryBlueDark.opacity(0.4))
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

                            // Tap mode banner
                            if pickingFor != .none {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(pickingFor == .from ? Color.primaryBlueDark : Color(hex: "5DB874"))
                                        .frame(width: 8, height: 8)
                                    Text(pickingFor == .from ? "Tap a room to set as Start" : "Tap a room to set as Destination")
                                        .font(.custom("Inter_18pt-SemiBold", size: 12))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Button {
                                        withAnimation(.spring()) { pickingFor = .none }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(5)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(6)
                                    }
                                }
                                .padding(.horizontal, 14).padding(.vertical, 9)
                                .background(pickingFor == .from ? Color.primaryBlueDark.opacity(0.90) : Color(hex: "5DB874").opacity(0.92))
                                .cornerRadius(14)
                                .padding(.top, 12)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                .zIndex(5)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // Corner legend badge
                            VStack(alignment: .leading, spacing: 5) {
                                legendBadgeRow(color: Color.primaryBlueDark, border: .clear, label: "Start / Entrance")
                                legendBadgeRow(color: Color(hex: "DBE9FF"), border: Color(hex: "60A5FA"), label: "Room")
                                legendBadgeRow(color: Color(hex: "BFDBFE"), border: Color(hex: "3B82F6"), label: "Critical / ICU")
                            }
                            .padding(8)
                            .background(Color.appBackground.opacity(0.95))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primaryBlueDark.opacity(0.15), lineWidth: 1))
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            .zIndex(4)

                            // Zoom hint
                            HStack(spacing: 4) {
                                Image(systemName: "hand.pinch").font(.system(size: 9))
                                Text("Pinch  •  2× reset").font(.custom("Inter_18pt-Regular", size: 9))
                            }
                            .foregroundColor(Color.primaryBlueDark.opacity(0.35))
                            .padding(8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .zIndex(4)

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
                                .gesture(
                                    SimultaneousGesture(
                                        MagnificationGesture().onChanged { v in
                                            let s = max(1.0, min(3.5, v))
                                            mapScale = s
                                            let eW = max(0, geo.size.width * (s - 1)) / 2
                                            let eH = max(0, geo.size.height * (s - 1)) / 2
                                            mapOffset = CGSize(
                                                width: mapOffset.width.clamped(to: -eW...eW),
                                                height: mapOffset.height.clamped(to: -eH...eH))
                                            lastOffset = mapOffset
                                        },
                                        DragGesture(minimumDistance: 1)
                                            .onChanged { v in
                                                let proposed = CGSize(
                                                    width: lastOffset.width + v.translation.width,
                                                    height: lastOffset.height + v.translation.height)
                                                let eW = max(0, geo.size.width * (mapScale - 1)) / 2
                                                let eH = max(0, geo.size.height * (mapScale - 1)) / 2
                                                mapOffset = CGSize(
                                                    width: proposed.width.clamped(to: -eW...eW),
                                                    height: proposed.height.clamped(to: -eH...eH))
                                            }
                                            .onEnded { _ in lastOffset = mapOffset }
                                    )
                                )
                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedFloor)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        // Fixed map height — tall enough to read clearly, short enough to scroll past
                        .frame(height: 420)
                        .padding(.horizontal, 16).padding(.top, 12)
                        .shadow(color: Color.primaryBlue.opacity(0.10), radius: 16, x: 0, y: 6)
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) { mapScale = 1; mapOffset = .zero; lastOffset = .zero }
                        }

                        // Directions card (inline when sheet is dismissed)
                        if let route = activeRoute {
                            DirectionsSheet(route: route, activeStep: $activeStep, isExpanded: $directionsExpanded)
                                .padding(.horizontal, 16).padding(.top, 12)
                        }

                        // Bottom padding to clear the tab bar
                        Spacer().frame(height: 100)
                    }
                }
                // Disable vertical scroll bounce inside the map gesture area
                // (ScrollView handles the outer scroll; inner gestures handle pan/zoom)

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
        if pickingFor == .none {
            // Double-tap-like shortcut: set as destination
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                toText = name
                if fromText.isEmpty { fromText = floor.defaultFrom }
                resolveRoute()
            }
            return
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if pickingFor == .from { fromText = name; pickingFor = .to }
            else { toText = name; pickingFor = .none }
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

    // MARK: - Corridor layer — single central spine
    @ViewBuilder
    private func corridorLayer(w: CGFloat, h: CGFloat) -> some View {
        Canvas { ctx, _ in
            // Outer building wall
            let wallPath = Path(roundedRect: CGRect(x: 0.01*w, y: 0.01*h, width: 0.98*w, height: 0.98*h), cornerRadius: 10)
            ctx.stroke(wallPath, with: .color(Color(hex: "94A3B8").opacity(0.30)), style: StrokeStyle(lineWidth: 1.5))

            // Central spine corridor y 0.44–0.56
            var spine = Path()
            spine.addRoundedRect(in: CGRect(x: 0.01*w, y: 0.44*h, width: 0.98*w, height: 0.12*h),
                                 cornerSize: CGSize(width: 6, height: 6))
            ctx.fill(spine, with: .color(Color(hex: "DBEAFE").opacity(0.55)))
            ctx.stroke(spine, with: .color(Color(hex: "93C5FD").opacity(0.70)), lineWidth: 1.0)

            // Centre-line dashes
            var dash = Path()
            let dashY = 0.50 * h
            var dxPos: CGFloat = 0.06 * w
            while dxPos < 0.96 * w {
                dash.move(to: CGPoint(x: dxPos, y: dashY))
                dash.addLine(to: CGPoint(x: min(dxPos + 0.04*w, 0.96*w), y: dashY))
                dxPos += 0.07 * w
            }
            ctx.stroke(dash, with: .color(Color(hex: "BFDBFE").opacity(0.65)),
                       style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [4, 6]))

            // Door stubs — tick mark from each room to the corridor
            for room in floor.rooms {
                let doorX = (room.x + room.width / 2) * w
                let isNorth = room.cy < 0.50
                let doorY1: CGFloat = isNorth ? 0.44 * h : 0.56 * h
                let doorY2: CGFloat = isNorth ? 0.41 * h : 0.59 * h
                var stub = Path()
                stub.move(to: CGPoint(x: doorX, y: doorY1))
                stub.addLine(to: CGPoint(x: doorX, y: doorY2))
                ctx.stroke(stub, with: .color(Color(hex: "93C5FD").opacity(0.45)),
                           style: StrokeStyle(lineWidth: 2, lineCap: .round))
            }
        }
    }

    // MARK: - Room cell — category-coloured with icon
    private func roomCell(room: RoomInfo, w: CGFloat, h: CGFloat) -> some View {
        let rw = room.width * w;  let rh = room.height * h
        let rx = room.x * w + rw / 2; let ry = room.y * h + rh / 2
        let isFrom  = room.name == fromText
        let isDest  = room.name == toText
        let dimmed  = pickingFor != .none && !isFrom && !isDest

        // State overrides category colours when selected
        let fillColor: Color  = isFrom ? Color.primaryBlueDark
                              : isDest ? Color(hex: "D4EDD6")
                              : room.category.fill
        let borderColor: Color = isFrom ? Color.primaryBlueDark
                               : isDest  ? Color(hex: "5DB874")
                               : room.category.border
        let textColor: Color   = isFrom ? .white
                               : isDest  ? Color(hex: "1E5631")
                               : room.category.textColor
        let iconColor: Color   = isFrom ? .white.opacity(0.7)
                               : isDest  ? Color(hex: "2E7D32").opacity(0.6)
                               : room.category.border.opacity(0.55)

        return ZStack(alignment: .center) {
            // Background
            RoundedRectangle(cornerRadius: 9)
                .fill(fillColor)
                .overlay(RoundedRectangle(cornerRadius: 9)
                    .stroke(borderColor, lineWidth: (isFrom || isDest) ? 2 : 1))
                .overlay(dimmed
                    ? RoundedRectangle(cornerRadius: 9).fill(Color.black.opacity(0.15))
                    : nil)

            // Content: icon above name
            VStack(spacing: 3) {
                Image(systemName: isFrom ? "location.fill"
                               : isDest  ? "mappin.circle.fill"
                               : room.category.icon)
                    .font(.system(size: min(rw, rh) * 0.18, weight: .medium))
                    .foregroundColor(iconColor)

                Text(room.name)
                    .font(.custom("Inter_18pt-SemiBold", size: min(rw * 0.13, 9)))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 4)
            }

            // Destination / start dot
            if isDest {
                Circle().fill(Color(hex: "5DB874")).frame(width: 7, height: 7)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(5)
            }
            if isFrom && !room.isEntrance {
                Circle().fill(Color.white.opacity(0.75)).frame(width: 7, height: 7)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(5)
            }
        }
        .frame(width: rw, height: rh).position(x: rx, y: ry)
        .shadow(color: borderColor.opacity(isFrom || isDest ? 0.30 : 0.12), radius: isFrom || isDest ? 6 : 3, x: 0, y: 2)
        .scaleEffect((isFrom || isDest) ? 1.02 : 1.0)
        .animation(.spring(response: 0.2), value: isFrom || isDest)
    }

    // MARK: - Route layer (identical to original)
    @ViewBuilder
    private func routeLayer(route: RouteDefinition, w: CGFloat, h: CGFloat) -> some View {
        let pts = route.waypoints.map { CGPoint(x: $0.x * w, y: $0.y * h) }
        if pts.count < 2 { EmptyView() } else {
            let start = pts.first!; let end = pts.last!
            let routePath = Path { p in p.move(to: pts[0]); for pt in pts.dropFirst() { p.addLine(to: pt) } }
            let prev = pts[pts.count - 2]
            let dx = end.x - prev.x; let dy = end.y - prev.y
            let len = max(sqrt(dx*dx + dy*dy), 0.001)
            let ux = dx / len; let uy = dy / len

            ZStack {
                routePath.stroke(Color.primaryBlueDark.opacity(0.18), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                AnimatedRoute(path: routePath, color: Color.primaryBlueDark)
                Path { p in
                    let tip  = CGPoint(x: end.x - ux * 2, y: end.y - uy * 2)
                    let perp = CGPoint(x: -uy, y: ux)
                    p.move(to: CGPoint(x: tip.x + ux * 11, y: tip.y + uy * 11))
                    p.addLine(to: CGPoint(x: tip.x - perp.x * 5.5, y: tip.y - perp.y * 5.5))
                    p.addLine(to: CGPoint(x: tip.x + perp.x * 5.5, y: tip.y + perp.y * 5.5))
                    p.closeSubpath()
                }.fill(Color.primaryBlueDark)
                PulsingDot(position: start, color: Color.primaryBlueDark)
            }
        }
    }

    // MARK: - Legend badge row
    private func legendBadgeRow(color: Color, border: Color, label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 3).fill(color)
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(border, lineWidth: 1))
                .frame(width: 12, height: 12)
            Text(label).font(.custom("Inter_18pt-Regular", size: 9)).foregroundColor(.textSecondary)
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

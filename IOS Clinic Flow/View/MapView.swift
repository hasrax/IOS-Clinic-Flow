//
//  MapView.swift  — UX Redesign v2
//  IOS Clinic Flow
//

import SwiftUI

// Additional colors for map visualization
extension Color {
    static let destGreen       = Color.successGreen
    static let destGreenLight  = Color.successTint
    static let mapBackground   = Color(hex: "F8FAFF")
    static let mapDark         = Color(hex: "D1D5DB")
    static let mapLight        = Color(hex: "E5E7EB")
    static let mapLighter      = Color(hex: "F3F4F6")
    static let corridorLight   = Color(hex: "DBEAFE")
    static let corridorStripe  = Color(hex: "93C5FD")
    static let warningBg       = Color(hex: "FFFBEB")
    static let warningText     = Color(hex: "F59E0B")
    static let mapGreen        = Color(hex: "1A5C2A")
}

// MARK: - Room category
private enum RoomCategory {
    case entry, services, diagnostic, clinical, critical, surgical, support
    var fill: Color { switch self {
        case .entry:      return .primaryBlueDark
        case .services:   return .primaryBlue
        case .diagnostic: return .primaryBlueTint
        case .clinical:   return .primaryBlueTint
        case .critical:   return .primaryBlueTint
        case .surgical:   return .primaryBlueTint
        case .support:    return .primaryBlueTint
    }}
    var border: Color { switch self {
        case .entry:      return .primaryBlueDark
        case .services:   return .primaryBlue
        case .diagnostic: return .accentBlue
        case .clinical:   return .accentBlue
        case .critical:   return .primaryBlue
        case .surgical:   return .accentBlue
        case .support:    return .accentBlue
    }}
    var textColor: Color { switch self {
        case .entry, .services: return .white
        default:                return .textPrimary
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

// MARK: - Room model
private struct RoomInfo: Identifiable {
    let id = UUID()
    let name: String
    let x: CGFloat; let y: CGFloat
    let width: CGFloat; let height: CGFloat
    var category: RoomCategory = .clinical
    var isEntrance: Bool = false
    var cx: CGFloat { x + width  / 2 }
    var cy: CGFloat { y + height / 2 }
    func doorY(corridorY: CGFloat = 0.50) -> CGFloat {
        return cy < corridorY ? (y + height) : y
    }
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
    let floorName: String
    let rooms: [RoomInfo]
    let manualRoutes: [RouteDefinition]
    let defaultFrom: String
    let defaultTo:   String
    let mapAssetName: String?
}

// MARK: - Dynamic routing engine
private let corridorCY: CGFloat = 0.50

private func dynamicRoute(from fromRoom: RoomInfo, to toRoom: RoomInfo) -> RouteDefinition {
    let fromDoorX = fromRoom.cx
    let fromDoorY = fromRoom.doorY(corridorY: corridorCY)
    let toDoorX   = toRoom.cx
    let toDoorY   = toRoom.doorY(corridorY: corridorCY)

    let waypoints: [CGPoint] = [
        CGPoint(x: fromRoom.cx, y: fromRoom.cy),
        CGPoint(x: fromDoorX,   y: fromDoorY),
        CGPoint(x: fromDoorX,   y: corridorCY),
        CGPoint(x: toDoorX,     y: corridorCY),
        CGPoint(x: toDoorX,     y: toDoorY),
        CGPoint(x: toRoom.cx,   y: toRoom.cy),
    ]

    let direction: String = {
        if abs(fromRoom.cx - toRoom.cx) < 0.05 { return "straight ahead" }
        return fromRoom.cx < toRoom.cx ? "right" : "left"
    }()

    let steps: [String] = [
        "Exit \(fromRoom.name).",
        "Step into the main corridor.",
        "Walk \(direction) along the corridor.",
        "\(toRoom.name) is on your \(toRoom.cy < corridorCY ? "left" : "right").",
    ]
    return RouteDefinition(from: fromRoom.name, to: toRoom.name, waypoints: waypoints, steps: steps)
}

private func findRoute(floor: FloorData, from: String, to: String) -> RouteDefinition? {
    guard from != to, !from.isEmpty, !to.isEmpty else { return nil }
    let allRooms = floor.rooms
    guard let fromRoom = allRooms.first(where: { $0.name == from }),
          let toRoom   = allRooms.first(where: { $0.name == to   }) else { return nil }
    if let manual = floor.manualRoutes.first(where: { $0.from == from && $0.to == to }) { return manual }
    if let manual = floor.manualRoutes.first(where: { $0.from == to && $0.to == from }) {
        return RouteDefinition(from: from, to: to,
            waypoints: manual.waypoints.reversed(),
            steps: manual.steps.reversed().map { "↩ " + $0 })
    }
    return dynamicRoute(from: fromRoom, to: toRoom)
}

// MARK: - Floor definitions
private let floorData: [FloorData] = [
    FloorData(
        floor: 1, floorName: "Outpatient",
        rooms: [
            RoomInfo(name: "Pharmacy",       x: 0.02, y: 0.02, width: 0.22, height: 0.40, category: .diagnostic),
            RoomInfo(name: "Waiting Area",   x: 0.26, y: 0.02, width: 0.22, height: 0.40, category: .support),
            RoomInfo(name: "Consultation 1", x: 0.50, y: 0.02, width: 0.22, height: 0.40, category: .clinical),
            RoomInfo(name: "Consultation 2", x: 0.74, y: 0.02, width: 0.24, height: 0.40, category: .clinical),
            RoomInfo(name: "Entrance",       x: 0.02, y: 0.58, width: 0.20, height: 0.30, category: .entry, isEntrance: true),
            RoomInfo(name: "Reception",      x: 0.24, y: 0.58, width: 0.26, height: 0.30, category: .services),
            RoomInfo(name: "Laboratory",     x: 0.52, y: 0.58, width: 0.22, height: 0.30, category: .diagnostic),
            RoomInfo(name: "X-Ray",          x: 0.76, y: 0.58, width: 0.22, height: 0.30, category: .diagnostic),
        ],
        manualRoutes: [],
        defaultFrom: "Entrance", defaultTo: "Laboratory",
        mapAssetName: "map"
    ),
    FloorData(
        floor: 2, floorName: "Inpatient",
        rooms: [
            RoomInfo(name: "ICU",            x: 0.02, y: 0.02, width: 0.30, height: 0.40, category: .critical),
            RoomInfo(name: "Ward A",         x: 0.34, y: 0.02, width: 0.20, height: 0.40, category: .clinical),
            RoomInfo(name: "Ward B",         x: 0.56, y: 0.02, width: 0.20, height: 0.40, category: .clinical),
            RoomInfo(name: "Nurses Station", x: 0.78, y: 0.02, width: 0.20, height: 0.40, category: .services),
            RoomInfo(name: "Elevator",       x: 0.02, y: 0.58, width: 0.20, height: 0.30, category: .services, isEntrance: true),
            RoomInfo(name: "Pharmacy Store", x: 0.24, y: 0.58, width: 0.22, height: 0.30, category: .diagnostic),
            RoomInfo(name: "Radiology",      x: 0.48, y: 0.58, width: 0.24, height: 0.30, category: .diagnostic),
            RoomInfo(name: "Cardiology",     x: 0.74, y: 0.58, width: 0.24, height: 0.30, category: .critical),
        ],
        manualRoutes: [],
        defaultFrom: "Elevator", defaultTo: "ICU",
        mapAssetName: nil
    ),
    FloorData(
        floor: 3, floorName: "Surgical",
        rooms: [
            RoomInfo(name: "Op. Theatre 1", x: 0.02, y: 0.02, width: 0.32, height: 0.40, category: .surgical),
            RoomInfo(name: "Op. Theatre 2", x: 0.36, y: 0.02, width: 0.32, height: 0.40, category: .surgical),
            RoomInfo(name: "Prep Room",     x: 0.70, y: 0.02, width: 0.28, height: 0.40, category: .clinical),
            RoomInfo(name: "Elevator",      x: 0.02, y: 0.58, width: 0.20, height: 0.30, category: .services, isEntrance: true),
            RoomInfo(name: "Recovery",      x: 0.24, y: 0.58, width: 0.26, height: 0.30, category: .critical),
            RoomInfo(name: "Scrub Room",    x: 0.52, y: 0.58, width: 0.22, height: 0.30, category: .support),
            RoomInfo(name: "Sterilisation", x: 0.76, y: 0.58, width: 0.22, height: 0.30, category: .support),
        ],
        manualRoutes: [],
        defaultFrom: "Elevator", defaultTo: "Op. Theatre 1",
        mapAssetName: nil
    ),
]

// MARK: - Animated route stroke
private struct AnimatedRoute: View {
    let path: Path; let color: Color
    @State private var phase: CGFloat = 0
    var body: some View {
        path.stroke(color, style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round, dash: [8, 5], dashPhase: phase))
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) { phase = -26 }
            }
    }
}

// MARK: - Pulsing dot
private struct PulsingDot: View {
    let position: CGPoint; let color: Color
    @State private var pulse = false
    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.20)).frame(width: pulse ? 30 : 14, height: pulse ? 30 : 14)
            Circle().fill(color.opacity(0.45)).frame(width: 14, height: 14)
            Circle().fill(color).frame(width: 9, height: 9)
        }
        .position(position)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}

// MARK: - Destination pin
private struct DestinationPin: View {
    let position: CGPoint; let color: Color
    var body: some View {
        Image(systemName: "mappin.circle.fill")
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(color)
            .shadow(color: color.opacity(0.35), radius: 4, x: 0, y: 2)
            .position(CGPoint(x: position.x, y: position.y - 11))
    }
}

// MARK: - Route Input Bar
private struct RouteInputBar: View {
    @Binding var fromText: String
    @Binding var toText:   String
    let allRooms: [String]
    let defaultFrom: String
    let onRouteChange: () -> Void
    let onSwap: () -> Void

    @FocusState private var focused: FieldID?
    enum FieldID { case from, to }

    private var fromSuggestions: [String] {
        guard focused == .from, !fromText.isEmpty else { return [] }
        return allRooms.filter { $0.localizedCaseInsensitiveContains(fromText) && $0 != fromText }
    }
    private var toSuggestions: [String] {
        guard focused == .to, !toText.isEmpty else { return [] }
        return allRooms.filter { $0.localizedCaseInsensitiveContains(toText) && $0 != toText }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                // FROM field
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.primaryBlueDark)
                        .frame(width: 9, height: 9)
                    TextField("From", text: $fromText)
                        .font(.custom("Inter_18pt-Regular", size: 13))
                        .foregroundColor(.textPrimary)
                        .focused($focused, equals: .from)
                        .submitLabel(.next)
                        .onSubmit { focused = .to }
                        .onChange(of: fromText) { _, _ in onRouteChange() }
                    if !fromText.isEmpty {
                        Button { fromText = ""; onRouteChange() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.textTertiary)
                        }
                    }
                }
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(Color.mapBackground)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(focused == .from ? Color.primaryBlue : Color.clear, lineWidth: 1.5))
                .frame(maxWidth: .infinity)

                // Swap button
                Button(action: onSwap) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primaryBlue)
                        .frame(width: 32, height: 32)
                        .background(Color.primaryBlueTint)
                        .cornerRadius(10)
                }

                // TO field
                HStack(spacing: 8) {
                    Image(systemName: "mappin.fill")
                        .font(.system(size: 9))
                        .foregroundColor(Color.destGreen)
                    TextField("To", text: $toText)
                        .font(.custom("Inter_18pt-Regular", size: 13))
                        .foregroundColor(.textPrimary)
                        .focused($focused, equals: .to)
                        .submitLabel(.done)
                        .onSubmit { focused = nil; onRouteChange() }
                        .onChange(of: toText) { _, _ in onRouteChange() }
                    if !toText.isEmpty {
                        Button { toText = ""; onRouteChange() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.textTertiary)
                        }
                    }
                }
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(Color.mapBackground)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(focused == .to ? Color.destGreen : Color.clear, lineWidth: 1.5))
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 14).padding(.vertical, 12)

            if !fromSuggestions.isEmpty {
                suggestionList(rooms: fromSuggestions) { r in
                    fromText = r; focused = .to; onRouteChange()
                }
            }

            if !toSuggestions.isEmpty {
                suggestionList(rooms: toSuggestions) { r in
                    toText = r; focused = nil; onRouteChange()
                }
            }

            if focused != .from && toText.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(allRooms, id: \.self) { name in
                            if name != fromText {
                                Button {
                                    toText = name
                                    if fromText.isEmpty { fromText = defaultFrom }
                                    focused = nil; onRouteChange()
                                } label: {
                                    Text(name)
                                        .font(.custom("Inter_18pt-Regular", size: 11))
                                        .foregroundColor(.primaryBlue)
                                        .padding(.horizontal, 11).padding(.vertical, 6)
                                        .background(Color.primaryBlueTint)
                                        .cornerRadius(20)
                                        .overlay(RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.primaryBlue.opacity(0.2), lineWidth: 1))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 14).padding(.bottom, 10)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
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
        .background(Color.mapBackground)
    }
}

// MARK: - Directions bottom card
private struct DirectionsCard: View {
    let route: RouteDefinition
    @Binding var activeStep: Int
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.mapDark)
                .frame(width: 36, height: 4)
                .padding(.top, 10)

            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.primaryBlueDark).frame(width: 34, height: 34)
                    Text("\(activeStep + 1)")
                        .font(.custom("Inter_18pt-Bold", size: 15))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(route.steps[activeStep])
                        .font(.custom("Inter_18pt-Medium", size: 13))
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 4) {
                        ForEach(0..<route.steps.count, id: \.self) { i in
                            Capsule()
                                .fill(i == activeStep
                                    ? Color.primaryBlueDark
                                    : (i < activeStep ? Color.primaryBlue.opacity(0.4) : Color.mapLight))
                                .frame(width: i == activeStep ? 22 : 8, height: 4)
                                .animation(.spring(response: 0.3), value: activeStep)
                        }
                        Spacer()
                        Text("\(activeStep + 1) / \(route.steps.count)")
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
                        .background(Color.primaryBlueTint)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)

            HStack(spacing: 10) {
                Button {
                    if activeStep > 0 { withAnimation(.spring()) { activeStep -= 1 } }
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(.custom("Inter_18pt-SemiBold", size: 12))
                        .foregroundColor(activeStep == 0 ? .textTertiary : .primaryBlue)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(activeStep == 0 ? Color.mapLighter : Color.primaryBlueTint)
                        .cornerRadius(10)
                }
                .disabled(activeStep == 0)

                Button {
                    if activeStep < route.steps.count - 1 { withAnimation(.spring()) { activeStep += 1 } }
                } label: {
                    let isLast = activeStep == route.steps.count - 1
                    HStack(spacing: 6) {
                        Text(isLast ? "Arrived!" : "Next")
                            .font(.custom("Inter_18pt-SemiBold", size: 12))
                        Image(systemName: isLast ? "checkmark" : "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(isLast ? Color.destGreen : Color.primaryBlueDark)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 16).padding(.bottom, 12)

            if isExpanded {
                Divider()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(route.steps.enumerated()), id: \.offset) { i, step in
                            Button { withAnimation(.spring()) { activeStep = i } } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(i == activeStep ? Color.primaryBlueDark
                                                  : (i < activeStep ? Color.primaryBlue.opacity(0.25) : Color.mapLighter))
                                            .frame(width: 26, height: 26)
                                        if i < activeStep {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.primaryBlue)
                                        } else {
                                            Text("\(i + 1)")
                                                .font(.custom("Inter_18pt-Bold", size: 10))
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
    @State private var mapScale: CGFloat = 1.0
    @State private var mapOffset: CGSize = .zero
    @State private var activeStep: Int = 0
    @State private var fromText = ""
    @State private var toText   = ""
    @State private var activeRoute: RouteDefinition? = nil
    @State private var directionsExpanded = false

    private var floor: FloorData { floorData[selectedFloor] }
    private var allRoomNames: [String] { floor.rooms.map(\.name) }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav bar
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

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {

                        RouteInputBar(
                            fromText: $fromText,
                            toText: $toText,
                            allRooms: allRoomNames,
                            defaultFrom: floor.defaultFrom,
                            onRouteChange: resolveRoute,
                            onSwap: swapRoute
                        )
                        .padding(.horizontal, 16)

                        // Floor switcher
                        HStack(spacing: 0) {
                            ForEach(0..<floorData.count, id: \.self) { i in
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        selectedFloor = i
                                        mapScale = 1; mapOffset = .zero
                                        activeStep = 0; directionsExpanded = false
                                        fromText = floorData[i].defaultFrom
                                        toText   = floorData[i].defaultTo
                                    }
                                    resolveRoute()
                                } label: {
                                    VStack(spacing: 2) {
                                        Text("FLOOR")
                                            .font(.custom("Inter_18pt-Regular", size: 9)).tracking(0.5)
                                            .foregroundColor(selectedFloor == i ? .white : .textTertiary)
                                        Text("\(i + 1)")
                                            .font(.custom("Inter_18pt-Bold", size: 20))
                                            .foregroundColor(selectedFloor == i ? .white : .textPrimary)
                                        Text(floorData[i].floorName)
                                            .font(.custom("Inter_18pt-Regular", size: 8)).tracking(0.3)
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
                        .padding(.horizontal, 16)

                        // Map — landscape ratio
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.appBackground)
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.primaryBlueDark.opacity(0.20), lineWidth: 1.5)

                            GeometryReader { geo in
                                let w = geo.size.width - 20
                                let h = geo.size.height - 20

                                ZStack {
                                    if let assetName = floor.mapAssetName,
                                       UIImage(named: assetName) != nil {
                                        Image(assetName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: w, height: h)
                                            .clipped()
                                            .opacity(0.85)
                                    } else {
                                        corridorLayer(w: w, h: h)
                                    }

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

                            // Legend badge
                            VStack(alignment: .trailing, spacing: 4) {
                                Spacer()
                                HStack(spacing: 6) {
                                    Circle().fill(Color.primaryBlueDark).frame(width: 8, height: 8)
                                    Text("From").font(.system(size: 9)).foregroundColor(.textSecondary)
                                    Circle().fill(Color.destGreen).frame(width: 8, height: 8)
                                    Text("To").font(.system(size: 9)).foregroundColor(.textSecondary)
                                }
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.white.opacity(0.92))
                                .cornerRadius(10)
                                .padding(10)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                        .frame(height: UIScreen.main.bounds.width * 0.65)
                        .padding(.horizontal, 16)
                        .shadow(color: Color.primaryBlue.opacity(0.10), radius: 16, x: 0, y: 6)

                        // Directions card
                        if let route = activeRoute {
                            DirectionsCard(route: route, activeStep: $activeStep, isExpanded: $directionsExpanded)
                                .padding(.horizontal, 16)
                        } else if !fromText.isEmpty && !toText.isEmpty {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Color.warningText)
                                Text("No route found between \"\(fromText)\" and \"\(toText)\" — try tapping a room on the map.")
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(14)
                            .background(Color.warningBg)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                        }

                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 8)
                }
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
    }

    private func handleRoomTap(_ name: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if fromText.isEmpty || fromText == name {
                toText = name
                if fromText.isEmpty || fromText == name { fromText = floor.defaultFrom }
            } else if toText.isEmpty || toText == name {
                toText = name
            } else {
                toText = name
            }
            resolveRoute()
        }
    }

    private func resolveRoute() {
        withAnimation(.easeInOut(duration: 0.3)) {
            activeRoute = findRoute(floor: floor, from: fromText, to: toText)
            activeStep  = 0
            if activeRoute != nil { directionsExpanded = false }
        }
    }

    private func swapRoute() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            let tmp = fromText; fromText = toText; toText = tmp
            resolveRoute()
        }
    }

    @ViewBuilder
    private func corridorLayer(w: CGFloat, h: CGFloat) -> some View {
        Canvas { ctx, _ in
            var spine = Path()
            spine.addRoundedRect(
                in: CGRect(x: 0.01*w, y: 0.44*h, width: 0.98*w, height: 0.12*h),
                cornerSize: CGSize(width: 6, height: 6))
            ctx.fill(spine, with: .color(Color.corridorLight.opacity(0.55)))
            ctx.stroke(spine, with: .color(Color.corridorStripe.opacity(0.70)), lineWidth: 1.0)
        }
    }

    private func roomCell(room: RoomInfo, w: CGFloat, h: CGFloat) -> some View {
        let rw = room.width * w;  let rh = room.height * h
        let rx = room.x * w + rw / 2; let ry = room.y * h + rh / 2
        let isFrom = room.name == fromText
        let isDest = room.name == toText

        let fillColor: Color  = isFrom ? Color.primaryBlueDark
                              : isDest ? Color.destGreenLight
                              : room.category.fill
        let borderColor: Color = isFrom ? Color.primaryBlueDark
                               : isDest  ? Color.destGreen
                               : room.category.border
        let textColor: Color   = (isFrom || isDest) ? (isFrom ? .white : Color.mapGreen)
                               : room.category.textColor

        return ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 9)
                .fill(fillColor.opacity(floor.mapAssetName != nil ? 0.82 : 1.0))
                .overlay(RoundedRectangle(cornerRadius: 9)
                    .stroke(borderColor, lineWidth: (isFrom || isDest) ? 2 : 1))

            VStack(spacing: 3) {
                Image(systemName: isFrom ? "location.fill" : isDest ? "mappin.circle.fill" : room.category.icon)
                    .font(.system(size: min(rw, rh) * 0.18, weight: .medium))
                    .foregroundColor(isFrom ? .white : isDest ? Color.destGreen : textColor)

                Text(room.name)
                    .font(.custom("Inter_18pt-SemiBold", size: min(rw * 0.13, 9)))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 4)
            }
        }
        .frame(width: rw, height: rh).position(x: rx, y: ry)
        .scaleEffect((isFrom || isDest) ? 1.03 : 1.0)
        .animation(.spring(response: 0.2), value: isFrom || isDest)
    }

    @ViewBuilder
    private func routeLayer(route: RouteDefinition, w: CGFloat, h: CGFloat) -> some View {
        let pts = route.waypoints.map { CGPoint(x: $0.x * w, y: $0.y * h) }
        guard pts.count >= 2 else { return AnyView(EmptyView()) }

        let routePath = Path { p in
            p.move(to: pts[0])
            for pt in pts.dropFirst() { p.addLine(to: pt) }
        }

        return AnyView(ZStack {
            routePath.stroke(Color.primaryBlueDark.opacity(0.15),
                             style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
            AnimatedRoute(path: routePath, color: Color.primaryBlueDark)
            PulsingDot(position: pts.first!, color: Color.primaryBlueDark)
            DestinationPin(position: pts.last!, color: Color.destGreen)
        })
    }
}

#Preview {
    NavigationStack { ClinicMapView() }
}

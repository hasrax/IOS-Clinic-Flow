//
//  MapView.swift  — UX Redesign v3
//  IOS Clinic Flow
//

import SwiftUI

// MARK: - Extra map colors
extension Color {
    static let destGreen      = Color.successGreen
    static let destGreenLight = Color.successTint
    static let mapBackground  = Color(hex: "F8FAFF")
    static let mapDark        = Color(hex: "D1D5DB")
    static let mapLight       = Color(hex: "E5E7EB")
    static let mapLighter     = Color(hex: "F3F4F6")
    static let warningBg      = Color(hex: "FFFBEB")
    static let warningText    = Color(hex: "F59E0B")
}

// MARK: - Room category
private enum RoomCategory {
    case entry, services, diagnostic, clinical, critical, surgical, support

    var color: Color { switch self {
        case .entry:      return Color(hex: "1E4DB7")
        case .services:   return Color(hex: "2563EB")
        case .diagnostic: return Color(hex: "7C3AED")
        case .clinical:   return Color(hex: "0891B2")
        case .critical:   return Color(hex: "DC2626")
        case .surgical:   return Color(hex: "D97706")
        case .support:    return Color(hex: "059669")
    }}

    var icon: String { switch self {
        case .entry:      return "door.right.hand.open"
        case .services:   return "person.2.fill"
        case .diagnostic: return "waveform.path.ecg"
        case .clinical:   return "stethoscope"
        case .critical:   return "heart.text.square.fill"
        case .surgical:   return "scissors"
        case .support:    return "archivebox.fill"
    }}
}

// MARK: - Room model
private struct RoomInfo: Identifiable {
    let id = UUID()
    let name: String
    let x: CGFloat
    let y: CGFloat
    var category: RoomCategory = .clinical
    var isEntrance: Bool = false
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

// MARK: - Dynamic routing
private func dynamicRoute(from f: RoomInfo, to t: RoomInfo) -> RouteDefinition {
    let spineY: CGFloat = (f.y + t.y) / 2
    let waypoints: [CGPoint] = [
        CGPoint(x: f.x, y: f.y),
        CGPoint(x: f.x, y: spineY),
        CGPoint(x: t.x, y: spineY),
        CGPoint(x: t.x, y: t.y),
    ]
    let dir = f.x < t.x ? "right" : (f.x > t.x ? "left" : "straight ahead")
    return RouteDefinition(
        from: f.name, to: t.name,
        waypoints: waypoints,
        steps: [
            "Leave \(f.name).",
            "Head into the corridor.",
            "Walk \(dir) towards \(t.name).",
            "You have arrived at \(t.name).",
        ]
    )
}

private func findRoute(floor: FloorData, from: String, to: String) -> RouteDefinition? {
    guard from != to, !from.isEmpty, !to.isEmpty else { return nil }
    guard let fRoom = floor.rooms.first(where: { $0.name == from }),
          let tRoom = floor.rooms.first(where: { $0.name == to   }) else { return nil }
    if let m = floor.manualRoutes.first(where: { $0.from == from && $0.to == to }) { return m }
    if let m = floor.manualRoutes.first(where: { $0.from == to && $0.to == from }) {
        return RouteDefinition(from: from, to: to,
            waypoints: m.waypoints.reversed(),
            steps: m.steps.reversed().map { "↩ " + $0 })
    }
    return dynamicRoute(from: fRoom, to: tRoom)
}

// MARK: - Floor definitions
private let floorData: [FloorData] = [
    FloorData(
        floor: 1, floorName: "Outpatient",
        rooms: [
            RoomInfo(name: "Entrance",       x: 0.15, y: 0.88, category: .entry,      isEntrance: true),
            RoomInfo(name: "Reception",      x: 0.50, y: 0.80, category: .services),
            RoomInfo(name: "Waiting Area",   x: 0.82, y: 0.72, category: .support),
            RoomInfo(name: "Consultation 1", x: 0.25, y: 0.50, category: .clinical),
            RoomInfo(name: "Consultation 2", x: 0.70, y: 0.50, category: .clinical),
            RoomInfo(name: "Laboratory",     x: 0.20, y: 0.22, category: .diagnostic),
            RoomInfo(name: "X-Ray",          x: 0.55, y: 0.18, category: .diagnostic),
            RoomInfo(name: "Pharmacy",       x: 0.82, y: 0.25, category: .diagnostic),
        ],
        manualRoutes: [],
        defaultFrom: "Entrance", defaultTo: "Laboratory",
        mapAssetName: "map"
    ),
    FloorData(
        floor: 2, floorName: "Inpatient",
        rooms: [
            RoomInfo(name: "Elevator",       x: 0.12, y: 0.85, category: .services,   isEntrance: true),
            RoomInfo(name: "Nurses Station", x: 0.50, y: 0.75, category: .services),
            RoomInfo(name: "ICU",            x: 0.20, y: 0.40, category: .critical),
            RoomInfo(name: "Ward A",         x: 0.50, y: 0.30, category: .clinical),
            RoomInfo(name: "Ward B",         x: 0.78, y: 0.40, category: .clinical),
            RoomInfo(name: "Radiology",      x: 0.30, y: 0.15, category: .diagnostic),
            RoomInfo(name: "Cardiology",     x: 0.65, y: 0.15, category: .critical),
            RoomInfo(name: "Pharmacy Store", x: 0.82, y: 0.75, category: .diagnostic),
        ],
        manualRoutes: [],
        defaultFrom: "Elevator", defaultTo: "ICU",
        mapAssetName: nil
    ),
    FloorData(
        floor: 3, floorName: "Surgical",
        rooms: [
            RoomInfo(name: "Elevator",       x: 0.12, y: 0.85, category: .services,   isEntrance: true),
            RoomInfo(name: "Scrub Room",     x: 0.40, y: 0.75, category: .support),
            RoomInfo(name: "Op. Theatre 1",  x: 0.22, y: 0.35, category: .surgical),
            RoomInfo(name: "Op. Theatre 2",  x: 0.65, y: 0.35, category: .surgical),
            RoomInfo(name: "Prep Room",      x: 0.50, y: 0.18, category: .clinical),
            RoomInfo(name: "Recovery",       x: 0.78, y: 0.55, category: .critical),
            RoomInfo(name: "Sterilisation",  x: 0.78, y: 0.80, category: .support),
        ],
        manualRoutes: [],
        defaultFrom: "Elevator", defaultTo: "Op. Theatre 1",
        mapAssetName: nil
    ),
]

// MARK: - Animated dashed route stroke
private struct AnimatedRoute: View {
    let path: Path
    let color: Color
    @State private var phase: CGFloat = 0
    var body: some View {
        path.stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round,
                                               dash: [7, 5], dashPhase: phase))
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) { phase = -24 }
            }
    }
}

// MARK: - Triangle shape
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Room pin
private struct RoomPin: View {
    let room: RoomInfo
    let isFrom: Bool
    let isDest: Bool
    let position: CGPoint

    private var bubbleColor: Color {
        isFrom ? .primaryBlueDark : isDest ? .destGreen : .white
    }
    private var iconColor: Color {
        (isFrom || isDest) ? .white : room.category.color
    }
    private var labelColor: Color {
        (isFrom || isDest) ? .white : Color(hex: "111827")
    }
    private var shadowColor: Color {
        isFrom ? Color.primaryBlueDark.opacity(0.35)
               : isDest ? Color.destGreen.opacity(0.35)
               : Color.black.opacity(0.15)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: isFrom ? "location.fill"
                                 : isDest ? "mappin.circle.fill"
                                 : room.category.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(iconColor)
                Text(room.name)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(labelColor)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(bubbleColor)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke((isFrom || isDest) ? Color.clear : Color(hex: "E5E7EB"), lineWidth: 1)
            )
            .shadow(color: shadowColor, radius: (isFrom || isDest) ? 6 : 3, x: 0, y: 2)

            Triangle()
                .fill(bubbleColor)
                .frame(width: 10, height: 6)
        }
        .position(x: position.x, y: position.y - 22)
        .scaleEffect((isFrom || isDest) ? 1.12 : 1.0)
        .animation(.spring(response: 0.25), value: isFrom || isDest)
    }
}

// MARK: - Pulsing origin dot
private struct PulsingDot: View {
    let position: CGPoint
    let color: Color
    @State private var pulse = false
    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.18)).frame(width: pulse ? 28 : 12, height: pulse ? 28 : 12)
            Circle().fill(color.opacity(0.42)).frame(width: 12, height: 12)
            Circle().fill(color).frame(width: 7, height: 7)
        }
        .position(position)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { pulse = true }
        }
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
                // FROM
                HStack(spacing: 8) {
                    Circle().fill(Color.primaryBlueDark).frame(width: 9, height: 9)
                    TextField("From", text: $fromText)
                        .font(.custom("Inter_18pt-Regular", size: 13))
                        .foregroundColor(.textPrimary)
                        .focused($focused, equals: .from)
                        .submitLabel(.next)
                        .onSubmit { focused = .to }
                        .onChange(of: fromText) { _, _ in onRouteChange() }
                    if !fromText.isEmpty {
                        Button { fromText = ""; onRouteChange() } label: {
                            Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.textTertiary)
                        }
                    }
                }
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(Color.mapBackground).cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(focused == .from ? Color.primaryBlue : Color.clear, lineWidth: 1.5))
                .frame(maxWidth: .infinity)

                // Swap
                Button(action: onSwap) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 12, weight: .bold)).foregroundColor(.primaryBlue)
                        .frame(width: 32, height: 32).background(Color.primaryBlueTint).cornerRadius(10)
                }

                // TO
                HStack(spacing: 8) {
                    Image(systemName: "mappin.fill").font(.system(size: 9)).foregroundColor(Color.destGreen)
                    TextField("To", text: $toText)
                        .font(.custom("Inter_18pt-Regular", size: 13))
                        .foregroundColor(.textPrimary)
                        .focused($focused, equals: .to)
                        .submitLabel(.done)
                        .onSubmit { focused = nil; onRouteChange() }
                        .onChange(of: toText) { _, _ in onRouteChange() }
                    if !toText.isEmpty {
                        Button { toText = ""; onRouteChange() } label: {
                            Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.textTertiary)
                        }
                    }
                }
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(Color.mapBackground).cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(focused == .to ? Color.destGreen : Color.clear, lineWidth: 1.5))
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 14).padding(.vertical, 12)

            if !fromSuggestions.isEmpty {
                suggestionList(rooms: fromSuggestions) { r in fromText = r; focused = .to; onRouteChange() }
            }
            if !toSuggestions.isEmpty {
                suggestionList(rooms: toSuggestions) { r in toText = r; focused = nil; onRouteChange() }
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
                                        .background(Color.primaryBlueTint).cornerRadius(20)
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
        .background(Color.white).cornerRadius(18)
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

// MARK: - Directions card
private struct DirectionsCard: View {
    let route: RouteDefinition
    @Binding var activeStep: Int
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(spacing: 0) {
            Capsule().fill(Color.mapDark).frame(width: 36, height: 4).padding(.top, 10)

            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.primaryBlueDark).frame(width: 34, height: 34)
                    Text("\(activeStep + 1)").font(.custom("Inter_18pt-Bold", size: 15)).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text(route.steps[activeStep])
                        .font(.custom("Inter_18pt-Medium", size: 13)).foregroundColor(.textPrimary)
                        .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 4) {
                        ForEach(0..<route.steps.count, id: \.self) { i in
                            Capsule()
                                .fill(i == activeStep ? Color.primaryBlueDark
                                      : (i < activeStep ? Color.primaryBlue.opacity(0.4) : Color.mapLight))
                                .frame(width: i == activeStep ? 22 : 8, height: 4)
                                .animation(.spring(response: 0.3), value: activeStep)
                        }
                        Spacer()
                        Text("\(activeStep + 1) / \(route.steps.count)")
                            .font(.custom("Inter_18pt-Regular", size: 10)).foregroundColor(.textTertiary)
                    }
                }
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { isExpanded.toggle() }
                } label: {
                    Image(systemName: isExpanded ? "chevron.down" : "list.bullet")
                        .font(.system(size: 12, weight: .semibold)).foregroundColor(.primaryBlue)
                        .frame(width: 30, height: 30).background(Color.primaryBlueTint).cornerRadius(8)
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
                        .background(activeStep == 0 ? Color.mapLighter : Color.primaryBlueTint).cornerRadius(10)
                }
                .disabled(activeStep == 0)

                Button {
                    if activeStep < route.steps.count - 1 { withAnimation(.spring()) { activeStep += 1 } }
                } label: {
                    let isLast = activeStep == route.steps.count - 1
                    HStack(spacing: 6) {
                        Text(isLast ? "Arrived!" : "Next").font(.custom("Inter_18pt-SemiBold", size: 12))
                        Image(systemName: isLast ? "checkmark" : "chevron.right").font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(isLast ? Color.destGreen : Color.primaryBlueDark).cornerRadius(10)
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
                                                .font(.system(size: 10, weight: .bold)).foregroundColor(.primaryBlue)
                                        } else {
                                            Text("\(i + 1)").font(.custom("Inter_18pt-Bold", size: 10))
                                                .foregroundColor(i == activeStep ? .white : .textTertiary)
                                        }
                                    }
                                    Text(step).font(.custom("Inter_18pt-Regular", size: 13))
                                        .foregroundColor(i == activeStep ? .textPrimary : .textSecondary)
                                        .multilineTextAlignment(.leading).padding(.top, 4)
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
    @State private var activeStep: Int = 0
    @State private var fromText = ""
    @State private var toText   = ""
    @State private var activeRoute: RouteDefinition? = nil
    @State private var directionsExpanded = false

    private var floor: FloorData { floorData[selectedFloor] }
    private var allRoomNames: [String] { floor.rooms.map(\.name) }

    // FIXED: Use a constant binding — neutral mode doesn't highlight any tab,
    // and tapping a tab sets pendingTab + dismiss() to navigate properly.
    private var tabBinding: Binding<TabItem> {
        .constant(.home)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                NavBar(title: "Clinic Navigation", onBack: { dismiss() })

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {

                        RouteInputBar(
                            fromText: $fromText, toText: $toText,
                            allRooms: allRoomNames, defaultFrom: floor.defaultFrom,
                            onRouteChange: resolveRoute, onSwap: swapRoute
                        )
                        .padding(.horizontal, 16)

                        // Floor switcher
                        HStack(spacing: 0) {
                            ForEach(0..<floorData.count, id: \.self) { i in
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        selectedFloor = i
                                        activeStep = 0; directionsExpanded = false
                                        fromText = floorData[i].defaultFrom
                                        toText   = floorData[i].defaultTo
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
                        .padding(4).background(Color.white).cornerRadius(14)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 16)

                        // ── MAP ──
                        let photoAspect: CGFloat = {
                            if let img = UIImage(named: floor.mapAssetName ?? "") {
                                return img.size.height / img.size.width
                            }
                            return 1.25
                        }()
                        let mapW = UIScreen.main.bounds.width - 32
                        let mapH = mapW * photoAspect

                        ZStack {
                            if let assetName = floor.mapAssetName,
                               UIImage(named: assetName) != nil {
                                Image(assetName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: mapW)
                            } else {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(hex: "EEF2FF"))
                                Canvas { ctx, size in
                                    for f in stride(from: 0.0, through: 1.0, by: 0.2) {
                                        var lv = Path()
                                        lv.move(to: CGPoint(x: f * size.width, y: 0))
                                        lv.addLine(to: CGPoint(x: f * size.width, y: size.height))
                                        ctx.stroke(lv, with: .color(Color.primaryBlue.opacity(0.07)), lineWidth: 1)
                                        var lh = Path()
                                        lh.move(to: CGPoint(x: 0, y: f * size.height))
                                        lh.addLine(to: CGPoint(x: size.width, y: f * size.height))
                                        ctx.stroke(lh, with: .color(Color.primaryBlue.opacity(0.07)), lineWidth: 1)
                                    }
                                }
                            }

                            if let route = activeRoute {
                                routeOverlay(route: route, w: mapW, h: mapH)
                            }

                            ForEach(floor.rooms) { room in
                                let px = room.x * mapW
                                let py = room.y * mapH
                                RoomPin(
                                    room: room,
                                    isFrom: room.name == fromText,
                                    isDest: room.name == toText,
                                    position: CGPoint(x: px, y: py)
                                )
                                Color.clear
                                    .frame(width: 50, height: 50)
                                    .position(x: px, y: py)
                                    .onTapGesture { handleRoomTap(room.name) }
                            }
                        }
                        .frame(width: mapW, height: mapH)
                        .cornerRadius(20)
                        .shadow(color: Color.primaryBlue.opacity(0.10), radius: 16, x: 0, y: 6)
                        .padding(.horizontal, 16)

                        if let route = activeRoute {
                            DirectionsCard(route: route, activeStep: $activeStep, isExpanded: $directionsExpanded)
                                .padding(.horizontal, 16)
                        } else if !fromText.isEmpty && !toText.isEmpty {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Color.warningText)
                                Text("No route found — try tapping a room on the map.")
                                    .font(.custom("Inter_18pt-Regular", size: 12)).foregroundColor(.textSecondary)
                            }
                            .padding(14).background(Color.warningBg).cornerRadius(12).padding(.horizontal, 16)
                        }

                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 8)
                }

                // FIXED: Use neutral mode — no tab is highlighted, and tapping
                // any tab sets AppRouter.pendingTab + dismisses this view,
                // so RootView picks it up and switches to the correct tab.
                BottomTabBar(selectedTab: tabBinding, isNeutral: true)
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

    @ViewBuilder
    private func routeOverlay(route: RouteDefinition, w: CGFloat, h: CGFloat) -> some View {
        let pts = route.waypoints.map { CGPoint(x: $0.x * w, y: $0.y * h) }
        if pts.count >= 2 {
            let routePath = Path { p in
                p.move(to: pts[0])
                for pt in pts.dropFirst() { p.addLine(to: pt) }
            }
            ZStack {
                routePath.stroke(Color.primaryBlueDark.opacity(0.12),
                                 style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                AnimatedRoute(path: routePath, color: Color.primaryBlueDark)
                PulsingDot(position: pts.first!, color: Color.primaryBlueDark)
            }
        }
    }

    private func handleRoomTap(_ name: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if fromText.isEmpty || fromText == name {
                toText = name
                if fromText.isEmpty || fromText == name { fromText = floor.defaultFrom }
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
}

#Preview {
    NavigationStack { ClinicMapView() }
}

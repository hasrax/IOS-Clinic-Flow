//
//  MapView.swift  — Simplified Navigation
//  IOS Clinic Flow
//
//  Clean, simple map navigation with:
//    • Clear room layout with intuitive positioning
//    • Simple from/to selection with quick access
//    • Animated dotted path showing route
//    • Clean, minimal UI focused on wayfinding
//    • Easy-to-use room selection
//

import SwiftUI

// MARK: - Room Types
private enum RoomType {
    case entrance, reception, clinical, diagnostic, emergency
    
    var color: Color {
        switch self {
        case .entrance:   return Color(hex: "1E4DB7")
        case .reception:  return Color(hex: "3B82F6") 
        case .clinical:   return Color(hex: "EBF4FF")
        case .diagnostic: return Color(hex: "DBE9FF")
        case .emergency:  return Color(hex: "EF4444")
        }
    }
    
    var borderColor: Color {
        switch self {
        case .entrance:   return Color(hex: "1E4DB7")
        case .reception:  return Color(hex: "3B82F6")
        case .clinical:   return Color(hex: "93C5FD")
        case .diagnostic: return Color(hex: "60A5FA")
        case .emergency:  return Color(hex: "EF4444")
        }
    }
    
    var textColor: Color {
        switch self {
        case .entrance, .reception, .emergency: return .white
        default: return Color(hex: "1A3A6E")
        }
    }
    
    var icon: String {
        switch self {
        case .entrance:   return "door.right.hand.open"
        case .reception:  return "person.2"
        case .clinical:   return "stethoscope"
        case .diagnostic: return "waveform.path.ecg"
        case .emergency:  return "cross.circle.fill"
        }
    }
}

// MARK: - Simple Room Model
private struct Room: Identifiable {
    let id = UUID()
    let name: String
    let type: RoomType
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    var centerX: CGFloat { x + width / 2 }
    var centerY: CGFloat { y + height / 2 }
}

// MARK: - Simple Route
private struct Route {
    let fromRoom: String
    let toRoom: String
    let pathPoints: [CGPoint]
    let instruction: String
}

// MARK: - Hospital Layout Data
private let hospitalRooms: [Room] = [
    // Entrance area
    Room(name: "Main Entrance", type: .entrance, x: 0.05, y: 0.85, width: 0.25, height: 0.12),
    Room(name: "Reception", type: .reception, x: 0.35, y: 0.85, width: 0.3, height: 0.12),
    
    // Left side - Clinical
    Room(name: "Consultation 1", type: .clinical, x: 0.05, y: 0.65, width: 0.25, height: 0.15),
    Room(name: "Consultation 2", type: .clinical, x: 0.05, y: 0.45, width: 0.25, height: 0.15),
    Room(name: "Consultation 3", type: .clinical, x: 0.05, y: 0.25, width: 0.25, height: 0.15),
    
    // Center - Services
    Room(name: "Pharmacy", type: .diagnostic, x: 0.4, y: 0.65, width: 0.2, height: 0.15),
    Room(name: "Laboratory", type: .diagnostic, x: 0.4, y: 0.45, width: 0.2, height: 0.15),
    Room(name: "X-Ray", type: .diagnostic, x: 0.4, y: 0.25, width: 0.2, height: 0.15),
    
    // Right side - Specialized
    Room(name: "Emergency", type: .emergency, x: 0.7, y: 0.65, width: 0.25, height: 0.15),
    Room(name: "ICU", type: .emergency, x: 0.7, y: 0.45, width: 0.25, height: 0.15),
    Room(name: "Surgery", type: .emergency, x: 0.7, y: 0.25, width: 0.25, height: 0.15),
    
    // Top area
    Room(name: "Waiting Area", type: .reception, x: 0.25, y: 0.05, width: 0.5, height: 0.15)
]

// MARK: - Predefined Routes (simplified)
private let hospitalRoutes: [Route] = [
    Route(fromRoom: "Main Entrance", toRoom: "Reception", 
          pathPoints: [CGPoint(x: 0.175, y: 0.91), CGPoint(x: 0.35, y: 0.91)],
          instruction: "Walk straight to Reception desk"),
    
    Route(fromRoom: "Main Entrance", toRoom: "Laboratory",
          pathPoints: [CGPoint(x: 0.175, y: 0.91), CGPoint(x: 0.175, y: 0.525), CGPoint(x: 0.5, y: 0.525)],
          instruction: "Go left, then straight to Laboratory"),
    
    Route(fromRoom: "Reception", toRoom: "Consultation 1",
          pathPoints: [CGPoint(x: 0.35, y: 0.91), CGPoint(x: 0.175, y: 0.91), CGPoint(x: 0.175, y: 0.725)],
          instruction: "Head left to Consultation room 1"),
    
    Route(fromRoom: "Reception", toRoom: "Emergency",
          pathPoints: [CGPoint(x: 0.65, y: 0.91), CGPoint(x: 0.825, y: 0.91), CGPoint(x: 0.825, y: 0.725)],
          instruction: "Go right corridor to Emergency"),
    
    Route(fromRoom: "Laboratory", toRoom: "X-Ray",
          pathPoints: [CGPoint(x: 0.5, y: 0.45), CGPoint(x: 0.5, y: 0.325)],
          instruction: "Go upstairs to X-Ray room"),
    
    Route(fromRoom: "Pharmacy", toRoom: "ICU",
          pathPoints: [CGPoint(x: 0.6, y: 0.725), CGPoint(x: 0.7, y: 0.725), CGPoint(x: 0.825, y: 0.525)],
          instruction: "Cross to the ICU ward"),
]

// MARK: - Route Finding
private func findRoute(from: String, to: String) -> Route? {
    return hospitalRoutes.first { route in
        (route.fromRoom == from && route.toRoom == to) || 
        (route.fromRoom == to && route.toRoom == from)
    }
}

// MARK: - Animated dotted path (key feature!)
private struct AnimatedPath: View {
    let pathPoints: [CGPoint]
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        if pathPoints.count >= 2 {
            let path = Path { p in
                p.move(to: pathPoints[0])
                for point in pathPoints.dropFirst() {
                    p.addLine(to: point)
                }
            }
            
            ZStack {
                // Background path
                path.stroke(
                    Color.primaryBlue.opacity(0.2), 
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                
                // Animated dotted line
                path.stroke(
                    Color.primaryBlue,
                    style: StrokeStyle(
                        lineWidth: 3, 
                        lineCap: .round,
                        dash: [8, 4],
                        dashPhase: animationPhase
                    )
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        animationPhase = -20
                    }
                }
                
                // Start point
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 8, height: 8)
                    .position(pathPoints.first!)
                
                // End point with arrow
                endPointArrow
            }
        }
    }
    
    @ViewBuilder
    private var endPointArrow: some View {
        if pathPoints.count >= 2 {
            let endPoint = pathPoints.last!
            let previousPoint = pathPoints[pathPoints.count - 2]
            
            let dx = endPoint.x - previousPoint.x
            let dy = endPoint.y - previousPoint.y
            let angle = atan2(dy, dx)
            
            Image(systemName: "arrowtriangle.right.fill")
                .font(.system(size: 12))
                .foregroundColor(.primaryBlue)
                .rotationEffect(.radians(angle))
                .position(endPoint)
        }
    }
}

// MARK: - Simplified room picker
private struct RoomPicker: View {
    let rooms: [Room]
    @Binding var selectedRoom: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Inter_18pt-SemiBold", size: 12))
                .foregroundColor(.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(rooms) { room in
                        Button(action: { selectedRoom = room.name }) {
                            Text(room.name)
                                .font(.custom("Inter_18pt-Regular", size: 11))
                                .foregroundColor(selectedRoom == room.name ? .white : color)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedRoom == room.name ? color : color.opacity(0.1))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(color.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

// MARK: - Main Map View
struct ClinicMapView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fromRoom: String = "Main Entrance"
    @State private var toRoom: String = "Reception"
    @State private var selectedRoute: Route?
    @State private var navTab: TabItem = .home
    
    var body: some View {
        VStack(spacing: 0) {
            // Simple header
            HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("Hospital Map")
                            .font(.custom("Inter_18pt-Bold", size: 18))
                            .foregroundColor(.textPrimary)
                        
                        Text("Find your way")
                            .font(.custom("Inter_18pt-Regular", size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Simple route selection
                        routeSelectionCard
                        
                        // Map
                        mapView
                        
                        // Instructions
                        if let route = selectedRoute {
                            instructionCard(route: route)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Space for bottom tab
                }
                .background(Color(hex: "F8FAFC"))
                
                BottomTabBar(selectedTab: $navTab)
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                updateRoute()
            }
            .onChange(of: navTab) { _, tab in 
                AppRouter.shared.pendingTab = tab
                dismiss() 
            }
        }
        
        // MARK: - Route Selection Card
        @ViewBuilder
        private var routeSelectionCard: some View {
            VStack(spacing: 16) {
                // FROM selection
                RoomPicker(
                    rooms: hospitalRooms.filter { $0.type == .entrance || $0.type == .reception },
                    selectedRoom: $fromRoom,
                    title: "FROM",
                    color: .primaryBlue
                )
                
                // Swap button
                Button(action: swapRooms) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Swap")
                            .font(.custom("Inter_18pt-SemiBold", size: 12))
                    }
                    .foregroundColor(.primaryBlue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.primaryBlueTint)
                    .cornerRadius(20)
                }
                
                // TO selection  
                RoomPicker(
                    rooms: hospitalRooms.filter { $0.name != fromRoom },
                    selectedRoom: $toRoom,
                    title: "TO",
                    color: Color(hex: "059669")
                )
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            .onChange(of: fromRoom) { _, _ in updateRoute() }
            .onChange(of: toRoom) { _, _ in updateRoute() }
        }
        
        // MARK: - Map View
        @ViewBuilder
        private var mapView: some View {
            GeometryReader { geometry in
                let size = geometry.size
                
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.primaryBlue.opacity(0.1), lineWidth: 1)
                        )
                    
                    // Grid background
                    Canvas { context, size in
                        let spacing: CGFloat = 30
                        context.stroke(
                            Path { path in
                                for x in stride(from: 0, through: size.width, by: spacing) {
                                    path.move(to: CGPoint(x: x, y: 0))
                                    path.addLine(to: CGPoint(x: x, y: size.height))
                                }
                                for y in stride(from: 0, through: size.height, by: spacing) {
                                    path.move(to: CGPoint(x: 0, y: y))
                                    path.addLine(to: CGPoint(x: size.width, y: y))
                                }
                            },
                            with: .color(Color.gray.opacity(0.1)),
                            lineWidth: 0.5
                        )
                    }
                    .clipped()
                    
                    // Rooms
                    ForEach(hospitalRooms) { room in
                        roomView(room: room, mapSize: size)
                    }
                    
                    // Route path
                    if let route = selectedRoute {
                        let scaledPoints = route.pathPoints.map { point in
                            CGPoint(
                                x: point.x * size.width,
                                y: point.y * size.height
                            )
                        }
                        AnimatedPath(pathPoints: scaledPoints)
                    }
                }
                .padding(16)
            }
            .frame(height: 400)
            .background(Color.primaryBlueTint.opacity(0.1))
            .cornerRadius(16)
        }
        
        // MARK: - Room View
        private func roomView(room: Room, mapSize: CGSize) -> some View {
            let roomFrame = CGRect(
                x: room.x * mapSize.width,
                y: room.y * mapSize.height,
                width: room.width * mapSize.width,
                height: room.height * mapSize.height
            )
            
            let isSelected = room.name == fromRoom || room.name == toRoom
            let isFrom = room.name == fromRoom
            let isTo = room.name == toRoom
            
            return ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isFrom ? Color.primaryBlue : isTo ? Color(hex: "059669") : room.type.color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.white : room.type.borderColor, lineWidth: isSelected ? 2 : 1)
                    )
                
                VStack(spacing: 2) {
                    Image(systemName: isFrom ? "location.fill" : isTo ? "mappin.circle.fill" : room.type.icon)
                        .font(.system(size: min(roomFrame.width, roomFrame.height) * 0.15))
                        .foregroundColor(isSelected ? .white : room.type.textColor)
                    
                    Text(room.name)
                        .font(.custom("Inter_18pt-Medium", size: min(roomFrame.width * 0.08, 8)))
                        .foregroundColor(isSelected ? .white : room.type.textColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 2)
                }
            }
            .frame(width: roomFrame.width, height: roomFrame.height)
            .position(x: roomFrame.midX, y: roomFrame.midY)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
            .onTapGesture {
                if toRoom != room.name {
                    toRoom = room.name
                }
            }
        }
        
        // MARK: - Instruction Card
        private func instructionCard(route: Route) -> some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "location.north.circle.fill")
                        .foregroundColor(.primaryBlue)
                        .font(.system(size: 20))
                    
                    Text("Directions")
                        .font(.custom("Inter_18pt-Bold", size: 16))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                }
                
                Text(route.instruction)
                    .font(.custom("Inter_18pt-Regular", size: 14))
                    .foregroundColor(.textSecondary)
                    .lineLimit(nil)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        
        // MARK: - Helper Functions
        private func updateRoute() {
            selectedRoute = findRoute(from: fromRoom, to: toRoom)
        }
        
        private func swapRooms() {
            let temp = fromRoom
            fromRoom = toRoom
            toRoom = temp
        }
}

#Preview {
    ClinicMapView()
}

//
//  MapView.swift
//  IOS Clinic Flow
//
//  Created by Lakindu Siriwardena on 2026-03-10.
//


import SwiftUI

// MARK: - room information
private struct RoomInfo: Identifiable {
    let id = UUID()
    //giving rooms auto generated IDs
    let name: String
    //display names for the rooms
    let x: CGFloat; let y: CGFloat
    //rooms location in the map
    let width: CGFloat; let height: CGFloat
    var isHighlighted: Bool = false
    var isEntrance:    Bool = false
}

// MARK: - floor information
private struct FloorData {
    let floor: Int
    let rooms: [RoomInfo]
    let directions: [String]
    //step by step instructions for the room
    let currentLocation: String
    let destination: String
}

private let floorData: [FloorData] = [
    FloorData(
        floor: 1,
        rooms: [
            RoomInfo(name: "Pharmacy",        x: 0.02, y: 0.03, width: 0.26, height: 0.22),
            RoomInfo(name: "Waiting Area",    x: 0.30, y: 0.03, width: 0.30, height: 0.13),
            RoomInfo(name: "MRI Suite",       x: 0.30, y: 0.18, width: 0.18, height: 0.12),
            RoomInfo(name: "Laboratory",      x: 0.62, y: 0.03, width: 0.36, height: 0.28, isHighlighted: true),
            RoomInfo(name: "Ultrasound Room", x: 0.02, y: 0.29, width: 0.33, height: 0.22),
            RoomInfo(name: "Room - 02",       x: 0.38, y: 0.30, width: 0.22, height: 0.18),
            RoomInfo(name: "Room - 01",       x: 0.63, y: 0.30, width: 0.22, height: 0.18),
            RoomInfo(name: "Reception",       x: 0.38, y: 0.51, width: 0.47, height: 0.15),
            RoomInfo(name: "Elevator",        x: 0.02, y: 0.60, width: 0.22, height: 0.18),
            RoomInfo(name: "Entrance",        x: 0.63, y: 0.69, width: 0.22, height: 0.12, isEntrance: true),
        ],
        
        //all the locations and th names and the sizes of the rooms for floor -01
        directions: [
            "Enter through the main entrance.",
            "Walk straight to Reception.",
            "Turn right.",
            "The Laboratory is ahead on your right.",
        ],
        currentLocation: "Entrance",
        destination: "Laboratory"
    ),
    //hard coded directions from entrance to lab xxxxx

    FloorData(
        floor: 2,
        rooms: [
            RoomInfo(name: "Cardiology",     x: 0.02, y: 0.03, width: 0.30, height: 0.22),
            RoomInfo(name: "Neurology",      x: 0.36, y: 0.03, width: 0.30, height: 0.22),
            RoomInfo(name: "Radiology",      x: 0.70, y: 0.03, width: 0.28, height: 0.22),
            RoomInfo(name: "ICU",            x: 0.02, y: 0.30, width: 0.44, height: 0.22, isHighlighted: true),
            RoomInfo(name: "Waiting Lounge", x: 0.50, y: 0.30, width: 0.48, height: 0.22),
            RoomInfo(name: "Nurses Station", x: 0.02, y: 0.58, width: 0.36, height: 0.18),
            RoomInfo(name: "Elevator",       x: 0.42, y: 0.58, width: 0.22, height: 0.18, isEntrance: true),
            RoomInfo(name: "Stairwell",      x: 0.70, y: 0.58, width: 0.28, height: 0.18),
        ],
        
        //all the locations and th names and the sizes of the rooms for floor -02
        directions: [
            "Take the elevator to Floor 2.",
            "Exit elevator and turn left.",
            "Walk past the Nurses Station.",
            "ICU is on your left.",
        ],
        currentLocation: "Elevator",
        destination: "ICU"
        //hard coded directions from Elevator to icu xxxxx

    ),
    FloorData(
        floor: 3,
        rooms: [
            RoomInfo(name: "Op. Theatre 1", x: 0.02, y: 0.03, width: 0.44, height: 0.25),
            RoomInfo(name: "Op. Theatre 2", x: 0.50, y: 0.03, width: 0.48, height: 0.25),
            RoomInfo(name: "Recovery Room", x: 0.02, y: 0.32, width: 0.36, height: 0.20, isHighlighted: true),
            RoomInfo(name: "Surgical ICU",  x: 0.42, y: 0.32, width: 0.30, height: 0.20),
            RoomInfo(name: "Sterilisation", x: 0.76, y: 0.32, width: 0.22, height: 0.20),
            RoomInfo(name: "Scrub Room",    x: 0.02, y: 0.57, width: 0.26, height: 0.18),
            RoomInfo(name: "Storage",       x: 0.32, y: 0.57, width: 0.22, height: 0.18),
            RoomInfo(name: "Elevator",      x: 0.60, y: 0.57, width: 0.22, height: 0.18, isEntrance: true),
        ],
        
        //all the locations and th names and the sizes of the rooms for floor -03
        directions: [
            "Take the elevator to Floor 3.",
            "Exit elevator and proceed forward.",
            "Turn left at the Scrub Room.",
            "Recovery Room is straight ahead.",
        ],
        currentLocation: "Elevator",
        destination: "Recovery Room"
    ),
    //hard coded directions from elevator to recovery room xxxx
]

// MARK: - main view
struct ClinicMapView: View {
    @Environment(\.dismiss) private var dismiss
    //dismiss action to go back from the current page to the initial page
    @State private var selectedFloor = 0
    @State private var showManualSearch = false
    @State private var navTab: TabItem = .home
    @State private var mapScale: CGFloat = 1.0
    //allowing to switch zoom scale
    @State private var mapOffset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
//to make sure that the drag is done swiftly
    private var current: FloorData { floorData[selectedFloor] }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom nav bar
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                    }
                    Spacer()
                    Text("Clinic Navigation")
                        .font(.custom("Inter_18pt-Bold", size: 18))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.appBackground)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // location icon
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 15))
                                .foregroundColor(.primaryBlue)
                            Text("You are at : \(current.currentLocation)")
                                .font(.custom("Inter_18pt-Medium", size: 13))
                                .foregroundColor(.primaryBlue)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.primaryBlueTint)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // continer for the floor map
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
//to make sure the rooms are properly inside the card
                            GeometryReader { geo in
                                let w = geo.size.width - 16
                                let h = geo.size.height - 16
                                ZStack {
                                    ForEach(current.rooms) { room in
                                        roomCell(room: room, w: w, h: h)
                                    }
                                    routePath(w: w, h: h)
                                }
                                .padding(8)
                                .scaleEffect(mapScale)
                                .offset(mapOffset)
                                .gesture(
                                    //this was added so the user can pinch the screen and stuff
                                    SimultaneousGesture(
                                        MagnificationGesture()
                                            .onChanged { v in mapScale = max(1, min(3, v)) },
                                        DragGesture()
                                            .onChanged { v in
                                                mapOffset = CGSize(
                                                    width:  lastOffset.width  + v.translation.width,
                                                    height: lastOffset.height + v.translation.height)
                                            }
                                            .onEnded { _ in lastOffset = mapOffset }
                                    )
                                )
                                .animation(.easeInOut(duration: 0.2), value: selectedFloor)
                            }
                        }
                        .frame(height: 310)
                        .padding(.horizontal, 20)
                        .onTapGesture(count: 2) {
                            withAnimation { mapScale = 1; mapOffset = .zero; lastOffset = .zero }
                        }

                        // ── Double-tap hint
                        Text("Double-tap to reset zoom")
                            .font(.custom("Inter_18pt-Regular", size: 11))
                            .foregroundColor(.textTertiary)

                        // this is the part that allows the user to loop through floors and select floors basically when the user selects a floor the floor is high lighted and shown
                        VStack(spacing: 6) {
                            HStack(spacing: 10) {
                                ForEach(0..<floorData.count, id: \.self) { i in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            selectedFloor = i
                                            mapScale = 1; mapOffset = .zero; lastOffset = .zero
                                        }
                                    } label: {
                                        Text("\(i + 1)")
                                            .font(.custom("Inter_18pt-Bold", size: 15))
                                            .foregroundColor(selectedFloor == i ? .white : .textPrimary)
                                            .frame(width: 40, height: 40)
                                            .background(
                                                selectedFloor == i
                                                    ? AnyView(RoundedRectangle(cornerRadius: 10).fill(Color.primaryBlueDark))
                                                    : AnyView(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "D1D5DB"), lineWidth: 1.5))
                                            )
                                    }
                                }
                            }
                            Text("Floors")
                                .font(.custom("Inter_18pt-Regular", size: 12))
                                .foregroundColor(.textSecondary)
                        }

                        // the thingie that explains what each color means and stuff
                        HStack(spacing: 20) {
                            legendDot(color: Color(hex: "D4EDD6"), label: "Destination")
                            legendDot(color: Color(hex: "DBE9FF"), label: "Regular Room")
                            legendDot(color: Color.primaryBlueDark, label: "Your Route", isLine: true)
                        }
                        .padding(.horizontal, 20)

                        // the direction tracker to display where the user has to move
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "location.north.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primaryBlue)
                                Text("Directions")
                                    .font(.custom("Inter_18pt-Bold", size: 16))
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Text("To: \(current.destination)")
                                    .font(.custom("Inter_18pt-Regular", size: 12))
                                    .foregroundColor(.primaryBlue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.primaryBlueTint)
                                    .cornerRadius(8)
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(Array(current.directions.enumerated()), id: \.offset) { i, step in
                                    HStack(alignment: .top, spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.primaryBlueTint)
                                                .frame(width: 26, height: 26)
                                            Text("\(i + 1)")
                                                .font(.custom("Inter_18pt-Bold", size: 11))
                                                .foregroundColor(.primaryBlue)
                                        }
                                        Text(step)
                                            .font(.custom("Inter_18pt-Regular", size: 14))
                                            .foregroundColor(.textPrimary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                        }
                        .padding(.horizontal, 20)
//step counter
                        // user can manual serach the locations if the clicking thing doesnt work
                        VStack(spacing: 8) {
                            Button { showManualSearch = true } label: {
                                Text("Manual search option")
                                    .font(.custom("Inter_18pt-SemiBold", size: 15))
                                    .foregroundColor(.primaryBlueDark)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.primaryBlueDark, lineWidth: 1.5)
                                    )
                            }

                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 11))
                                    .foregroundColor(.textTertiary)
                                Text("A manual search option is also available for users to find departments directly.")
                                    .font(.custom("Inter_18pt-Regular", size: 11))
                                    .foregroundColor(.textTertiary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }

                BottomTabBar(selectedTab: $navTab, isNeutral: true)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
        .sheet(isPresented: $showManualSearch) {
            ManualSearchSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - room design
    private func roomCell(room: RoomInfo, w: CGFloat, h: CGFloat) -> some View {
        let rw = room.width * w
        let rh = room.height * h
        let rx = room.x * w + rw / 2
        let ry = room.y * h + rh / 2

        return ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    room.isHighlighted ? Color(hex: "D4EDD6") :
                    room.isEntrance    ? Color.primaryBlueDark.opacity(0.9) :
                    Color(hex: "DBE9FF")
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            room.isHighlighted ? Color(hex: "5DB874") :
                            room.isEntrance    ? Color.primaryBlueDark :
                            Color(hex: "A8C4E0"),
                            lineWidth: room.isHighlighted || room.isEntrance ? 1.5 : 1
                        )
                )
//coloring of the cell
            Text(room.name)
                .font(.custom("Inter_18pt-Medium", size: 7.5))
                .foregroundColor(
                    room.isEntrance    ? .white :
                    room.isHighlighted ? Color(hex: "276B34") :
                    Color(hex: "2C5282")
                )
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .padding(5)
        }
        .frame(width: rw, height: rh)
        .position(x: rx, y: ry)
    }

    // MARK: - path color and design
    @ViewBuilder
    private func routePath(w: CGFloat, h: CGFloat) -> some View {
        if selectedFloor == 0 {
            let entrance  = CGPoint(x: (0.63 + 0.11) * w, y: (0.69 + 0.06) * h)
            let midH      = CGPoint(x: entrance.x,          y: (0.51 + 0.075) * h)
            let midV      = CGPoint(x: (0.62 + 0.18) * w,   y: midH.y)
            let labBottom = CGPoint(x: midV.x,               y: (0.03 + 0.28) * h)

            Path { p in
                p.move(to: entrance)
                p.addLine(to: midH)
                p.addLine(to: midV)
                p.addLine(to: labBottom)
            }
            .stroke(
                Color.primaryBlueDark,
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [6, 4])
            )

            // arrow head
            Path { p in
                p.move(to: CGPoint(x: labBottom.x, y: labBottom.y - 8))
                p.addLine(to: CGPoint(x: labBottom.x - 5, y: labBottom.y + 2))
                p.addLine(to: CGPoint(x: labBottom.x + 5, y: labBottom.y + 2))
                p.closeSubpath()
            }
            .fill(Color.primaryBlueDark)
        }
    }

    // MARK: - legend helper
    private func legendDot(color: Color, label: String, isLine: Bool = false) -> some View {
        HStack(spacing: 6) {
            if isLine {
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 18, height: 3)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(color.opacity(0.4), lineWidth: 1))
                    .frame(width: 14, height: 14)
            }
            Text(label)
                .font(.custom("Inter_18pt-Regular", size: 11))
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Manual Search Sheet
private struct ManualSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var start       = ""
    @State private var destination = ""
    @State private var didSearch   = false
//holding the start and destination locations
    private let suggestions = [
        "Reception", "Laboratory", "Pharmacy", "MRI Suite",
        "Ultrasound Room", "Cardiology", "Neurology", "ICU",
        "Operating Theatre", "Radiology",
    ]
//to offer suggestions
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Find a Department")
                    .font(.custom("Inter_18pt-Bold", size: 18))
                    .foregroundColor(.textPrimary)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Color.surfaceMuted)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            VStack(spacing: 20) {
                searchField(label: "Start",
                            placeholder: "e.g. Entrance, Reception …",
                            icon: "location.circle",
                            text: $start)

                searchField(label: "Destination",
                            placeholder: "e.g. Laboratory, Cardiology …",
                            icon: "mappin.circle",
                            text: $destination)
//quick search tips, basically chips to give options
                if !didSearch {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick destinations")
                            .font(.custom("Inter_18pt-Medium", size: 12))
                            .foregroundColor(.textSecondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(suggestions, id: \.self) { s in
                                    Button { destination = s } label: {
                                        Text(s)
                                            .font(.custom("Inter_18pt-Regular", size: 12))
                                            .foregroundColor(.primaryBlue)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(Color.primaryBlueTint)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }
                    }
                }

                if didSearch {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "5DB874"))
                        Text("Route found: \(start.isEmpty ? "Entrance" : start) → \(destination)")
                            .font(.custom("Inter_18pt-Medium", size: 13))
                            .foregroundColor(.textPrimary)
                        Spacer()
                    }
                    .padding(14)
                    .background(Color(hex: "D4EDD6"))
                    .cornerRadius(12)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
//if the start position is set as null this will make the start the entrance
                Button {
                    withAnimation { didSearch = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
                } label: {
                    Text("Search")
                        .font(.custom("Inter_18pt-SemiBold", size: 15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(destination.isEmpty ? Color.textTertiary : Color.primaryBlueDark)
                        .cornerRadius(14)
                }
                .disabled(destination.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }

    private func searchField(label: String, placeholder: String, icon: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.custom("Inter_18pt-SemiBold", size: 14))
                .foregroundColor(.textPrimary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(.primaryBlue)
                    .frame(width: 20)
                TextField(placeholder, text: text)
                    .font(.custom("Inter_18pt-Regular", size: 14))
                    .foregroundColor(.textPrimary)
                if !text.wrappedValue.isEmpty {
                    Button { text.wrappedValue = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.surfaceMuted, lineWidth: 1))
        }
    }
}

#Preview {
    NavigationStack { ClinicMapView() }
}

//
//  MapView.swift
//  IOS Clinic Flow
//
//  Created by Lakindu Siriwardena on 2026-03-10.
//  Routing update 2026-03-11 — tap / type any room to get a live path.
//

import SwiftUI

// MARK: - Room
private struct RoomInfo: Identifiable {
    let id = UUID()
    let name: String
    let x: CGFloat; let y: CGFloat
    let width: CGFloat; let height: CGFloat
    var isEntrance: Bool = false

    /// Centre point in normalised [0,1] space
    var cx: CGFloat { x + width  / 2 }
    var cy: CGFloat { y + height / 2 }
}

// MARK: - Route definition
/// A pre-authored route between two named rooms on the same floor.
/// `waypoints` are normalised (0…1) coordinates that hug corridors.
private struct RouteDefinition {
    let from: String
    let to:   String
    let waypoints: [CGPoint]   // in normalised space; multiply by (w,h) at draw time
    let steps: [String]
}

// MARK: - Floor data
private struct FloorData {
    let floor: Int
    let rooms: [RoomInfo]
    let routes: [RouteDefinition]
    let defaultFrom: String
    let defaultTo:   String
}

// MARK: - All floors + routes
//
// Corridor geometry reference (normalised 0…1):
//
// FLOOR 1
//   H-corridor  : y 0.66–0.79  (below all rooms; Entrance sits at y 0.69–0.81)
//   V-right spine: x 0.86–0.98, y 0.03–0.66  (right of Laboratory)
//   Gap between rooms row 1 and row 2 (x 0.35–0.38, y 0.29): tiny vertical gap used for MRI/Waiting
//   All routes must travel DOWN to y≈0.72 (H-corridor centre) before turning horizontally,
//   then UP the right spine (x 0.92) to reach Laboratory, or stay in H-corridor for other rooms.
//
// FLOOR 2
//   H-corridor  : y 0.52–0.76  (below all three rows of rooms)
//   All vertical traversal must happen inside x-gaps between rooms:
//     Left gap    : x 0.00–0.02 … use x 0.01  — too narrow; use gap between Cardiology & Neurology: x 0.32–0.36, centre x 0.34
//     Centre gap  : x 0.64–0.70, centre x 0.67  (between Neurology right edge 0.66 and Radiology left 0.70)
//     Right edge  : x 0.96–0.98, centre x 0.97  (right of Radiology)
//     ICU right edge: x 0.46, gap to Waiting Lounge left 0.50 → use x 0.48
//
// FLOOR 3
//   H-corridor  : y 0.52–0.75  (below all rooms)
//   Vertical gaps: left of map x 0.00–0.02 (use x 0.01), gap between theatres x 0.46–0.50 (use x 0.48)
//   All routes go down to y 0.63 (H-corridor centre) then horizontal then up.

private let floorData: [FloorData] = [

    // ── Floor 1 ──────────────────────────────────────────────────────────────
    // Room edges (right/bottom):
    //   Pharmacy        x: 0.02–0.28   y: 0.03–0.25
    //   Waiting Area    x: 0.30–0.60   y: 0.03–0.16
    //   MRI Suite       x: 0.30–0.48   y: 0.18–0.30
    //   Laboratory      x: 0.62–0.98   y: 0.03–0.31
    //   Ultrasound Room x: 0.02–0.35   y: 0.29–0.51
    //   Room 02         x: 0.38–0.60   y: 0.30–0.48
    //   Room 01         x: 0.63–0.85   y: 0.30–0.48
    //   Reception       x: 0.38–0.85   y: 0.51–0.66
    //   Elevator        x: 0.02–0.24   y: 0.60–0.78
    //   Entrance        x: 0.63–0.85   y: 0.69–0.81
    //
    // H-corridor centre: y = 0.84  (below Entrance bottom 0.81, below Elevator bottom 0.78)
    // V-right spine    : x = 0.92  (right of Laboratory right edge 0.98 — use gap right side)
    //   Actually Lab is at x 0.62–0.98, so right spine must go LEFT of Lab: x = 0.60
    //   But Room 01 is x 0.63–0.85. So safest vertical to reach Lab is x = 0.60 (between Room01 right
    //   edge 0.85 and Lab — no, Lab starts at 0.62 and Room01 starts at 0.63, they overlap in x).
    //   Use x = 0.60 which is just left of both Lab (0.62) and Room01 (0.63). ✓
    // Left vertical    : x = 0.36  (gap between Ultrasound right 0.35 and Room02 left 0.38)
    //   For Pharmacy/Ultrasound access use x = 0.15 (inside Pharmacy/Ultrasound x range but
    //   going only from room door downward within that room's x — path enters/exits room edge,
    //   not passing THROUGH another room).
    //
    // Safe corridor-only waypoint rules for Floor 1:
    //   • Every route exits its room door downward to y=0.84 first
    //   • Then travels horizontally at y=0.84
    //   • Then ascends to destination via a clear vertical lane
    //
    // Clear vertical lanes:
    //   x=0.15  : left lane  (inside Pharmacy/Ultrasound column — safe going down from those rooms)
    //   x=0.36  : mid-left lane (gap: Ultrasound right 0.35 | Room02 left 0.38) ✓
    //   x=0.60  : mid lane   (gap: Room01/Lab left is 0.62/0.63 — use 0.60 as approach lane) ✓
    //   x=0.92  : right lane — but Lab occupies x 0.62–0.98, so NO right lane exists above Reception
    //
    // MRI Suite sits at x 0.30–0.48, y 0.18–0.30. The gap to its left: x=0.28–0.30 (narrow).
    //   Use x=0.36 lane to reach y=0.30 (MRI bottom), then x=0.39 (MRI centre x).
    //   x=0.36 lane goes from y=0.84 up to y=0.30 safely (Room02 starts at y=0.30, same level).
    //   Need y=0.29 to be clear at x=0.36: Room02 left is 0.38, so x=0.36 is clear. ✓
    //
    // Waiting Area sits at x 0.30–0.60, y 0.03–0.16.
    //   x=0.36 lane: from y=0.84 up to y=0.16 (Waiting Area bottom). Is x=0.36 clear y=0.16–0.29?
    //   That gap is between Waiting Area bottom (0.16) and MRI top (0.18) — only 0.02 gap.
    //   Better: use x=0.45 (centre of Waiting Area). x=0.45 lane from y=0.84 up:
    //     passes through Room02 (x 0.38–0.60, y 0.30–0.48) — BLOCKED.
    //   Use x=0.36 up to y=0.29 (just above Room02 top), then diagonal is not allowed.
    //   Must go: H-corridor → x=0.36 up to y=0.29 → then horizontal to x=0.45 at y=0.29 → up to y=0.16. ✓
    FloorData(
        floor: 1,
        rooms: [
            RoomInfo(name: "Pharmacy",        x: 0.02, y: 0.03, width: 0.26, height: 0.22),
            RoomInfo(name: "Waiting Area",    x: 0.30, y: 0.03, width: 0.30, height: 0.13),
            RoomInfo(name: "MRI Suite",       x: 0.30, y: 0.18, width: 0.18, height: 0.12),
            RoomInfo(name: "Laboratory",      x: 0.62, y: 0.03, width: 0.36, height: 0.28),
            RoomInfo(name: "Ultrasound Room", x: 0.02, y: 0.29, width: 0.33, height: 0.22),
            RoomInfo(name: "Room 02",         x: 0.38, y: 0.30, width: 0.22, height: 0.18),
            RoomInfo(name: "Room 01",         x: 0.63, y: 0.30, width: 0.22, height: 0.18),
            RoomInfo(name: "Reception",       x: 0.38, y: 0.51, width: 0.47, height: 0.15),
            RoomInfo(name: "Elevator",        x: 0.02, y: 0.60, width: 0.22, height: 0.18),
            RoomInfo(name: "Entrance",        x: 0.63, y: 0.69, width: 0.22, height: 0.12, isEntrance: true),
        ],
        routes: [
            // Entrance → Laboratory
            // Entrance door: bottom-centre x=0.74, y=0.81
            // Down to H-corridor y=0.84, right to x=0.60, up clear lane x=0.60 to y=0.17 (Lab centre y)
            RouteDefinition(
                from: "Entrance", to: "Laboratory",
                waypoints: [
                    CGPoint(x: 0.74, y: 0.81), // exit Entrance door (bottom)
                    CGPoint(x: 0.74, y: 0.84), // H-corridor
                    CGPoint(x: 0.60, y: 0.84), // travel left in H-corridor to x=0.60 lane
                    CGPoint(x: 0.60, y: 0.17), // up clear lane (left of Lab at x=0.62)
                ],
                steps: ["Enter through the main entrance.", "Head into the main corridor.", "Walk left to the central lane.", "Head north — Laboratory is on your right."]
            ),
            // Entrance → Reception
            // Reception top-centre: x=0.61, y=0.51. Enter from below at y=0.66.
            RouteDefinition(
                from: "Entrance", to: "Reception",
                waypoints: [
                    CGPoint(x: 0.74, y: 0.81),
                    CGPoint(x: 0.74, y: 0.84),
                    CGPoint(x: 0.61, y: 0.84),
                    CGPoint(x: 0.61, y: 0.66), // enter Reception from its bottom edge
                ],
                steps: ["Enter through the main entrance.", "Head into the main corridor.", "Walk left.", "Reception is directly ahead."]
            ),
            // Entrance → Pharmacy
            // Pharmacy bottom-centre: x=0.15, y=0.25. Must go via H-corridor → x=0.15 lane up.
            // x=0.15 lane y=0.84→0.25: passes through Ultrasound Room (y 0.29–0.51) — BLOCKED at x=0.15.
            // Route: H-corridor → x=0.36 lane up to y=0.51 (Ultrasound bottom) → x=0.15 at y=0.51 → up to y=0.25.
            // Wait — Ultrasound x: 0.02–0.35. So x=0.36 is just RIGHT of Ultrasound (clear). ✓
            // x=0.36 from y=0.84 to y=0.51 is clear (Room02 starts at y=0.30, x=0.38–0.60 — x=0.36 is left of Room02). ✓
            // Then from (0.36, 0.51) go left to (0.15, 0.51) — this travels through Ultrasound Room bottom edge (y=0.51). Borderline.
            // Better: go to y=0.27 (between Pharmacy bottom 0.25 and Ultrasound top 0.29) at x=0.36,
            //   then left to x=0.15 at y=0.27 — but does x=0.15→0.36 at y=0.27 cross anything?
            //   Pharmacy occupies x=0.02–0.28, y=0.03–0.25. y=0.27 is below Pharmacy bottom. Clear. ✓
            //   Ultrasound occupies y=0.29–0.51. y=0.27 is above Ultrasound top. Clear. ✓
            RouteDefinition(
                from: "Entrance", to: "Pharmacy",
                waypoints: [
                    CGPoint(x: 0.74, y: 0.81),
                    CGPoint(x: 0.74, y: 0.84),
                    CGPoint(x: 0.36, y: 0.84), // H-corridor to left lane
                    CGPoint(x: 0.36, y: 0.27), // up left lane to gap between Pharmacy and Ultrasound
                    CGPoint(x: 0.15, y: 0.27), // travel left in the gap
                    CGPoint(x: 0.15, y: 0.25), // enter Pharmacy from bottom
                ],
                steps: ["Enter through the main entrance.", "Head into the main corridor.", "Turn left and walk to the left lane.", "Head north past the mid section.", "Turn left into the Pharmacy corridor.", "Pharmacy is on your right."]
            ),
            // Entrance → Elevator
            // Elevator bottom-centre: x=0.13, y=0.78. In H-corridor at y=0.84 → x=0.13 → up.
            RouteDefinition(
                from: "Entrance", to: "Elevator",
                waypoints: [
                    CGPoint(x: 0.74, y: 0.81),
                    CGPoint(x: 0.74, y: 0.84),
                    CGPoint(x: 0.13, y: 0.84),
                    CGPoint(x: 0.13, y: 0.78), // enter Elevator from bottom
                ],
                steps: ["Enter through the main entrance.", "Head into the main corridor.", "Turn left and walk to the far end.", "The Elevator is on your right."]
            ),
            // Entrance → MRI Suite
            // MRI Suite bottom-centre: x=0.39, y=0.30.
            // Route: H-corridor → x=0.36 lane up to y=0.29 → x=0.39 at y=0.29 → enter MRI from bottom.
            RouteDefinition(
                from: "Entrance", to: "MRI Suite",
                waypoints: [
                    CGPoint(x: 0.74, y: 0.81),
                    CGPoint(x: 0.74, y: 0.84),
                    CGPoint(x: 0.36, y: 0.84),
                    CGPoint(x: 0.36, y: 0.29), // up left-mid lane (clear of Room02 which starts x=0.38)
                    CGPoint(x: 0.39, y: 0.29), // slight right into MRI bottom
                ],
                steps: ["Enter through the main entrance.", "Head into the main corridor.", "Turn left along the corridor.", "Head north up the left-centre lane.", "MRI Suite is on your right."]
            ),
            // Entrance → Ultrasound Room
            // Ultrasound bottom-centre: x=0.18, y=0.51.
            // Route: H-corridor → x=0.36 lane up to y=0.51 → x=0.18 at y=0.51.
            // x=0.36 up from y=0.84 to y=0.51: clear (Room02 is x=0.38–0.60). ✓
            // Horizontal x=0.36→0.18 at y=0.51: passes through Ultrasound bottom edge. Enter from bottom-right. ✓
            RouteDefinition(
                from: "Entrance", to: "Ultrasound Room",
                waypoints: [
                    CGPoint(x: 0.74, y: 0.81),
                    CGPoint(x: 0.74, y: 0.84),
                    CGPoint(x: 0.36, y: 0.84),
                    CGPoint(x: 0.36, y: 0.51), // up left-mid lane to Ultrasound level
                    CGPoint(x: 0.18, y: 0.51), // enter Ultrasound from bottom-right
                ],
                steps: ["Enter through the main entrance.", "Head into the main corridor.", "Turn left.", "Head north up the left-centre lane.", "Ultrasound Room is on your left."]
            ),
            // Entrance → Waiting Area
            // Waiting Area bottom-centre: x=0.45, y=0.16.
            // Route: H-corridor → x=0.36 lane to y=0.29 → horizontal to x=0.45 at y=0.29 → up to y=0.16.
            // x=0.36→0.45 at y=0.29: this skims the top of Room02 (y=0.30). Use y=0.28 to stay clear.
            // x=0.45 from y=0.28 up to y=0.16: clear (Waiting Area is x=0.30–0.60, we exit at y=0.16 bottom). ✓
            RouteDefinition(
                from: "Entrance", to: "Waiting Area",
                waypoints: [
                    CGPoint(x: 0.74, y: 0.81),
                    CGPoint(x: 0.74, y: 0.84),
                    CGPoint(x: 0.36, y: 0.84),
                    CGPoint(x: 0.36, y: 0.28), // up to just above Room02 top
                    CGPoint(x: 0.45, y: 0.28), // cross right in the gap
                    CGPoint(x: 0.45, y: 0.16), // enter Waiting Area from bottom
                ],
                steps: ["Enter through the main entrance.", "Head into the main corridor.", "Turn left.", "Head north up the left-centre lane.", "Turn right in the gap above Room 02.", "Waiting Area is directly ahead."]
            ),
            // Reception → Laboratory
            RouteDefinition(
                from: "Reception", to: "Laboratory",
                waypoints: [
                    CGPoint(x: 0.61, y: 0.66), // exit Reception bottom
                    CGPoint(x: 0.61, y: 0.84),
                    CGPoint(x: 0.60, y: 0.84),
                    CGPoint(x: 0.60, y: 0.17), // up x=0.60 lane
                ],
                steps: ["Exit Reception.", "Enter the main corridor.", "Head to the central lane.", "Laboratory is directly ahead."]
            ),
            // Elevator → Laboratory
            RouteDefinition(
                from: "Elevator", to: "Laboratory",
                waypoints: [
                    CGPoint(x: 0.13, y: 0.78), // exit Elevator bottom
                    CGPoint(x: 0.13, y: 0.84),
                    CGPoint(x: 0.60, y: 0.84),
                    CGPoint(x: 0.60, y: 0.17),
                ],
                steps: ["Exit the Elevator.", "Enter the main corridor.", "Turn right and walk to the central lane.", "Head north — Laboratory is on your right."]
            ),
            // Pharmacy → Laboratory
            RouteDefinition(
                from: "Pharmacy", to: "Laboratory",
                waypoints: [
                    CGPoint(x: 0.15, y: 0.25), // exit Pharmacy bottom
                    CGPoint(x: 0.15, y: 0.27),
                    CGPoint(x: 0.36, y: 0.27), // cross right to clear lane
                    CGPoint(x: 0.36, y: 0.84),
                    CGPoint(x: 0.60, y: 0.84),
                    CGPoint(x: 0.60, y: 0.17),
                ],
                steps: ["Exit Pharmacy.", "Cross right to the corridor.", "Head south to the main corridor.", "Turn right.", "Head north up the central lane.", "Laboratory is on your right."]
            ),
            // Room 01 → Room 02
            // Room01: x 0.63–0.85, y 0.30–0.48. Bottom-centre x=0.74, y=0.48.
            // Room02: x 0.38–0.60, y 0.30–0.48. Bottom-centre x=0.49, y=0.48.
            // Both rooms share the same y bottom (0.48). Gap between them: x=0.60–0.63.
            // Route: exit Room01 bottom → y=0.50 (just below both rooms) → x=0.49 → enter Room02 bottom.
            // y=0.50 is clear between Room02 bottom (0.48) and Reception top (0.51). Tight but valid.
            RouteDefinition(
                from: "Room 01", to: "Room 02",
                waypoints: [
                    CGPoint(x: 0.74, y: 0.48), // exit Room01 bottom
                    CGPoint(x: 0.74, y: 0.50), // step into gap below rooms
                    CGPoint(x: 0.49, y: 0.50), // travel left in gap
                    CGPoint(x: 0.49, y: 0.48), // enter Room02 bottom
                ],
                steps: ["Exit Room 01.", "Step into the gap below.", "Walk left to Room 02.", "Enter Room 02."]
            ),
            // Pharmacy → Ultrasound Room
            // Both share the left column. Pharmacy bottom y=0.25, Ultrasound top y=0.29. Gap y=0.25–0.29.
            // Route: exit Pharmacy bottom → y=0.27 → x=0.15 → y=0.29 enter Ultrasound.
            RouteDefinition(
                from: "Pharmacy", to: "Ultrasound Room",
                waypoints: [
                    CGPoint(x: 0.15, y: 0.25), // Pharmacy bottom
                    CGPoint(x: 0.15, y: 0.27), // gap
                    CGPoint(x: 0.15, y: 0.29), // Ultrasound top
                ],
                steps: ["Exit Pharmacy.", "Walk through the connecting gap.", "Ultrasound Room is immediately below."]
            ),
            // Reception → Elevator
            RouteDefinition(
                from: "Reception", to: "Elevator",
                waypoints: [
                    CGPoint(x: 0.61, y: 0.66), // Reception bottom
                    CGPoint(x: 0.61, y: 0.84),
                    CGPoint(x: 0.13, y: 0.84),
                    CGPoint(x: 0.13, y: 0.78), // Elevator bottom
                ],
                steps: ["Exit Reception.", "Enter the main corridor.", "Turn left and walk to the far end.", "Elevator is on your right."]
            ),
        ],
        defaultFrom: "Entrance",
        defaultTo:   "Laboratory"
    ),

    // ── Floor 2 ──────────────────────────────────────────────────────────────
    // Room edges:
    //   Cardiology     x: 0.02–0.32  y: 0.03–0.25
    //   Neurology      x: 0.36–0.66  y: 0.03–0.25
    //   Radiology      x: 0.70–0.98  y: 0.03–0.25
    //   ICU            x: 0.02–0.46  y: 0.30–0.52
    //   Waiting Lounge x: 0.50–0.98  y: 0.30–0.52
    //   Nurses Station x: 0.02–0.38  y: 0.58–0.76
    //   Elevator       x: 0.42–0.64  y: 0.58–0.76
    //   Stairwell      x: 0.70–0.98  y: 0.58–0.76
    //
    // H-corridor: y 0.53–0.57  (gap between lower rooms top 0.58 and middle row bottom 0.52)
    //   Actually use y=0.55 as corridor centre.
    // ALSO: gap below lower rooms bottom (0.76) → use y=0.80 as lower H-corridor.
    // Vertical lanes (must not cross rooms):
    //   x=0.34 : gap between Cardiology right (0.32) and Neurology left (0.36). ✓ for top rows.
    //   x=0.68 : gap between Neurology right (0.66) and Radiology left (0.70). ✓ for top rows.
    //   x=0.48 : gap between ICU right (0.46) and Waiting Lounge left (0.50). ✓ for mid row.
    //   x=0.40 : gap between Nurses Station right (0.38) and Elevator left (0.42). ✓ for lower row.
    //   x=0.67 : gap between Elevator right (0.64) and Stairwell left (0.70). ✓ for lower row.
    //
    // Strategy: all routes go via H-corridor at y=0.80 (below all rooms), then up safe vertical lanes.
    FloorData(
        floor: 2,
        rooms: [
            RoomInfo(name: "Cardiology",     x: 0.02, y: 0.03, width: 0.30, height: 0.22),
            RoomInfo(name: "Neurology",      x: 0.36, y: 0.03, width: 0.30, height: 0.22),
            RoomInfo(name: "Radiology",      x: 0.70, y: 0.03, width: 0.28, height: 0.22),
            RoomInfo(name: "ICU",            x: 0.02, y: 0.30, width: 0.44, height: 0.22),
            RoomInfo(name: "Waiting Lounge", x: 0.50, y: 0.30, width: 0.48, height: 0.22),
            RoomInfo(name: "Nurses Station", x: 0.02, y: 0.58, width: 0.36, height: 0.18),
            RoomInfo(name: "Elevator",       x: 0.42, y: 0.58, width: 0.22, height: 0.18, isEntrance: true),
            RoomInfo(name: "Stairwell",      x: 0.70, y: 0.58, width: 0.28, height: 0.18),
        ],
        routes: [
            // Elevator → ICU
            // Elevator bottom x=0.53, y=0.76. ICU bottom-right: x=0.46 approach, y=0.52.
            // Route: Elevator bottom → y=0.80 → x=0.48 → y=0.52 → x=0.24 (ICU centre) via y=0.52.
            RouteDefinition(
                from: "Elevator", to: "ICU",
                waypoints: [
                    CGPoint(x: 0.53, y: 0.76),
                    CGPoint(x: 0.53, y: 0.80),
                    CGPoint(x: 0.48, y: 0.80), // left to ICU/WL gap lane
                    CGPoint(x: 0.48, y: 0.52), // up to mid-row bottom
                    CGPoint(x: 0.24, y: 0.52), // left into ICU bottom
                ],
                steps: ["Exit the elevator.", "Head into the lower corridor.", "Move to the central lane.", "Head north.", "ICU is on your left."]
            ),
            // Elevator → Cardiology
            RouteDefinition(
                from: "Elevator", to: "Cardiology",
                waypoints: [
                    CGPoint(x: 0.53, y: 0.76),
                    CGPoint(x: 0.53, y: 0.80),
                    CGPoint(x: 0.34, y: 0.80), // left to Cardiology/Neurology gap lane
                    CGPoint(x: 0.34, y: 0.25), // up clear lane (gap between Cardiology & Neurology)
                    CGPoint(x: 0.17, y: 0.25), // enter Cardiology from bottom-right
                ],
                steps: ["Exit the elevator.", "Head into the lower corridor.", "Move to the left lane.", "Head north.", "Cardiology is on your left."]
            ),
            // Elevator → Neurology
            RouteDefinition(
                from: "Elevator", to: "Neurology",
                waypoints: [
                    CGPoint(x: 0.53, y: 0.76),
                    CGPoint(x: 0.53, y: 0.80),
                    CGPoint(x: 0.34, y: 0.80),
                    CGPoint(x: 0.34, y: 0.25), // up Cardiology/Neurology gap
                    CGPoint(x: 0.51, y: 0.25), // enter Neurology from bottom-left
                ],
                steps: ["Exit the elevator.", "Head into the lower corridor.", "Move to the left-centre lane.", "Head north.", "Neurology is on your right."]
            ),
            // Elevator → Radiology
            RouteDefinition(
                from: "Elevator", to: "Radiology",
                waypoints: [
                    CGPoint(x: 0.53, y: 0.76),
                    CGPoint(x: 0.53, y: 0.80),
                    CGPoint(x: 0.68, y: 0.80), // right to Neurology/Radiology gap
                    CGPoint(x: 0.68, y: 0.25), // up clear lane
                    CGPoint(x: 0.84, y: 0.25), // enter Radiology from bottom-left
                ],
                steps: ["Exit the elevator.", "Head into the lower corridor.", "Move to the right-centre lane.", "Head north.", "Radiology is on your right."]
            ),
            // Elevator → Waiting Lounge
            RouteDefinition(
                from: "Elevator", to: "Waiting Lounge",
                waypoints: [
                    CGPoint(x: 0.53, y: 0.76),
                    CGPoint(x: 0.53, y: 0.80),
                    CGPoint(x: 0.74, y: 0.80), // right
                    CGPoint(x: 0.74, y: 0.52), // up into Waiting Lounge bottom
                ],
                steps: ["Exit the elevator.", "Head into the lower corridor.", "Turn right.", "Waiting Lounge is directly ahead."]
            ),
            // Elevator → Nurses Station
            RouteDefinition(
                from: "Elevator", to: "Nurses Station",
                waypoints: [
                    CGPoint(x: 0.53, y: 0.76),
                    CGPoint(x: 0.53, y: 0.80),
                    CGPoint(x: 0.20, y: 0.80),
                    CGPoint(x: 0.20, y: 0.76), // enter Nurses Station from bottom
                ],
                steps: ["Exit the elevator.", "Head into the lower corridor.", "Turn left.", "Nurses Station is on your right."]
            ),
            // Nurses Station → ICU
            // Nurses Station top x=0.20, y=0.58. ICU bottom-left x=0.24, y=0.52.
            // Gap between Nurses Station top (0.58) and ICU bottom (0.52): y=0.52–0.58 is clear. ✓
            RouteDefinition(
                from: "Nurses Station", to: "ICU",
                waypoints: [
                    CGPoint(x: 0.20, y: 0.58), // Nurses Station top-centre
                    CGPoint(x: 0.20, y: 0.52), // ICU bottom (same x column)
                ],
                steps: ["Exit the Nurses Station (top).", "ICU is directly above."]
            ),
            // Stairwell → ICU
            RouteDefinition(
                from: "Stairwell", to: "ICU",
                waypoints: [
                    CGPoint(x: 0.84, y: 0.76),
                    CGPoint(x: 0.84, y: 0.80),
                    CGPoint(x: 0.48, y: 0.80),
                    CGPoint(x: 0.48, y: 0.52),
                    CGPoint(x: 0.24, y: 0.52),
                ],
                steps: ["Exit the Stairwell.", "Head into the lower corridor.", "Walk left to the central lane.", "Head north.", "ICU is on your left."]
            ),
            // ICU → Waiting Lounge
            RouteDefinition(
                from: "ICU", to: "Waiting Lounge",
                waypoints: [
                    CGPoint(x: 0.24, y: 0.52), // ICU bottom-centre
                    CGPoint(x: 0.48, y: 0.52), // cross right to gap lane
                    CGPoint(x: 0.48, y: 0.80), // down to H-corridor
                    CGPoint(x: 0.74, y: 0.80), // right
                    CGPoint(x: 0.74, y: 0.52), // up into Waiting Lounge
                ],
                steps: ["Exit the ICU.", "Move to the central gap.", "Head south to the corridor.", "Turn right.", "Waiting Lounge is ahead."]
            ),
            // Cardiology → Neurology
            // x=0.34 lane: y=0.25 to y=0.29 is clear (ICU top is y=0.30). ✓
            // Then right to x=0.48 (ICU/WL gap) at y=0.29.
            // x=0.48 down from y=0.29 to y=0.80 is clear (passes between ICU right 0.46 and WL left 0.50). ✓
            // Then right to x=0.51, up to y=0.25 (Neurology bottom via x=0.34 gap on the Neurology side).
            // Actually better: from (0.48, 0.80) → right to (0.34, 0.80)... wait, need to go RIGHT to reach Neurology.
            // Neurology x=0.36–0.66. Enter bottom at x=0.51, y=0.25.
            // x=0.48 at y=0.80 → right to x=0.51 → up to y=0.29 (clear, ICU top 0.30) → up to y=0.25.
            RouteDefinition(
                from: "Cardiology", to: "Neurology",
                waypoints: [
                    CGPoint(x: 0.17, y: 0.25), // Cardiology bottom
                    CGPoint(x: 0.34, y: 0.25), // right to gap lane (Cardiology right 0.32 | Neurology left 0.36)
                    CGPoint(x: 0.34, y: 0.29), // down to just above ICU top (0.30)
                    CGPoint(x: 0.48, y: 0.29), // right to ICU/WL gap lane
                    CGPoint(x: 0.48, y: 0.80), // down to H-corridor
                    CGPoint(x: 0.51, y: 0.80), // slight right
                    CGPoint(x: 0.51, y: 0.29), // up ICU/WL gap lane
                    CGPoint(x: 0.51, y: 0.25), // enter Neurology bottom
                ],
                steps: ["Exit Cardiology.", "Move right to the gap lane.", "Head south to just above the mid row.", "Cross right to the central gap.", "Continue south to the main corridor.", "Move slightly right.", "Head north up the central lane.", "Neurology is directly ahead."]
            ),
        ],
        defaultFrom: "Elevator",
        defaultTo:   "ICU"
    ),

    // ── Floor 3 ──────────────────────────────────────────────────────────────
    // Room edges:
    //   Op. Theatre 1  x: 0.02–0.46  y: 0.03–0.28
    //   Op. Theatre 2  x: 0.50–0.98  y: 0.03–0.28
    //   Recovery Room  x: 0.02–0.38  y: 0.32–0.52
    //   Surgical ICU   x: 0.42–0.72  y: 0.32–0.52
    //   Sterilisation  x: 0.76–0.98  y: 0.32–0.52
    //   Scrub Room     x: 0.02–0.28  y: 0.57–0.75
    //   Storage        x: 0.32–0.54  y: 0.57–0.75
    //   Elevator       x: 0.60–0.82  y: 0.57–0.75
    //
    // H-corridor: y=0.78 (below all lower rooms bottom 0.75)
    // Vertical lanes:
    //   x=0.48 : gap between Op.Theatre1 right (0.46) and Op.Theatre2 left (0.50). Top rows. ✓
    //   x=0.40 : gap between Recovery right (0.38) and Surgical ICU left (0.42). Mid row. ✓
    //   x=0.74 : gap between Surgical ICU right (0.72) and Sterilisation left (0.76). Mid row. ✓
    //   x=0.30 : gap between Scrub Room right (0.28) and Storage left (0.32). Lower row. ✓
    //   x=0.57 : gap between Storage right (0.54) and Elevator left (0.60). Lower row. ✓
    //   x=0.84 : gap right of Elevator right (0.82). Lower row. ✓
    FloorData(
        floor: 3,
        rooms: [
            RoomInfo(name: "Op. Theatre 1", x: 0.02, y: 0.03, width: 0.44, height: 0.25),
            RoomInfo(name: "Op. Theatre 2", x: 0.50, y: 0.03, width: 0.48, height: 0.25),
            RoomInfo(name: "Recovery Room", x: 0.02, y: 0.32, width: 0.36, height: 0.20),
            RoomInfo(name: "Surgical ICU",  x: 0.42, y: 0.32, width: 0.30, height: 0.20),
            RoomInfo(name: "Sterilisation", x: 0.76, y: 0.32, width: 0.22, height: 0.20),
            RoomInfo(name: "Scrub Room",    x: 0.02, y: 0.57, width: 0.26, height: 0.18),
            RoomInfo(name: "Storage",       x: 0.32, y: 0.57, width: 0.22, height: 0.18),
            RoomInfo(name: "Elevator",      x: 0.60, y: 0.57, width: 0.22, height: 0.18, isEntrance: true),
        ],
        routes: [
            // Elevator → Recovery Room
            // Route: Elevator bottom → y=0.78 → x=0.40 lane → y=0.52 → x=0.20 (Recovery centre).
            RouteDefinition(
                from: "Elevator", to: "Recovery Room",
                waypoints: [
                    CGPoint(x: 0.71, y: 0.75), // Elevator bottom
                    CGPoint(x: 0.71, y: 0.78),
                    CGPoint(x: 0.40, y: 0.78), // left to Recovery/SurgICU gap lane
                    CGPoint(x: 0.40, y: 0.52), // up to mid-row bottom
                    CGPoint(x: 0.20, y: 0.52), // left into Recovery Room
                ],
                steps: ["Exit the elevator.", "Head into the lower corridor.", "Move to the central lane.", "Head north.", "Recovery Room is on your left."]
            ),
            // Elevator → Surgical ICU
            RouteDefinition(
                from: "Elevator", to: "Surgical ICU",
                waypoints: [
                    CGPoint(x: 0.71, y: 0.75),
                    CGPoint(x: 0.71, y: 0.78),
                    CGPoint(x: 0.57, y: 0.78), // Storage/Elevator gap lane
                    CGPoint(x: 0.57, y: 0.52), // up to mid-row bottom
                    CGPoint(x: 0.57, y: 0.52), // Surgical ICU bottom-centre
                ],
                steps: ["Exit the elevator.", "Head into the lower corridor.", "Move to the left-adjacent lane.", "Head north.", "Surgical ICU is directly ahead."]
            ),
            // Elevator → Sterilisation
            RouteDefinition(
                from: "Elevator", to: "Sterilisation",
                waypoints: [
                    CGPoint(x: 0.71, y: 0.75),
                    CGPoint(x: 0.71, y: 0.78),
                    CGPoint(x: 0.84, y: 0.78), // right to Sterilisation lane
                    CGPoint(x: 0.84, y: 0.52), // up
                    CGPoint(x: 0.87, y: 0.52), // enter Sterilisation bottom
                ],
                steps: ["Exit the elevator.", "Head into the lower corridor.", "Turn right.", "Head north.", "Sterilisation is on your right."]
            ),
            // Elevator → Op. Theatre 1
            RouteDefinition(
                from: "Elevator", to: "Op. Theatre 1",
                waypoints: [
                    CGPoint(x: 0.71, y: 0.75),
                    CGPoint(x: 0.71, y: 0.78),
                    CGPoint(x: 0.40, y: 0.78),
                    CGPoint(x: 0.40, y: 0.52),  // up to mid-row bottom (Recovery/SurgICU gap)
                    CGPoint(x: 0.40, y: 0.30),  // gap between mid row (bottom 0.52) and top row (bottom 0.28) — clear ✓
                    CGPoint(x: 0.24, y: 0.28),  // enter Op.Theatre1 bottom
                ],
                steps: ["Exit the elevator.", "Head into the lower corridor.", "Move to the central lane.", "Head north past the mid level.", "Continue to Op. Theatre 1."]
            ),
            // Elevator → Op. Theatre 2
            // x=0.48 is the gap between OT1 right (0.46) and OT2 left (0.50).
            // Route: Elevator → H-corridor → x=0.48 lane → up through mid-row gap → up to OT2 bottom.
            // Mid row gap: Recovery/SurgICU/Sterilisation all bottom at y=0.52, top at y=0.32.
            // x=0.48 at y=0.52→0.32: x=0.48 is inside Surgical ICU (x 0.42–0.72) — BLOCKED.
            // Must use x=0.40 (Recovery/SurgICU gap) up to y=0.32, then x=0.48 from y=0.32 to y=0.28.
            // x=0.40 from y=0.78 to y=0.32: clear (Recovery x=0.02–0.38, SurgICU x=0.42–0.72). ✓
            RouteDefinition(
                from: "Elevator", to: "Op. Theatre 2",
                waypoints: [
                    CGPoint(x: 0.71, y: 0.75),
                    CGPoint(x: 0.71, y: 0.78),
                    CGPoint(x: 0.40, y: 0.78),  // H-corridor to Recovery/SurgICU gap lane
                    CGPoint(x: 0.40, y: 0.32),  // up to mid-row top
                    CGPoint(x: 0.48, y: 0.32),  // cross right to OT1/OT2 gap lane
                    CGPoint(x: 0.48, y: 0.28),  // enter OT2 from bottom-left edge
                    CGPoint(x: 0.74, y: 0.15),  // Op. Theatre 2 centre
                ],
                steps: ["Exit the elevator.", "Head into the lower corridor.", "Move to the central lane.", "Head north past the mid level.", "Cross to the theatre gap.", "Enter Op. Theatre 2."]
            ),
            // Elevator → Scrub Room
            RouteDefinition(
                from: "Elevator", to: "Scrub Room",
                waypoints: [
                    CGPoint(x: 0.71, y: 0.75),
                    CGPoint(x: 0.71, y: 0.78),
                    CGPoint(x: 0.15, y: 0.78),
                    CGPoint(x: 0.15, y: 0.75), // enter Scrub Room from bottom
                ],
                steps: ["Exit the elevator.", "Head into the lower corridor.", "Turn left — Scrub Room is at the end."]
            ),
            // Scrub Room → Op. Theatre 1
            RouteDefinition(
                from: "Scrub Room", to: "Op. Theatre 1",
                waypoints: [
                    CGPoint(x: 0.15, y: 0.57), // Scrub Room top
                    CGPoint(x: 0.15, y: 0.52), // gap between Scrub top 0.57 and Recovery bottom 0.52
                    CGPoint(x: 0.20, y: 0.52), // enter Recovery approach — actually going to Theatre 1
                    CGPoint(x: 0.20, y: 0.32), // gap between Recovery bottom 0.52 and top (Theatre) bottom 0.28
                    CGPoint(x: 0.24, y: 0.28), // enter Op. Theatre 1 bottom
                ],
                steps: ["Exit the Scrub Room (top).", "Enter the mid corridor.", "Continue north.", "Op. Theatre 1 is directly above."]
            ),
            // Recovery Room → Surgical ICU
            RouteDefinition(
                from: "Recovery Room", to: "Surgical ICU",
                waypoints: [
                    CGPoint(x: 0.20, y: 0.52), // Recovery bottom
                    CGPoint(x: 0.40, y: 0.52), // right to gap lane
                    CGPoint(x: 0.57, y: 0.52), // Surgical ICU bottom-centre
                ],
                steps: ["Exit Recovery Room.", "Move right to the gap.", "Surgical ICU is directly ahead."]
            ),
            // Op. Theatre 1 → Op. Theatre 2
            // Gap between them: x=0.46–0.50 at any y.
            // Both are y=0.03–0.28. Gap centre x=0.48.
            // Route: exit Op.Theatre 1 right edge → x=0.48 at y=0.15 → enter Op.Theatre2 left edge.
            RouteDefinition(
                from: "Op. Theatre 1", to: "Op. Theatre 2",
                waypoints: [
                    CGPoint(x: 0.46, y: 0.15), // exit OT1 right edge at mid height
                    CGPoint(x: 0.50, y: 0.15), // enter OT2 left edge
                ],
                steps: ["Exit Op. Theatre 1 (right side).", "Op. Theatre 2 is directly adjacent."]
            ),
            // Surgical ICU → Sterilisation
            // Gap between them: x=0.72–0.76 at y=0.32–0.52. Gap centre x=0.74.
            RouteDefinition(
                from: "Surgical ICU", to: "Sterilisation",
                waypoints: [
                    CGPoint(x: 0.72, y: 0.42), // exit SurgICU right edge
                    CGPoint(x: 0.76, y: 0.42), // enter Sterilisation left edge
                ],
                steps: ["Exit Surgical ICU (right side).", "Sterilisation is directly adjacent."]
            ),
        ],
        defaultFrom: "Elevator",
        defaultTo:   "Recovery Room"
    ),
]

// MARK: - Routing engine
private func findRoute(floor: FloorData, from: String, to: String) -> RouteDefinition? {
    if from == to { return nil }
    if let r = floor.routes.first(where: { $0.from == from && $0.to == to }) { return r }
    // Reverse the route if exact match not found
    if let r = floor.routes.first(where: { $0.from == to && $0.to == from }) {
        return RouteDefinition(
            from: from, to: to,
            waypoints: r.waypoints.reversed(),
            steps: r.steps.reversed().map { "↩ " + $0 }
        )
    }
    return nil
}

// MARK: - Animated dashed route
private struct AnimatedRoute: View {
    let path: Path
    let color: Color
    @State private var phase: CGFloat = 0
    var body: some View {
        path.stroke(color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round, dash: [7, 5], dashPhase: phase))
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
            Circle().fill(color.opacity(0.22)).frame(width: pulse ? 26 : 14, height: pulse ? 26 : 14)
            Circle().fill(color.opacity(0.45)).frame(width: 14, height: 14)
            Circle().fill(color).frame(width: 7, height: 7)
        }
        .position(position)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}

// MARK: - Route picker field
private struct RoutePickerField: View {
    let icon: String
    let iconColor: Color
    let placeholder: String
    @Binding var text: String
    let allRooms: [String]
    let onSelect: (String) -> Void

    @State private var isEditing = false
    @FocusState private var focused: Bool

    private var filtered: [String] {
        guard !text.isEmpty else { return allRooms }
        return allRooms.filter { $0.localizedCaseInsensitiveContains(text) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
                    .frame(width: 20)
                TextField(placeholder, text: $text, onEditingChanged: { isEditing = $0 })
                    .font(.custom("Inter_18pt-Regular", size: 14))
                    .foregroundColor(.textPrimary)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit {
                        if let match = filtered.first { select(match) }
                    }
                if !text.isEmpty {
                    Button { text = ""; isEditing = true; focused = true } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(focused ? Color.primaryBlue.opacity(0.6) : Color(hex: "E5E7EB"), lineWidth: 1.5))

            // Dropdown suggestions
            if isEditing && !filtered.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(filtered.prefix(5), id: \.self) { room in
                        Button { select(room) } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "mappin").font(.system(size: 11)).foregroundColor(.primaryBlue)
                                Text(room).font(.custom("Inter_18pt-Regular", size: 13)).foregroundColor(.textPrimary)
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                        }
                        if room != filtered.prefix(5).last {
                            Divider().padding(.leading, 38)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
                .zIndex(10)
            }
        }
    }

    private func select(_ room: String) {
        text = room; isEditing = false; focused = false; onSelect(room)
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
    @State private var stepTimer: Timer?

    // Routing state
    @State private var fromText = ""
    @State private var toText   = ""
    @State private var activeRoute: RouteDefinition? = nil
    @State private var pickingFor: PickTarget = .none
    enum PickTarget { case from, to, none }

    private var floor: FloorData { floorData[selectedFloor] }
    private var allRoomNames: [String] { floor.rooms.map(\.name) }

    var body: some View {
        ZStack {
            Color(hex: "F4F6FA").ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // ── Route picker card ────────────────────────────────
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                    .font(.system(size: 14)).foregroundColor(.primaryBlue)
                                Text("Plan your route")
                                    .font(.custom("Inter_18pt-Bold", size: 15)).foregroundColor(.textPrimary)
                                Spacer()
                                if activeRoute != nil {
                                    Button {
                                        withAnimation(.spring()) {
                                            fromText = floor.defaultFrom; toText = floor.defaultTo
                                            resolveRoute()
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.counterclockwise").font(.system(size: 10, weight: .semibold))
                                            Text("Reset").font(.custom("Inter_18pt-Regular", size: 12))
                                        }
                                        .foregroundColor(.primaryBlue)
                                        .padding(.horizontal, 10).padding(.vertical, 5)
                                        .background(Color.primaryBlueTint).cornerRadius(20)
                                    }
                                }
                            }

                            // From / To fields
                            HStack(alignment: .top, spacing: 0) {
                                // Connector icons
                                VStack(spacing: 0) {
                                    Spacer().frame(height: 20)
                                    ZStack {
                                        Circle().fill(Color.primaryBlueDark).frame(width: 10, height: 10)
                                        if pickingFor == .from {
                                            Circle().stroke(Color.primaryBlueDark.opacity(0.4), lineWidth: 3).frame(width: 16, height: 16)
                                        }
                                    }
                                    Rectangle().fill(Color(hex: "D1D5DB")).frame(width: 2, height: 32)
                                    ZStack {
                                        Image(systemName: "mappin.fill").font(.system(size: 12)).foregroundColor(Color(hex: "5DB874"))
                                        if pickingFor == .to {
                                            Circle().stroke(Color(hex: "5DB874").opacity(0.4), lineWidth: 3).frame(width: 16, height: 16)
                                        }
                                    }
                                    Spacer()
                                }
                                .frame(width: 30).padding(.top, 4)

                                VStack(spacing: 10) {
                                    // FROM
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("From").font(.custom("Inter_18pt-SemiBold", size: 11)).foregroundColor(.textSecondary)
                                            Spacer()
                                            Button {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                    pickingFor = pickingFor == .from ? .none : .from
                                                }
                                            } label: {
                                                Text(pickingFor == .from ? "Cancel tap" : "Tap map")
                                                    .font(.custom("Inter_18pt-Regular", size: 10))
                                                    .foregroundColor(.primaryBlue)
                                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                                    .background(pickingFor == .from ? Color.primaryBlue.opacity(0.15) : Color.primaryBlueTint)
                                                    .cornerRadius(10)
                                            }
                                        }
                                        RoutePickerField(icon: "location.circle", iconColor: .primaryBlueDark,
                                                         placeholder: "e.g. Entrance, Reception…",
                                                         text: $fromText, allRooms: allRoomNames,
                                                         onSelect: { _ in resolveRoute() })
                                    }

                                    // TO
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("To").font(.custom("Inter_18pt-SemiBold", size: 11)).foregroundColor(.textSecondary)
                                            Spacer()
                                            Button {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                    pickingFor = pickingFor == .to ? .none : .to
                                                }
                                            } label: {
                                                Text(pickingFor == .to ? "Cancel tap" : "Tap map")
                                                    .font(.custom("Inter_18pt-Regular", size: 10))
                                                    .foregroundColor(Color(hex: "5DB874"))
                                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                                    .background(pickingFor == .to ? Color(hex: "5DB874").opacity(0.15) : Color(hex: "E8F7EC"))
                                                    .cornerRadius(10)
                                            }
                                        }
                                        RoutePickerField(icon: "mappin.circle", iconColor: Color(hex: "5DB874"),
                                                         placeholder: "e.g. Laboratory, ICU…",
                                                         text: $toText, allRooms: allRoomNames,
                                                         onSelect: { _ in resolveRoute() })
                                    }
                                }
                            }

                            // Quick destination chips
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(allRoomNames, id: \.self) { name in
                                        Button {
                                            toText = name
                                            if fromText.isEmpty { fromText = floor.defaultFrom }
                                            resolveRoute()
                                        } label: {
                                            Text(name)
                                                .font(.custom("Inter_18pt-Regular", size: 11))
                                                .foregroundColor(toText == name ? .white : .primaryBlue)
                                                .padding(.horizontal, 11).padding(.vertical, 6)
                                                .background(toText == name ? Color.primaryBlueDark : Color.primaryBlueTint)
                                                .cornerRadius(20)
                                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.primaryBlue.opacity(0.2), lineWidth: 1))
                                        }
                                    }
                                }
                            }

                            // Status pill
                            if !fromText.isEmpty && !toText.isEmpty {
                                HStack(spacing: 8) {
                                    if let route = activeRoute {
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(Color(hex: "5DB874"))
                                        Text("\(route.from)  →  \(route.to)")
                                            .font(.custom("Inter_18pt-Medium", size: 12)).foregroundColor(.textPrimary)
                                        Spacer()
                                        Text("\(route.steps.count) steps")
                                            .font(.custom("Inter_18pt-Regular", size: 11)).foregroundColor(.textSecondary)
                                    } else {
                                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Color(hex: "F59E0B"))
                                        Text("No route found between these rooms")
                                            .font(.custom("Inter_18pt-Regular", size: 12)).foregroundColor(Color(hex: "92400E"))
                                    }
                                }
                                .padding(.horizontal, 12).padding(.vertical, 9)
                                .background(activeRoute != nil ? Color(hex: "D4EDD6") : Color(hex: "FEF3C7"))
                                .cornerRadius(10)
                                .transition(.opacity.combined(with: .scale(scale: 0.97)))
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                        // ── Floor selector ───────────────────────────────────
                        HStack(spacing: 0) {
                            ForEach(0..<floorData.count, id: \.self) { i in
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        selectedFloor = i
                                        mapScale = 1; mapOffset = .zero; lastOffset = .zero; activeStep = 0
                                        fromText = floorData[i].defaultFrom; toText = floorData[i].defaultTo
                                        pickingFor = .none
                                    }
                                    resolveRoute(); restartStepTimer()
                                } label: {
                                    VStack(spacing: 3) {
                                        Text("Floor").font(.custom("Inter_18pt-Regular", size: 10))
                                            .foregroundColor(selectedFloor == i ? .white : .textSecondary)
                                        Text("\(i + 1)").font(.custom("Inter_18pt-Bold", size: 18))
                                            .foregroundColor(selectedFloor == i ? .white : .textPrimary)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                                    .background(selectedFloor == i ? AnyView(Color.primaryBlueDark) : AnyView(Color.clear))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .background(Color.white).cornerRadius(14)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)

                        // ── Map card ─────────────────────────────────────────
                        GeometryReader { cardGeo in
                            let cardW = cardGeo.size.width; let cardH = cardGeo.size.height
                            ZStack {
                                RoundedRectangle(cornerRadius: 20).fill(Color(hex: "EBF2FF"))

                                Canvas { ctx, size in
                                    let cols = 14; let rows = 11; var p = Path()
                                    for c in 0...cols { let x = size.width * CGFloat(c) / CGFloat(cols); p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height)) }
                                    for r in 0...rows { let y = size.height * CGFloat(r) / CGFloat(rows); p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y)) }
                                    ctx.stroke(p, with: .color(Color.primaryBlue.opacity(0.055)), lineWidth: 0.5)
                                }.cornerRadius(20)

                                Text("FLOOR \(selectedFloor + 1)").font(.custom("Inter_18pt-Bold", size: 52))
                                    .foregroundColor(Color.primaryBlue.opacity(0.04))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                                VStack(spacing: 2) {
                                    Image(systemName: "arrow.up").font(.system(size: 9, weight: .bold)).foregroundColor(Color.primaryBlueDark.opacity(0.5))
                                    Text("N").font(.custom("Inter_18pt-Bold", size: 8)).foregroundColor(Color.primaryBlueDark.opacity(0.5))
                                }
                                .padding(10).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

                                // Tap-to-pick hint
                                if pickingFor != .none {
                                    Text(pickingFor == .from ? "Tap a room to set as Start" : "Tap a room to set as Destination")
                                        .font(.custom("Inter_18pt-SemiBold", size: 12)).foregroundColor(.white)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(pickingFor == .from ? Color.primaryBlueDark.opacity(0.88) : Color(hex: "5DB874").opacity(0.90))
                                        .cornerRadius(20)
                                        .padding(.top, 10)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                        .zIndex(5)
                                }

                                GeometryReader { geo in
                                    let w = geo.size.width - 20; let h = geo.size.height - 20
                                    ZStack {
                                        corridorLayer(w: w, h: h)
                                        ForEach(floor.rooms) { room in
                                            roomCell(room: room, w: w, h: h)
                                                .onTapGesture { handleRoomTap(room.name) }
                                        }
                                        if let route = activeRoute { routeLayer(route: route, w: w, h: h) }
                                    }
                                    .padding(10)
                                    .scaleEffect(mapScale, anchor: .center)
                                    .offset(mapOffset)
                                    .gesture(
                                        SimultaneousGesture(
                                            MagnificationGesture().onChanged { v in
                                                let s = max(1.0, min(3.5, v)); mapScale = s
                                                mapOffset = clampedOffset(mapOffset, scale: s, cW: cardW, cH: cardH)
                                                lastOffset = mapOffset
                                            },
                                            DragGesture(minimumDistance: 1)
                                                .onChanged { v in
                                                    let proposed = CGSize(width: lastOffset.width + v.translation.width,
                                                                          height: lastOffset.height + v.translation.height)
                                                    mapOffset = clampedOffset(proposed, scale: mapScale, cW: cardW, cH: cardH)
                                                }
                                                .onEnded { _ in lastOffset = mapOffset }
                                        )
                                    )
                                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedFloor)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                        .frame(height: 320)
                        .shadow(color: Color.primaryBlue.opacity(0.10), radius: 16, x: 0, y: 6)
                        .padding(.horizontal, 20)
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) { mapScale = 1; mapOffset = .zero; lastOffset = .zero }
                        }

                        // Legend
                        HStack {
                            legendItem(color: Color(hex: "D4EDD6"), border: Color(hex: "5DB874"), label: "Destination")
                            legendItem(color: Color.primaryBlueDark.opacity(0.85), border: .clear, label: "Start")
                            legendItem(color: Color(hex: "DBE9FF"), border: Color(hex: "A8C4E0"), label: "Room")
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "hand.pinch").font(.system(size: 10)).foregroundColor(.textTertiary)
                                Text("Pinch  •  double-tap reset").font(.custom("Inter_18pt-Regular", size: 10)).foregroundColor(.textTertiary)
                            }
                        }
                        .padding(.horizontal, 22)

                        // ── Directions card ──────────────────────────────────
                        if let route = activeRoute {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle().fill(Color.primaryBlue.opacity(0.12)).frame(width: 34, height: 34)
                                        Image(systemName: "location.north.fill").font(.system(size: 14)).foregroundColor(.primaryBlue)
                                    }
                                    Text("Directions").font(.custom("Inter_18pt-Bold", size: 17)).foregroundColor(.textPrimary)
                                    Spacer()
                                    Text("\(route.steps.count) steps").font(.custom("Inter_18pt-Regular", size: 12)).foregroundColor(.textSecondary)
                                }
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(Array(route.steps.enumerated()), id: \.offset) { i, step in
                                        HStack(alignment: .top, spacing: 14) {
                                            VStack(spacing: 0) {
                                                ZStack {
                                                    Circle().fill(i == activeStep ? Color.primaryBlueDark : Color.primaryBlueTint).frame(width: 28, height: 28)
                                                    if i == activeStep { Circle().stroke(Color.primaryBlueDark.opacity(0.3), lineWidth: 3).frame(width: 34, height: 34) }
                                                    Text("\(i + 1)").font(.custom("Inter_18pt-Bold", size: 11))
                                                        .foregroundColor(i == activeStep ? .white : .primaryBlue)
                                                }
                                                if i < route.steps.count - 1 {
                                                    Rectangle().fill(Color.primaryBlueTint).frame(width: 2, height: 22)
                                                }
                                            }
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(step).font(.custom("Inter_18pt-Medium", size: 14))
                                                    .foregroundColor(i == activeStep ? .textPrimary : .textSecondary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                if i == activeStep {
                                                    Text("Current step").font(.custom("Inter_18pt-Regular", size: 11)).foregroundColor(.primaryBlue)
                                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                                }
                                            }
                                            .padding(.top, 4)
                                            .padding(.bottom, i < route.steps.count - 1 ? 22 : 0)
                                            Spacer()
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture { withAnimation(.spring()) { activeStep = i } }
                                    }
                                }
                            }
                            .padding(18).background(Color.white).cornerRadius(20)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
                            .padding(.horizontal, 20)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }

                        Spacer().frame(height: 28)
                    }
                }
                BottomTabBar(selectedTab: $navTab)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { fromText = floor.defaultFrom; toText = floor.defaultTo; resolveRoute(); restartStepTimer() }
        .onDisappear { stepTimer?.invalidate() }
        .onChange(of: navTab) { _, tab in AppRouter.shared.pendingTab = tab; dismiss() }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left").font(.system(size: 14, weight: .semibold))
                        Text("Back").font(.custom("Inter_18pt-Regular", size: 14))
                    }.foregroundColor(.textPrimary)
                }
            }
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("Clinic Navigation").font(.custom("Inter_18pt-Bold", size: 17)).foregroundColor(.textPrimary)
                    Text("Floor \(selectedFloor + 1)").font(.custom("Inter_18pt-Regular", size: 11)).foregroundColor(.textSecondary)
                }
            }
        }
    }

    // MARK: - Room tap handler
    private func handleRoomTap(_ name: String) {
        guard pickingFor != .none else { return }
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
            activeStep = 0
        }
        restartStepTimer()
    }

    // MARK: - Step timer
    private func restartStepTimer() {
        stepTimer?.invalidate(); activeStep = 0
        guard let route = activeRoute else { return }
        stepTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                activeStep = (activeStep + 1) % route.steps.count
            }
        }
    }

    // MARK: - Drag clamping
    private func clampedOffset(_ proposed: CGSize, scale: CGFloat, cW: CGFloat, cH: CGFloat) -> CGSize {
        let eW = max(0, cW * (scale - 1)) / 2; let eH = max(0, cH * (scale - 1)) / 2
        return CGSize(width: proposed.width.clamped(to: -eW...eW), height: proposed.height.clamped(to: -eH...eH))
    }

    // MARK: - Corridor layer
    @ViewBuilder
    private func corridorLayer(w: CGFloat, h: CGFloat) -> some View {
        let cc = Color(hex: "D6E6FF"); let bc = Color(hex: "A8C4E0").opacity(0.5)
        if selectedFloor == 0 {
            // Floor 1: H-corridor y=0.81–0.90, left vertical gap lane x=0.33–0.38, right lane x=0.57–0.62
            Canvas { ctx, _ in
                var p = Path()
                // Main H-corridor below all rooms
                p.addRoundedRect(in: CGRect(x: 0.02*w, y: 0.81*h, width: 0.96*w, height: 0.10*h), cornerSize: CGSize(width: 4, height: 4))
                // Left-mid vertical lane (x≈0.33–0.39, connecting H-corridor up to Pharmacy/MRI/Ultrasound level)
                p.addRoundedRect(in: CGRect(x: 0.33*w, y: 0.25*h, width: 0.06*w, height: 0.56*h), cornerSize: CGSize(width: 3, height: 3))
                // Central vertical lane (x≈0.57–0.63, connecting H-corridor up to Lab)
                p.addRoundedRect(in: CGRect(x: 0.57*w, y: 0.03*h, width: 0.06*w, height: 0.78*h), cornerSize: CGSize(width: 3, height: 3))
                ctx.fill(p, with: .color(cc)); ctx.stroke(p, with: .color(bc), lineWidth: 0.8)
            }
        } else if selectedFloor == 1 {
            // Floor 2: H-corridor y=0.77–0.87, vertical lanes at x=0.31–0.37 and x=0.45–0.51 and x=0.65–0.71
            Canvas { ctx, _ in
                var p = Path()
                p.addRoundedRect(in: CGRect(x: 0.02*w, y: 0.77*h, width: 0.96*w, height: 0.10*h), cornerSize: CGSize(width: 4, height: 4))
                // Left gap lane (Cardiology|Neurology gap)
                p.addRoundedRect(in: CGRect(x: 0.31*w, y: 0.25*h, width: 0.06*w, height: 0.52*h), cornerSize: CGSize(width: 3, height: 3))
                // Centre gap lane (ICU|WaitingLounge gap)
                p.addRoundedRect(in: CGRect(x: 0.45*w, y: 0.25*h, width: 0.06*w, height: 0.52*h), cornerSize: CGSize(width: 3, height: 3))
                // Right gap lane (Neurology|Radiology gap)
                p.addRoundedRect(in: CGRect(x: 0.65*w, y: 0.25*h, width: 0.06*w, height: 0.52*h), cornerSize: CGSize(width: 3, height: 3))
                ctx.fill(p, with: .color(cc)); ctx.stroke(p, with: .color(bc), lineWidth: 0.8)
            }
        } else {
            // Floor 3: H-corridor y=0.76–0.86, vertical lanes at x=0.37–0.43 and x=0.45–0.51
            Canvas { ctx, _ in
                var p = Path()
                p.addRoundedRect(in: CGRect(x: 0.02*w, y: 0.76*h, width: 0.96*w, height: 0.10*h), cornerSize: CGSize(width: 4, height: 4))
                // Recovery|SurgICU gap lane
                p.addRoundedRect(in: CGRect(x: 0.37*w, y: 0.28*h, width: 0.06*w, height: 0.48*h), cornerSize: CGSize(width: 3, height: 3))
                // OT1|OT2 gap lane (also spans mid row gap)
                p.addRoundedRect(in: CGRect(x: 0.45*w, y: 0.03*h, width: 0.06*w, height: 0.25*h), cornerSize: CGSize(width: 3, height: 3))
                ctx.fill(p, with: .color(cc)); ctx.stroke(p, with: .color(bc), lineWidth: 0.8)
            }
        }
    }

    // MARK: - Room cell
    private func roomCell(room: RoomInfo, w: CGFloat, h: CGFloat) -> some View {
        let rw = room.width * w;  let rh = room.height * h
        let rx = room.x * w + rw / 2; let ry = room.y * h + rh / 2
        let isFrom = room.name == fromText; let isDest = room.name == toText
        let isPickMode = pickingFor != .none

        let fillColor: Color = isDest  ? Color(hex: "D4EDD6")
                             : (isFrom || room.isEntrance) ? Color.primaryBlueDark
                             : Color(hex: "DBE9FF")
        let borderColor: Color = isDest  ? Color(hex: "5DB874")
                               : (isFrom || room.isEntrance) ? Color.primaryBlueDark
                               : Color(hex: "A8C4E0")

        return ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(colors: [fillColor, fillColor.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(borderColor, lineWidth: (isFrom || isDest) ? 2 : 1))
                .overlay(isPickMode ? RoundedRectangle(cornerRadius: 8).stroke(Color.primaryBlue.opacity(0.20), lineWidth: 1.5) : nil)

            if isDest { Circle().fill(Color(hex: "5DB874")).frame(width: 6, height: 6).padding(5).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing) }
            if isFrom && !room.isEntrance { Circle().fill(Color.white.opacity(0.7)).frame(width: 6, height: 6).padding(5).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing) }

            Text(room.name)
                .font(.custom("Inter_18pt-SemiBold", size: 7.5))
                .foregroundColor((isFrom || room.isEntrance) ? .white : isDest ? Color(hex: "1E5631") : Color(hex: "1A3A5C"))
                .lineLimit(3).multilineTextAlignment(.leading).padding(5)
        }
        .frame(width: rw, height: rh).position(x: rx, y: ry)
        .shadow(color: borderColor.opacity(0.20), radius: 4, x: 0, y: 2)
        .animation(.spring(response: 0.2), value: isFrom || isDest)
    }

    // MARK: - Route layer
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
                    let tip = CGPoint(x: end.x - ux * 2, y: end.y - uy * 2)
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

    // MARK: - Legend
    private func legendItem(color: Color, border: Color, label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 4).fill(color)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(border, lineWidth: 1))
                .frame(width: 14, height: 14)
            Text(label).font(.custom("Inter_18pt-Regular", size: 11)).foregroundColor(.textSecondary)
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

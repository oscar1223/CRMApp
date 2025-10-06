# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CRMApp is an iOS booking/CRM application built with SwiftUI. The app provides calendar management, booking analytics, AI chat, and settings for managing business operations. It targets iOS 15+ and uses Xcode for development.

## Development Commands

### Build and Run
- Open `CRMApp.xcodeproj` in Xcode
- Select a simulator or device from the Xcode toolbar
- Press `⌘R` to build and run
- Press `⌘B` to build without running

### Testing
- Press `⌘U` to run all tests
- Use Product → Test to run specific test schemes

## Architecture

### Core Structure

The app uses a tab-based navigation pattern with four main sections:
1. **Calendar** - Event scheduling and day/month/week views
2. **Booking** - Revenue analytics and client management
3. **Chat** - AI assistant interface
4. **Settings** - User profile and business configuration

### Key Components

**Entry Point**: `CRMApp/CRMAppApp.swift` - Main app struct with WindowGroup

**Main View**: `CRMApp/ContentView.swift` - Root view containing:
- `AppTab` enum defining the four main tabs (calendar, booking, chat, settings)
- Tab state management and responsive layout logic
- Gradient background with iPad-specific adaptations
- Event data management (eventsCountByDay, eventsByDay dictionaries)

**Design System**: `CRMApp/Components/NotionDesignSystem.swift` - Centralized design tokens including:
- `Color` extensions for brand colors, backgrounds, text, calendar events, status, and borders
- `ModernButtonStyle`, `ModernTextSize`, `ModernSpacing` enums for consistent styling
- View modifiers: `modernButton()`, `modernCard()`, `modernText()`, `modernPadding()`
- Responsive scaling based on device type (iPad vs iPhone) and orientation

**Tab Bar**: `CRMApp/Components/AppTabBar.swift` - Custom floating tab bar component with animations

### View Organization

**Calendar Module** (`CRMApp/Views/Calendar/`):
- `CalendarMainView.swift` - Container with ViewMode (.month/.week), responsive layouts (vertical/horizontal for iPad landscape)
- `MonthGrid.swift` - Month calendar grid with day cells
- `WeekStrip.swift` - Horizontal week view
- `EventsList.swift` - List of events for selected date
- `EditEventSheet.swift` - Modal for editing/deleting events
- `NewBookingActionsSheet.swift` - Sheet for creating new bookings

**Booking Module** (`CRMApp/Views/Booking/`):
- `BookingMainView.swift` - Revenue analytics with LineChart, time range picker (7d/30d/90d), client list

**Chat Module** (`CRMApp/Views/Chat/`):
- `ChatMainView.swift` - AI chat interface with message bubbles, suggestion chips, blur background input bar

**Settings Module** (`CRMApp/Views/Settings/`):
- `SettingsMainView.swift` - Profile header, payment CTA card, settings sections

### Data Models

**Models** (`CRMApp/Models/`):
- `Event.swift` - `MockEvent` struct with id, title, startDate, endDate, isAllDay
- `Client.swift` - `Client` struct with id, name, email, phone, totalSpent (includes mock data)
- `ChatMessage.swift` - `ChatMessage` struct for chat interface

### Responsive Design

The app implements device-specific layouts:
- **iPad Detection**: `UIDevice.current.userInterfaceIdiom == .pad`
- **Orientation Handling**: Observes `UIDevice.orientationDidChangeNotification` for landscape/portrait
- **Responsive Scaling**: `responsiveScaleFactor()` in NotionDesignSystem.swift adjusts sizes for iPad (1.1x) vs iPhone (1.0x)
- **Adaptive Layouts**: CalendarMainView switches between vertical and horizontal layouts for iPad landscape (60/40 split)
- **Dynamic Spacing**: Views adjust padding, font sizes, and element sizes based on device and orientation

## State Management

- State is primarily managed with `@State` in views
- Calendar events use dictionaries: `[Date: Int]` for counts, `[Date: [MockEvent]]` for event lists
- Bindings propagate state between parent (ContentView) and child views (CalendarMainView)

## Design Principles

- **Notion-inspired**: Clean, minimal aesthetic with subtle shadows and borders
- **Responsive-first**: All views adapt to iPhone/iPad and portrait/landscape
- **Compact UI**: Reduced padding and font sizes for efficient space usage
- **Smooth animations**: Spring animations (response: 0.3-0.5, dampingFraction: 0.7-0.8) for transitions
- **Modern SwiftUI**: Uses native SwiftUI patterns (no UIKit view controllers)

## Common Patterns

### Adding a New View
1. Create in appropriate `Views/` subdirectory
2. Use `modernCard()`, `modernButton()`, `modernText()` modifiers from NotionDesignSystem
3. Add responsive properties for iPad/landscape support
4. Include animations for state transitions

### Modifying Colors or Styles
- Edit `NotionDesignSystem.swift` for global changes
- Use existing color tokens (e.g., `.brandPrimary`, `.textSecondary`) rather than hardcoded values

### Working with Events
- Events are stored in `eventsByDay: [Date: [MockEvent]]` in ContentView
- Use `Calendar.current.startOfDay(for:)` as dictionary key
- Update both `eventsByDay` and `eventsCountByDay` when adding/removing events

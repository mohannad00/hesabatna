# Hesabatna App - UI/UX Design Documentation

## Table of Contents
1. [App Overview](#app-overview)
2. [Design System](#design-system)
3. [Screen Details](#screen-details)
4. [User Flows](#user-flows)
5. [Components & Widgets](#components--widgets)
6. [Animations & Interactions](#animations--interactions)

---

## App Overview

**Hesabatna** is a modern expense tracking and group management application that helps users split bills, track shared expenses, manage tasks, and take notes. The app features a clean, gradient-based design with smooth animations and an intuitive user experience.

### Key Features
- 📊 **Group Expense Management**: Create groups, add members, track expenses and payments
- ✅ **Task Management**: Create and manage personal tasks with priorities
- 📝 **Note Taking**: Color-coded note system for quick organization
- 👤 **Profile Management**: Customizable user profile with theme preferences
- 🌓 **Theme Support**: Light, Dark, and System-adaptive themes
- 📤 **Export Functionality**: Export group data as PDF reports

### App Version
Current Version: **v1.0.0**

---

## Design System

### Color Palette

#### Primary Colors
- **Primary Blue**: `#2196F3` - Main brand color, used for primary actions
- **Primary Dark**: `#1976D2` - Used for gradients and hover states
- **Primary Light**: `#42A5F5` - Used in dark theme
- **Secondary**: `#03A9F4` - Accent color
- **Tertiary**: `#00BCD4` - Additional accent

#### Semantic Colors
- **Success Green**: `#10B981` - Positive actions, completed states
- **Warning Amber**: `#F59E0B` - Warning states, medium priority
- **Error Red**: `#EF4444` - Errors, delete actions, high priority
- **Info Cyan**: `#06B6D4` - Information states
- **Purple**: `#8B5CF6` - Profile/user-related actions

#### Background Colors

**Light Theme:**
- Primary Background: `#F5F9FF` - Soft blue-tinted white
- Card Background: `#FFFFFF` - Pure white
- Secondary Background: `#F8FBFF` - Very light blue

**Dark Theme:**
- Primary Background: `#0A1628` - Deep navy blue
- Card Background: `#0D1B2A` - Slightly lighter navy
- Secondary Background: `#1B263B` - Medium navy

#### Text Colors

**Light Theme:**
- Primary Text: `#2D3142` - Almost black with slight blue tint
- Secondary Text: `#6B7280` - Medium gray
- Tertiary Text: `#9CA3AF` - Light gray

**Dark Theme:**
- Primary Text: `#E5E7EB` - Off-white
- Secondary Text: `#9CA3AF` - Medium gray
- Tertiary Text: `#6B7280` - Darker gray

### Typography

#### Font Weights
- **Regular**: 400 - Body text
- **Medium**: 500 - Subtle emphasis
- **Semibold**: 600 - Section headers, labels
- **Bold**: 700 - Page titles, important text

#### Font Sizes
- **Headline Large**: 32px - Major page titles
- **Headline Medium**: 28px - Section titles
- **Title Large**: 22px - Card titles, subtitles
- **Title Medium**: 18px - Subsection headers
- **Body Large**: 16px - Primary body text
- **Body Medium**: 14px - Secondary text, captions
- **Small**: 12px - Timestamps, metadata
- **Tiny**: 11px - Badge text, minimal labels

### Spacing System
- **Extra Small**: 4px
- **Small**: 8px
- **Medium**: 12px
- **Regular**: 16px
- **Large**: 20px
- **Extra Large**: 24px
- **XXL**: 32px

### Border Radius
- **Small**: 6-8px - Small badges
- **Medium**: 12-14px - Buttons, small cards
- **Large**: 16-20px - Cards, containers
- **Extra Large**: 24-28px - Major cards, dialogs

### Elevation & Shadows

#### Light Theme
```
Small Shadow:
- color: rgba(33, 150, 243, 0.1)
- blur: 12px
- offset: (0, 4px)

Medium Shadow:
- color: rgba(33, 150, 243, 0.15)
- blur: 20px
- offset: (0, 8px)

Large Shadow:
- color: rgba(33, 150, 243, 0.3)
- blur: 30px
- offset: (0, 14px)
```

#### Dark Theme
```
Small Shadow:
- color: rgba(0, 0, 0, 0.3)
- blur: 12px
- offset: (0, 4px)

Medium Shadow:
- color: rgba(0, 0, 0, 0.4)
- blur: 20px
- offset: (0, 8px)

Large Shadow:
- color: rgba(0, 0, 0, 0.5)
- blur: 30px
- offset: (0, 14px)
```

---

## Screen Details

### 1. Home Screen (Navigation Hub)

**Purpose**: Main navigation interface with tab-based architecture

#### Layout
- **Top App Bar**:
  - Gradient background (Primary Blue → Primary Dark)
  - Adaptive title based on selected tab
  - Icon representing current section
  - Version badge (v1.0.0) on the right
  - Subtle gradient divider line at bottom

- **Page View**: Swipeable content area displaying:
  1. Groups List (Expenses)
  2. Tasks
  3. Notes
  4. Profile

- **Bottom Navigation Bar**:
  - Height: 56px
  - Margin: 12px horizontal, 16px bottom
  - Border radius: 16px
  - Floating design with gradient background
  - 4 navigation items with icons and labels
  - Selected state: Blue gradient background with white icon
  - Unselected state: Gray icon and text
  - Smooth transitions between states

#### Navigation Items
1. **Expenses** (Wallet icon) - Shows groups list
2. **Tasks** (Check circle icon) - Task management
3. **Notes** (Note icon) - Note taking
4. **Profile** (Person icon) - User settings

#### Interactions
- Tap navigation items to switch tabs
- Swipe horizontally to switch between screens
- Smooth page transitions (300ms, easeInOut curve)

---

### 2. Groups List Screen (Expenses Tab)

**Purpose**: Display all expense groups, create new groups

#### Empty State
- **Icon**: Group add icon with gradient background circle
- **Title**: "No groups yet" (28px, bold)
- **Subtitle**: "Create your first group to start tracking shared expenses"
- **Background**: Gradient overlay

#### Group List View
- **Layout**: Vertical scrolling list
- **Padding**: 16px horizontal, 80px bottom (for FAB clearance)
- **Item Spacing**: 8px between cards

#### Group Card Design
- **Height**: Auto (based on content)
- **Border Radius**: 16px
- **Background**: White → Light blue gradient
- **Border**: 1px solid white (60% opacity)
- **Shadow**: Blue-tinted, 12px blur
- **Padding**: 12px all around

#### Card Content
- **Left Section**:
  - Icon container: 
    - Gradient background (Primary Blue → Primary Dark)
    - Border radius: 12px
    - Size: 44x44px
    - Icon: People icon, white, 22px
    - Shadow: Blue glow, 8px blur

- **Middle Section**:
  - Group name: 16px, bold, dark text
  - Member count: 12px, medium weight, gray text
  - Date badge:
    - Background: Light blue gradient
    - Border radius: 6px
    - Padding: 4px vertical, 10px horizontal
    - Calendar icon + formatted date
    - Font: 11px, semibold, blue text

- **Right Section**:
  - Arrow button: 18px icon in light blue gradient container

#### Animations
- **Entry Animation**: 
  - Staggered appearance (300ms + index * 100ms)
  - Vertical slide from bottom (50px offset)
  - Fade in opacity
  - Ease out back curve

- **Tap Animation**:
  - Fade + slide transition to group detail screen
  - Shared element transition on group icon

#### Interactions
- **Tap**: Navigate to Group Detail Screen
- **Long Press**: Show options menu (Edit/Delete)
- **FAB**: Opens Add Group Dialog

#### Floating Action Button (FAB)
- **Position**: Bottom right with 16px padding
- **Background**: Blue gradient
- **Size**: Compact
- **Icon**: Plus icon, white, 20px
- **Shadow**: Blue glow with 12px blur
- **Border Radius**: 16px

---

### 3. Group Detail Screen

**Purpose**: View group summary, manage expenses, payments, and members

#### App Bar Section
- **Background**: Gradient (Primary Blue → Darker Blue)
- **Height**: Auto (based on content)
- **Shadow**: Medium elevation

##### First Row (Fixed)
- **Back Button**: 
  - Semi-transparent white background
  - Border radius: 12px
  - White icon, 22px
  
- **Group Name**: 
  - 20px, bold, white text
  - Single line with ellipsis
  
- **Member Count**: 
  - 13px, medium weight
  - 85% white opacity

- **Collapse/Expand Toggle**:
  - Semi-transparent white background
  - Animated rotation icon (up/down arrow)
  - Controls toolbar visibility

##### Second Row (Collapsible Toolbar)
- **Height**: 90px when expanded
- **Background**: 10% white overlay
- **Border Radius**: 16px
- **Margin**: 16px horizontal
- **Padding**: 8px vertical
- **Animation**: Smooth slide up/down (200ms)
- **Trigger**: Scroll down to hide, scroll up to show

**Action Buttons** (4 items, equally distributed):
1. **Add Expense**
   - Icon: Plus
   - Label: "Expense"
   
2. **Add Payment**
   - Icon: Payment
   - Label: "Payment"
   
3. **Export Data**
   - Icon: File download
   - Label: "Export"
   
4. **Add Member**
   - Icon: Person add
   - Label: "Member"

**Button Design**:
- Semi-transparent white background (20% opacity)
- Border radius: 8px
- Icon size: 16px
- Label: 9px, semibold, white
- Padding: 6px horizontal, 4px vertical

##### Tab Bar
- **Background**: 12% white overlay
- **Border**: 1px solid white (15% opacity)
- **Border Radius**: 16px
- **Margin**: 16px horizontal
- **Indicator**: White background with shadow
- **Indicator Padding**: 3px

**Tab Design**:
- **Selected**: White background, dark text
- **Unselected**: Transparent, 90% white text
- **Height**: Auto (padding-based)
- **Font**: 13px, semibold (selected), medium (unselected)

**Tab Structure**:
1. **Summary Tab**: Dashboard icon + "Summary"
2. **Transactions Tab**: Receipt icon + "Transactions"
3. **Member Tabs**: One tab per member (Person icon + Name)

#### Tab Content Area

##### Summary Tab
Displays:
- Total expenses
- Group balance overview
- Member balances (who owes whom)
- Settlement suggestions

##### Transactions Tab
Displays:
- Combined list of expenses and payments
- Chronological order (newest first)
- Expense cards with amount, payer, date
- Payment cards with amount, from → to, date
- Edit/delete actions per transaction

##### Member Detail Tabs
Shows for each member:
- Member's total expenses paid
- Member's share of group expenses
- Member's balance (owed or owes)
- List of expenses this member paid
- List of expenses this member is involved in
- Payments made/received

#### Empty State (No Members)
- **Icon**: Group icon in semi-transparent circle
- **Title**: "No Members Yet" (20px, bold)
- **Subtitle**: "Add members to start tracking expenses"

#### Scroll Behavior
- Toolbar auto-hides on scroll down
- Toolbar appears on scroll up
- Threshold: 8px scroll distance
- Smooth animation (200ms ease out)

---

### 4. Add Expense Screen

**Purpose**: Create or edit group expenses with custom split options

#### App Bar
- **Title**: "Add Expense" or "Edit Expense"
- **Background**: Primary container color
- **Back Button**: Standard navigation

#### Form Layout (Scrollable)
- **Padding**: 16px all around
- **Spacing**: 16px between fields

#### Form Fields

1. **Description Field**
   - Label: "Description"
   - Hint: "e.g., Dinner at restaurant"
   - Icon: Description icon
   - Required field
   - Text capitalization: Sentences

2. **Amount Field**
   - Label: "Amount"
   - Hint: "0.00"
   - Icon: Dollar icon
   - Suffix: Currency code (e.g., "USD")
   - Keyboard: Decimal number
   - Required, must be > 0

3. **Payer Dropdown**
   - Label: "Paid by"
   - Icon: Person icon
   - Options: All group members
   - Required field

4. **Date Selector**
   - Icon: Calendar icon
   - Label: "Date"
   - Display: Formatted date (e.g., "Oct 27, 2024")
   - Tap: Opens date picker dialog
   - Default: Today

5. **Split Method Selector**
   - Title: "Split Method" (bold)
   - Type: Segmented button
   - Options:
     - **Equal**: Splits amount equally among selected members
     - **Custom**: Allows custom amounts per member
   - Icons: People icon (Equal), Tune icon (Custom)

6. **Beneficiaries Section**
   - Title: "Split between" (bold)
   - Container: Card with member checkboxes
   - Each member shows:
     - Checkbox to include/exclude
     - Member name
     - If custom split: Amount input field (appears when checked)

   **Custom Split Fields**:
   - Indent: 72px left, 16px right
   - Label: "Amount for [Member Name]"
   - Suffix: Currency code
   - Validation: Sum must equal total expense amount

7. **Notes Field** (Optional)
   - Label: "Notes (Optional)"
   - Hint: "Add any additional details"
   - Icon: Note icon
   - Max lines: 3
   - Text capitalization: Sentences

#### Submit Button
- **Text**: "Add Expense" or "Update Expense"
- **Style**: Filled button, full width
- **Padding**: 16px vertical
- **Font**: 16px
- **Color**: Primary color
- **Validation**: 
  - Checks all required fields
  - Validates custom split totals
  - Shows error snackbar if validation fails

#### Validation Messages
- Missing description: "Please enter a description"
- Missing/invalid amount: "Please enter a valid amount"
- No beneficiaries: "Please select at least one beneficiary"
- Custom split mismatch: "Custom split total (X) must equal expense amount (Y)"

---

### 5. Add Payment Screen

**Purpose**: Record payments between group members

#### App Bar
- **Title**: "Add Payment" or "Edit Payment"
- **Background**: Primary container color
- **Loading Indicator**: Shows during submission (20x20px)

#### Form Layout
- **Type**: Single column form in cards
- **Padding**: 16px all around
- **Spacing**: 16px between cards

#### Form Fields (Each in a Card)

1. **Receiver Selection Card**
   - **Title**: "To (Receiver)" (title medium)
   - **Field**: Dropdown with all members
   - **Hint**: "Select receiver"
   - Required field

2. **Payer Selection Card**
   - **Title**: "From (Payer)" (title medium)
   - **Field**: Dropdown (excludes receiver)
   - **Hint**: "Select payer"
   - **Logic**: Auto-adjusts if same as receiver
   - Required field

3. **Amount Card**
   - **Title**: "Amount ([Currency])" (title medium)
   - **Field**: Number input
   - **Icon**: Dollar icon
   - **Hint**: "0.00"
   - **Keyboard**: Decimal number
   - Required, must be > 0

4. **Date Card**
   - **Title**: "Date" (title medium)
   - **Display**: Tappable formatted date
   - **Icon**: Calendar icon
   - **Tap**: Opens date picker (2020 - now)

5. **Notes Card** (Optional)
   - **Title**: "Notes (Optional)" (title medium)
   - **Field**: Multi-line text (3 lines)
   - **Hint**: "Add a note..."

#### Submit Button
- **Type**: Elevated button with icon
- **Icon**: Payment icon (or loading spinner)
- **Text**: 
  - Normal: "Add Payment" / "Update Payment"
  - Loading: "Adding..." / "Updating..."
- **Style**: Full width, 16px padding
- **Colors**: Primary background, on-primary text
- **Disabled**: While submitting

#### Validation
- Requires at least 2 members in group
- Shows message if < 2 members: "At least 2 members are required to add a payment"
- Validates amount > 0
- Prevents same member as payer and receiver

#### Success/Error Handling
- **Success**: Shows snackbar, navigates back
- **Error**: Shows error snackbar, stays on screen

---

### 6. Tasks Screen

**Purpose**: Personal task management with priority system

#### Empty State
- **Icon**: Check circle outline in gradient circle
- **Title**: "No tasks yet" (28px, bold)
- **Subtitle**: "Create your first task to get started"
- **Background**: Gradient overlay

#### Task List Layout
- **Padding**: 20px horizontal, 20-100px vertical (FAB clearance)
- **Sections**: 
  1. Active Tasks
  2. Completed Tasks

#### Section Headers
- **Number Badge**:
  - Gradient background (Primary Blue → Darker Blue)
  - Border radius: 12px
  - Padding: 8px vertical, 12px horizontal
  - White text, 16px, bold
  - Blue shadow glow

- **Title**: 22px, bold, section spacing: 12px below

#### Task Cards

**Design**:
- **Margin**: 12px bottom
- **Border Radius**: 24px
- **Background**: White → Light tinted gradient
- **Border**: 1px priority color (20% opacity)
- **Shadow**: Priority-colored, 20px blur
- **Padding**: 20px all around

**Priority Colors**:
- **High (1)**: Red (#EF4444 → #F87171)
- **Medium (2)**: Blue (#2196F3 → #42A5F5)
- **Low (3)**: Green (#10B981 → #34D399)

**Card Content**:
- **Left**: 
  - Priority-colored gradient circle (32x32px)
  - Animated checkmark (appears when completed)
  - Animation: 300ms fade in

- **Middle** (Expanded):
  - Task title: 17px, semibold, dark text
  - Description: 14px, gray text (if present)
  - Strike-through styling when completed
  - 16px spacing from checkbox

- **Right**:
  - Delete button: Red icon, 22px
  - Trash icon

#### Animations
- **Checkbox Toggle**: 
  - 300ms tween animation
  - Checkmark fades in/out based on completion state

#### Interactions
- **Tap Card**: Toggle completion status
- **Tap Delete**: Remove task
- **FAB**: Opens Add Task Dialog

#### Add Task Dialog

**Design**:
- **Border Radius**: 24px
- **Title**: "New Task"
- **Background**: Theme-adaptive

**Fields**:
1. **Task Title**
   - Label: "Task Title"
   - Border: Outlined
   - Auto-focus enabled

2. **Description** (Optional)
   - Label: "Description (Optional)"
   - Max lines: 2

3. **Priority Selector**
   - Type: Segmented button
   - Options:
     - 🔴 High
     - 🟡 Medium (default)
     - 🟢 Low

**Actions**:
- **Cancel**: Text button
- **Add**: Filled button (requires title)

---

### 7. Notes Screen

**Purpose**: Quick note-taking with color organization

#### Empty State
- **Icon**: Note outline in gradient circle
- **Title**: "No notes yet" (28px, bold)
- **Subtitle**: "Create your first note"
- **Background**: Gradient overlay

#### Notes Grid Layout
- **Type**: 2-column grid
- **Padding**: 20px horizontal, 20-100px vertical
- **Spacing**: 16px (cross and main axis)
- **Aspect Ratio**: 0.9 (slightly taller than wide)

#### Note Cards

**Design**:
- **Border Radius**: 24px
- **Background**: Color-tinted gradient
- **Border**: 1.5px solid note color
- **Shadow**: Color-matched, 20px blur

**Color Options**:
- Blue (#2196F3)
- Red (#EF4444)
- Green (#10B981)
- Amber (#F59E0B)
- Purple (#8B5CF6)
- Cyan (#06B6D4)

**Card Content** (Padding: 16px):
- **Header Row**:
  - Title: 18px, bold (max 2 lines)
  - Delete button: Small icon (20px) in note color

- **Content**:
  - Body text: 14px, gray (max 6 lines)
  - Line height: 1.5
  - Ellipsis overflow

- **Footer**:
  - Time icon: 12px in note color
  - Timestamp: 11px, semibold, note color
  - Format: "MMM dd"

#### Animations
- **Entry**: 
  - Staggered scale animation
  - Duration: 300ms + (index * 50ms)
  - Curve: Ease out back
  - Scale from 0.0 to 1.0

#### Interactions
- **Tap Card**: Currently no action (placeholder for edit)
- **Tap Delete**: Remove note
- **FAB**: Opens Add Note Dialog

#### Add Note Dialog

**Design**:
- **Border Radius**: 24px
- **Title**: "New Note"
- **Background**: Theme-adaptive
- **Content**: Scrollable

**Fields**:
1. **Title**
   - Label: "Title"
   - Border: Outlined
   - Auto-focus enabled

2. **Content**
   - Label: "Content"
   - Max lines: 4

3. **Color Selector**
   - **Label**: "Choose Color" (bold)
   - **Layout**: Horizontal wrap
   - **Spacing**: 12px between colors

**Color Buttons**:
- Size: 40x40px
- Shape: Circle
- Selected state:
  - White border (3px)
  - Colored shadow glow
  - White checkmark icon (20px)

**Actions**:
- **Cancel**: Text button
- **Add**: Filled button (requires title)

---

### 8. Profile Screen

**Purpose**: User settings, preferences, and app information

#### Layout
- **Type**: Scrollable list
- **Padding**: 20px horizontal, 20-100px vertical
- **Spacing**: 32px between sections

#### Profile Header Card

**Design**:
- **Padding**: 28px all around
- **Border Radius**: 28px
- **Background**: Blue gradient (Primary → Dark)
- **Shadow**: Large blue glow (30px blur, 14px offset)

**Content**:
- **Avatar Circle**:
  - Size: 90x90px
  - Background: White
  - Icon: Person icon, blue, 48px
  - Shadow: Black shadow (20px blur, 8px offset)

- **Greeting**: 
  - Text: "Hello, [Username]!" (26px, bold, white)
  - Spacing: 18px below avatar

- **Badge**: 
  - Text: "Premium User"
  - Background: 20% white overlay
  - Border radius: 20px
  - Padding: 6px vertical, 16px horizontal
  - Font: 12px, semibold, white

#### Settings Sections

Each section includes:
- **Section Title**: 18px, bold, left-padded 16px
- **Container Card**: 
  - Border radius: 24px
  - 1px border (primary color, 5-10% opacity)
  - Background: Theme-adaptive
  - Shadow: Medium elevation

**Section 1: General**
1. **Username Setting**
   - Icon: Purple gradient (Person outline, 24px)
   - Title: "Username" (17px, semibold)
   - Subtitle: Current username
   - Action: Purple edit icon
   - Tap: Opens edit dialog

2. **Notifications** (Placeholder)
   - Icon: Red gradient (Bell, 24px)
   - Title: "Notifications"
   - Subtitle: "Manage notification preferences"
   - Action: Forward arrow

3. **Theme Setting**
   - Icon: Blue gradient (Light/Dark mode icon, 24px)
   - Title: "Theme"
   - Subtitle: "System (Auto)" / "Dark Mode" / "Light Mode"
   - Action: Popup menu with 3 options
   - Options: System, Light, Dark (checkmark on selected)

4. **Language** (Placeholder)
   - Icon: Green gradient (Language, 24px)
   - Title: "Language"
   - Subtitle: "Change app language"
   - Action: Forward arrow

**Section 2: Data**
1. **Backup & Restore** (Placeholder)
   - Icon: Amber gradient (Backup, 24px)
   - Title: "Backup & Restore"
   - Subtitle: "Manage your data backups"

2. **Export Data** (Placeholder)
   - Icon: Cyan gradient (Download, 24px)
   - Title: "Export Data"
   - Subtitle: "Download all your data"

3. **Debug & Testing**
   - Icon: Red gradient (Bug, 24px)
   - Title: "Debug & Testing"
   - Subtitle: "Add sample data for testing"
   - Tap: Opens Debug Screen

**Section 3: About**
1. **About Hesabatna** (Placeholder)
   - Icon: Purple gradient (Info, 24px)
   - Title: "About Hesabatna"
   - Subtitle: "Version 2.0.0"

2. **Privacy Policy** (Placeholder)
   - Icon: Gray gradient (Privacy, 24px)
   - Title: "Privacy Policy"
   - Subtitle: "Read our privacy policy"

#### Settings Tile Design
- **Content Padding**: 20px horizontal, 10px vertical
- **Icon Container**: 
  - Size: 48x48px (12px padding)
  - Border radius: 14px
  - Gradient background (color-specific)
  - Shadow: Colored glow (12px blur, 4px offset)

#### Edit Username Dialog

**Design**:
- **Border Radius**: 24px
- **Background**: Theme-adaptive
- **Title Bar**: 
  - Purple gradient icon (Person, 20px)
  - "Edit Username" text (20px, bold)

**Content**:
- Text field with purple focus border
- Hint: "Enter your name"
- Prefix icon: Edit icon in purple

**Actions**:
- **Cancel**: Text button (gray)
- **Save**: Elevated button (purple, requires non-empty)

#### Theme Popup Menu
- 3 options: System, Light, Dark
- Each shows icon, label, and checkmark if selected
- Blue checkmark color (#2196F3)

---

## User Flows

### Creating a Group and Adding Expenses

```
1. User opens app → Expenses tab (default)
2. Tap FAB (+) → Add Group Dialog opens
3. Enter group name → Tap "Create"
4. Group card appears in list with animation
5. Tap group card → Navigate to Group Detail Screen
6. Screen shows "No Members Yet" empty state
7. Tap "Member" button in toolbar → Add Member Dialog
8. Enter member name → Tap "Add"
9. Member tab appears
10. Tap "Expense" button → Navigate to Add Expense Screen
11. Fill in expense details:
    - Description: "Dinner"
    - Amount: "50.00"
    - Paid by: Select member
    - Split: Equal/Custom
    - Select beneficiaries
12. Tap "Add Expense" → Navigate back
13. Expense appears in Transactions tab
14. Summary tab shows updated balances
```

### Recording a Payment

```
1. Navigate to Group Detail Screen
2. Tap "Payment" button in toolbar
3. Select receiver (To)
4. Select payer (From) - auto-excludes receiver
5. Enter amount
6. Select date (optional)
7. Add notes (optional)
8. Tap "Add Payment"
9. Success snackbar appears
10. Navigate back to group detail
11. Payment appears in Transactions tab
12. Balances update in Summary tab
```

### Managing Tasks

```
1. Navigate to Tasks tab from bottom nav
2. Tap FAB (+) → Add Task Dialog
3. Enter task title
4. Enter description (optional)
5. Select priority (High/Medium/Low)
6. Tap "Add"
7. Task appears in Active Tasks section
8. Tap task card → Toggles completion
9. Completed task moves to Completed section
10. Tap delete icon → Removes task
```

### Creating Notes

```
1. Navigate to Notes tab from bottom nav
2. Tap FAB (+) → Add Note Dialog
3. Enter note title
4. Enter note content
5. Tap a color circle to select
6. Tap "Add"
7. Note appears in grid with animation
8. Tap delete icon → Removes note
```

### Changing Theme

```
1. Navigate to Profile tab
2. Tap "Theme" setting
3. Popup menu appears with 3 options
4. Select desired theme
5. App instantly applies new theme
6. Preference saved automatically
```

### Exporting Group Data

```
1. Navigate to Group Detail Screen
2. Tap "Export" button in toolbar
3. PDF generation process starts
4. Share sheet appears
5. User selects sharing method
6. Success snackbar confirms export
```

---

## Components & Widgets

### 1. Animated Gradient FAB

**Purpose**: Floating action button with gradient background

**Design**:
- Gradient: Primary Blue → Primary Dark
- Border radius: 16px
- Size: Compact (40x40px)
- Icon: White, 20px
- Shadow: Blue glow (12px blur)
- Elevation: 8

**Animation**:
- Subtle scale animation on appearance
- Ripple effect on tap

**Usage**: 
- Groups List Screen
- Tasks Screen
- Notes Screen

### 2. Custom App Bar (Deprecated)

**Note**: This component was used previously but has been removed from Tasks, Notes, and Profile screens in favor of the main app bar.

### 3. Add Group Dialog

**Purpose**: Create or edit expense groups

**Design**:
- Material Dialog with rounded corners (24px)
- Title with gradient icon
- Single text field for group name
- Two-button action row

**Fields**:
- Group name input
- Auto-focus enabled
- Validation: Non-empty required

**Actions**:
- Cancel (text button)
- Create/Update (filled button)

### 4. Add Member Dialog

**Purpose**: Add members to groups

**Design**:
- Material Dialog with rounded corners (24px)
- Title: "Add Member"
- Single text field for member name

**Fields**:
- Member name input
- Auto-focus enabled
- Validation: Non-empty, no duplicates

**Actions**:
- Cancel (text button)
- Add (filled button)

### 5. Transaction Cards

**Purpose**: Display expenses and payments in transaction list

**Expense Card**:
- Icon: Receipt
- Title: Description
- Subtitle: Paid by [Name]
- Amount: Large, right-aligned
- Date: Below subtitle
- Actions: Edit, Delete (on tap)

**Payment Card**:
- Icon: Payment arrow
- Title: [From] → [To]
- Amount: Large, right-aligned
- Date: Below subtitle
- Actions: Edit, Delete (on tap)

**Design**:
- Border radius: 20px
- Gradient background
- Border: 1px primary color (10% opacity)
- Shadow: Medium elevation
- Padding: 16px

### 6. Balance Cards

**Purpose**: Show member balances and settlements

**Design**:
- Gradient background
- Border radius: 20px
- Color-coded by balance (green = owed, red = owes)
- Member avatar or icon
- Balance amount (large font)
- Settlement suggestion text

### 7. Debug Overlay

**Purpose**: Development tool for testing and debugging

**Features**:
- Toggle button (floating)
- Data reset options
- Sample data generation
- Database statistics
- Theme quick-switching

---

## Animations & Interactions

### Entry Animations

**Staggered List Appearance**:
- Used in: Groups List, Tasks, Notes
- Duration: 300ms + (index * 100ms or 50ms)
- Effect: Vertical slide + fade in
- Curve: Ease out back
- Offset: 50px vertical or scale from 0.0

**Scale Animation**:
- Used in: Note cards
- Duration: 300ms + (index * 50ms)
- Effect: Scale from 0.0 to 1.0
- Curve: Ease out back

### Interactive Animations

**Button Ripple**:
- Duration: 300ms
- Effect: Circular ripple from tap point
- Color: Theme-adaptive overlay

**Card Tap**:
- Duration: 100ms
- Effect: Subtle scale down (0.98)
- Spring back on release

**Checkbox Toggle**:
- Duration: 300ms
- Effect: Checkmark fade in/out
- Tween animation for completion state

**Tab Switch**:
- Duration: 300ms
- Curve: Ease in out
- Effect: Horizontal slide + fade

### Toolbar Animations

**Auto-hide Toolbar** (Group Detail Screen):
- Trigger: Scroll down > 8px
- Duration: 200ms
- Effect: Size transition (height: 90px → 0px)
- Curve: Ease out
- Reverse: Scroll up triggers show

**Collapse Button Rotation**:
- Duration: 200ms
- Effect: Icon rotates 180° (0.0 → 0.5 turns)
- Synchronized with toolbar visibility

### Navigation Animations

**Page Transition**:
- Duration: 300ms
- Effect: Horizontal swipe + fade
- Curve: Ease in out
- Direction: Left/right based on navigation

**Hero Animation**:
- Used in: Group icon (List → Detail)
- Duration: 300ms
- Effect: Smooth position + size transition
- Tag: 'group_icon_[groupId]'

**Bottom Sheet**:
- Duration: 300ms
- Effect: Slide up from bottom
- Backdrop: Semi-transparent overlay
- Curve: Ease out

### Loading States

**Circular Progress**:
- Size: 20x20px (buttons), 40x40px (screen center)
- Color: Primary blue
- Stroke width: 2px (small), 3px (large)

**Skeleton Loading**:
- Effect: Shimmer animation
- Colors: Gray gradient
- Used for: Placeholder content

---

## Accessibility Considerations

### Color Contrast
- All text meets WCAG AA standards
- Minimum contrast ratio: 4.5:1 for body text
- Minimum contrast ratio: 3:1 for large text and icons

### Touch Targets
- Minimum size: 44x44px
- Adequate spacing between tappable elements
- Extended tap areas for small icons

### Text Scaling
- All text respects system font size settings
- Layout adapts to larger text sizes
- No text truncation at 200% zoom

### Visual Feedback
- Clear focus indicators
- Tap feedback (ripple effect)
- Loading states for async operations
- Success/error confirmations via snackbars

### Dark Mode
- Full support for dark theme
- Proper contrast ratios maintained
- Reduced eye strain for low-light conditions

---

## Platform Considerations

### Android & iOS Compatibility
- Material Design 3 components
- Platform-adaptive dialogs and pickers
- Back button handling (Android)
- Safe area insets (iOS notch/home indicator)

### Responsive Design
- Adaptive layouts for different screen sizes
- Grid column count adjusts for tablets
- Bottom navigation optimized for mobile
- Dialog widths constrained on large screens

---

## Export & Sharing Features

### PDF Export
- **Trigger**: Export button in group detail toolbar
- **Content**: 
  - Group summary
  - Member list with balances
  - Complete transaction history
  - Settlement suggestions
- **Format**: Professional PDF layout
- **Sharing**: Native share sheet integration

### Data Format
- JSON structure
- Human-readable export
- Import capability (future feature)

---

## Future Enhancements

### Planned Features
- 📊 Charts and visualizations for spending patterns
- 🔔 Push notifications for expense additions
- 🌍 Multi-language support
- ☁️ Cloud sync and backup
- 👥 Multi-user collaboration (real-time)
- 🎨 Custom themes and color schemes
- 📸 Receipt photo attachments
- 🏷️ Expense categories and tags
- 📅 Recurring expenses
- 💱 Multiple currency support

---

## Technical Notes

### State Management
- Uses Riverpod for reactive state management
- Provider-based architecture
- Automatic UI updates on data changes

### Data Persistence
- Local SQLite database via Drift/Moor
- SharedPreferences for user preferences
- Automatic data serialization

### Performance
- Lazy loading for large lists
- Efficient state updates
- Optimized build methods
- Minimal rebuilds

---

## Design Assets Required

### Icons
- All icons from Material Icons package
- Custom icons: None currently
- Icon sizes: 16px, 20px, 22px, 24px, 48px

### Images
- No custom images currently used
- App icon: Required (multiple sizes for platforms)
- Splash screen: Gradient background with logo

### Fonts
- System default font (Segoe UI on Windows, SF Pro on iOS, Roboto on Android)
- No custom fonts currently used

---

## Version History

### v1.0.0 (Current)
- Initial release
- Core expense tracking features
- Task and note management
- Profile settings
- Light/Dark theme support
- PDF export functionality

---

## Contact & Feedback

For design questions, feedback, or collaboration:
- App Name: Hesabatna
- Version: 1.0.0
- Last Updated: October 27, 2025

---

**End of Documentation**


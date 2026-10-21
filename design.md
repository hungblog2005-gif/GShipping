# GShipping --- Frontend Design Specification

**Version:** 1.0.0\
**Product:** GShipping\
**Platform:** Flutter Web\
**Audience:** Administrators and customers\
**Visual direction:** Professional Blue & White\
**Status:** Frontend specification for a newly initialized project

------------------------------------------------------------------------

## 1. Product vision

GShipping is a web-based shipping and delivery platform with two
distinct experiences:

1.  **Customer portal:** sign in, create and manage shipment requests,
    maintain addresses, and track shipments.
2.  **Admin portal:** monitor operations, manage shipments and address
    data, inspect shipment details, and access operational summaries.

The frontend must be professional, responsive, accessible, and prepared
for backend integration. Since backend endpoints and response schemas
have not yet been supplied, all data access must be abstracted behind
repositories. Use clearly labeled mock data during UI development; do
not invent API endpoints or assume production business rules.

### Product principles

-   **Clarity first:** shipment status, tracking number, recipient, and
    next action should be easy to find.
-   **Role-aware navigation:** customer and admin navigation must be
    separate.
-   **API-independent UI:** screens depend on repository interfaces
    rather than HTTP details.
-   **Honest states:** loading, empty, error, offline, and success
    states are first-class UI states.
-   **Responsive by design:** optimize desktop first for operations,
    while preserving usable tablet and mobile layouts.
-   **Accessible interactions:** labels, keyboard focus, contrast, and
    status text must not depend on color alone.

## 2. Scope

### Included in the first frontend release

-   Public landing / entry page
-   Sign in and sign out UI
-   Route guards and role-aware navigation scaffolding
-   Customer dashboard
-   Admin dashboard
-   Shipment list, search, filter, and detail views
-   Create-shipment form UI
-   Address book and address selection UI
-   Province/city selector component, ready for a future API
-   Shipment tracking page with timeline UI
-   Profile and settings shell
-   Shared design system and reusable components
-   Mock repositories for development and demos
-   Responsive layouts, form validation, and error handling
-   Basic widget tests for critical UI states

### Not assumed or included until requirements are confirmed

-   Actual backend endpoints, authentication provider, and token format
-   Payment, COD, pricing, carrier integrations, label printing, and
    refunds
-   Real-time tracking or WebSocket updates
-   Exact shipment lifecycle, cancellation policy, and permissions
-   Admin analytics definitions and production KPI calculations
-   Map provider, geocoding, and route optimization
-   Production secrets or API credentials

These items can be added after backend contracts and business rules are
known.

## 3. Information architecture

### Public routes

  -----------------------------------------------------------------------
  Route                               Purpose
  ----------------------------------- -----------------------------------
  `/`                                 Entry page and product introduction

  `/login`                            Sign-in screen

  `/track`                            Public tracking lookup, if enabled
                                      by product requirements

  `/track/:trackingCode`              Tracking result, if public tracking
                                      is enabled
  -----------------------------------------------------------------------

### Customer routes

  Route                       Purpose
  --------------------------- -------------------------
  `/customer`                 Customer dashboard
  `/customer/shipments`       Shipment list
  `/customer/shipments/new`   Create shipment
  `/customer/shipments/:id`   Shipment details
  `/customer/addresses`       Saved addresses
  `/customer/profile`         Profile and preferences

### Admin routes

  -----------------------------------------------------------------------
  Route                               Purpose
  ----------------------------------- -----------------------------------
  `/admin`                            Operations dashboard

  `/admin/shipments`                  Shipment management

  `/admin/shipments/:id`              Shipment detail and permitted
                                      actions

  `/admin/addresses`                  Address and location data view,
                                      depending on backend support

  `/admin/customers`                  Customer list, only if supported by
                                      backend and permissions

  `/admin/settings`                   Administrative settings shell
  -----------------------------------------------------------------------

Route names are proposed frontend conventions, not backend endpoints. If
public tracking or a module is not part of the agreed product scope,
hide its route and navigation entry.

## 4. Role experiences

### Customer portal

Primary navigation: - Overview - My shipments - Create shipment - My
addresses - Profile

The customer dashboard should prioritize: - A clear "Create shipment"
primary action - Shipment counts by available statuses - Recent
shipments - A tracking-code lookup - Helpful empty states for new
customers

Customers may only see or change records authorized by the backend.
Hiding controls in the frontend is not a substitute for server-side
authorization.

### Admin portal

Primary navigation: - Overview - Shipments - Addresses / locations (only
where supported) - Customers (only where supported) - Settings

The admin dashboard should prioritize: - Operational shipment summary
cards - Shipment search and filtering - Recent or attention-needed
shipments, based on confirmed backend rules - A clear path to shipment
details - Loading and data freshness indicators

Do not show invented live statistics in production. Mock data must be
labeled as demo data.

## 5. Visual design system

### 5.1 Brand direction

**Personality:** dependable, efficient, precise, modern.\
**Style:** Blue & White, clean SaaS interface, restrained shadows,
generous whitespace, clear data hierarchy.

Avoid excessive gradients, oversized decoration, or animations that
distract from operational tasks.

### 5.2 Color tokens

  -----------------------------------------------------------------------
  Token                   Hex                     Usage
  ----------------------- ----------------------- -----------------------
  `primary`               `#2563EB`               Primary actions, active
                                                  links, selected
                                                  controls

  `primaryHover`          `#1D4ED8`               Hover / pressed state

  `primaryTint`           `#EFF6FF`               Selected navigation,
                                                  soft emphasis

  `navy`                  `#0F172A`               High-contrast text /
                                                  optional dark
                                                  navigation

  `background`            `#F8FAFC`               App background

  `surface`               `#FFFFFF`               Cards, dialogs, panels

  `textPrimary`           `#0F172A`               Headings and main
                                                  content

  `textSecondary`         `#64748B`               Descriptions and
                                                  metadata

  `border`                `#E2E8F0`               Borders and separators

  `success`               `#15803D`               Successful / delivered
                                                  state

  `successTint`           `#F0FDF4`               Soft success background

  `warning`               `#B45309`               Attention / pending
                                                  state

  `warningTint`           `#FFFBEB`               Soft warning background

  `error`                 `#B91C1C`               Errors / failed state

  `errorTint`             `#FEF2F2`               Soft error background

  `info`                  `#0369A1`               Informational state

  `infoTint`              `#F0F9FF`               Soft information
                                                  background
  -----------------------------------------------------------------------

Status-to-color mappings are provisional. Final labels and states must
match the backend domain model. Always pair color with text and, where
helpful, an icon.

### 5.3 Typography

Use Inter if font assets and licensing are configured; otherwise use a
readable system fallback.

  Style               Desktop size   Weight
  ----------------- -------------- --------
  Page title                 28 px      700
  Section title              20 px      600
  Card title                 16 px      600
  Body                       14 px      400
  Supporting text            12 px      400
  Button                     14 px      600
  KPI value              28--32 px      700

Use a 22--24 px page title on narrow screens. Keep line lengths
comfortable and avoid using too many font sizes.

### 5.4 Spacing, shape, and elevation

Use a 4 px base spacing scale: - `4`: icon/text gap - `8`: compact
control spacing - `12`: related content - `16`: standard component
spacing - `24`: section spacing - `32`: major page spacing - `40–48`:
large layout separation

Suggested shape tokens: - Small control radius: 8 px - Card radius: 12
px - Dialog radius: 16 px - Standard border: 1 px - Card elevation:
subtle; prefer border and whitespace over heavy shadows

### 5.5 Iconography

Use one consistent icon family, preferably Material Symbols / Flutter
Material Icons. Icons must be paired with labels where their meaning is
not obvious. Provide tooltips for icon-only desktop actions.

## 6. Responsive layout

Use layout constraints rather than checking platform alone.

  -----------------------------------------------------------------------
  Width                               Layout behavior
  ----------------------------------- -----------------------------------
  `< 600 px`                          Mobile: single-column forms,
                                      compact top bar, drawer or bottom
                                      navigation, list cards instead of
                                      wide tables

  `600–1023 px`                       Tablet: flexible grid, collapsible
                                      navigation, tables may allow
                                      controlled horizontal scrolling

  `>= 1024 px`                        Desktop: persistent sidebar, top
                                      bar, multi-column dashboard and
                                      data tables

  `>= 1440 px`                        Wide desktop: cap content width
                                      where appropriate; do not stretch
                                      forms excessively
  -----------------------------------------------------------------------

Suggested desktop shell: - Sidebar expanded width: 248 px - Sidebar
collapsed width: 76 px - Top bar height: 64--72 px - Main content
padding: 24--32 px - Section gap: 24 px

Responsive requirements: - No unintended horizontal overflow. - Data
tables must have a mobile alternative, not simply shrink all columns. -
Forms use one column on mobile and may use two columns on wide
screens. - Primary actions remain visible and reachable. - Dialogs must
fit smaller browser windows and support scrolling when necessary.

## 7. Shared application shell

### Sidebar

-   GShipping logo / wordmark
-   Role-aware navigation
-   Clear selected route
-   Collapse control on desktop
-   Tooltip for collapsed icon items
-   Profile and sign-out section at the bottom

### Top bar

-   Current page title or breadcrumb
-   Optional global search only when implemented
-   Notifications only when backed by real data
-   User avatar / profile menu
-   Mobile navigation trigger

### Main content

-   Consistent page header with title and description
-   Primary action aligned consistently
-   Content sections with predictable spacing
-   Loading, empty, and error patterns

## 8. Screen specifications

### 8.1 Entry page

Purpose: route users to sign in or public tracking, where enabled.

Components: - GShipping logo and short value proposition - Primary "Sign
in" action - Optional tracking lookup - Responsive, restrained hero
area - Footer with only real links

Do not add pricing, service promises, carrier logos, or operational
claims that have not been confirmed.

### 8.2 Sign-in page

Components: - Email / username field, according to the eventual auth
contract - Password field with visibility toggle - Submit button and
loading state - Field-level validation and general error message -
Optional "Forgot password?" only if recovery flow will be supported -
Optional remember-session checkbox only if its security behavior is
defined

Requirements: - Do not store passwords in local storage. - Do not
hardcode credentials or tokens. - Keep authentication behind an
`AuthRepository` abstraction. - Show a demo sign-in only in explicit
development mode, with a visible demo label. - Redirect by the
authenticated user's role, using the app's auth state and router guard.

### 8.3 Customer dashboard

Components: - Welcome header - "Create shipment" primary button -
Summary cards based on available data - Recent shipments list - Tracking
lookup - First-use empty state with a clear next step

KPI labels and calculations must be confirmed against the backend. If
only shipment lists are available, derive counts from authorized records
only when the pagination and data contract make that calculation valid.

### 8.4 Admin dashboard

Components: - Page header and optional date range filter - KPI cards
only for confirmed metrics - Recent shipments table - Attention-needed
panel only if corresponding statuses and rules exist - Loading, error,
and empty states

No hardcoded production metrics. Charts are optional and should only be
added when real time-series data exists.

### 8.5 Shipment list

Desktop columns (adapt to actual model): - Tracking / shipment
identifier - Recipient - Destination summary - Created date - Status -
Actions

Controls: - Search by supported fields - Status filter based on actual
status enum - Date filter only if backend supports it or client-side
filtering is valid - Pagination / page size - Clear filters - Retry
after errors

Mobile: - Card per shipment - Tracking identifier and status at top -
Recipient and destination below - View details action - Avoid dense,
horizontally overflowing tables

### 8.6 Create shipment form

Use a clear step or section structure.

**Sender** - Name - Phone - Address

**Recipient** - Name - Phone - Province / city - District and ward only
if available in the chosen location data source - Detailed address

**Package** - Item description - Weight - Dimensions only if required -
Delivery notes - Service selection only if supported

**Review** - Summary of entered information - Edit action for each
section - Submit button with progress indicator

Validation: - Required fields are clearly marked. - Phone and numeric
validation must follow agreed product rules. - Display field-level
errors and preserve entered data after recoverable failures. - Prevent
accidental duplicate submissions while a request is in progress. - Do
not invent shipping price calculations. - Dependent location selectors
must reset child selections when a parent selection changes.

### 8.7 Address book

Customer address view: - Saved address cards or table - Add / edit /
delete controls only when supported - Mark default address only if the
product supports this concept - Empty state with "Add address" - Confirm
destructive actions

Admin location view: - Separate from customer saved addresses if these
are different domain concepts. - Show province/city fields only when
available from the configured source. - Do not mix system location
catalog data with a customer's personal address book.

### 8.8 Tracking page

Components: - Tracking code search field - Shipment summary - Current
status label - Timeline of tracking events - Last updated timestamp, if
provided - Clear not-found and service-error states

Timeline: - Display events in chronological order according to the
source contract. - Show event time, event label, and
location/description only when supplied. - Do not fabricate tracking
events or imply real-time updates if the backend does not provide
them. - Public access must follow the eventual privacy policy; avoid
exposing personal details to anyone who knows a tracking code.

### 8.9 Shipment detail

Sections: - Shipment identifier and status - Sender and recipient
summary, subject to role permissions - Package information - Tracking
timeline - Created / updated metadata - Available actions based on role,
status, and backend capabilities

Admin-only actions must not appear in customer UI. The backend must
enforce all authorization regardless of frontend visibility.

### 8.10 Profile and settings

Initial shell: - Basic profile details supported by auth/user data -
Sign-out - Future settings sections only when requirements exist

Do not display editable fields that cannot be persisted.

## 9. Reusable component library

Suggested components:

  Component            Responsibility
  -------------------- -----------------------------------------------
  `AppShell`           Shared authenticated page frame
  `AppSidebar`         Role-aware desktop navigation
  `AppTopbar`          Page context and profile menu
  `PageHeader`         Title, description, actions
  `AppButton`          Primary, secondary, danger, and text variants
  `AppTextField`       Standard input and validation
  `AppDropdown<T>`     Typed dropdown
  `StatusBadge`        Status label with accessible color and icon
  `StatCard`           Dashboard summary card
  `ShipmentTable`      Desktop shipment list
  `ShipmentCard`       Responsive shipment summary
  `TrackingTimeline`   Shipment event timeline
  `AddressForm`        Reusable sender / recipient address fields
  `AppLoading`         Loading presentation
  `AppEmptyState`      No-data presentation and optional action
  `AppErrorState`      Friendly error message and retry callback
  `ConfirmDialog`      Confirmation for destructive actions
  `AppSnackBar`        Consistent operation feedback

Keep visual components presentational where possible. Data fetching
belongs in providers/controllers and repositories, not inside generic
buttons, cards, or fields.

## 10. Flutter architecture

Use a feature-first structure with clear boundaries. Start simple and
avoid adding abstraction without a use case.

``` text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   └── theme/
│       ├── app_colors.dart
│       ├── app_spacing.dart
│       ├── app_typography.dart
│       └── app_theme.dart
├── core/
│   ├── config/
│   ├── errors/
│   ├── network/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── customer_dashboard/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── admin_dashboard/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── shipments/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── addresses/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── tracking/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── models/
    └── widgets/
```

Within each feature: - `data`: DTOs, data sources, repository
implementations, mock repositories. - `domain`: entities, repository
contracts, use cases when useful. - `presentation`: pages, widgets,
controllers/providers, view state.

For a small initial project, it is acceptable to keep domain layers
lightweight. Do not create empty files or speculative classes solely to
match the tree.

### State management

Choose one state-management solution and use it consistently. Riverpod
is a reasonable default for dependency injection and async state;
Provider or Bloc is also acceptable if already selected. Do not mix
approaches without a clear reason.

### Routing

Use a centralized router (for example, `go_router`) with named routes
and redirect logic. Keep route definitions in one place.

Required behavior: - Unknown route → not-found page - Unauthenticated
access to protected route → sign-in - Customer role accessing admin
route → unauthorized page or customer home - Admin role accessing
customer-only route → redirect according to agreed policy - Deep links
should work on web hosting with the appropriate server rewrite
configuration

Frontend guards improve UX but do not replace backend authorization.

## 11. Data and API integration strategy

### Repository boundary

Screens must depend on interfaces such as: - `AuthRepository` -
`ShipmentRepository` - `AddressRepository` - `TrackingRepository`

Implement mock repositories first. Later, add HTTP implementations
behind the same interfaces so UI screens do not need to be rewritten.

Example conceptual flow:

``` text
Page / Widget
    ↓
Controller or Provider
    ↓
Repository interface
    ↓
Mock repository (now) / HTTP data source (later)
```

### API integration rules

-   Do not invent endpoint URLs, request bodies, response keys, or
    status enums.
-   Store the API base URL in environment-specific configuration once
    the backend contract is known.
-   Centralize HTTP client setup, timeout, serialization, and error
    mapping.
-   Parse response data into typed models before presenting it.
-   Handle HTTP failures, timeouts, malformed JSON, and empty results.
-   Never embed private API keys or secrets in a web client.
-   Do not persist passwords in browser storage.
-   Use server-side authorization for every protected operation.
-   Add cancellation, pagination, caching, or retry only where useful
    and consistent with backend semantics.

### Mock data rules

-   Keep mock data in a separate development-only source.
-   Label demo data visibly in the UI or development environment.
-   Avoid fake "live" tracking claims.
-   Make switching to the real repository explicit through dependency
    configuration.
-   Add tests for mock and HTTP repository behavior separately when the
    API exists.

## 12. UI states and feedback

Every data-driven page should define: 1. Initial / loading 2. Success
with data 3. Empty result 4. Recoverable error with retry 5. Permission
denied, where applicable 6. Submitting / disabled action state for forms

Feedback: - Use inline field errors for validation. - Use snackbars for
brief success/failure confirmation. - Use dialogs for destructive or
consequential actions. - Avoid raw exception text in user-facing
messages. - Log diagnostic details only through a configured
development-safe logging strategy.

## 13. Accessibility and quality

-   Maintain readable contrast for text and controls.
-   Do not use color alone to communicate shipment state.
-   Provide semantic labels for icon-only controls.
-   Support keyboard navigation and visible focus in web forms.
-   Ensure focus order follows visual order.
-   Use tooltips where desktop icon actions are ambiguous.
-   Aim for touch targets around 44--48 px on compact layouts.
-   Support browser zoom without clipping key controls.
-   Keep Vietnamese labels consistent and proofread.
-   Use locale-aware date, time, and number formatting when the locale
    requirements are confirmed.

## 14. Performance and web delivery

-   Use `const` widgets where possible.
-   Keep `build()` methods free of expensive work and network requests.
-   Use lazy lists for long collections.
-   Avoid unnecessary full-page rebuilds.
-   Optimize image/font assets and include only needed packages.
-   Test on Chrome at multiple viewport sizes.
-   Configure production hosting to serve the Flutter web entry point
    for client-side routes.
-   Keep environment configuration separate for local, staging, and
    production builds.
-   Do not commit secrets or environment-specific credentials.

## 15. Testing strategy

### Unit tests

-   Model serialization and validation
-   Status-label mapping
-   Repository behavior
-   Role-based route decisions
-   Form validation helpers

### Widget tests

-   Sign-in validation and loading state
-   Dashboard loading / empty / error states
-   Shipment list filters and empty state
-   Create-shipment required fields
-   Address dropdown dependency behavior
-   Tracking not-found and timeline states
-   Role-aware navigation visibility

### Manual acceptance checks

-   Desktop width (1440 px)
-   Laptop width (1280 px)
-   Tablet width (768 px)
-   Mobile width (390 px)
-   Keyboard-only navigation
-   Browser refresh on a nested route
-   Network failure and retry
-   No accidental overflow
-   Customer cannot navigate to admin views through the UI
-   No mock data presented as real production data

## 16. Implementation roadmap

### Phase 0 --- Project baseline

**Deliverables** - Verify Flutter SDK and Web target - Initialize Git
and baseline project - Add lint rules and format conventions - Decide
state management and router - Add `design.md`

**Exit criteria** - App starts in Chrome - `flutter analyze` runs -
Directory conventions are agreed

### Phase 1 --- Design foundation

**Deliverables** - Color, typography, spacing, and theme tokens - Shared
buttons, fields, status badge, cards - Responsive app shell - Sidebar,
top bar, page header - Loading, empty, error, and confirmation
components

**Exit criteria** - Components render consistently at target widths -
Theme can be updated centrally

### Phase 2 --- Routing and authentication scaffolding

**Deliverables** - Public and protected routes - Sign-in page - Auth
state abstraction - Role-aware redirects - Mock auth for development
only - Not-found and unauthorized pages

**Exit criteria** - Customer and admin navigation paths can be
demonstrated - Mock auth is clearly separated from production auth

### Phase 3 --- Customer experience

**Deliverables** - Customer dashboard - Shipment list and detail -
Create-shipment form - Address book - Tracking lookup and timeline

**Exit criteria** - Main flows work with mock repositories - Form
validation and error states are covered by tests

### Phase 4 --- Admin experience

**Deliverables** - Admin dashboard - Shipment management list and
detail - Search/filter UI - Admin address/location view where
applicable - Role-aware actions

**Exit criteria** - Admin pages use shared components - No unconfirmed
backend capability is represented as functional

### Phase 5 --- API integration

**Prerequisite:** backend API documentation or confirmed
request/response contracts.

**Deliverables** - HTTP data sources - Typed DTOs and model mapping -
Auth integration - Shipment, address, and tracking repository
implementations - Error and pagination mapping - Environment
configuration

**Exit criteria** - Mock and real data sources can be switched through
dependency configuration - UI behavior is tested against known API
contracts

### Phase 6 --- QA and deployment

**Deliverables** - Responsive review - Widget and unit tests -
Accessibility checks - Production build - Hosting fallback / rewrite
configuration - Environment and release checklist

**Exit criteria** - Critical flows pass on supported browsers - No
unresolved critical analyzer or test failures - Deployment configuration
supports nested routes

## 17. Suggested dependency policy

Select packages only when their role is clear. Common candidates: -
Router: `go_router` - State management: `flutter_riverpod` or the
project's chosen alternative - HTTP: `http` or `dio` - Model generation:
`json_serializable` only when model volume warrants it - Icons: Flutter
Material Icons initially

Check package compatibility with the installed Flutter SDK before adding
dependencies. Avoid introducing a large UI kit unless it materially
reduces implementation effort and allows the required design
customization.

## 18. Definition of done

A feature is complete when: - It follows the shared Blue & White design
system. - It behaves correctly at desktop, tablet, and mobile widths. -
Loading, empty, error, and success states are implemented where
relevant. - It uses typed models and repository boundaries. - It does
not invent backend behavior or expose secrets. - Role-specific UI is
correct and backend authorization assumptions are documented. - Critical
behavior has unit or widget tests. - `dart format`, `flutter analyze`,
and relevant tests have been run. - The implementation does not break
other routes or shared components.

## 19. Decisions required before production integration

Confirm these with the backend/product owner before connecting real
services: 1. Authentication method, user model, token/session lifecycle,
and roles 2. Shipment schema, allowed statuses, and status transitions
3. Create/update/cancel shipment permissions 4. Address schema and
authoritative province/district/ward source 5. Tracking event schema,
timestamps, and public visibility 6. Pagination, sorting, filtering, and
search behavior 7. Dashboard metric definitions 8. API base URLs, error
format, and environment setup 9. Privacy rules for customer and tracking
information 10. Hosting and deployment target

------------------------------------------------------------------------

**Implementation rule:** build the visual system and complete user flows
against mock repositories first. Connect real services only after the
backend contract is confirmed. Keep the UI, business rules, and HTTP
implementation separated so GShipping can evolve without a frontend
rewrite.

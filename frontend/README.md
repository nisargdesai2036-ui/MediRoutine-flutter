# MediRoutine — Frontend (Phase 1 Refactored)

**MediRoutine** is a modern, personal medicine-routine and medication-adherence companion.

---

## 🎨 Editorial Split-Screen Visual Identity

The authentication experience has been refactored into a high-end, product-grade split composition:

### 1. Brand Panel (Left on Desktop / Header on Mobile)
- **Deep Indigo & Twilight Canvas** (#0C101D / #13192B).
- **Generative Abstract Routine Sculpture (AbstractRoutineVisual)**:
  - Restrained, continuous 24h orbital ribbon symbolizing daily continuity and adherence.
  - Three luminous milestone nodes (*Morning*, *Midday*, *Evening*).
  - Minimalist capsule & pulse synchronicity glyph in the center.
- **Editorial Brand Typography**:
  - * Your health on routine.*
  - Supporting copy and trust pill badge (*Private encrypted health data*).

### 2. Auth Surface (Right on Desktop / Main Card on Mobile)
- **Crisp, Light Surface** (#FFFFFF / #F8FAFC) with generous whitespace.
- **Refined Inputs (MediTextField)**: Clean off-white surface, subtle #E2E8F0 borders, royal violet active outline, floating labels, and inline animated errors.
- **Tactile CTAs (MediButton)**: Solid violet primary action with hover depth and loading feedback.
- **Password Strength & Live Match Feedback**: 3-tier dynamic strength meter on sign-up with live match confirmation checkmark.
- **Social Authentication**: Google & Apple sign-in options with optical icon alignment.

---

## 📱 Responsive Architecture

- **Desktop / Laptop (>= 900px)**: Two-column split layout (Left 48% Brand Artwork Panel + Right 52% Auth Surface).
- **Tablet / Mobile (< 900px)**: Single-column vertical flow with brand mark and animated mode switching between Login and Sign Up.

---

## 🚀 Running the App Locally

`ash
# In the frontend directory:
cd frontend

# Run in Chrome Web:
flutter run -d chrome

# Run as Windows Desktop App:
flutter run -d windows

# Run Tests:
flutter test

# Run Static Analysis:
flutter analyze
`

All 17 automated unit and widget tests pass with 0 warnings and 0 linter errors.

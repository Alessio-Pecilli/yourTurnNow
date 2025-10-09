# YourTurnNow

Application developed in **Flutter (Dart)** for managing tasks and shared expenses among roommates.  
The user interface was partially designed with **Figma** and **Adobe Photoshop**, following the principles of **Material Design 3**.

---

## General Overview

YourTurnNow is a cross-platform application designed to simplify and organize shared living.  
Each user can manage their personal tasks, record individual or shared expenses, and view detailed summaries with automatically generated charts.

The app integrates Google-based authentication (OAuth2) and distinguishes between basic users and administrators, offering different functionalities depending on the role.

---

## Main Features

### Basic User
- Create and manage personal goals or tasks.  
- Add and edit personal or shared transactions.  
- View summaries and graphical reports of expenses.  

### Administrator
- Manage the list of roommates.  
- Create, edit, and remove expense or task categories.  
- Access all user functionalities.

---

## Architecture and Technologies

- **Language:** Dart  
- **Framework:** Flutter  
- **State Management:** Riverpod  
- **Design System:** Material Design 3 with dynamic color support  
- **Authentication:** OAuth2 (Google)  
- **Internationalization (i18n):** multilingual interface support  
- **Accessibility:** compliant with WCAG 2.1.4 guidelines (contrast ratios, keyboard shortcuts, color differentiation)

---

## Testing and Code Quality

- Implementation of **unit tests** and **widget tests** for critical components.  
- Integration of automated tests within CI/CD pipelines.  
- Code quality control and version management via Git and GitHub.

---

## Performance

- Use of **Sliver** widgets for efficient list rendering.  
- Optimization through `const` widgets and caching mechanisms.  
- Navigation handled with **go_router** to minimize rebuilds.

---

## DevOps and Deployment

- **Monorepo** project structure.  
- **CI/CD** pipelines configured with GitHub Actions.  
- **Docker** used for containerized builds and deployments.  
- Secure management of secrets and environment variables.

---

## Main Dependencies

- `provider`  
- `shared_preferences`  
- `connectivity_plus`  
- `flutter_native_splash`  
- `google_fonts`  
- `pdf`  
- `printing`  
- `go_router`

---

## Project Goals

- Provide a simple and complete solution for managing shared living.  
- Ensure a smooth, accessible, and modern user experience.  
- Apply professional development practices, from design to testing and automated deployment.

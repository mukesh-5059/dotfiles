# Gemini Code Assistant Context

This document provides context for the Gemini AI code assistant about the `eww` configuration in this directory.

## Project Overview

This is a configuration for `eww` (Elkowar's Wacky Widgets), a standalone widget system for Linux desktops. It provides a status bar, a side bar, and various other informational and control widgets.

The configuration is structured as follows:

-   **`eww.yuck`**: The main configuration file that defines variables, polls for data, and includes all the widget definitions.
-   **`eww.scss`**: The main stylesheet that imports all other `.scss` files.
-   **`widgets/`**: This directory contains the `.yuck` files that define the structure of the individual widgets.
-   **`scss/`**: This directory contains the `.scss` files that define the styling for the widgets.
-   **`scripts/`**: This directory contains various shell scripts that are used to fetch data for the widgets (e.g., battery level, current workspace, volume, etc.).
-   **`icons/`**: This directory contains SVG and PNG icons used in the widgets.

## Building and Running

The main executable for this project is `eww`. The configuration defines several windows that can be opened.

To run the widgets, first ensure the `eww` daemon is running:
```bash
eww daemon
```

Then, you can open the desired windows:

-   **Bar**:
    ```bash
    eww open bar
    ```

-   **Side Bar**:
    ```bash
    eww open side-bar
    ```

-   **Calendar**:
    ```bash
    eww open calendar
    ```

You can close a window with `eww close <window_name>`. To see all defined windows, you can inspect the `.yuck` files in the `widgets/` directory.

## Development Conventions

-   **Widget Structure**: Widget structure is defined in `.yuck` files in the `widgets/` directory. The main `eww.yuck` file includes these.
-   **Styling**: Styling is done using SCSS. The main stylesheet is `eww.scss`, which imports modular stylesheets from the `scss/` directory. Colors are defined in `colors.scss`.
-   **Data Fetching**: Data is fetched by shell scripts in the `scripts/` directory. These are called by `defpoll` and `deflisten` definitions in `eww.yuck`.
-   **Icons**: Icons are stored in the `icons/` directory.

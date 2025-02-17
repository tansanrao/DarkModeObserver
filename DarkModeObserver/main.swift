//
//  main.swift
//  DarkModeObserver
//
//  Created by Tanuj Ravi Rao on 2/17/25.
//

import Foundation
import AppKit
_ = NSApplication.shared

func currentTheme() -> String {
    // "Dark" if present; otherwise, assume "light"
    let theme = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
    return (theme == "Dark") ? "dark" : "light"
}

func runShellCommand(_ command: String) {
    let process = Process()
    // Using zsh (you can change this if you use a different shell)
    process.executableURL = URL(fileURLWithPath: "/bin/zsh")
    process.arguments = ["-c", command]
    
    do {
        try process.run()
    } catch {
        print("Error running command: \(error)")
    }
}

func updateAlacritty(for theme: String) {
    var command = "echo 'Updating Alacritty to \(theme) mode' >> ~/theme_log.txt"
    runShellCommand(command)
    if theme == "dark" {
        command = """
        FILE="$HOME/.config/alacritty/alacritty.toml"
        # Check if the file is a symlink, and if so, resolve its absolute path
        if [ -L "$FILE" ]; then
            FILE=$(perl -MCwd -e 'print Cwd::abs_path(shift)' "$FILE")
        fi
        # Perform the sed substitution to change the theme
        sed 's/catppuccin-latte/catppuccin-mocha/g' "$FILE" > "${FILE}.tmp" && mv "${FILE}.tmp" "$FILE"
        """
        runShellCommand(command)
    } else {
        command = """
        FILE="$HOME/.config/alacritty/alacritty.toml"
        # Check if the file is a symlink, and if so, resolve its absolute path
        if [ -L "$FILE" ]; then
            FILE=$(perl -MCwd -e 'print Cwd::abs_path(shift)' "$FILE")
        fi
        # Perform the sed substitution to change the theme
        sed 's/catppuccin-mocha/catppuccin-latte/g' "$FILE" > "${FILE}.tmp" && mv "${FILE}.tmp" "$FILE"
        """
        runShellCommand(command)
    }
}

func writeCurrentThemeFile(for theme: String) {
    let command = "echo '\(theme)' > ~/.current_theme"
    runShellCommand(command)
}

func setupThemeObserver() {
    let notificationCenter = DistributedNotificationCenter.default()
    
    notificationCenter.addObserver(forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
                                     object: nil,
                                     queue: OperationQueue.main) { notification in
        let theme = currentTheme()
        print("Theme changed to: \(theme)")
        
        updateAlacritty(for: theme)
        writeCurrentThemeFile(for: theme)
    }
}

print("Starting DarkModeObserver CLI Tool")
print("Current theme is: \(currentTheme())")
setupThemeObserver()


// Keep the tool running to listen for notifications.
RunLoop.main.run()

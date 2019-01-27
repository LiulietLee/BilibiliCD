# LLDialog
Material design dialog for iOS written in Swift.

![](https://cloud.githubusercontent.com/assets/9763162/12781499/b909ede8-caaf-11e5-8dac-d5fce055aec0.png)

## Installation

```
pod 'LLDialog', :git => 'https://github.com/LiulietLee/LLDialog.git'
```

or just move [Source/LLDialog.swift](Source/LLDialog.swift) to your project.

## Usage
You can see a simple example by downloading this project.

### Construct with Builder

```swift
LLDialog()
// Set title. (Optional, but recommended)
.set(title: "Use Google's location service?")

// Set message. (Optional, but recommended)
.set(message: "Let Google help apps determine location. This means sending anonymous location data to Google, even when no apps are running.")

// Set the buttons.
.setPositiveButton(withTitle: "AGREE", target: self, action: #selector(<#tappedPositiveButton#>))
.setNegativeButton(withTitle: "DISAGREE", target: self, action: #selector(<#tappedNegativeButton#>))

// At last, show the dialog.
.show()
// Or, especially if targeting extensions, show in a parent view.
.show(in: <#T##parent UIView##UIView#>)
```

### Or Convenience Initialzier

```swift
LLDialog(
    title: "Unapplied method reference",
    message: "It produces better indentation. Maybe not after SE-0042.",
    positiveButton: .init(
        title: "", // Title for positive button is required. Blank is the same as "OK".
        onTouchUpInside: (target: self,
                          action: #selector(<#tappedPositiveButton#>))),
    negativeButton: .init(
        title: "What?",
        onTouchUpInside: (target: self,
                          action: #selector(<#tappedNegativeButton#>)))
).show()
```

## TO DO

- [ ] The animation after tapping the button.

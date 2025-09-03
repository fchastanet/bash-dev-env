# VSCode Profile Decoder

This script allows you to decode VS Code profile files (`.code-profile`) into
readable JSONC format.

VS Code profiles contain nested JSONC strings that need to be parsed multiple
times to reveal their actual content. This tool handles the decoding and
produces a more readable representation of the profile.

## Usage

```bash
# Decode a single file
node decodeVsCodeProfile.js /path/to/profile.code-profile

# Decode all .code-profile files in a directory (recursively)
node decodeVsCodeProfile.js /path/to/directory
```

For each `.code-profile` file processed, the script will create a corresponding
`.code-profile.decoded.jsonc` file in the same location.

## Security Features

The script automatically detects and redacts sensitive information:

- Passwords, tokens, and credentials are identified based on key names
- Sensitive information is redacted in the output files
- A security warning is shown when sensitive data is detected
- All sensitive paths are listed in the summary report

## What gets decoded

The script recursively decodes all JSON and JSONC (JSON with comments) strings
found in the profile file, including:

- Settings (including nested settings)
- Keybindings
- Snippets (including individual snippet files)
- Global state (including storage items)
- Extensions
- Any other nested JSON/JSONC string properties

## Notes

- The script properly handles JSONC (JSON with comments) format
- Properties are recursively decoded at any depth
- Some parts of the profile may not be valid JSON/JSONC and will be kept as
  strings
- The script handles errors gracefully and continues processing other files if
  one fails
- Passwords and sensitive data (like API tokens) are automatically redacted

## Error Reporting

When parsing issues are encountered, the script provides detailed error
information:

- Exact error location (line and column)
- Full line content where the error occurs
- Highlighted context around the error
- Visual indicator pointing to the exact error position
- Helpful suggestions for fixing each type of error

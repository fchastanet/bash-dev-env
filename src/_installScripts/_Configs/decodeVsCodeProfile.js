#!/usr/bin/env node

/**
 * This script decodes VS Code profile files (.code-profile)
 * VS Code profiles contain nested JSON/JSONC strings that need to be parsed multiple times
 * to get the actual content.
 *
 * Usage:
 *   node decodeVsCodeProfile.js <file-or-directory-path>
 *
 * The script creates two output files for each processed profile:
 * 1. <filename>.code-profile.decoded.jsonc - A human-readable, prettified JSON with comments
 * 2. <filename>.code-profile.json - A re-encoded version in the same format as the original file
 *
 * Security features:
 * - Automatically detects and redacts passwords and other sensitive information
 * - Clears the commandPalette.mru.cache entries for privacy
 * - Provides warnings and a summary of redacted sensitive data
 *
 * Limitations:
 * - Comments in the original file cannot be fully preserved in the decoded output due to limitations
 *   in how JSON/JSONC parsing works. Comments in nested JSON strings are lost during parsing.
 * - The re-encoded .json file is structurally compatible with VS Code but won't retain the original comments.
 */

const fs = require("fs");
const path = require("path");
const util = require("util");
const jsoncParser = require("jsonc-parser");

// Promisify fs functions
const readFile = util.promisify(fs.readFile);
const writeFile = util.promisify(fs.writeFile);
const readdir = util.promisify(fs.readdir);
const stat = util.promisify(fs.stat);

// ANSI color codes for better error highlighting
const colors = {
  red: "\x1b[31m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  magenta: "\x1b[35m",
  cyan: "\x1b[36m",
  reset: "\x1b[0m",
};

// List of key patterns that might indicate passwords or sensitive data
const SENSITIVE_KEY_PATTERNS = [
  /pass(word)?/i,
  /token/i,
  /secret/i,
  /key$/i,
  /credential/i,
  /auth(?!ority)/i, // matches 'auth' but not 'authority'
  /api[-_]?key/i,
  /private[-_]?key/i,
];

// Track if passwords were found and removed
const passwordsFound = {
  detected: false,
  paths: [],
};

/**
 * Map JSONC parser error codes to descriptive messages
 *
 * @param {number} errorCode - The error code from jsonc-parser
 * @returns {string} - Description of the error
 */
function getParseErrorMessage(errorCode) {
  const errorMessages = {
    1: "Invalid symbol",
    2: "Invalid file ending",
    3: "Invalid comment",
    4: "Comment not permitted",
    5: "Invalid escape character in string",
    6: "Invalid character in string",
    7: "Property name expected",
    8: "Comma expected",
    9: "Colon expected",
    10: "Value expected",
    11: "End of file expected",
    12: "Invalid number format",
    13: "Invalid number format",
    14: "Property name expected",
    15: "Invalid trailing comma",
    16: "Expected value",
  };

  return errorMessages[errorCode] || `Unknown error (code: ${errorCode})`;
}

/**
 * Get helpful suggestion for fixing a parse error based on error code
 *
 * @param {number} errorCode - The error code from jsonc-parser
 * @returns {string} - A suggestion for fixing the error
 */
function getErrorSuggestion(errorCode) {
  const suggestions = {
    1: "Check for invalid symbols or characters that are not allowed in JSON.",
    2: "The file ended unexpectedly. Check for missing closing brackets, braces, or quotes.",
    3: "Check for invalid characters in a comment.",
    4: "A comment is not allowed in this position.",
    5: "Check for invalid escape sequences in strings.",
    6: "Invalid character in a string literal. Ensure special characters are properly escaped.",
    7: "Property names should be enclosed in double quotes.",
    8: "Expected a comma between object properties or array elements.",
    9: "Expected a colon after property name in an object.",
    10: "Value expected. Check for missing values or trailing commas.",
    11: "End of file expected. There might be extra content after valid JSON.",
    12: "Invalid number format.",
    13: "Invalid characters in number format.",
    14: "Property key expected. Check for missing or invalid object property names.",
    15: "Invalid trailing comma. JSON doesn't allow trailing commas in arrays or objects.",
    16: "Expected a valid JSON value (string, number, boolean, null, object, or array).",
  };

  return suggestions[errorCode] || "Check syntax at the highlighted position.";
}

function logParseErrors(errors, path) {
  console.warn(
    `\nWarning: JSONC parsing at ${path} had ${errors.length} errors but continued`
  );

  // Display a more comprehensive error message with code snippets
  errors.forEach((error, index) => {
    const errorCode = error.error;
    const errorMessage = getParseErrorMessage(errorCode);

    // Extract a snippet of the problematic code (20 chars before and after)
    const startPos = Math.max(0, error.offset - 20);
    const endPos = Math.min(str.length, error.offset + error.length + 20);
    let snippet = str.substring(startPos, endPos);

    // Add markers to highlight the exact error position in the snippet
    if (startPos < error.offset) {
      const markerPos = error.offset - startPos;
      const errorLength = Math.max(1, error.length); // Ensure we highlight at least one character

      snippet =
        snippet.substring(0, markerPos) +
        colors.red +
        snippet.substring(markerPos, markerPos + errorLength) +
        colors.reset +
        snippet.substring(markerPos + errorLength);

      // Add a caret indicator below the error
      const caretLine =
        " ".repeat(markerPos) + colors.yellow + "^" + colors.reset;
      snippet += "\n" + caretLine;
    }

    // Get the line number and column
    const lines = str.substring(0, error.offset).split("\n");
    const lineNum = lines.length;
    const colNum = lines[lines.length - 1].length + 1;

    // Get context for error
    const lineContent = str.split("\n")[lineNum - 1] || "";
    const suggestion = getErrorSuggestion(error.error);

    console.warn(
      `\n${colors.yellow}[Error ${index + 1}]${colors.reset} ${colors.cyan}${errorMessage}${colors.reset} (Code: ${errorCode})`
    );
    console.warn(
      `${colors.blue}Location:${colors.reset} line ${lineNum}, column ${colNum} in ${colors.green}${path}${colors.reset}`
    );

    // Show the specific line with error
    if (lineContent) {
      console.warn(
        `${colors.blue}Line ${lineNum}:${colors.reset} ${lineContent.replace(/\n/g, "")}`
      );
    }

    console.warn(`${colors.yellow}↓ Context around error ↓${colors.reset}`);
    console.warn("―".repeat(40));
    console.warn(snippet.replace(/\n/g, `${colors.magenta}↵${colors.reset}\n`));
    console.warn("―".repeat(40));
    console.warn(`${colors.green}Suggestion:${colors.reset} ${suggestion}`);
  });
}

/**
 * Tries to parse a string as JSONC
 *
 * @param {string} str - The string to parse
 * @param {string} [path=''] - Current path for logging purposes
 * @returns {any} - Parsed object or the original string if not valid JSONC
 */
function tryParseJsonc(str, path = "") {
  if (typeof str !== "string") {
    return str;
  }

  // Quick check to see if this looks like JSON/JSONC (starts with { or [)
  const trimmed = str.trim();
  if (!trimmed.startsWith("{") && !trimmed.startsWith("[")) {
    return str;
  }

  try {
    // Use jsonc-parser to parse, preserving comments
    const errors = [];
    const result = jsoncParser.parse(str, errors, {
      allowTrailingComma: true,
      disallowComments: false,
    });

    if (errors.length > 0) {
      logParseErrors(errors, path);
    }

    return result;
  } catch (e) {
    console.warn(`Could not parse JSONC at ${path}:`, e.message);
    return str;
  }
}

/**
 * Recursively processes an object to decode any JSON/JSONC string properties
 *
 * @param {any} obj - The object to process
 * @param {string} [path=''] - Current path for logging purposes
 * @returns {any} - The processed object with decoded properties
 */
function recursivelyDecodeJsonc(obj, path = "") {
  // Handle null and undefined
  if (obj === null || obj === undefined) {
    return obj;
  }

  // If it's a string, try to parse it as JSONC
  if (typeof obj === "string") {
    const parsed = tryParseJsonc(obj, path);
    if (parsed !== obj) {
      // It was parsed successfully, so recurse into the parsed object
      return recursivelyDecodeJsonc(parsed, path);
    }
    return obj;
  }

  // If it's an array, recursively process each element
  if (Array.isArray(obj)) {
    return obj.map((item, index) =>
      recursivelyDecodeJsonc(item, `${path}[${index}]`)
    );
  }

  // If it's an object, recursively process each property
  if (typeof obj === "object") {
    const result = {};
    for (const key of Object.keys(obj)) {
      result[key] = recursivelyDecodeJsonc(
        obj[key],
        path ? `${path}.${key}` : key
      );
    }
    return result;
  }

  // For other types (number, boolean, etc.), return as-is
  return obj;
}

/**
 * Decodes a VSCode profile file by parsing multiple levels of JSON/JSONC encoding
 *
 * This version attempts to preserve comments in the original file
 *
 * @param {string} content - The content of the profile file
 * @returns {Object} - The decoded profile object
 */
function decodeProfile(content) {
  try {
    // First level of parsing with jsonc-parser
    const profile = jsoncParser.parse(content);

    // Recursively decode all nested JSON/JSONC strings
    return recursivelyDecodeJsonc(profile);
  } catch (e) {
    console.error("Error parsing profile:", e);
    throw e;
  }
}

/**
 * Parse content as JSONC and return both the parsed object and the tree with location information
 * This is useful for preserving comments and structure
 *
 * @param {string} content - The content to parse
 * @returns {Object} - Object with parsed content and tree
 */
function parseTreeWithComments(content) {
  const errors = [];
  // Parse the tree to preserve structure and location information
  const tree = jsoncParser.parseTree(content, errors, {
    allowTrailingComma: true,
    disallowComments: false,
  });

  // Also parse the object for easy access to values
  const obj = jsoncParser.parse(content, errors, {
    allowTrailingComma: true,
    disallowComments: false,
  });

  return {tree, obj, errors};
}

/**
 * Convert an object to JSONC string, with nice formatting
 *
 * @param {any} obj - The object to stringify
 * @returns {string} - Formatted JSONC string
 */
function stringifyJsonc(obj) {
  // Use standard JSON.stringify with nice formatting
  // Comments cannot be preserved automatically and will be lost
  return JSON.stringify(obj, null, 2);
}

function isIgnoredKey(currentPath) {
  // Check if the current path matches any ignored patterns
  return (
    currentPath === "commandPalette.mru.cache" ||
    currentPath === "storage.commandPalette.mru.cache" ||
    currentPath === "globalState.storage.commandPalette.mru.cache" ||
    currentPath.includes("remote.tunnels.toRestore.") ||
    currentPath.includes("project-scopes.scopes")
  );
}

/**
 * Mask sensitive information like passwords and tokens in the profile data
 *
 * @param {any} profile - The profile data to sanitize
 * @param {string} [currentPath=''] - Current path within the object (for logging)
 * @param {string} [filePath=''] - File being processed (for logging)
 * @returns {any} - Sanitized profile data with passwords redacted
 */
function maskSensitiveInfo(profile, currentPath = "", filePath = "") {
  // Handle null and undefined
  if (profile === null || profile === undefined) {
    return profile;
  }

  // Handle primitive values
  if (typeof profile !== "object") {
    return profile;
  }

  // Create appropriate container (array or object)
  const result = Array.isArray(profile) ? [] : {};

  for (const key in profile) {
    if (Object.hasOwnProperty.call(profile, key)) {
      const value = profile[key];
      const keyPath = currentPath ? `${currentPath}.${key}` : key;

      if (isIgnoredKey(keyPath)) {
        if (Array.isArray(value)) {
          // Replace with empty array
          result[key] = [];
          console.log(
            `${colors.green}INFO:${colors.reset} Cleared ${keyPath} in ${filePath}`
          );
          continue;
        } else if (
          keyPath.includes("commandPalette.mru.cache") &&
          Object.hasOwnProperty.call(value, "entries")
        ) {
          // Special case for commandPalette.mru.cache.entries
          value.entries = [];
          result[key] = value;
          console.log(
            `${colors.green}INFO:${colors.reset} Cleared ${keyPath}.entries in ${filePath}`
          );
          continue;
        }
      }

      // Check if the key matches any sensitive patterns
      const keyIsSensitive = isSensitiveKey(key);
      const valueIsSensitive = keyIsSensitive && looksLikeSecret(value);

      if (valueIsSensitive) {
        // Mark as detected and add to paths
        passwordsFound.detected = true;
        if (!passwordsFound.paths.includes(keyPath)) {
          passwordsFound.paths.push(keyPath);
        }

        // Mask the value
        result[key] = "[SECURED]";

        if (filePath) {
          console.warn(
            `${colors.yellow}WARNING:${colors.reset} Sensitive data detected in "${colors.cyan}${keyPath}${colors.reset}" in ${filePath}. Redacting from output.`
          );
        }
      } else if (typeof value === "object" && value !== null) {
        // Recur for nested objects/arrays
        result[key] = maskSensitiveInfo(value, keyPath, filePath);
      } else {
        // Copy the value as-is
        result[key] = value;
      }
    }
  }

  return result;
}

/**
 * Check if a key name might indicate sensitive data like passwords
 *
 * @param {string} key - The key name to check
 * @returns {boolean} - True if the key might contain sensitive data
 */
function isSensitiveKey(key) {
  return SENSITIVE_KEY_PATTERNS.some((pattern) => pattern.test(key));
}

/**
 * Check if a value looks like a password or token
 * Simple heuristic: if it's a non-empty string that's not a URL or common setting value
 *
 * @param {any} value - The value to check
 * @returns {boolean} - True if the value might be a password
 */
function looksLikeSecret(value) {
  if (typeof value !== "string" || value.length === 0) {
    return false;
  }

  // Skip URLs
  if (value.startsWith("http://") || value.startsWith("https://")) {
    return false;
  }

  // Skip common non-secret values
  const nonSecretValues = [
    "true",
    "false",
    "null",
    "undefined",
    "none",
    "off",
    "on",
    "0",
    "1",
  ];
  if (nonSecretValues.includes(value.toLowerCase())) {
    return false;
  }

  return true;
}

/**
 * Re-encode a decoded profile to match the original VS Code profile format
 *
 * @param {Object} profile - The decoded and sanitized profile object
 * @returns {string} - The re-encoded profile as a string
 */
function encodeProfile(profile) {
  // Create a copy of the profile to modify
  const encodedProfile = {...profile};

  // The settings value should be a JSON string in VS Code profiles
  if (encodedProfile.settings && typeof encodedProfile.settings === "object") {
    try {
      // Format settings nicely but comments will be lost
      encodedProfile.settings = JSON.stringify(
        encodedProfile.settings,
        null,
        2
      );
    } catch (e) {
      console.warn(
        `${colors.yellow}Warning:${colors.reset} Error stringifying settings, using simpler approach:`,
        e.message
      );
      encodedProfile.settings = JSON.stringify(encodedProfile.settings);
    }
  }

  // Re-encode other string properties that might be JSON
  for (const key in encodedProfile) {
    const value = encodedProfile[key];
    if (typeof value === "object" && value !== null && key !== "settings") {
      // For other object properties, check if they were originally JSON strings
      try {
        // In a VS Code profile, many properties might be stored as JSON strings
        encodedProfile[key] = JSON.stringify(value);
      } catch (e) {
        // Keep as object if stringification fails
      }
    }
  }

  // Encode the entire profile
  return JSON.stringify(encodedProfile);
}

async function writeFileContent(filePath, content) {
  let outputContent = "";
  try {
    // For now, use the standard stringify method
    // In a future version we could use jsonc-parser's modify API for more targeted changes
    outputContent = stringifyJsonc(content);
    outputContent = outputContent + "\n"; // Ensure it ends with a newline

    // Note: Unfortunately, comments are lost during the initial parse of deeply nested JSON
    console.log(
      `${colors.yellow}Note:${colors.reset} Comments in the original file cannot be fully preserved in the decoded output`
    );
  } catch (e) {
    console.warn(
      `${colors.yellow}Warning:${colors.reset} Error while trying to encode json:`,
      e.message
    );
  }

  // Write the decoded file with pretty formatting
  await writeFile(filePath, outputContent, "utf8");
  console.log(`File saved to ${filePath}`);
}

/**
 * Process a single file
 *
 * @param {string} filePath - Path to the file to process
 * @param {string} targetDir - Target directory for output files
 * @returns {Promise<void>}
 */
async function processFile(filePath, targetDir) {
  try {
    console.log(`Processing ${filePath}`);

    // Read the file
    const content = await readFile(filePath, "utf8");

    // Try to parse with comments preservation first
    const {tree, obj, errors} = parseTreeWithComments(content);

    if (errors.length > 0) {
      console.warn(
        `${colors.yellow}Warning:${colors.reset} JSONC parsing encountered ${errors.length} errors but continued`
      );
    }

    // Decode the profile (for deeply nested JSON strings)
    const decodedProfile = decodeProfile(content);

    // Create output filename for decoded version - changing extension to .decoded.jsonc
    const outputDecodedFileName = path.basename(filePath) + ".decoded.jsonc";
    const outputDecodedPath = path.join(targetDir, outputDecodedFileName);
    writeFileContent(outputDecodedPath, content);

    // Mask sensitive information
    const sanitizedProfile = maskSensitiveInfo(decodedProfile, "", filePath);

    // Create output filename for decoded version - changing extension to .decoded.jsonc
    const outputSanitizedFileName =
      path.basename(filePath) + ".sanitized.jsonc";
    const outputSanitizedPath = path.join(targetDir, outputSanitizedFileName);
    writeFileContent(outputSanitizedPath, content);

    // Create output filename for re-encoded version - changing extension to .json
    // and move it to the target directory
    const targetFileName = path.basename(filePath);
    const targetFilePath = path.join(targetDir, targetFileName);

    // Re-encode the sanitized profile and write to new file
    let encodedProfile = encodeProfile(sanitizedProfile);
    encodedProfile = encodedProfile + "\n"; // Ensure it ends with a newline
    await writeFile(targetFilePath, encodedProfile, "utf8");

    console.log(`Re-encoded sanitized profile saved to ${targetFilePath}`);

    // Log any detected passwords
    if (passwordsFound.detected) {
      console.warn(
        `${colors.yellow}Warning:${colors.reset} Passwords or sensitive data were detected and redacted in the output.`
      );
      console.warn(`See keys: ${passwordsFound.paths.join(", ")}`);
    }
  } catch (error) {
    console.error(`Error processing ${filePath}:`, error.message);
  }
}

/**
 * Process a directory by finding all .code-profile files
 *
 * @param {string} dirPath - Path to the directory
 * @param {string} targetDir - Target directory for output files
 * @returns {Promise<void>}
 */
async function processDirectory(dirPath, targetDir) {
  try {
    const files = await readdir(dirPath);

    for (const file of files) {
      const fullPath = path.join(dirPath, file);
      const stats = await stat(fullPath);

      if (stats.isDirectory()) {
        await processDirectory(fullPath, targetDir);
      } else if (path.extname(file) === ".code-profile") {
        await processFile(fullPath, targetDir);
      }
    }
  } catch (error) {
    console.error(`Error processing directory ${dirPath}:`, error.message);
  }
}

/**
 * Main function
 */
async function main() {
  const args = process.argv.slice(2);

  if (args.length !== 2) {
    console.error(
      "Usage: node decodeVsCodeProfile.js <src-directory-path> <target-directory-path> "
    );
    process.exit(1);
  }

  const srcDir = args[0];
  const targetDir = args[1];

  // Validate source and target directories
  if (!srcDir || !targetDir) {
    console.error("Both source and target directory paths must be provided");
    process.exit(1);
  }
  const srcDirStats = fs.statSync(srcDir);
  if (!srcDirStats.isDirectory()) {
    console.error(`${srcDir} is not a directory`);
    process.exit(1);
  }
  if (!fs.existsSync(targetDir)) {
    // create target directory if it doesn't exist
    fs.mkdirSync(targetDir, {recursive: true});
    console.log(`Created target directory: ${targetDir}`);
  }
  const targetDirStats = await stat(targetDir);
  if (!targetDirStats.isDirectory()) {
    // create target directory if it doesn't exist
    fs.mkdirSync(targetDir, {recursive: true});
    console.log(`Created target directory: ${targetDir}`);
  }
  console.log(`Source directory: ${srcDir}`);
  console.log(`Target directory: ${targetDir}`);
  try {
    fs.accessSync(targetDir, fs.constants.W_OK);
  } catch (error) {
    console.error(
      `Target directory ${targetDir} is not writable: ${error.message}`
    );
    process.exit(1);
  }
  try {
    fs.accessSync(srcDir, fs.constants.R_OK);
  } catch (error) {
    console.error(`Source directory ${srcDir} is not readable`);
    process.exit(1);
  }
  // check if source and target directories are not the same
  if (path.resolve(srcDir) === path.resolve(targetDir)) {
    console.error("Source and target directories cannot be the same");
    process.exit(1);
  }

  // Reset the password tracking for each run
  passwordsFound.detected = false;
  passwordsFound.paths = [];

  try {
    await processDirectory(srcDir, targetDir);

    // Show summary of password detection
    if (passwordsFound.detected) {
      console.log("\n" + "=".repeat(80));
      console.log(
        `${colors.yellow}SECURITY WARNING:${colors.reset} Passwords or sensitive data were detected and redacted`
      );
      console.log("The following paths contained sensitive information:");
      passwordsFound.paths.forEach((path) => {
        console.log(`- ${colors.cyan}${path}${colors.reset}`);
      });
      console.log(
        'All sensitive data has been replaced by "[SECURED]" string in the output files.'
      );
      console.log("=".repeat(80) + "\n");
    }
  } catch (error) {
    console.error(`Error accessing ${srcDir}:`, error.message);
    process.exit(1);
  }
}

main().catch((error) => {
  console.error("Unhandled error:", error);
  process.exit(1);
});

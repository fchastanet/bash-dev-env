# VsCode profiles

Before exporting your profiles, make sure to open the file
`VsCodeConfig-profiles/src/.gitignore` in VSCode so when exporting the profiles,
the profiles will be proposed to be saved in the same directory as this
`.gitignore` file.

Export manually each of your VSCode profiles to a file named
`<yourProfileName>.json` in `VsCodeConfig-profiles/src` directory.

Launch sanitizer to remove any sensitive data from the profiles:

```bash
npm run convert-vscode-profiles
```

The files are:

- transformed to formatted and readable json and copied in
  `VsCodeConfig-profiles/decoded` directory
- sanitized to remove any sensitive data and copied in
  `VsCodeConfig-profiles/sanitized` directory
- re-encoded to a minified json and copied in `VsCodeConfig-profiles/profiles`
  directory that are the files that will be copied inside install script
  VsCodeConfig binary

# GitHub Pages Deployment Instructions

This document describes how to configure GitHub Pages for the bash-dev-env documentation site built with Hugo/Docsy.

## Prerequisites

The repository has been migrated from Docsify to Hugo/Docsy. The following files have been created:

- `content/` - Hugo content structure with markdown documentation
- `configs/site-config.yaml` - Site-specific Hugo configuration
- `assets/scss/_variables_project_override.scss` - Custom theme styles
- `.github/workflows/build-site.yml` - GitHub Actions workflow for building and deploying
- `go.mod` and `go.sum` - Hugo module dependencies

## GitHub Repository Settings

### 1. Configure GitHub Pages Source

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select **GitHub Actions**
4. Save the settings

This tells GitHub to use the GitHub Actions workflow (`.github/workflows/build-site.yml`) to build and deploy the site instead of using a branch.

### 2. Configure GitHub Actions Permissions

The workflow needs write permissions to deploy to GitHub Pages:

1. Go to **Settings** → **Actions** → **General**
2. Scroll down to **Workflow permissions**
3. Select **Read and write permissions**
4. Check the box: **Allow GitHub Actions to create and approve pull requests**
5. Click **Save**

## Triggering a Deployment

The documentation site will be automatically deployed when:

1. Changes are pushed to the `master` branch and affect these paths:
   - `content/**`
   - `static/**`
   - `hugo.yaml`
   - `go.mod`
   - `go.sum`

2. Or manually triggered via the **Actions** tab:
   - Go to **Actions** → **Build and Deploy Documentation**
   - Click **Run workflow**
   - Select the `master` branch
   - Click **Run workflow**

## Verifying Deployment

After the workflow completes:

1. Go to **Settings** → **Pages**
2. Check the deployment status
3. The site URL will be: `https://fchastanet.github.io/bash-dev-env/`

You can also check the deployment in the **Actions** tab to see the workflow execution logs.

## Local Development

To preview the documentation locally:

```bash
# Install Hugo Extended (if not already installed)
# See: https://gohugo.io/installation/

# Download Hugo modules
hugo mod get -u

# Start the development server
hugo server -D

# Navigate to http://localhost:1313/bash-dev-env/
```

To build the site for production:

```bash
hugo --minify
```

The generated site will be in the `public/` directory (which is git-ignored).

## Troubleshooting

### Build Fails with "shortcode not found"

This is expected when building locally with a minimal hugo.yaml. The GitHub Actions workflow uses a complete configuration that includes all required shortcodes from the my-documents theme.

### Changes Not Reflected on GitHub Pages

1. Check the **Actions** tab to see if the workflow ran successfully
2. Verify that changes were pushed to files in the trigger paths
3. Check that the workflow completed without errors
4. Wait a few minutes for GitHub Pages to update (can take 1-5 minutes)
5. Clear your browser cache and reload the page

### Workflow Fails with Permission Errors

Ensure that workflow permissions are set correctly (see step 2 above).

## Additional Resources

- [Hugo Documentation](https://gohugo.io/documentation/)
- [Docsy Theme Documentation](https://www.docsy.dev/docs/)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [GitHub Actions for Pages](https://github.com/actions/deploy-pages)

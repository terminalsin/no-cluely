# 🚀 Release Pipeline Setup Guide

This guide explains how to set up the automated release pipeline that publishes the No-Cluely Driver SDK to all major package managers.

## 📋 Overview

The GitHub Actions workflow automatically publishes to:
- **npm** (Node.js/TypeScript)
- **PyPI** (Python)
- **Maven Central** (Java)
- **crates.io** (Rust)
- **GitHub Releases** (Binaries)

## 🔐 Required Secrets

Add these secrets to your GitHub repository settings (`Settings` → `Secrets and variables` → `Actions`):

### 1. npm (Node.js/TypeScript)

**Secret Name:** `NPM_TOKEN`

**Setup:**
1. Create an npm account at https://www.npmjs.com
2. Generate an automation token:
   ```bash
   npm login
   npm token create --type=automation
   ```
3. Copy the token and add it as `NPM_TOKEN` secret

**Package:** `@no-cluely/detector`

### 2. PyPI (Python)

**Secret Name:** `PYPI_TOKEN`

**Setup:**
1. Create a PyPI account at https://pypi.org
2. Go to Account Settings → API Tokens
3. Generate a new token with "Entire account" scope
4. Copy the token (starts with `pypi-`) and add it as `PYPI_TOKEN` secret

**Package:** `no-cluely-detector`

### 3. Maven Central (Java)

**Required Secrets:**
- `MAVEN_USERNAME`
- `MAVEN_PASSWORD`
- `MAVEN_GPG_PRIVATE_KEY`
- `MAVEN_GPG_PASSPHRASE`

**Setup:**
1. **Create Sonatype OSSRH Account:**
   - Sign up at https://issues.sonatype.org
   - Create a JIRA ticket to claim your group ID (`com.nocluely`)
   - Follow the verification process

2. **Generate GPG Key:**
   ```bash
   # Generate key
   gpg --gen-key
   
   # Export private key
   gpg --armor --export-secret-keys YOUR_KEY_ID
   
   # Upload public key to keyserver
   gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
   ```

3. **Add Secrets:**
   - `MAVEN_USERNAME`: Your Sonatype JIRA username
   - `MAVEN_PASSWORD`: Your Sonatype JIRA password
   - `MAVEN_GPG_PRIVATE_KEY`: The exported private key (entire content)
   - `MAVEN_GPG_PASSPHRASE`: The passphrase for your GPG key

**Package:** `com.nocluely:cluely-detector`

### 4. crates.io (Rust)

**Secret Name:** `CARGO_TOKEN`

**Setup:**
1. Create a crates.io account at https://crates.io
2. Log in with GitHub
3. Go to Account Settings → API Tokens
4. Generate a new token and add it as `CARGO_TOKEN` secret

**Packages:** `no-cluely-driver` (library) + `cluely-detector` (CLI)

## 🏗️ Release Process

### Automatic Release (Recommended)

1. **Create a GitHub Release:**
   ```bash
   # Create and push a tag
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Create Release on GitHub:**
   - Go to your repository → Releases → Create a new release
   - Choose the tag you just pushed (`v1.0.0`)
   - Add release notes
   - Click "Publish release"

3. **Workflow automatically:**
   - Builds all components
   - Tests each package
   - Publishes to all package managers
   - Creates GitHub release with binaries

### Manual Release

You can also trigger releases manually:

1. Go to Actions → "🚀 Release & Publish Multi-Language SDK"
2. Click "Run workflow"
3. Enter the version number (e.g., `1.0.0`)
4. Optionally enable "Dry run" to test without publishing

## 📦 Package Manager Accounts Setup

### npm Organization (Optional but Recommended)

Create an npm organization for cleaner package names:
1. Go to https://www.npmjs.com/org/create
2. Create organization (e.g., `@no-cluely`)
3. Update `bindings/node/package.json` name to use scoped package

### PyPI Project Setup

1. Reserve your package name by uploading a placeholder:
   ```bash
   cd bindings/python
   python -m build
   twine upload dist/*
   ```

### Maven Central Group ID

1. Verify domain ownership for `com.nocluely` group ID
2. Follow Sonatype's domain verification process
3. Wait for approval (can take 1-2 business days)

## 🔧 Version Management

The workflow automatically updates version numbers in:
- `Cargo.toml` (Rust)
- `bindings/cli/Cargo.toml` (CLI)
- `bindings/node/package.json` (Node.js)
- `bindings/python/pyproject.toml` (Python)
- `bindings/java/pom.xml` (Java)

Version format: `MAJOR.MINOR.PATCH` (e.g., `1.0.0`)

## 🧪 Testing Before Release

### Local Testing

```bash
# Test all components
./build-all.sh

# Test specific component
./build-all.sh --only-node
./build-all.sh --only-python
```

### Dry Run

Use the manual workflow with "Dry run" enabled to test the entire pipeline without actually publishing.

## 🔍 Troubleshooting

### Common Issues

1. **npm publish fails:**
   - Check if package name is available
   - Verify NPM_TOKEN has correct permissions
   - Ensure you're not trying to republish the same version

2. **PyPI upload fails:**
   - Package name might be taken
   - Check if version already exists
   - Verify PYPI_TOKEN has upload permissions

3. **Maven Central deployment fails:**
   - GPG signing issues (check passphrase)
   - Group ID not approved yet
   - Missing required metadata (description, licenses, etc.)

4. **crates.io publish fails:**
   - Crate name might be taken
   - Check dependencies are published first
   - Verify CARGO_TOKEN permissions

### Debug Logs

Check the GitHub Actions logs for detailed error messages. Each step logs its progress and any errors.

## 📊 Release Monitoring

After a successful release, verify packages are available:

- **npm:** https://www.npmjs.com/package/@no-cluely/detector
- **PyPI:** https://pypi.org/project/no-cluely-detector/
- **Maven:** https://search.maven.org/artifact/com.nocluely/cluely-detector
- **crates.io:** https://crates.io/crates/no-cluely-driver

## 🔄 Update Workflow

To modify the release process:

1. Edit `.github/workflows/release.yml`
2. Test changes with dry runs
3. Update this documentation as needed

## 🎯 Next Steps

1. Set up all package manager accounts
2. Add all required secrets to GitHub
3. Test with a pre-release version (e.g., `1.0.0-beta.1`)
4. Create your first official release!

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review GitHub Actions logs
3. Consult package manager documentation
4. Open an issue in the repository 
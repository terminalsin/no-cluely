# Maven Central Publishing Setup

This document explains how to set up Maven Central publishing for the Java bindings of the No-Cluely Driver.

## 🔐 GPG Setup for Artifact Signing

Maven Central requires all artifacts to be cryptographically signed with GPG. Here's how to set this up:

### 1. Generate GPG Key (One-time setup)

```bash
# Generate a new GPG key
gpg --full-generate-key

# Select RSA (1)
# Use 4096 bits
# Set expiration (recommend 2 years)
# Provide real name and email

# List your keys
gpg --list-secret-keys --keyid-format LONG

# Export the private key (base64 encoded for GitHub secrets)
gpg --armor --export-secret-keys YOUR_KEY_ID | base64
```

### 2. Configure GitHub Secrets

Add these secrets to your GitHub repository:

| Secret Name             | Description                    | Example                  |
| ----------------------- | ------------------------------ | ------------------------ |
| `MAVEN_GPG_PRIVATE_KEY` | Base64-encoded GPG private key | `LS0tLS1CRUdJTi...`      |
| `MAVEN_GPG_PASSPHRASE`  | GPG key passphrase             | `your-secure-passphrase` |
| `MAVEN_USERNAME`        | Sonatype OSSRH username        | `your-ossrh-username`    |
| `MAVEN_PASSWORD`        | Sonatype OSSRH password        | `your-ossrh-password`    |

### 3. Upload Public Key to Key Servers

```bash
# Upload to key servers
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
gpg --keyserver keys.openpgp.org --send-keys YOUR_KEY_ID
```

## 🏢 Sonatype OSSRH Setup

1. **Create Account**: Sign up at [Sonatype OSSRH](https://s01.oss.sonatype.org/)
2. **Request Namespace**: Create a JIRA ticket to request the `io.github.terminalsin` namespace
3. **Verify Domain**: Prove ownership of the GitHub repository
4. **Get Credentials**: Use your OSSRH username/password for Maven deployment

## 🔧 CI/CD Behavior

The CI pipeline handles GPG gracefully:

### With GPG Configured ✅
- Artifacts are signed with GPG
- Published to Maven Central (OSSRH)
- Full release deployment

### Without GPG Configured ⚠️
- Artifacts are **not** signed
- Only built and installed locally
- Skips Maven Central publishing
- Useful for development/testing

## 🧪 Testing Locally

### Test with GPG (Production-like)
```bash
# Ensure GPG is set up locally
gpg --list-secret-keys

# Build and sign artifacts
cd bindings/java
mvn clean deploy -P release
```

### Test without GPG (Development)
```bash
# Build without signing
cd bindings/java
mvn clean install
```

## 📚 References

- [Sonatype OSSRH Guide](https://central.sonatype.org/publish/publish-guide/)
- [Maven GPG Plugin](https://maven.apache.org/plugins/maven-gpg-plugin/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## 🆘 Troubleshooting

### GPG Import Fails
- Ensure the key is properly base64-encoded
- Check that the key isn't expired
- Verify the passphrase is correct

### Maven Central Deployment Fails
- Verify OSSRH credentials
- Check that the `io.github.terminalsin` namespace is approved
- Ensure all required metadata is present in `pom.xml`

### Signatures Invalid
- Confirm the GPG key is uploaded to key servers
- Check that the key hasn't been revoked
- Verify the passphrase matches the key 
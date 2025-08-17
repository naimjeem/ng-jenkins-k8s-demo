# Jenkins Webhook Setup Guide

## Why Your Jenkins Pipeline Isn't Triggered

Your Jenkins pipeline isn't being triggered because:

1. **Branch Restriction**: Your Jenkinsfile only runs on `main` branch, but you're on `fix/lint-error`
2. **Missing Webhook Configuration**: GitHub isn't sending webhook events to Jenkins
3. **Webhook Endpoint Not Configured**: Jenkins doesn't have the GitHub webhook plugin properly configured

## Solution: Set Up GitHub Webhook Integration

### Step 1: Install Required Jenkins Plugins

In Jenkins, go to **Manage Jenkins** > **Manage Plugins** and install:

- **GitHub Integration Plugin**
- **GitHub Plugin** 
- **GitHub API Plugin**
- **Pipeline: GitHub Plugin**

### Step 2: Configure GitHub Webhook in Jenkins

1. **Create a Jenkins Job**:
   - Go to **New Item** > **Pipeline**
   - Name: `ng-jenkins-demo-pipeline`
   - Type: **Pipeline**

2. **Configure Pipeline**:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/naimjeem/ng-jenkins-k8s-demo.git`
   - **Credentials**: Add your GitHub credentials
   - **Branch Specifier**: `*/main` (or `*/master`)
   - **Script Path**: `Jenkinsfile`

3. **Configure Webhook Trigger**:
   - Check **GitHub hook trigger for GITScm polling**
   - This enables automatic triggering on webhook events

### Step 3: Configure GitHub Repository Webhook

1. **Go to GitHub Repository**:
   - Navigate to your repository settings
   - Go to **Settings** > **Webhooks**

2. **Add Webhook**:
   - **Payload URL**: `http://your-jenkins-url/github-webhook/`
   - **Content type**: `application/json`
   - **Secret**: Generate a secure secret (optional but recommended)
   - **Events**: Select **Just the push event**

3. **Test Webhook**:
   - Click **Test delivery** to verify the connection

### Step 4: Update Jenkinsfile for Better Branch Handling

Your current Jenkinsfile is too restrictive. Here's what to modify:

```groovy
// Change this line in your Jenkinsfile:
if (env.BRANCH_NAME != 'main' && env.BRANCH_NAME != 'master' && !env.BUILD_CAUSE_MANUALTRIGGER) {
    error "Pipeline only runs on main/master branch or manual trigger. Current branch: ${BRANCH_NAME}"
}

// To this (more flexible):
if (env.BRANCH_NAME != 'main' && env.BRANCH_NAME != 'master' && !env.BUILD_CAUSE_MANUALTRIGGER) {
    echo "Skipping pipeline for branch: ${BRANCH_NAME}"
    currentBuild.result = 'SUCCESS'
    return
}
```

### Step 5: Test the Setup

1. **Push to main branch**:
   ```bash
   git checkout main
   git merge fix/lint-error
   git push origin main
   ```

2. **Check Jenkins**:
   - Go to Jenkins dashboard
   - Look for the triggered build
   - Check build logs for any errors

### Alternative: Use GitHub Actions Instead

Since you already have a GitHub Actions workflow, you might want to use that instead:

1. **Delete the Jenkinsfile** if you prefer GitHub Actions
2. **Use the `.github/workflows/deploy.yml`** for CI/CD
3. **GitHub Actions will automatically trigger** on pushes to main

### Troubleshooting

#### Jenkins Not Receiving Webhooks
- Check Jenkins URL is accessible from GitHub
- Verify webhook endpoint: `/github-webhook/`
- Check Jenkins logs for webhook errors

#### Pipeline Still Not Triggering
- Ensure you're pushing to `main` branch
- Check Jenkins job configuration
- Verify SCM polling is enabled

#### Permission Issues
- Ensure Jenkins has access to your GitHub repository
- Check GitHub credentials in Jenkins
- Verify webhook secret matches (if configured)

## Quick Test

Run this command to test if your webhook is working:

```bash
# Test webhook delivery
curl -X POST http://your-jenkins-url/github-webhook/ \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -d '{"ref":"refs/heads/main","repository":{"name":"ng-jenkins-demo"}}'
```

## Next Steps

1. **Choose your CI/CD approach**: Jenkins or GitHub Actions
2. **Set up webhook integration** following the steps above
3. **Test with a push to main branch**
4. **Monitor pipeline execution** and fix any issues

Your pipeline should start triggering automatically once the webhook is properly configured!

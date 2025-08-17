# 🔧 Jenkins-GitHub Integration Troubleshooting Guide

## 🚨 **Why Your Jenkins Isn't Working with GitHub**

Your Jenkins pipeline isn't being triggered from GitHub because of **missing webhook configuration**. Here's what's happening:

1. **GitHub sends webhook events** when you push code
2. **Jenkins isn't listening** for these webhook events
3. **No automatic pipeline triggering** occurs
4. **Manual builds only** work

## 🎯 **Quick Fix: Set Up GitHub Webhook Integration**

### **Step 1: Install Required Jenkins Plugins**

1. **Go to Jenkins Dashboard**
2. **Manage Jenkins** → **Manage Plugins**
3. **Available** tab → Search and install:
   - ✅ **GitHub Integration Plugin**
   - ✅ **GitHub Plugin**
   - ✅ **GitHub API Plugin**
   - ✅ **Pipeline: GitHub Plugin**

### **Step 2: Create Jenkins Pipeline Job**

1. **New Item** → **Pipeline**
2. **Job Name**: `ng-jenkins-demo-pipeline`
3. **Configure Pipeline**:
   - **Definition**: `Pipeline script from SCM`
   - **SCM**: `Git`
   - **Repository URL**: `https://github.com/naimjeem/ng-jenkins-k8s-demo.git`
   - **Credentials**: Add your GitHub credentials
   - **Branch Specifier**: `*/main`
   - **Script Path**: `Jenkinsfile`

4. **🔑 IMPORTANT**: Check **GitHub hook trigger for GITScm polling**

### **Step 3: Configure GitHub Repository Webhook**

1. **Go to your GitHub repository**
2. **Settings** → **Webhooks**
3. **Add webhook**:
   - **Payload URL**: `http://your-jenkins-url/github-webhook/`
   - **Content type**: `application/json`
   - **Secret**: Generate a secure secret (optional)
   - **Events**: Select **Just the push event**
   - **Active**: ✅ Checked

### **Step 4: Test the Webhook**

1. **Click "Test delivery"** in GitHub webhook settings
2. **Check Jenkins** for triggered builds
3. **Verify webhook logs** in GitHub

## 🧪 **Test Your Setup**

### **Option A: Test with Current Code**
```bash
# Make a small change and push
echo "# Test webhook" >> README.md
git add README.md
git commit -m "Test Jenkins webhook integration"
git push origin main
```

### **Option B: Test Webhook Manually**
```bash
# Test webhook endpoint (replace with your Jenkins URL)
curl -X POST http://your-jenkins-url/github-webhook/ \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -d '{"ref":"refs/heads/main","repository":{"name":"ng-jenkins-demo"}}'
```

## 🔍 **Troubleshooting Common Issues**

### **Issue 1: Jenkins Not Receiving Webhooks**
**Symptoms**: No builds triggered, webhook delivery fails
**Solutions**:
- ✅ Check Jenkins URL is accessible from GitHub
- ✅ Verify webhook endpoint: `/github-webhook/`
- ✅ Check Jenkins logs for webhook errors
- ✅ Ensure Jenkins is running and accessible

### **Issue 2: Webhook Delivery Fails**
**Symptoms**: GitHub shows webhook delivery failed
**Solutions**:
- ✅ Check Jenkins URL in webhook configuration
- ✅ Verify Jenkins is accessible from internet (or use ngrok for local testing)
- ✅ Check webhook secret matches (if configured)
- ✅ Ensure Jenkins has proper permissions

### **Issue 3: Pipeline Job Not Found**
**Symptoms**: Webhook received but no job triggered
**Solutions**:
- ✅ Verify job name matches exactly
- ✅ Check "GitHub hook trigger for GITScm polling" is enabled
- ✅ Ensure SCM configuration is correct
- ✅ Check branch specifier matches your branch

### **Issue 4: Permission Denied**
**Symptoms**: Authentication errors in Jenkins logs
**Solutions**:
- ✅ Add GitHub credentials in Jenkins
- ✅ Use Personal Access Token (PAT) for GitHub
- ✅ Ensure Jenkins has access to repository
- ✅ Check repository permissions

## 🚀 **Alternative: Use GitHub Actions (Easier)**

If Jenkins continues to be problematic, consider using GitHub Actions:

1. **Delete Jenkinsfile** and Jenkins setup
2. **Use GitHub Actions** workflow (already created)
3. **Automatic triggering** on every push
4. **No webhook configuration needed**

## 📋 **Step-by-Step Verification Checklist**

- [ ] Jenkins plugins installed
- [ ] Pipeline job created with correct SCM settings
- [ ] GitHub webhook configured with correct URL
- [ ] Webhook trigger enabled in Jenkins job
- [ ] GitHub credentials added to Jenkins
- [ ] Repository permissions verified
- [ ] Webhook delivery tested successfully
- [ ] Pipeline job triggered automatically

## 🆘 **Still Not Working?**

### **Check Jenkins Logs**
1. **Manage Jenkins** → **System Log**
2. Look for webhook-related errors
3. Check for authentication issues

### **Check GitHub Webhook Logs**
1. **Repository Settings** → **Webhooks**
2. Click on your webhook
3. Check "Recent Deliveries" for errors

### **Verify Network Connectivity**
1. Ensure Jenkins is accessible from GitHub
2. Check firewall settings
3. Use ngrok for local Jenkins testing

## 🎉 **Success Indicators**

Your Jenkins-GitHub integration is working when:
- ✅ Webhook deliveries show "200 OK" status
- ✅ Jenkins automatically triggers builds on push
- ✅ Pipeline executes successfully
- ✅ Build logs show proper SCM checkout

## 📞 **Need More Help?**

1. **Check Jenkins system logs** for specific error messages
2. **Verify webhook delivery status** in GitHub
3. **Test with a simple push** to main branch
4. **Ensure all plugins are properly installed**

Your Jenkins should start working with GitHub once the webhook is properly configured! 🚀

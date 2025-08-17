# Jenkins Setup Guide for Automatic Pipeline Triggering

This guide will help you set up Jenkins to automatically trigger the pipeline when code is pushed to the main branch.

## 🚀 **Prerequisites**

- Jenkins running on `localhost:8000`
- GitHub repository with your Angular app
- Jenkins server accessible from GitHub (for webhooks)

## 📋 **Step 1: Install Required Jenkins Plugins**

1. **Go to Jenkins Dashboard** → **Manage Jenkins** → **Manage Plugins**
2. **Install the following plugins** (if not already installed):

### **Essential Plugins:**
- **Git** - For SCM integration
- **Pipeline** - For Jenkinsfile support
- **GitHub Integration** - For webhook support
- **GitHub API** - For GitHub API integration
- **GitHub Branch Source** - For branch source management
- **Docker Pipeline** - For Docker operations
- **Kubernetes CLI** - For kubectl commands
- **Test Results Aggregator** - For test results
- **Cobertura** - For code coverage
- **Timestamper** - For build timestamps
- **AnsiColor** - For colored console output

### **Optional but Recommended:**
- **Blue Ocean** - For better pipeline visualization
- **Build Timeout** - For build timeout management
- **Credentials Binding** - For secure credential management

## 🔧 **Step 2: Configure Jenkins Global Settings**

### **2.1 Configure Git:**
1. **Manage Jenkins** → **Configure System**
2. **Git installations** → Add Git installation
3. **Set Git executable path** (usually `/usr/bin/git` on Linux, `C:\Program Files\Git\bin\git.exe` on Windows)

### **2.2 Configure GitHub:**
1. **Manage Jenkins** → **Configure System**
2. **GitHub** section → **Add GitHub Server**
3. **API URL**: `https://api.github.com`
4. **Credentials**: Add GitHub personal access token
5. **Test connection** to verify

### **2.3 Configure Docker:**
1. **Manage Jenkins** → **Configure System**
2. **Docker Builder** section → **Add Docker Builder**
3. **Docker Host URI**: `tcp://localhost:2375` (or your Docker host)
4. **Test connection** to verify

### **2.4 Configure kubectl:**
1. **Manage Jenkins** → **Configure System**
2. **Kubernetes CLI** section → **Add kubectl installation**
3. **Set kubectl executable path**

## 🎯 **Step 3: Create Jenkins Pipeline Job**

### **3.1 Create New Job:**
1. **Dashboard** → **New Item**
2. **Enter item name**: `ng-jenkins-demo-pipeline`
3. **Select**: `Pipeline`
4. **Click OK**

### **3.2 Configure Pipeline:**
1. **General Section:**
   - ✅ **Discard old builds** (Keep 10 builds)
   - ✅ **This project is parameterized**
   - ✅ **GitHub project** (enter your repo URL)

2. **Build Triggers Section:**
   - ✅ **GitHub hook trigger for GITScm polling**
   - ✅ **Poll SCM** (optional, as backup)
   - **Schedule**: `H/5 * * * *` (poll every 5 minutes)

3. **Pipeline Section:**
   - **Definition**: `Pipeline script from SCM`
   - **SCM**: `Git`
   - **Repository URL**: Your GitHub repo URL
   - **Credentials**: Add your GitHub credentials
   - **Branch Specifier**: `*/main` (or `*/master`)
   - **Script Path**: `Jenkinsfile`

4. **Advanced Project Options:**
   - **Quiet period**: `0` (immediate trigger)
   - **SCM checkout retry count**: `3`

## 🔗 **Step 4: Configure GitHub Webhook**

### **4.1 In GitHub Repository:**
1. **Go to your repository** → **Settings** → **Webhooks**
2. **Add webhook**
3. **Payload URL**: `http://your-jenkins-url/github-webhook/`
   - Replace `your-jenkins-url` with your actual Jenkins URL
   - Example: `http://localhost:8000/github-webhook/`
4. **Content type**: `application/json`
5. **Secret**: Leave empty (or add a secret for security)
6. **Events**: Select **Just the push event**
7. **Active**: ✅ Checked
8. **Click Add webhook**

### **4.2 Test Webhook:**
1. **Make a small change** to your main branch
2. **Push to GitHub**
3. **Check Jenkins** - pipeline should start automatically
4. **Check webhook delivery** in GitHub webhook settings

## 🐳 **Step 5: Configure Docker and Kubernetes Access**

### **5.1 Docker Access:**
Ensure Jenkins can access Docker:
```bash
# Add jenkins user to docker group (Linux)
sudo usermod -aG docker jenkins

# Or configure Docker socket permissions
sudo chmod 666 /var/run/docker.sock
```

### **5.2 Kubernetes Access:**
Ensure Jenkins can access kubectl:
```bash
# Copy kubeconfig to Jenkins home
sudo cp ~/.kube/config /var/lib/jenkins/.kube/
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/config

# Or use service account tokens
kubectl create serviceaccount jenkins -n default
kubectl create clusterrolebinding jenkins --clusterrole=cluster-admin --serviceaccount=default:jenkins
```

## 🔍 **Step 6: Test the Pipeline**

### **6.1 Manual Test:**
1. **In Jenkins**, go to your pipeline job
2. **Click Build Now**
3. **Monitor the build** in real-time
4. **Check console output** for any errors

### **6.2 Automatic Test:**
1. **Make a change** to your code
2. **Commit and push** to main branch
3. **Watch Jenkins** automatically start the pipeline
4. **Verify deployment** in Minikube

## 📊 **Step 7: Monitor and Troubleshoot**

### **7.1 Build History:**
- **View build history** in Jenkins dashboard
- **Check build descriptions** for status badges
- **Review console logs** for detailed output

### **7.2 Common Issues:**

#### **Webhook Not Triggering:**
- Check webhook URL is correct
- Verify Jenkins is accessible from GitHub
- Check webhook delivery status in GitHub
- Ensure branch name matches (main vs master)

#### **Pipeline Failing:**
- Check console logs for specific errors
- Verify Docker and kubectl access
- Check Minikube status
- Verify image names and tags

#### **Permission Issues:**
- Ensure Jenkins user has proper permissions
- Check Docker and Kubernetes access
- Verify file paths and permissions

## 🎯 **Step 8: Advanced Configuration**

### **8.1 Branch Protection:**
1. **In GitHub**: Protect main branch
2. **Require status checks** to pass
3. **Require branches to be up to date**

### **8.2 Pipeline Parameters:**
Add build parameters for flexibility:
- Environment selection (dev/staging/prod)
- Docker image tags
- Kubernetes namespaces

### **8.3 Notifications:**
Configure notifications for:
- Slack
- Email
- Teams
- Discord

## ✅ **Verification Checklist**

- [ ] Jenkins plugins installed
- [ ] Git configured
- [ ] GitHub integration working
- [ ] Docker access configured
- [ ] kubectl access configured
- [ ] Pipeline job created
- [ ] GitHub webhook configured
- [ ] Manual build successful
- [ ] Automatic trigger working
- [ ] Deployment successful
- [ ] Health checks passing

## 🚀 **Next Steps**

Once your pipeline is working automatically:

1. **Set up branch protection** in GitHub
2. **Configure notifications** for build status
3. **Add more environments** (staging, production)
4. **Implement rollback strategies**
5. **Add monitoring and alerting**
6. **Set up backup and disaster recovery**

## 📚 **Additional Resources**

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [GitHub Webhooks Guide](https://docs.github.com/en/developers/webhooks-and-events/webhooks)
- [Kubernetes Jenkins Plugin](https://plugins.jenkins.io/kubernetes-cli/)
- [Docker Jenkins Plugin](https://plugins.jenkins.io/docker-workflow/)

---

**🎉 Congratulations!** Your Jenkins pipeline is now set up to automatically trigger on every push to the main branch, providing true CI/CD automation for your Angular application deployment to Minikube.

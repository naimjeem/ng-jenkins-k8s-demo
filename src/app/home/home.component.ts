import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="container">
      <div class="hero-section">
        <h1>🚀 Welcome to Angular Jenkins Demo</h1>
        <p class="hero-subtitle">A complete CI/CD pipeline demonstration with Kubernetes deployment</p>
        <div class="hero-buttons">
          <button class="btn btn-primary" (click)="showInfo()">Learn More</button>
          <button class="btn btn-secondary" (click)="checkHealth()">Health Check</button>
        </div>
      </div>

      <div class="features-grid">
        <div class="feature-card">
          <div class="feature-icon">⚡</div>
          <h3>Angular 17</h3>
          <p>Built with the latest Angular framework featuring standalone components and modern tooling.</p>
        </div>
        
        <div class="feature-card">
          <div class="feature-icon">🐳</div>
          <h3>Docker</h3>
          <p>Multi-stage containerization for optimized production builds and deployment.</p>
        </div>
        
        <div class="feature-card">
          <div class="feature-icon">☸️</div>
          <h3>Kubernetes</h3>
          <p>Deployed on Minikube with health checks, scaling, and ingress configuration.</p>
        </div>
        
        <div class="feature-card">
          <div class="feature-icon">🔧</div>
          <h3>Jenkins Pipeline</h3>
          <p>Automated CI/CD pipeline with testing, building, and deployment stages.</p>
        </div>
      </div>

      <div class="status-section">
        <h2>Deployment Status</h2>
        <div class="status-grid">
          <div class="status-item">
            <span class="status-label">Environment:</span>
            <span class="status-value">{{ environment }}</span>
          </div>
          <div class="status-item">
            <span class="status-label">Version:</span>
            <span class="status-value">{{ version }}</span>
          </div>
          <div class="status-item">
            <span class="status-label">Build:</span>
            <span class="status-value">{{ buildNumber }}</span>
          </div>
          <div class="status-item">
            <span class="status-label">Status:</span>
            <span class="status-value status-healthy">Healthy</span>
          </div>
        </div>
      </div>

      <div class="pipeline-info">
        <h2>CI/CD Pipeline Stages</h2>
        <div class="pipeline-stages">
          <div class="stage" *ngFor="let stage of pipelineStages; let i = index">
            <div class="stage-number">{{ i + 1 }}</div>
            <div class="stage-content">
              <h4>{{ stage.name }}</h4>
              <p>{{ stage.description }}</p>
            </div>
          </div>
        </div>
      </div>

      <div class="quick-actions">
        <h2>Quick Actions</h2>
        <div class="action-buttons">
          <button class="btn btn-success" (click)="triggerBuild()">Trigger Build</button>
          <button class="btn btn-warning" (click)="viewLogs()">View Logs</button>
          <button class="btn btn-secondary" (click)="openDashboard()">K8s Dashboard</button>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .hero-section {
      text-align: center;
      padding: 3rem 0;
      margin-bottom: 3rem;
    }

    .hero-section h1 {
      font-size: 3rem;
      margin-bottom: 1rem;
      background: linear-gradient(135deg, #667eea, #764ba2);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }

    .hero-subtitle {
      font-size: 1.2rem;
      color: var(--light-text);
      margin-bottom: 2rem;
    }

    .hero-buttons {
      display: flex;
      gap: 1rem;
      justify-content: center;
      flex-wrap: wrap;
    }

    .features-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 2rem;
      margin-bottom: 3rem;
    }

    .feature-card {
      background: var(--card-background);
      padding: 2rem;
      border-radius: var(--border-radius);
      box-shadow: var(--shadow);
      text-align: center;
      transition: transform 0.3s ease;
    }

    .feature-card:hover {
      transform: translateY(-5px);
    }

    .feature-icon {
      font-size: 3rem;
      margin-bottom: 1rem;
    }

    .feature-card h3 {
      margin-bottom: 1rem;
      color: var(--primary-color);
    }

    .status-section {
      background: var(--card-background);
      padding: 2rem;
      border-radius: var(--border-radius);
      box-shadow: var(--shadow);
      margin-bottom: 3rem;
    }

    .status-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 1rem;
      margin-top: 1rem;
    }

    .status-item {
      display: flex;
      justify-content: space-between;
      padding: 0.5rem 0;
      border-bottom: 1px solid #eee;
    }

    .status-value.status-healthy {
      color: var(--success-color);
      font-weight: bold;
    }

    .pipeline-info {
      background: var(--card-background);
      padding: 2rem;
      border-radius: var(--border-radius);
      box-shadow: var(--shadow);
      margin-bottom: 3rem;
    }

    .pipeline-stages {
      display: grid;
      gap: 1rem;
      margin-top: 1rem;
    }

    .stage {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: 1rem;
      background: #f8f9fa;
      border-radius: var(--border-radius);
    }

    .stage-number {
      background: var(--primary-color);
      color: white;
      width: 2rem;
      height: 2rem;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: bold;
    }

    .quick-actions {
      background: var(--card-background);
      padding: 2rem;
      border-radius: var(--border-radius);
      box-shadow: var(--shadow);
      text-align: center;
    }

    .action-buttons {
      display: flex;
      gap: 1rem;
      justify-content: center;
      flex-wrap: wrap;
      margin-top: 1rem;
    }

    @media (max-width: 768px) {
      .hero-section h1 {
        font-size: 2rem;
      }
      
      .hero-buttons {
        flex-direction: column;
        align-items: center;
      }
      
      .features-grid {
        grid-template-columns: 1fr;
      }
      
      .status-grid {
        grid-template-columns: 1fr;
      }
      
      .action-buttons {
        flex-direction: column;
        align-items: center;
      }
    }
  `]
})
export class HomeComponent {
  environment = 'Production';
  version = '1.0.0';
  buildNumber = 'BUILD_' + Date.now();

  pipelineStages = [
    { name: 'Checkout', description: 'Clone source code from repository' },
    { name: 'Install Dependencies', description: 'Install Node.js dependencies' },
    { name: 'Lint', description: 'Run code quality checks' },
    { name: 'Test', description: 'Execute unit tests with coverage' },
    { name: 'Build', description: 'Create production build' },
    { name: 'Docker Build', description: 'Build and tag container image' },
    { name: 'Deploy to Minikube', description: 'Update Kubernetes deployment' },
    { name: 'Health Check', description: 'Verify deployment success' }
  ];

  showInfo() {
    alert('This is a demo Angular application showcasing CI/CD with Jenkins and Kubernetes deployment on Minikube!');
  }

  checkHealth() {
    // In a real app, this would make an HTTP request to /health endpoint
    alert('Health check endpoint: /health\nStatus: Healthy ✅');
  }

  triggerBuild() {
    alert('Build triggered! Check Jenkins pipeline for progress.');
  }

  viewLogs() {
    alert('View logs with: kubectl logs -n ng-jenkins-demo -l app=ng-jenkins-demo');
  }

  openDashboard() {
    alert('Open Kubernetes dashboard with: minikube dashboard');
  }
}

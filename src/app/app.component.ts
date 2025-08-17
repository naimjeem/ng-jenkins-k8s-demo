import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  template: `
    <div class="app-container">
      <header class="app-header">
        <h1>🚀 Angular Jenkins Demo</h1>
        <p>CI/CD Pipeline with Minikube Deployment</p>
      </header>
      
      <main class="app-main">
        <router-outlet></router-outlet>
      </main>
      
      <footer class="app-footer">
        <p>Built with Angular 17 | Deployed via Jenkins | Running on Minikube</p>
        <p>Version: {{ version }} | Build: {{ buildNumber }}</p>
      </footer>
    </div>
  `,
  styles: [`
    .app-container {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    
    .app-header {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      text-align: center;
      padding: 2rem;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    
    .app-header h1 {
      margin: 0 0 0.5rem 0;
      font-size: 2.5rem;
      font-weight: 300;
    }
    
    .app-header p {
      margin: 0;
      font-size: 1.1rem;
      opacity: 0.9;
    }
    
    .app-main {
      flex: 1;
      padding: 2rem;
    }
    
    .app-footer {
      background: #f8f9fa;
      text-align: center;
      padding: 1rem;
      border-top: 1px solid #e9ecef;
      color: #6c757d;
    }
    
    .app-footer p {
      margin: 0.25rem 0;
      font-size: 0.9rem;
    }
  `]
})
export class AppComponent {
  version = '1.0.0';
  buildNumber = 'BUILD_' + Date.now();
}

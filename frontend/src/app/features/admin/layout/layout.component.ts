import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';

@Component({
  selector: 'app-admin-layout',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <div class="admin-wrapper">
      <!-- Sidebar -->
      <aside class="sidebar">
        <div class="brand">
          <div class="logo-icon">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path></svg>
          </div>
          <div class="brand-text">
            <h3>PolicySquare</h3>
            <span>Admin Portal</span>
          </div>
        </div>
        
        <nav>
          <a routerLink="/commercial/admin/rfq" routerLinkActive="active">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
            RFQ Management
          </a>
          <a routerLink="/commercial/admin/claims" routerLinkActive="active">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
            Footprints of Claims
          </a>
          <a routerLink="/commercial/admin/underwriting" routerLinkActive="active">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"></path></svg>
            Underwriting Tips
          </a>
        </nav>

        <div class="sidebar-footer">
          <button class="logout-btn" (click)="logout()">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
            Logout session
          </button>
        </div>
      </aside>

      <!-- Main Content -->
      <main class="content">
        <header class="top-nav glass-panel">
          <div class="user-badge">
            <div class="avatar">A</div>
            <div class="user-info">
              <span class="name">Administrator</span>
              <span class="role">System Access</span>
            </div>
          </div>
        </header>
        <div class="page-container">
          <router-outlet></router-outlet>
        </div>
      </main>
    </div>
  `,
  styles: [`
    .admin-wrapper { 
      display: flex; 
      height: 100vh; 
      background: var(--bg-primary);
    }
    
    /* Sidebar */
    .sidebar {
      width: 280px; 
      background: #0f172a; 
      color: white; 
      display: flex; 
      flex-direction: column;
      box-shadow: var(--shadow-lg);
      z-index: 10;
    }
    
    .brand { 
      padding: 1.5rem; 
      display: flex;
      align-items: center;
      gap: 1rem;
      border-bottom: 1px solid rgba(255,255,255,0.05); 
    }
    
    .logo-icon {
      width: 40px;
      height: 40px;
      background: linear-gradient(135deg, var(--brand-primary), var(--accent-purple));
      border-radius: var(--radius-md);
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 4px 10px rgba(37, 99, 235, 0.4);
    }
    
    .logo-icon svg { width: 24px; height: 24px; color: white; }
    
    .brand-text h3 { 
      margin: 0; 
      font-size: 1.25rem;
      font-weight: 600;
      letter-spacing: -0.025em;
    }
    
    .brand-text span { 
      font-size: 0.75rem; 
      color: #94a3b8; 
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    
    nav { 
      flex: 1; 
      padding: 1.5rem 1rem; 
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }
    
    nav a {
      display: flex; 
      align-items: center;
      gap: 0.75rem;
      padding: 0.875rem 1rem; 
      color: #cbd5e1; 
      text-decoration: none;
      border-radius: var(--radius-md);
      transition: all var(--transition-fast);
      font-weight: 500;
      font-size: 0.95rem;
    }
    
    nav a svg { width: 20px; height: 20px; opacity: 0.7; transition: all var(--transition-fast); }
    
    nav a:hover { 
      background: rgba(255,255,255,0.05); 
      color: white; 
      transform: translateX(4px);
    }
    
    nav a:hover svg { opacity: 1; transform: scale(1.1); }
    
    nav a.active { 
      background: rgba(37, 99, 235, 0.15); 
      color: var(--brand-primary-light); 
      border-left: 3px solid var(--brand-primary);
    }
    
    nav a.active svg { opacity: 1; color: var(--brand-primary); }
    
    .sidebar-footer {
      padding: 1.5rem;
      border-top: 1px solid rgba(255,255,255,0.05);
    }
    
    .logout-btn {
      width: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
      padding: 0.875rem;
      background: transparent;
      color: #f87171;
      border: 1px solid rgba(248, 113, 113, 0.2);
      border-radius: var(--radius-md);
      font-family: inherit;
      font-weight: 500;
      cursor: pointer;
      transition: all var(--transition-fast);
    }
    
    .logout-btn svg { width: 18px; height: 18px; }
    
    .logout-btn:hover { 
      background: rgba(239, 68, 68, 0.1); 
      color: #ef4444; 
    }

    /* Main Content */
    .content { 
      flex: 1; 
      display: flex; 
      flex-direction: column; 
      overflow: hidden; 
      position: relative;
    }
    
    .top-nav {
      position: absolute;
      top: 1rem;
      right: 1.5rem;
      left: 1.5rem;
      height: 64px;
      display: flex;
      justify-content: flex-end;
      align-items: center;
      padding: 0 1.5rem;
      z-index: 5;
    }
    
    .user-badge {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      cursor: pointer;
    }
    
    .avatar {
      width: 36px;
      height: 36px;
      border-radius: 50%;
      background: var(--brand-primary);
      color: white;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 600;
      font-size: 1rem;
      box-shadow: 0 2px 4px rgba(37, 99, 235, 0.3);
    }
    
    .user-info {
      display: flex;
      flex-direction: column;
    }
    
    .user-info .name {
      font-weight: 600;
      font-size: 0.875rem;
      color: var(--text-primary);
    }
    
    .user-info .role {
      font-size: 0.75rem;
      color: var(--text-tertiary);
    }
    
    .page-container { 
      flex: 1; 
      padding: 6rem 2rem 2rem 2rem; 
      overflow-y: auto; 
    }
  `]
})
export class AdminLayoutComponent {
  constructor(private router: Router) { }

  logout() {
    localStorage.removeItem('isAdminLoggedIn');
    this.router.navigate(['/commercial/admin/login']);
  }
}

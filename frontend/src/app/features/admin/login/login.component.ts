import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';

@Component({
    selector: 'app-admin-login',
    standalone: true,
    imports: [CommonModule, FormsModule],
    template: `
    <div class="login-container">
      <div class="login-card">
        <h2>Admin Portal</h2>
        <p>Restricted Access</p>
        
        <div class="form-group">
          <label>Username</label>
          <input type="text" [(ngModel)]="username" class="form-control" placeholder="admin">
        </div>
        <div class="form-group">
          <label>Password</label>
          <input type="password" [(ngModel)]="password" class="form-control" placeholder="password">
        </div>

        <div class="error" *ngIf="error">{{ error }}</div>

        <button (click)="login()" class="login-btn">Login</button>
      </div>
    </div>
  `,
    styles: [`
    .login-container {
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      background: #2c3e50;
      font-family: 'Segoe UI', sans-serif;
    }
    .login-card {
      background: white;
      padding: 40px;
      border-radius: 8px;
      width: 100%;
      max-width: 350px;
      text-align: center;
    }
    h2 { color: #2c3e50; margin-bottom: 5px; }
    p { color: #7f8c8d; margin-bottom: 30px; }
    .form-group { text-align: left; margin-bottom: 20px; }
    label { display: block; margin-bottom: 5px; font-weight: 500; }
    .form-control {
      width: 100%; padding: 10px;
      border: 1px solid #bdc3c7;
      border-radius: 4px;
    }
    .login-btn {
      width: 100%; background: #e74c3c; color: white;
      padding: 12px; border: none; border-radius: 4px;
      font-size: 1rem; cursor: pointer;
    }
    .login-btn:hover { background: #c0392b; }
    .error { color: red; margin-bottom: 15px; font-size: 0.9rem; }
  `]
})
export class AdminLoginComponent {
    username = '';
    password = '';
    error = '';

    constructor(private router: Router) { }

    login() {
        // Simple hardcoded check for demonstration
        if (this.username === 'admin' && this.password === 'admin123') {
            localStorage.setItem('isAdminLoggedIn', 'true');
            this.router.navigate(['/commercial/admin/rfq']);
        } else {
            this.error = 'Invalid credentials';
        }
    }
}

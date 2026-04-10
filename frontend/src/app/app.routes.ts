import { Routes } from '@angular/router';
import { AuthGuard } from './core/guards/auth.guard';

export const routes: Routes = [
    { path: '', redirectTo: 'commercial/admin/login', pathMatch: 'full' },

    // --- Admin Authentication ---
    {
        path: 'commercial/admin/login',
        loadComponent: () => import('./features/admin/login/login.component').then(m => m.AdminLoginComponent)
    },

    // --- Admin Dashboard & Features ---
    {
        path: 'commercial/admin',
        loadComponent: () => import('./features/admin/layout/layout.component').then(m => m.AdminLayoutComponent),
        canActivate: [() => import('./core/guards/admin.guard').then(m => m.AdminGuard)],
        children: [
            { path: '', redirectTo: 'rfq', pathMatch: 'full' },
            {
                path: 'rfq',
                loadComponent: () => import('./features/admin/dashboard/dashboard.component').then(m => m.AdminDashboardComponent)
            },
            {
                path: 'claims',
                loadComponent: () => import('./features/admin/claims-story/claims-story.component').then(m => m.AdminClaimStoryComponent)
            },
            {
                path: 'underwriting',
                loadComponent: () => import('./features/admin/underwriting-tip/underwriting-tip.component').then(m => m.AdminUnderwritingTipComponent)
            }
        ]
    },

    // Catch-all route to prevent 404s from leaking into dead client pages
    { path: '**', redirectTo: 'commercial/admin/login' }
];

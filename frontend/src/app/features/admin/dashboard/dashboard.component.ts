import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RfqService, Rfq } from '../../../core/services/commercial/rfq.service';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="admin-container">
      <div class="top-bar">
        <div class="header-group">
          <h2>RFQ Management</h2>
          <p class="subtitle">Review and respond to client Request for Quotes</p>
        </div>
        <button (click)="refresh()" class="btn-secondary">
          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" width="18" height="18"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path></svg>
          Refresh Data
        </button>
      </div>
      
      <div class="rfq-list">
        <!-- Header Row -->
        <div class="list-header">
          <span class="col-id">Reference ID</span>
          <span class="col-company">Company Name</span>
          <span class="col-product">Product</span>
          <span class="col-mobile">Contact</span>
          <span class="col-status">Status</span>
          <span class="col-action"></span>
        </div>

        <div class="premium-card rfq-item" *ngFor="let rfq of rfqs; let i = index" [style.animation-delay]="i * 0.05 + 's'">
            <div class="row-content" (click)="toggle(rfq)">
                <span class="col-id">#{{ rfq.id?.substring(0,8) }}</span>
                <span class="col-company">{{ rfq.companyName }}</span>
                <span class="col-product">{{ rfq.product }}</span>
                <span class="col-mobile">{{ rfq.mobileNumber }}</span>
                <span class="col-status">
                  <span class="status-badge" [ngClass]="rfq.status === 'PENDING' ? 'badge-warning' : 'badge-success'">
                    {{ rfq.status }}
                  </span>
                </span>
                <span class="col-action">
                  <svg class="chevron" [class.rotated]="rfq === expandedRfq" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                </span>
            </div>
            
            <div class="details-panel" *ngIf="rfq === expandedRfq">
                <div class="info-grid">
                    <div class="meta-card">
                        <div class="meta-item">
                          <span class="label">Primary Contact</span>
                          <span class="value">{{ rfq.mobileNumber }}</span>
                        </div>
                        <div class="meta-item">
                          <span class="label">Date Submitted</span>
                          <span class="value">{{ rfq.createdAt | date:'medium' }}</span>
                        </div>
                    </div>
                    
                    <div class="data-card">
                        <h4 class="card-title">Request Specifications</h4>
                        <div class="data-grid p-4">
                            <!-- Recursive Template to handle nested Objects & Arrays -->
                            <ng-template #recursiveList let-list>
                                <div *ngFor="let item of list | keyvalue" class="mb-2">
                                    <div *ngIf="isObject(item.value) || isArray(item.value); else valueNode">
                                        <div class="font-semibold text-[var(--primary)] text-sm mb-1 mt-3 pb-1 border-b border-gray-100">
                                            {{ formatKey($any(item.key).toString()) }}
                                        </div>
                                        <div class="pl-4 border-l border-gray-200">
                                            <ng-container *ngTemplateOutlet="recursiveList; context:{ $implicit: item.value }"></ng-container>
                                        </div>
                                    </div>
                                    <ng-template #valueNode>
                                        <!-- Only render if value is not empty or false -->
                                        <div *ngIf="item.value !== '' && item.value !== false" class="flex justify-between py-1 border-b border-gray-50 last:border-0">
                                            <span class="text-sm text-gray-500 font-medium w-1/2 pr-4 break-words">{{ formatKey($any(item.key).toString()) }}</span>
                                            <span class="text-sm text-[var(--text-primary)] w-1/2 text-right break-words font-semibold">
                                                <ng-container *ngIf="item.value === true; else textVal">
                                                    <svg class="w-4 h-4 text-green-500 inline-block" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                                                </ng-container>
                                                <ng-template #textVal>{{ item.value }}</ng-template>
                                            </span>
                                        </div>
                                    </ng-template>
                                </div>
                            </ng-template>
                            
                            <!-- Root call -->
                            <ng-container *ngTemplateOutlet="recursiveList; context:{ $implicit: getFormattedData(rfq.rfqData) }"></ng-container>
                        </div>
                    </div>
                </div>

                <div class="quote-action glass-panel">
                    <h3 class="action-title">Issue Official Quote</h3>
                    
                    <div class="form-group">
                      <label>Details & Coverage Terms</label>
                      <textarea class="premium-input" [(ngModel)]="quoteInput" rows="4" placeholder="Enter quote details, premium amount, coverage conditions, or attach a link..."></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label>Upload Official Document (PDF/Image)</label>
                        <div class="file-drop-zone">
                          <input type="file" class="premium-input file-input" (change)="onFileSelected($event)" />
                        </div>
                    </div>

                    <div class="action-footer">
                        <button class="btn-primary" (click)="submitQuote(rfq)">
                          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" width="18" height="18"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                          Send Quote & Update Status
                        </button>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="empty-state" *ngIf="rfqs.length === 0">
          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path></svg>
          <p>No RFQs found in the system.</p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .admin-container {
      max-width: 1400px; 
      margin: 0 auto; 
      animation: fadeIn var(--transition-slow);
    }
    
    .top-bar { 
      display: flex; 
      justify-content: space-between; 
      align-items: flex-end; 
      margin-bottom: 2rem; 
    }
    
    h2 { 
      color: var(--text-primary); 
      margin: 0 0 0.25rem 0; 
      font-size: 1.5rem;
      font-weight: 700;
      letter-spacing: -0.025em;
    }
    
    .subtitle { 
      color: var(--text-secondary); 
      margin: 0; 
      font-size: 0.875rem; 
    }
    
    /* List Layout */
    .rfq-list {
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
    }
    
    .list-header {
      display: flex;
      padding: 0 1.5rem 0.5rem 1.5rem;
      font-size: 0.75rem;
      font-weight: 600;
      color: var(--text-tertiary);
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    
    .rfq-item { 
      margin-bottom: 0; 
      overflow: hidden; 
      opacity: 0;
      animation: slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards;
    }
    
    .row-content { 
      padding: 1rem 1.5rem; 
      display: flex; 
      align-items: center; 
      cursor: pointer; 
    }
    
    /* Column Sizing */
    .col-id { width: 100px; flex-shrink: 0; font-family: monospace; color: var(--text-tertiary); }
    .col-company { flex: 2; font-weight: 600; color: var(--text-primary); }
    .col-product { flex: 1.5; color: var(--text-secondary); }
    .col-mobile { flex: 1; color: var(--text-secondary); font-size: 0.875rem; }
    .col-status { width: 120px; flex-shrink: 0; }
    .col-action { width: 40px; flex-shrink: 0; display: flex; justify-content: flex-end; color: var(--text-tertiary); }
    
    .chevron { width: 20px; height: 20px; transition: transform var(--transition-base); }
    .chevron.rotated { transform: rotate(180deg); color: var(--brand-primary); }
    
    /* Badges */
    .status-badge {
      display: inline-flex;
      align-items: center;
      padding: 0.25rem 0.625rem;
      border-radius: var(--radius-pill);
      font-size: 0.75rem;
      font-weight: 600;
      letter-spacing: 0.025em;
    }
    .badge-warning { background: var(--accent-warning-bg); color: #d97706; border: 1px solid rgba(245, 158, 11, 0.2); }
    .badge-success { background: var(--accent-success-bg); color: var(--accent-success); border: 1px solid rgba(16, 185, 129, 0.2); }
    
    /* Details Panel */
    .details-panel { 
      padding: 1.5rem; 
      background: #f8fafc; 
      border-top: 1px solid var(--border-subtle); 
      animation: fadeIn 0.3s ease-out;
    }
    
    .info-grid { 
      display: grid; 
      grid-template-columns: 1fr 2fr; 
      gap: 1.5rem; 
      margin-bottom: 1.5rem; 
    }
    
    .meta-card {
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }
    
    .meta-item {
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
    }
    
    .meta-item .label { font-size: 0.75rem; color: var(--text-tertiary); text-transform: uppercase; letter-spacing: 0.05em; font-weight: 600; }
    .meta-item .value { color: var(--text-primary); font-weight: 500; font-size: 0.95rem; }
    
    .data-card { 
      background: white; 
      border: 1px solid var(--border-subtle); 
      border-radius: var(--radius-md); 
      overflow: hidden; 
    }
    
    .card-title {
      padding: 1rem;
      margin: 0;
      font-size: 0.875rem;
      font-weight: 600;
      color: var(--text-primary);
      border-bottom: 1px solid var(--border-subtle);
      background: #fdfdfd;
    }
    
    .data-grid { display: flex; flex-direction: column; }
    .data-row { 
      display: flex; 
      padding: 0.75rem 1rem; 
      border-bottom: 1px solid #f1f5f9; 
      font-size: 0.875rem;
    }
    .data-row:last-child { border-bottom: none; }
    .data-row:nth-child(even) { background: #fafbfc; }
    .data-key { width: 40%; font-weight: 500; color: var(--text-secondary); padding-right: 1rem; }
    .data-val { width: 60%; color: var(--text-primary); word-break: break-word; }
    
    /* Action Section */
    .quote-action { 
      padding: 1.5rem; 
      border-radius: var(--radius-lg); 
      border: 1px solid var(--border-subtle); 
      background: white;
    }
    
    .action-title { margin: 0 0 1.25rem 0; font-size: 1.125rem; font-weight: 600; color: var(--text-primary); }
    .form-group { margin-bottom: 1.25rem; }
    .form-group label { margin-bottom: 0.5rem; color: var(--text-secondary); }
    
    .file-input {
      padding: 0.5rem;
      cursor: pointer;
    }
    
    .action-footer {
      display: flex;
      justify-content: flex-end;
      margin-top: 1.5rem;
    }
    
    /* Empty State */
    .empty-state {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 4rem 2rem;
      color: var(--text-tertiary);
      background: rgba(255,255,255,0.5);
      border-radius: var(--radius-lg);
      border: 1px dashed var(--border-subtle);
    }
    
    .empty-state svg { width: 48px; height: 48px; margin-bottom: 1rem; opacity: 0.5; }

    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    @keyframes slideUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
  `]
})
export class AdminDashboardComponent implements OnInit {
  rfqs: Rfq[] = [];
  expandedRfq: Rfq | null = null;
  quoteInput = '';
  selectedFile: File | null = null;

  constructor(private rfqService: RfqService) { }

  ngOnInit() {
    this.refresh();
  }

  refresh() {
    this.rfqService.getAllRfqs().subscribe(data => this.rfqs = data);
  }

  toggle(rfq: Rfq) {
    if (this.expandedRfq === rfq) {
      this.expandedRfq = null;
    } else {
      this.expandedRfq = rfq;
      this.quoteInput = rfq.quoteDetails || '';
      this.selectedFile = null; // Reset file
    }
  }

  onFileSelected(event: any) {
    this.selectedFile = event.target.files[0];
  }

  parseData(json: string): any {
    try { return JSON.parse(json); } catch (e) { return json; }
  }

  submitQuote(rfq: Rfq) {
    if (!rfq.id) return;

    // Pass the file (even if null/undefined, the service handles it)
    this.rfqService.updateQuote(rfq.id, this.quoteInput, this.selectedFile || undefined).subscribe({
      next: (updated) => {
        alert('Quote sent successfully!');
        rfq.status = 'QUOTED';
        rfq.quoteDetails = this.quoteInput;
        // We'd ideally update the rfq object with the file path from response, but simple update is fine for now
        this.expandedRfq = null;
        this.selectedFile = null;
      },
      error: (err) => alert('Failed to send quote')
    });
  }

  isObject(value: any): boolean {
    return value !== null && typeof value === 'object' && !Array.isArray(value);
  }

  isArray(value: any): boolean {
    return Array.isArray(value);
  }

  getFormattedData(json: string): any {
    if (!json) return {};
    try {
      return JSON.parse(json);
    } catch (e) {
      console.error('Error parsing JSON data for dashboard item:', e);
      return {};
    }
  }

  formatKey(key: string): string {
    // camelCase to Title Case
    const result = key.replace(/([A-Z])/g, " $1");
    return result.charAt(0).toUpperCase() + result.slice(1);
  }
}

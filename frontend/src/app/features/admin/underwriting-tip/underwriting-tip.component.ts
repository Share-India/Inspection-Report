import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { UnderwritingTipService, UnderwritingTip } from '../../../core/services/commercial/underwriting-tip.service';

@Component({
  selector: 'app-admin-underwriting-tip',
  standalone: true,
  imports: [CommonModule, FormsModule, ReactiveFormsModule],
  template: `
    <div class="admin-container">
      <div class="top-bar">
        <div class="header-group">
          <h2>Fine Prints of Underwriting</h2>
          <p class="subtitle">Educate agents and clients with critical insurance technicalities</p>
        </div>
        <button class="btn-primary" (click)="toggleView()">
          <svg *ngIf="!showForm" fill="none" stroke="currentColor" viewBox="0 0 24 24" width="18" height="18"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
          <svg *ngIf="showForm" fill="none" stroke="currentColor" viewBox="0 0 24 24" width="18" height="18"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
          {{ showForm ? 'Back to Library' : 'Add New Tip' }}
        </button>
      </div>

      <!-- CREATE FORM -->
      <div *ngIf="showForm" class="premium-card form-container">
        <h3 class="card-title">Publish Underwriting Tip</h3>
        <form [formGroup]="tipForm" (ngSubmit)="onSubmit()" class="tip-form">
          <div class="form-row">
              <div class="form-group">
                <label>Technical Title</label>
                <input class="premium-input" formControlName="title" type="text" placeholder="e.g. Local Authority Clause">
              </div>
              
              <div class="form-group">
                <label>Coverage Category</label>
                <select class="premium-input" formControlName="category">
                  <option value="" disabled selected>Select Category</option>
                  <option value="Commercial">Commercial</option>
                  <option value="Health">Health</option>
                  <option value="Life">Life</option>
                  <option value="Motor">Motor</option>
                </select>
              </div>
          </div>

          <div class="form-group">
            <label>Detailed Description</label>
            <textarea class="premium-input" formControlName="description" rows="4" placeholder="Explain the technical or legal meaning of this clause/tip..."></textarea>
          </div>

          <div class="form-group">
            <label>Real-World Example</label>
            <textarea class="premium-input" formControlName="example" rows="3" placeholder="Provide a scenario demonstrating how this applies..."></textarea>
          </div>

          <div class="form-group">
            <label>Key Takeaway</label>
            <textarea class="premium-input" formControlName="keyTakeaway" rows="2" placeholder="What is the most important thing to remember?"></textarea>
          </div>

          <div class="form-group file-group">
            <label>Upload Infographic/Cover Image</label>
            <div class="file-drop-zone">
              <input type="file" (change)="onFileSelected($event)" accept="image/*" class="premium-input file-input">
            </div>
          </div>

          <div class="action-footer">
            <button type="submit" [disabled]="!tipForm.valid" class="btn-primary submit-btn">
              Publish to Library
            </button>
          </div>
        </form>
      </div>

      <!-- LIST VIEW -->
      <div *ngIf="!showForm" class="tip-grid">
        <div class="premium-card tip-card" *ngFor="let tip of tips; let i = index" [style.animation-delay]="i * 0.05 + 's'">
          <div class="card-header">
            <span class="category-badge">{{ tip.category }}</span>
            <div class="actions">
              <button class="icon-btn view-btn" (click)="openTip(tip)" title="Read Tip">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path></svg>
              </button>
              <button class="icon-btn delete-btn" (click)="deleteTip(tip.id!)" title="Delete Tip">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
              </button>
            </div>
          </div>
          
          <div class="card-body" (click)="openTip(tip)">
            <h3>{{ tip.title }}</h3>
            <p class="desc-preview">{{ tip.description }}</p>
          </div>
          
          <div class="card-footer" (click)="openTip(tip)">
            <span class="date">{{ tip.createdAt | date:'mediumDate' }}</span>
            <span class="read-more">Read Full Tip &rarr;</span>
          </div>
        </div>
        
        <div *ngIf="tips.length === 0" class="empty-state">
          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path></svg>
          <p>The Underwriting Library is currently empty. Add a new tip to educate your team.</p>
        </div>
      </div>

      <!-- VIEW MODAL -->
      <div class="modal-backdrop" *ngIf="selectedTip" (click)="closeModal()">
        <div class="glass-panel modal-content" (click)="$event.stopPropagation()">
            <button class="close-btn" (click)="closeModal()">
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
            
            <div class="modal-body">
                <div class="modal-hero" *ngIf="selectedTip.imagePath">
                  <img [src]="'http://localhost:8081' + selectedTip.imagePath" class="modal-img">
                </div>
                
                <div class="modal-header">
                  <span class="category-badge large-badge">{{ selectedTip.category }}</span>
                  <h2>{{ selectedTip.title }}</h2>
                </div>
                
                <div class="modal-sections">
                  <div class="section primary-desc">
                      <p>{{ selectedTip.description }}</p>
                  </div>
                  
                  <div class="callout-box example-box" *ngIf="selectedTip.example">
                      <div class="callout-header">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        <h4>Real-World Example</h4>
                      </div>
                      <p>{{ selectedTip.example }}</p>
                  </div>
                  
                  <div class="callout-box takeaway-box" *ngIf="selectedTip.keyTakeaway">
                      <div class="callout-header">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
                        <h4>Key Takeaway</h4>
                      </div>
                      <p>{{ selectedTip.keyTakeaway }}</p>
                  </div>
                </div>
            </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .admin-container { 
      max-width: 1200px; 
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
    
    /* CREATE FORM */
    .form-container {
      padding: 0; 
      overflow: hidden;
      margin-bottom: 2rem;
      max-width: 800px;
      margin: 0 auto 2rem auto;
      animation: slideUp 0.3s ease-out;
    }
    
    .card-title {
      padding: 1.25rem 1.5rem;
      margin: 0;
      background: #fdfdfd;
      border-bottom: 1px solid var(--border-subtle);
      font-size: 1.125rem;
      color: var(--text-primary);
    }
    
    .tip-form {
      padding: 2rem;
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
    }
    
    .form-row { 
      display: grid; 
      grid-template-columns: 1fr 1fr; 
      gap: 1.5rem; 
    }
    
    .form-group {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
      margin-bottom: 0;
    }
    
    .file-drop-zone { position: relative; }
    .file-input { background: #f8fafc; border: 1px dashed var(--border-subtle); padding: 1rem; cursor: pointer; }
    
    .action-footer {
      display: flex;
      justify-content: flex-end;
      padding-top: 1rem;
      border-top: 1px solid var(--border-subtle);
      margin-top: 0.5rem;
    }
    
    .submit-btn { padding: 0.75rem 1.5rem; font-size: 0.95rem; }
    .submit-btn:disabled { opacity: 0.6; cursor: not-allowed; }

    /* LIST VIEW */
    .tip-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
      gap: 1.5rem;
    }

    .tip-card { 
      display: flex; 
      flex-direction: column;
      height: 100%;
      border-color: var(--border-subtle);
      opacity: 0;
      animation: slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards;
      cursor: pointer;
    }
    
    .card-header {
      padding: 1.25rem 1.5rem 0.5rem 1.5rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    
    .category-badge {
      display: inline-block;
      padding: 0.35rem 0.75rem;
      background: var(--brand-primary-light);
      color: var(--brand-primary);
      font-size: 0.75rem;
      font-weight: 600;
      border-radius: var(--radius-pill);
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    
    .category-badge.large-badge {
      font-size: 0.85rem;
      margin-bottom: 1rem;
    }
    
    .actions { display: flex; gap: 0.25rem; }
    
    .icon-btn {
      background: transparent;
      border: none;
      color: var(--text-tertiary);
      cursor: pointer;
      padding: 0.5rem;
      border-radius: var(--radius-sm);
      transition: all var(--transition-fast);
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .icon-btn svg { width: 18px; height: 18px; }
    
    .icon-btn.view-btn:hover { background: var(--brand-primary-light); color: var(--brand-primary); }
    .icon-btn.delete-btn:hover { background: var(--accent-danger-bg); color: var(--accent-danger); }
    
    .card-body { 
      padding: 0.5rem 1.5rem 1rem 1.5rem; 
      flex: 1;
    }
    
    .card-body h3 { 
      margin: 0 0 0.75rem 0; 
      color: var(--text-primary); 
      font-size: 1.25rem;
      line-height: 1.3;
    }
    
    .desc-preview {
      margin: 0;
      color: var(--text-secondary);
      font-size: 0.95rem;
      line-height: 1.5;
      display: -webkit-box;
      -webkit-line-clamp: 3;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
    
    .card-footer {
      padding: 1rem 1.5rem;
      border-top: 1px solid var(--border-subtle);
      display: flex;
      justify-content: space-between;
      align-items: center;
      background: #fafbfc;
      border-bottom-left-radius: var(--radius-lg);
      border-bottom-right-radius: var(--radius-lg);
    }
    
    .date { font-size: 0.8rem; color: var(--text-tertiary); font-weight: 500; }
    .read-more { font-size: 0.875rem; font-weight: 600; color: var(--brand-primary); }
    
    .empty-state {
      grid-column: 1 / -1;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 5rem 2rem;
      color: var(--text-tertiary);
      background: rgba(255,255,255,0.5);
      border-radius: var(--radius-lg);
      border: 1px dashed var(--border-subtle);
      text-align: center;
    }
    
    .empty-state svg { width: 48px; height: 48px; margin-bottom: 1rem; opacity: 0.5; }

    /* Modal Styling */
    .modal-backdrop { 
      position: fixed; 
      top: 0; left: 0; right: 0; bottom: 0; 
      background: rgba(15, 23, 42, 0.4); 
      backdrop-filter: blur(4px);
      -webkit-backdrop-filter: blur(4px);
      display: flex; 
      align-items: center; 
      justify-content: center; 
      z-index: 1000; 
      animation: fadeIn 0.2s ease-out;
      padding: 2rem;
    }
    
    .modal-content { 
      background: white !important; 
      width: 100%; 
      max-width: 750px; 
      max-height: 90vh; 
      border-radius: var(--radius-xl); 
      overflow-y: auto; 
      position: relative; 
      box-shadow: var(--shadow-float); 
      animation: slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1);
    }
    
    .close-btn { 
      position: absolute; 
      top: 1.25rem; 
      right: 1.25rem; 
      background: rgba(255,255,255,0.9);
      border: none;
      width: 32px;
      height: 32px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer; 
      color: var(--text-secondary); 
      z-index: 10;
      box-shadow: var(--shadow-sm);
      transition: all var(--transition-fast);
    }
    
    .close-btn:hover { 
      background: white;
      color: var(--text-primary); 
      transform: scale(1.05);
    }
    
    .close-btn svg { width: 20px; height: 20px; }
    
    .modal-hero {
      width: 100%;
      height: 250px;
      background: #f1f5f9;
    }
    
    .modal-img { 
      width: 100%; 
      height: 100%; 
      object-fit: cover; 
    }
    
    .modal-body { padding: 2.5rem; }
    
    .modal-header { margin-bottom: 2rem; }
    .modal-header h2 { font-size: 2.25rem; margin-bottom: 0; line-height: 1.2; }
    
    .modal-sections { display: flex; flex-direction: column; gap: 2rem; }
    
    .primary-desc p { 
      font-size: 1.125rem; 
      line-height: 1.7; 
      color: var(--text-primary); 
      white-space: pre-wrap; 
    }
    
    .callout-box {
      border-radius: var(--radius-lg);
      padding: 1.5rem;
    }
    
    .callout-header {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      margin-bottom: 0.75rem;
    }
    
    .callout-header svg { width: 20px; height: 20px; }
    .callout-header h4 { margin: 0; font-size: 1.125rem; font-weight: 600; }
    
    .callout-box p {
      margin: 0;
      line-height: 1.6;
      font-size: 1rem;
    }
    
    .example-box { 
      background: var(--accent-success-bg); 
      border: 1px solid rgba(16, 185, 129, 0.2); 
    }
    
    .example-box .callout-header { color: #047857; }
    .example-box p { color: #065f46; }
    
    .takeaway-box { 
      background: var(--accent-warning-bg); 
      border: 1px solid rgba(245, 158, 11, 0.2); 
    }
    
    .takeaway-box .callout-header { color: #b45309; }
    .takeaway-box p { color: #92400e; font-weight: 500;}

    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    @keyframes slideUp { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }
  `]
})
export class AdminUnderwritingTipComponent implements OnInit {
  showForm = false;
  tips: UnderwritingTip[] = [];
  selectedTip: UnderwritingTip | null = null;
  tipForm: FormGroup;
  selectedFile: File | null = null;


  constructor(
    private tipService: UnderwritingTipService,
    private fb: FormBuilder,
    private cdr: ChangeDetectorRef
  ) {
    this.tipForm = this.fb.group({
      title: ['', Validators.required],
      category: ['', Validators.required],
      description: [''],
      example: [''],
      keyTakeaway: ['']
    });
  }

  ngOnInit() {
    this.loadTips();
  }

  toggleView() {
    this.showForm = !this.showForm;
  }

  loadTips() {
    this.tipService.getAllTips().subscribe(data => {
      this.tips = data;
      this.cdr.detectChanges();
    });
  }

  onFileSelected(event: any) {
    this.selectedFile = event.target.files[0];
  }

  onSubmit() {
    if (this.tipForm.valid) {
      const tip: UnderwritingTip = this.tipForm.value;
      this.tipService.createTip(tip, this.selectedFile || undefined).subscribe({
        next: () => {
          this.loadTips();
          this.toggleView();
          this.tipForm.reset();
          this.selectedFile = null;
        },
        error: (err) => alert('Failed to create tip')
      });
    }
  }

  deleteTip(id: string) {
    if (confirm('Are you sure you want to delete this tip?')) {
      this.tipService.deleteTip(id).subscribe(() => this.loadTips());
    }
  }

  openTip(tip: UnderwritingTip) {
    this.selectedTip = tip;
  }

  closeModal() {
    this.selectedTip = null;
  }
}

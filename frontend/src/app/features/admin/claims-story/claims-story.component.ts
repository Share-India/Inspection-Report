import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators, FormArray } from '@angular/forms';
import { ClaimStoryService, ClaimStory } from '../../../core/services/commercial/claim-story.service';

@Component({
  selector: 'app-admin-claim-story',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="admin-container">
      <div class="top-bar">
        <div class="header-group">
          <h2>Footprints of Claims</h2>
          <p class="subtitle">Manage and publish legal claim stories and precedents</p>
        </div>
        <button class="btn-primary" (click)="toggleView()">
            <svg *ngIf="!showForm" fill="none" stroke="currentColor" viewBox="0 0 24 24" width="18" height="18"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
            <svg *ngIf="showForm" fill="none" stroke="currentColor" viewBox="0 0 24 24" width="18" height="18"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
            {{ showForm ? 'Back to List' : 'Add New Story' }}
        </button>
      </div>

      <!-- CREATE FORM -->
      <div *ngIf="showForm" class="premium-card form-container">
        <h3 class="card-title">Publish New Case Story</h3>
        <form [formGroup]="storyForm" (ngSubmit)="onSubmit()" class="story-form">
            <div class="form-row">
                <div class="form-group">
                    <label>Story Title</label>
                    <input type="text" formControlName="title" placeholder="e.g. NCDRC Rejects Claim..." class="premium-input">
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

            <div class="form-row">
                <div class="form-group">
                    <label>Case Name (Parties)</label>
                    <input type="text" formControlName="caseName" placeholder="e.g. HDFC vs Widow" class="premium-input">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Court/Tribunal</label>
                    <input type="text" formControlName="court" placeholder="e.g. NCDRC" class="premium-input">
                </div>
                <div class="form-group">
                    <label>Core Issue Summary</label>
                    <input type="text" formControlName="issue" placeholder="Brief issue description..." class="premium-input">
                </div>
            </div>

            <div class="form-group">
                <label>The Full Story</label>
                <textarea formControlName="story" rows="4" class="premium-input" placeholder="Detail the events and progression of the case..."></textarea>
            </div>

            <div class="form-group">
                <label>The Final Verdict</label>
                <textarea formControlName="verdict" rows="3" class="premium-input" placeholder="Detail the court's ruling and justification..."></textarea>
            </div>

            <div class="form-group">
                <label>Critical Legal Principles <span class="hint">(One principle per line)</span></label>
                <textarea formControlName="principlesRaw" rows="3" class="premium-input" placeholder="e.g. Principle of Utmost Good Faith\nMaterial Non-Disclosure..."></textarea>
            </div>

            <div class="form-group">
                <label>The Bottom Line (Key Takeaway)</label>
                <input type="text" formControlName="bottomLine" class="premium-input" placeholder="What is the one major lesson to learn?">
            </div>

            <div class="form-group file-group">
                <label>Upload Infographic/Cover Image</label>
                <div class="file-drop-zone">
                  <input type="file" (change)="onFileSelected($event)" class="premium-input file-input">
                </div>
            </div>

            <div class="action-footer">
                <button type="submit" class="btn-primary submit-btn" [disabled]="storyForm.invalid || submitting">
                    {{ submitting ? 'Saving...' : 'Publish Story to Feed' }}
                </button>
            </div>
        </form>
      </div>

      <!-- LIST VIEW -->
      <div *ngIf="!showForm" class="story-grid">
        <div class="premium-card story-item" *ngFor="let story of stories; let i = index" [style.animation-delay]="i * 0.05 + 's'">
            <div class="story-img" *ngIf="story.imagePath">
                <img [src]="'http://localhost:8081' + story.imagePath" alt="Story Graphic">
            </div>
            <div class="story-content">
                <div class="story-meta">
                  <span class="category-badge" *ngIf="story.category">{{ story.category }}</span>
                  <span class="court-badge" *ngIf="story.court">{{ story.court }}</span>
                </div>
                <h3>{{ story.title }}</h3>
                <p class="case-name">{{ story.caseName }}</p>
                <p class="verdict-preview">{{ story.verdict }}</p>
                
                <div class="card-actions">
                  <button class="btn-secondary view-btn" (click)="openStory(story)">Read Full Story</button>
                  <button class="icon-btn delete-btn" (click)="deleteStory(story.id!)" title="Delete Story">
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                  </button>
                </div>
            </div>
        </div>
        
        <div *ngIf="stories.length === 0" class="empty-state">
          <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z"></path></svg>
          <p>No footprint stories found. Create one to populate the feed.</p>
        </div>
      </div>

      <!-- VIEW MODAL -->
      <div class="modal-backdrop" *ngIf="selectedStory" (click)="closeModal()">
        <div class="glass-panel modal-content" (click)="$event.stopPropagation()">
            <button class="close-btn" (click)="closeModal()">
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
            
            <div class="modal-body">
                <div class="modal-hero" *ngIf="selectedStory.imagePath">
                  <img [src]="'http://localhost:8081' + selectedStory.imagePath" class="modal-img">
                </div>
                
                <div class="modal-header">
                  <h2>{{ selectedStory.title }}</h2>
                  <div class="meta-row">
                      <span class="meta-pill" *ngIf="selectedStory.category"><span class="label">Category:</span> {{ selectedStory.category }}</span>
                      <span class="meta-pill"><span class="label">Case:</span> {{ selectedStory.caseName }}</span>
                      <span class="meta-pill" *ngIf="selectedStory.court"><span class="label">Court:</span> {{ selectedStory.court }}</span>
                  </div>
                </div>
                
                <div class="modal-sections">
                  <div class="section">
                      <h4><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg> The Core Issue</h4>
                      <p>{{ selectedStory.issue }}</p>
                  </div>

                  <div class="section">
                      <h4><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg> The Story</h4>
                      <p>{{ selectedStory.story }}</p>
                  </div>

                  <div class="section">
                      <h4><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg> The Verdict</h4>
                      <p>{{ selectedStory.verdict }}</p>
                  </div>
                  
                  <div class="section list-section" *ngIf="selectedStory.principles && selectedStory.principles.length > 0">
                      <h4><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 11l3 3L22 4"></path><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path></svg> Critical Principles</h4>
                      <ul>
                          <li *ngFor="let p of selectedStory.principles">{{ p }}</li>
                      </ul>
                  </div>

                  <div class="section highlight-box">
                      <h4>The Bottom Line</h4>
                      <p>{{ selectedStory.bottomLine }}</p>
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
    
    .story-form {
      padding: 2rem;
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
    
    .hint {
      font-weight: 400;
      color: var(--text-tertiary);
      font-size: 0.75rem;
      margin-left: 0.5rem;
    }
    
    .file-drop-zone {
      position: relative;
    }
    
    .file-input {
      background: #f8fafc;
      border: 1px dashed var(--border-subtle);
      padding: 1rem;
      cursor: pointer;
    }
    
    .action-footer {
      display: flex;
      justify-content: flex-end;
      padding-top: 1rem;
      border-top: 1px solid var(--border-subtle);
      margin-top: 0.5rem;
    }
    
    .submit-btn {
      padding: 0.75rem 1.5rem;
      font-size: 0.95rem;
    }

    .submit-btn:disabled { 
      opacity: 0.6;
      cursor: not-allowed;
    }

    /* LIST VIEW */
    .story-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
      gap: 1.5rem;
    }

    .story-item { 
      display: flex; 
      flex-direction: column;
      height: 100%;
      border-color: var(--border-subtle);
      opacity: 0;
      animation: slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards;
    }
    
    .story-img { 
      width: 100%; 
      height: 200px;
      background: #f1f5f9; 
      overflow: hidden; 
      border-bottom: 1px solid var(--border-subtle);
    }
    
    .story-img img { 
      width: 100%; 
      height: 100%; 
      object-fit: cover; 
      transition: transform var(--transition-slow);
    }
    
    .story-item:hover .story-img img {
      transform: scale(1.05);
    }
    
    .story-content { 
      padding: 1.5rem; 
      display: flex;
      flex-direction: column;
      flex: 1;
    }
    
    .story-meta {
      margin-bottom: 0.75rem;
    }
    
    .category-badge {
      display: inline-block;
      padding: 0.25rem 0.5rem;
      background: var(--brand-primary-light);
      color: var(--brand-primary);
      font-size: 0.7rem;
      font-weight: 600;
      border-radius: var(--radius-sm);
      text-transform: uppercase;
      letter-spacing: 0.05em;
      margin-right: 0.5rem;
    }
    
    .court-badge {
      display: inline-block;
      padding: 0.25rem 0.5rem;
      background: #f1f5f9;
      color: #334155;
      font-size: 0.7rem;
      font-weight: 600;
      border-radius: var(--radius-sm);
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    
    .story-content h3 { 
      margin: 0 0 0.5rem 0; 
      color: var(--text-primary); 
      font-size: 1.25rem;
      line-height: 1.4;
    }
    
    .case-name {
      margin: 0 0 1rem 0;
      color: var(--text-secondary);
      font-weight: 500;
      font-size: 0.875rem;
    }
    
    .verdict-preview {
      margin: 0 0 1.5rem 0;
      color: var(--text-secondary);
      font-size: 0.95rem;
      line-height: 1.5;
      display: -webkit-box;
      -webkit-line-clamp: 3;
      -webkit-box-orient: vertical;
      overflow: hidden;
      flex: 1;
    }
    
    .card-actions {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-top: 1.25rem;
      border-top: 1px solid var(--border-subtle);
    }
    
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
    
    .icon-btn.delete-btn:hover {
      background: var(--accent-danger-bg);
      color: var(--accent-danger);
    }
    
    /* Empty State */
    .empty-state {
      grid-column: 1 / -1;
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
      background: white !important; /* Override glass if needed, or keep white */
      width: 100%; 
      max-width: 800px; 
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
    
    .modal-body {
      padding: 2.5rem;
    }
    
    .modal-header {
      margin-bottom: 2.5rem;
    }
    
    .modal-header h2 {
      font-size: 2rem;
      margin-bottom: 1rem;
      line-height: 1.3;
    }
    
    .meta-row { 
      display: flex;
      gap: 1rem;
      flex-wrap: wrap;
    }
    
    .meta-pill {
      background: #f1f5f9;
      padding: 0.5rem 1rem;
      border-radius: var(--radius-md);
      font-size: 0.875rem;
      color: var(--text-primary);
    }
    
    .meta-pill .label {
      color: var(--text-secondary);
      font-weight: 500;
      margin-right: 0.25rem;
    }
    
    .modal-sections {
      display: flex;
      flex-direction: column;
      gap: 2rem;
    }
    
    .section h4 { 
      color: var(--text-primary); 
      font-size: 1.125rem;
      display: flex;
      align-items: center;
      gap: 0.5rem;
      margin-bottom: 1rem; 
      border-bottom: 1px solid var(--border-subtle);
      padding-bottom: 0.75rem;
    }
    
    .section h4 svg {
      width: 20px;
      height: 20px;
      color: var(--brand-primary);
    }
    
    .section p { 
      line-height: 1.7; 
      color: var(--text-secondary); 
      white-space: pre-wrap; 
      font-size: 1rem;
    }
    
    .list-section ul {
      padding-left: 1.5rem;
      color: var(--text-secondary);
      line-height: 1.7;
    }
    
    .list-section li {
      margin-bottom: 0.5rem;
    }
    
    .highlight-box { 
      background: var(--accent-warning-bg); 
      padding: 1.5rem; 
      border-radius: var(--radius-lg); 
      border: 1px solid rgba(245, 158, 11, 0.2);
    }
    
    .highlight-box h4 { 
      border-bottom: none;
      padding-bottom: 0;
      margin-bottom: 0.5rem;
      color: #b45309; 
    }
    
    .highlight-box p {
      color: #92400e;
      font-weight: 500;
    }

    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    @keyframes slideUp { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }
  `]
})
export class AdminClaimStoryComponent implements OnInit {
  stories: ClaimStory[] = [];
  selectedStory: ClaimStory | null = null;
  showForm = false;
  storyForm: FormGroup;
  selectedFile: File | null = null;
  submitting = false;

  constructor(
    private fb: FormBuilder,
    private storyService: ClaimStoryService,
    private cdr: ChangeDetectorRef
  ) {
    this.storyForm = this.fb.group({
      title: ['', Validators.required],
      category: ['', Validators.required],
      caseName: ['', Validators.required],
      court: [''],
      issue: [''],
      story: ['', Validators.required],
      verdict: [''],
      principlesRaw: [''], // We will split this by newline
      bottomLine: ['']
    });
  }

  ngOnInit() {
    this.loadStories();
  }

  loadStories() {
    this.storyService.getAllStories().subscribe({
      next: (data) => {
        this.stories = data;
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error('Error loading stories:', err);
        this.cdr.detectChanges();
      }
    });
  }

  toggleView() {
    this.showForm = !this.showForm;
  }

  onFileSelected(event: any) {
    this.selectedFile = event.target.files[0];
  }

  onSubmit() {
    if (this.storyForm.valid) {
      this.submitting = true;
      const formVal = this.storyForm.value;

      const story: ClaimStory = {
        title: formVal.title,
        category: formVal.category,
        caseName: formVal.caseName,
        court: formVal.court,
        issue: formVal.issue,
        story: formVal.story,
        verdict: formVal.verdict,
        principles: formVal.principlesRaw ? formVal.principlesRaw.split('\n').filter((p: string) => p.trim() !== '') : [],
        bottomLine: formVal.bottomLine
      };

      this.storyService.createStory(story, this.selectedFile || undefined).subscribe({
        next: (res) => {
          alert('Story Published Successfully!');
          this.submitting = false;
          this.showForm = false;
          this.storyForm.reset();
          this.selectedFile = null;
          this.loadStories();
        },
        error: (err) => {
          console.error(err);
          alert('Failed to publish story');
          this.submitting = false;
        }
      });
    }
  }

  deleteStory(id: string) {
    if (confirm('Are you sure you want to delete this story?')) {
      this.storyService.deleteStory(id).subscribe(() => this.loadStories());
    }
  }

  openStory(story: ClaimStory) {
    this.selectedStory = story;
  }

  closeModal() {
    this.selectedStory = null;
  }
}
